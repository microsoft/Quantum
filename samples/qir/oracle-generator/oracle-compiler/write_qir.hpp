// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.
#pragma once

#include <algorithm>
#include <iostream>
#include <vector>

#include <fmt/format.h>

#include <mockturtle/networks/abstract_xag.hpp>
#include <mockturtle/properties/mccost.hpp>
#include <mockturtle/utils/node_map.hpp>

#include <llvm/IR/Function.h>
#include <llvm/IR/IRBuilder.h>
#include <llvm/IR/Module.h>
#include <llvm/Support/raw_os_ostream.h>
#include <llvm/Support/raw_ostream.h>

using namespace mockturtle;

namespace detail
{

std::vector<abstract_xag_network::node> get_linear_fanin(
    abstract_xag_network const& axag,
    abstract_xag_network::node const& node)
{
    if (axag.is_nary_xor(node))
    {
        std::vector<abstract_xag_network::node> fanin(axag.fanin_size(node));
        axag.foreach_fanin(node, [&](auto const& f, auto i) { fanin[i] = axag.get_node(f); });
        return fanin;
    }
    else
    {
        return {node};
    }
}
} // namespace detail

/*! \brief Helper class for QIR types and functions. */
class qir_context
{
  public:
    qir_context(llvm::Module& module)
    {
        auto& ctx = module.getContext();

        const auto get_type = [&](std::string const& name, llvm::StructType** dest, llvm::PointerType** dest_ptr)
        {
            if (*dest = module.getTypeByName(name); !dest)
            {
                fmt::print("[e] type {} not defined in source QIR.\n", name);
                std::abort();
            }
            *dest_ptr = llvm::PointerType::getUnqual(*dest);
        };

        get_type("Array", &arrayTy, &arrayPtrTy);
        get_type("Qubit", &qubitTy, &qubitPtrTy);

        x = module.getOrInsertFunction("__quantum__qis__x__body", llvm::Type::getVoidTy(ctx), qubitPtrTy);
        cnot = module.getOrInsertFunction(
            "Microsoft__Quantum__Intrinsic__CNOT__body", llvm::Type::getVoidTy(ctx), qubitPtrTy, qubitPtrTy);
        ccnot = module.getOrInsertFunction(
            "Microsoft__Quantum__Intrinsic__CCNOT__body", llvm::Type::getVoidTy(ctx), qubitPtrTy, qubitPtrTy,
            qubitPtrTy);
        allocate_array =
            module.getOrInsertFunction("__quantum__rt__qubit_allocate_array", arrayPtrTy, llvm::Type::getInt64Ty(ctx));
        array_update_alias_count = module.getOrInsertFunction(
            "__quantum__rt__array_update_alias_count", llvm::Type::getVoidTy(ctx), arrayPtrTy,
            llvm::Type::getInt32Ty(ctx));
        release_array =
            module.getOrInsertFunction("__quantum__rt__qubit_release_array", llvm::Type::getVoidTy(ctx), arrayPtrTy);
        get_element = module.getOrInsertFunction(
            "__quantum__rt__array_get_element_ptr_1d", llvm::Type::getInt8PtrTy(ctx), arrayPtrTy,
            llvm::Type::getInt64Ty(ctx));
    }

    llvm::StructType* getArrayTy() const
    {
        return arrayTy;
    }
    llvm::PointerType* getArrayPtrTy() const
    {
        return arrayPtrTy;
    }
    llvm::StructType* getQubitTy() const
    {
        return qubitTy;
    }
    llvm::PointerType* getQubitPtrTy() const
    {
        return qubitPtrTy;
    }

    auto X() const
    {
        return x;
    }
    auto CNOT() const
    {
        return cnot;
    }
    auto CCNOT() const
    {
        return ccnot;
    }
    auto AllocateArray() const
    {
        return allocate_array;
    }
    auto ArrayUpdateAliasCount() const
    {
        return array_update_alias_count;
    }
    auto ReleaseArray() const
    {
        return release_array;
    }
    auto GetElement() const
    {
        return get_element;
    }

  private:
    llvm::StructType *arrayTy{}, *qubitTy{};
    llvm::PointerType *arrayPtrTy{}, *qubitPtrTy{};
    llvm::FunctionCallee x, cnot, ccnot, allocate_array, array_update_alias_count, release_array, get_element;
};

/* restricting to abstract XAG for now */
void write_qir(
    abstract_xag_network const& axag,
    llvm::Function const& source_function,
    qir_context const& qir,
    llvm::Module& module,
    llvm::Function& function)
{
    using namespace llvm;

    auto& ctx = module.getContext();
    function.deleteBody();

    auto* entry = BasicBlock::Create(ctx, "entry", &function);
    IRBuilder builder(entry);

    // Initialize node mapping
    node_map<Value*, abstract_xag_network> node_to_value(axag);
    node_to_value[axag.get_constant(false)] = ConstantInt::getFalse(ctx);

    // get input arguments
    std::vector<llvm::Value*> deconstructed_inputs;
    if (source_function.arg_size() == 1u)
    {
        deconstructed_inputs.push_back(function.getArg(0u));
    }
    else
    {
        std::vector<abstract_xag_network::node> pis(axag.num_pis());
        axag.foreach_pi([&](auto const& n, auto i) { pis[i] = n; });
        auto pisIt = pis.begin();

        for (auto i = 0u; i < source_function.arg_size(); ++i)
        {
            auto const* arg = source_function.getArg(i);
            auto* gep = builder.CreateStructGEP(function.getArg(0u), i);
            auto* load = builder.CreateLoad(gep, arg->getName());
            if (arg->getType()->isIntegerTy(1u))
            {
                node_to_value[*pisIt++] = load;
            }
            else if (arg->getType()->isIntegerTy(64u))
            {
                for (auto j = 0u; j < 64u; ++j)
                {
                    auto* array_get = builder.CreateCall(
                        qir.GetElement(), {load, llvm::ConstantInt::get(llvm::Type::getInt64Ty(ctx), j)});
                    auto* array_bitcast =
                        builder.CreateBitCast(array_get, llvm::PointerType::getUnqual(qir.getQubitPtrTy()));
                    node_to_value[*pisIt++] = builder.CreateLoad(array_bitcast);
                }
            }
        }
    }

    // get output arguments
    auto const* retTy = source_function.getReturnType();
    std::vector<llvm::Value*> outputs;
    if (retTy->isIntegerTy(1u)) // Bool
    {
        outputs.push_back(function.getArg(1));
    }
    else if (retTy->isIntegerTy(64)) // Int
    {
        for (auto j = 0u; j < 64u; ++j)
        {
            auto* array_get = builder.CreateCall(
                qir.GetElement(), {function.getArg(1), llvm::ConstantInt::get(llvm::Type::getInt64Ty(ctx), j)});
            auto* array_bitcast = builder.CreateBitCast(array_get, llvm::PointerType::getUnqual(qir.getQubitPtrTy()));
            outputs.push_back(builder.CreateLoad(array_bitcast));
        }
    }
    else // Qubit* tuple
    {
        // access elements from output struct
        for (auto i = 0u; i < axag.num_pos(); ++i)
        {
            auto* gep = builder.CreateStructGEP(function.getArg(1u), i);
            outputs.push_back(builder.CreateLoad(gep));
        }
    }

    // allocate helper qubits (one for each AND gate)
    llvm::Value* temporaries = nullptr;
    const auto num_ands = *multiplicative_complexity(axag);
    if (num_ands > 0u)
    {
        temporaries =
            builder.CreateCall(qir.AllocateArray(), {ConstantInt::get(Type::getInt64Ty(ctx), num_ands)}, "qs");
        builder.CreateCall(
            qir.ArrayUpdateAliasCount(), {temporaries, llvm::ConstantInt::get(llvm::Type::getInt32Ty(ctx), 1)});
    }

    // translate single AND gate with linear fanin into quantum operations (used for compute and uncompute)
    const auto translate_and_gate = [&](abstract_xag_network::node n, uint32_t index, bool compute)
    {
        std::array<std::vector<abstract_xag_network::node>, 2> ltfis, diff;
        axag.foreach_fanin(
            n, [&](auto const& f, auto j) { ltfis[j] = ::detail::get_linear_fanin(axag, axag.get_node(f)); });

        std::set_difference(
            ltfis[0].begin(), ltfis[0].end(), ltfis[1].begin(), ltfis[1].end(), std::back_inserter(diff[0]));
        std::set_difference(
            ltfis[1].begin(), ltfis[1].end(), ltfis[0].begin(), ltfis[0].end(), std::back_inserter(diff[1]));

        // first round of XORs to compute linear functions
        const auto prepare_linear = [&]()
        {
            for (auto c = 0u; c < 2u; ++c)
            {
                for (auto& q : ltfis[c])
                {
                    if (q == diff[c].front()) continue;

                    builder.CreateCall(qir.CNOT(), {node_to_value[q], node_to_value[diff[c].front()]});
                }
            }
        };

        prepare_linear();
        auto* get_elem =
            builder.CreateCall(qir.GetElement(), {temporaries, ConstantInt::get(Type::getInt64Ty(ctx), index)});
        auto* bitcast = builder.CreateBitCast(get_elem, PointerType::getUnqual(qir.getQubitPtrTy()));
        auto* temporary = builder.CreateLoad(bitcast);

        builder.CreateCall(qir.CCNOT(), {node_to_value[diff[0].front()], node_to_value[diff[1].front()], temporary});
        if (compute)
        {
            node_to_value[n] = temporary;
        }
        prepare_linear();
    };

    // assuming topological order
    std::vector<uint32_t> and_nodes;
    auto and_index = 0u;
    axag.foreach_node(
        [&](auto const& n)
        {
            if (!axag.is_and(n)) return;

            translate_and_gate(n, and_index++, true);
            and_nodes.push_back(n);
        });

    // copy out to outputs
    axag.foreach_po(
        [&](auto const& f, auto i)
        {
            for (auto q : ::detail::get_linear_fanin(axag, axag.get_node(f)))
            {
                builder.CreateCall(qir.CNOT(), {node_to_value[q], outputs[i]});
            }
            if (axag.is_complemented(f))
            {
                builder.CreateCall(qir.X(), {outputs[i]});
            }
        });

    for (int i = num_ands - 1; i >= 0; --i)
    {
        translate_and_gate(and_nodes[i], i, false);
    }

    if (temporaries)
    {
        builder.CreateCall(qir.ReleaseArray(), {temporaries});
        builder.CreateCall(
            qir.ArrayUpdateAliasCount(), {temporaries, llvm::ConstantInt::get(llvm::Type::getInt32Ty(ctx), -1)});
    }

    builder.CreateRetVoid();
}
