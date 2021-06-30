// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.
#include <fstream>
#include <iostream>
#include <unordered_map>

// Including libfmt, making it easier to generate formatted strings in C++.
#include <fmt/format.h>

// mockturtle is a library to manipulate logic network representations of
// Boolean functions.
#include <mockturtle/algorithms/cleanup.hpp>
#include <mockturtle/algorithms/cut_rewriting.hpp>
#include <mockturtle/algorithms/gates_to_nodes.hpp>
#include <mockturtle/algorithms/node_resynthesis.hpp>
#include <mockturtle/algorithms/node_resynthesis/shannon.hpp>
#include <mockturtle/algorithms/node_resynthesis/xag_minmc2.hpp>
#include <mockturtle/networks/abstract_xag.hpp>
#include <mockturtle/networks/klut.hpp>
#include <mockturtle/networks/xag.hpp>
#include <mockturtle/utils/cost_functions.hpp>

// We modify LLVM through the object model provided by the LLVM C++ API.
#include <llvm/ADT/StringExtras.h>
#include <llvm/IR/LLVMContext.h>
#include <llvm/IR/IRBuilder.h>
#include <llvm/IR/Module.h>
#include <llvm/IRReader/IRReader.h>
#include <llvm/Support/raw_os_ostream.h>

// These helper functions read LLVM functions (corresponding to Q# functions)
// into a logic network and write the logic network into LLVM functions
// (corresponding to Q# operations).
#include "read_qir.hpp"
#include "write_qir.hpp"

using namespace mockturtle;

/*! \brief Finds which functions should be generated into which operations. */
std::unordered_map<llvm::Function*, llvm::Function*> find_function_pairs(llvm::Module& module)
{
    // For simplicity, we won't check that the operation's signature matches the
    // function declaration, but in a real application you may want to do so.

    // store all functions generated from Q#
    std::unordered_map<std::string, llvm::Function*> qs_functions;
    std::unordered_map<llvm::Function*, llvm::Function*> function_to_operation;

    // This first loop stores all potential candidate functions (LLVM functions,
    // corresponding to Q# functions written by the user) into the map
    // `qs_functions`, addressed by the functions' names.
    for (auto& f : module.functions())
    {
        auto name = f.getName();
        if (!name.endswith("__body") || name.startswith("__")) continue;
        auto qualifiedName = name.substr(0u, name.size() - 6u);

        qs_functions.insert({qualifiedName.str(), &f});
    }

    // Q# operations are also LLVM functions.  This second loop checks whether a
    // function name has a corresponding classical Q# function implementation,
    // in our sample the operation `Microsoft.Quantum.OracleGenerator.Majority3`
    // corresponds to the fuction
    // `Microsoft.Quantum.OracleGenerator.Classical.Majority3`.  If we find such
    // a match, we save this in the map `function_to_operation`, using the
    // function as the key, and the operation as the value.
    for (auto& f : module.functions())
    {
        auto name = f.getName();
        if (!name.endswith("__body") || name.startswith("__")) continue;

        auto qualifiedName = name.substr(0u, name.size() - 6u);
        llvm::SmallVector<llvm::StringRef, 0> parts;
        qualifiedName.split(parts, "__");
        parts.insert(parts.end() - 1u, "Classical");

        if (auto it = qs_functions.find(llvm::join(parts, "__")); it != qs_functions.end())
        {
            function_to_operation.insert({it->second, &f});
        }
    }

    // return all matches that were found.
    return function_to_operation;
}

/*! \brief Optimize logic network representation of LLVM function
 *
 * The LLVM function that corresponds to the classical Boolean function
 * specified as Q# function, is represented internally as a logic network, more
 * precisely an XAG (XOR-AND graph).  This is a logic network containing only
 * 2-input AND gates and XOR gates, possibly inverters.  The logic network
 * representation is optimized before we use it to generate an LLVM function
 * that represents the Q# operation.  This enables the user to write the Q#
 * function in different ways, yet still obtaining a high quality implementation
 * for the corresponding function.
 *
 * The output is a so-called abstract XAG, which normalizes the representation
 * of an XAG (e.g., by propagating inverters to the output, and merging binary
 * XOR gates into multi-input XOR gates).  This makes it easier to generate the
 * LLVM function from it.
 */
abstract_xag_network optimize(xag_network& xag)
{
    future::xag_minmc_resynthesis<xag_network> resyn;

    // The multiplicative complexity of the XAG is the number of AND gates in it.
    // We aim to minimize the number of AND gates.
    auto mc = *multiplicative_complexity(xag);
    fmt::print("[i] initial XAG from LLVM: {} AND gates, {} XOR gates\n", mc, xag.num_gates() - mc);

    // If the number of input variables is small (here 8 variables), we collapse
    // the whole logic network into a truth table and resynthesize an optimized
    // logic network from scratch.  Therefore, all Q# functions with at most 8
    // variables will always lead to the same generated oracle implementation,
    // independent of how it has bene implemented.
    if (xag.num_pis() <= 8)
    {
        // A k-LUT network is a logic network in which each gate is a
        // lookup-table (truth table) with at most k inputs, here k is 8, and
        // the logic network will have a single gate for each function output.
        auto klut = single_node_network<klut_network>(xag);

        // There exist a database that maps 5-input Boolean functions into their
        // optimum XAGs in mockturtle.  If the function has more than 5-inputs
        // we decompose it into smaller subfunctions using the Shannon
        // decomposition.
        xag_network opt;
        if (xag.num_pis() > 5)
        {
            shannon_resynthesis<xag_network, decltype(resyn)> shannon_resyn(5u, &resyn);
            node_resynthesis(opt, klut, shannon_resyn);
        }
        else
        {
            node_resynthesis(opt, klut, resyn);
        }
        xag = opt;
    }

    // This is generic optimization pass based on cut rewriting.  It enumerates
    // for each gate in the logic network up to 12 subnetworks with at most 5
    // inputs.  These are replaced with optimum logic network representations.
    cut_rewriting_params ps;
    ps.cut_enumeration_ps.cut_size = 5u;
    ps.cut_enumeration_ps.cut_limit = 12u;
    const auto xag_opt =
        cut_rewriting<xag_network, decltype(resyn), mc_cost<xag_network>>(cleanup_dangling(xag), resyn, ps);
    mc = *multiplicative_complexity(xag_opt);
    fmt::print("[i] optimized XAG:         {} AND gates, {} XOR gates\n", mc, xag_opt.num_gates() - mc);

    // This transforms the XAG into an abstract XAG, applying further
    // normalization steps, such as propagating inverters to the output and
    // merging binary XOR gates into multi-input XOR gates.  This step does not
    // increase the number of AND gates in the logic network.
    return cleanup_dangling<xag_network, abstract_xag_network>(xag_opt);
}

int main(int argc, char** argv)
{
    // Print usage information and quit, when unexpected number of arguments are
    // passed.
    if (argc != 3u)
    {
        fmt::print("usage: {} input output\n", argv[0]);
        return 1;
    }

    // Parse QIR file (LLVM file) and store it into an LLVM::Module instance.
    llvm::LLVMContext context;
    llvm::SMDiagnostic err;
    auto module = parseIRFile(argv[1], err, context);
    if (!module)
    {
        fmt::print("[e] error reading module: {}\n", err.getMessage().str());
        return 2;
    }

    // Match Q# functions to empty Q# operations by name.
    const auto pairs = find_function_pairs(*module);
    qir_context qir(*module);

    // For each match, read LLVM function into logic network, optimize it, and
    // write it back as LLVM function representing the implementation of the Q#
    // operation.
    for (auto [func, op] : pairs)
    {
        fmt::print("[i] generate operation {} from function {}\n", op->getName().str(), func->getName().str());

        auto xag = read_qir<xag_network>(*module, *func);
        const auto opt = optimize(xag);
        write_qir(opt, *func, qir, *module, *op);
    }

    // Write the modified module into the output file.
    std::ofstream out(argv[2], std::ofstream::out);
    llvm::raw_os_ostream os(out);
    os << *module;
    out.close();

    return 0;
}
