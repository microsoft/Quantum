// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.
#include <fstream>
#include <iostream>
#include <unordered_map>

#include <fmt/format.h>
#include <kitty/dynamic_truth_table.hpp>
#include <kitty/print.hpp>

#include <mockturtle/algorithms/cleanup.hpp>
#include <mockturtle/algorithms/cut_rewriting.hpp>
#include <mockturtle/algorithms/gates_to_nodes.hpp>
#include <mockturtle/algorithms/node_resynthesis.hpp>
#include <mockturtle/algorithms/node_resynthesis/shannon.hpp>
#include <mockturtle/algorithms/node_resynthesis/xag_minmc2.hpp>
#include <mockturtle/algorithms/simulation.hpp>
#include <mockturtle/io/write_verilog.hpp>
#include <mockturtle/networks/abstract_xag.hpp>
#include <mockturtle/networks/klut.hpp>
#include <mockturtle/networks/xag.hpp>
#include <mockturtle/utils/cost_functions.hpp>

#include <llvm/ADT/StringExtras.h>
#include <llvm/IR/LLVMContext.h>
#include <llvm/IR/Module.h>
#include <llvm/IRReader/IRReader.h>
#include <llvm/Support/raw_os_ostream.h>

#include <llvm/IR/IRBuilder.h>

#include "read_qir.hpp"
#include "write_qir.hpp"

using namespace mockturtle;

/*! \brief Finds which functions should be synthesized into which operations. */
std::unordered_map<llvm::Function*, llvm::Function*> find_function_pairs(llvm::Module& module)
{
    // TODO check that operation's signature matches function's signature

    // store all functions generated from Q#
    std::unordered_map<std::string, llvm::Function*> qs_functions;
    std::unordered_map<llvm::Function*, llvm::Function*> function_to_operation;

    for (auto& f : module.functions())
    {
        auto name = f.getName();
        if (!name.endswith("__body") || name.startswith("__")) continue;
        auto qualifiedName = name.substr(0u, name.size() - 6u);

        qs_functions.insert({qualifiedName.str(), &f});
    }

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

    return function_to_operation;
}

abstract_xag_network optimize(xag_network& xag)
{
    future::xag_minmc_resynthesis<xag_network> resyn;

    auto mc = *multiplicative_complexity(xag);
    fmt::print("[i] initial XAG from LLVM: {} AND gates, {} XOR gates\n", mc, xag.num_gates() - mc);

    /* collapse and resynthesize if number of inputs is small */
    if (xag.num_pis() <= 8)
    {
        auto klut = single_node_network<klut_network>(xag);
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

    /* optimize XAG */
    cut_rewriting_params ps;
    ps.cut_enumeration_ps.cut_size = 5u;
    ps.cut_enumeration_ps.cut_limit = 12u;
    const auto xag_opt =
        cut_rewriting<xag_network, decltype(resyn), mc_cost<xag_network>>(cleanup_dangling(xag), resyn, ps);
    mc = *multiplicative_complexity(xag_opt);
    fmt::print("[i] optimized XAG:         {} AND gates, {} XOR gates\n", mc, xag_opt.num_gates() - mc);

    return cleanup_dangling<xag_network, abstract_xag_network>(xag_opt);
}

int main(int argc, char** argv)
{
    if (argc != 3u)
    {
        fmt::print("usage: {} input output\n", argv[0]);
        return 1;
    }

    llvm::LLVMContext context;
    llvm::SMDiagnostic err;

    auto module = parseIRFile(argv[1], err, context);
    if (!module)
    {
        fmt::print("[e] error reading module: {}\n", err.getMessage().str());
        return 2;
    }

    const auto pairs = find_function_pairs(*module);
    qir_context qir(*module);

    for (auto [func, op] : pairs)
    {
        fmt::print("[i] generate operation {} from function {}\n", op->getName().str(), func->getName().str());

        auto xag = read_qir<xag_network>(*module, *func);
        const auto opt = optimize(xag);
        write_qir(opt, *func, qir, *module, *op);
    }

    std::ofstream out(argv[2], std::ofstream::out);
    llvm::raw_os_ostream os(out);
    os << *module;
    out.close();

    return 0;
}
