// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.
#pragma once

#include <iostream>
#include <unordered_map>
#include <unordered_set>

#include <fmt/format.h>

#include <mockturtle/algorithms/cleanup.hpp>
#include <mockturtle/generators/modular_arithmetic.hpp>
#include <mockturtle/traits.hpp>

#include <llvm/IR/Constants.h>
#include <llvm/IR/InstrTypes.h>
#include <llvm/IR/Instructions.h>
#include <llvm/IR/LLVMContext.h>
#include <llvm/IR/LegacyPassManager.h>
#include <llvm/IR/Module.h>
#include <llvm/IR/Operator.h>
#include <llvm/Pass.h>
#include <llvm/Support/SourceMgr.h>
#include <llvm/Support/raw_os_ostream.h>
#include <llvm/Support/raw_ostream.h>
#include <llvm/Transforms/Scalar.h>
#include <llvm/Transforms/Utils.h>

using namespace mockturtle;

namespace detail
{
    // Reading LLVM functions into a logic network is generically implemented
    // for arbitrary logic network types (Ntk) present in the mockturtle
    // library, even though we only use it on XAGs.
    template <typename Ntk> struct read_qir_impl
    {
        read_qir_impl(llvm::Module& module, llvm::Function& function)
            : module(module)
            , function(function)
        {
        }

        // initiates logic network generation from the calling function; this
        // function also initializes signals for primary inputs based on the
        // function's arguments.
        Ntk run()
        {
            Ntk ntk;
            fmt::print("[i] process function func {}\n", function.getName().str());

            value_signals[llvm::ConstantInt::getTrue(module.getContext())] = {ntk.get_constant(true)};
            value_signals[llvm::ConstantInt::getFalse(module.getContext())] = {ntk.get_constant(false)};

            // analyze function arguments for inputs
            for (auto const& arg : function.args())
            {
                if (arg.getType()->isIntegerTy(1u))
                {
                    value_signals[&arg] = {ntk.create_pi()};
                }
                else if (arg.getType()->isIntegerTy(64u))
                {
                    value_signals[&arg].resize(64u);
                    std::generate(
                        value_signals[&arg].begin(), value_signals[&arg].end(), [&]() { return ntk.create_pi(); });
                }
                else
                {
                    fmt::print("[e] unsupported type for argument {}\n", arg.getArgNo());
                    std::abort();
                }
            }

            // for now, the sample only supports Boolean and Integer functions (i.e., all
            // input and output types are either of type `Bool`, `Int` or a tuple of
            // type `Bool` `Int`)
            if (!analyze_function_signature(function))
            {
                fmt::print("[e] function signature not supported: inputs must be Bool and return type must be Bool or "
                           "Bool tuple\n");
                std::abort();
            }

            for (auto const& f : process_function(ntk, function))
            {
                ntk.create_po(f);
            }

            return cleanup_dangling(ntk);
        }

      private:
        // process one function (this function can be called recursively if the
        // calling function calls other functions)
        typename std::vector<typename Ntk::signal> process_function(Ntk& ntk, llvm::Function& function)
        {
            llvm::legacy::FunctionPassManager mgr(function.getParent());
            mgr.add(llvm::createDemoteRegisterToMemoryPass());
            mgr.doInitialization();
            mgr.run(function);
            mgr.doFinalization();

            return process_block(ntk, function.getEntryBlock());
        }

        // During logic network generation, each instruction (llvm::Value) is
        // assigned logic network signals, which can be retrieved from this
        // function.
        typename std::vector<typename Ntk::signal> const& get_signal(Ntk& ntk, llvm::Value const* value)
        {
            llvm::ConstantInt const* constant = nullptr;

            if (const auto it = value_signals.find(value); it != value_signals.end())
            {
                return it->second;
            }
            else if (value->getType()->isIntegerTy(64u) && (constant = llvm::dyn_cast<llvm::ConstantInt const>(value)))
            {
                value_signals[value] = constant_word(ntk, constant->getValue().getZExtValue(), 64u);
                return value_signals[value];
            }
            else if (const auto it = tuple_headers.find(value); it != tuple_headers.end())
            {
                return value_signals[it->second];
            }
            else
            {
                fmt::print("[e] cannot find value");
                print(value);
                std::abort();
            }
        }

        // Process one basic block in an LLVM function.
        typename std::vector<typename Ntk::signal> process_block(Ntk& ntk, llvm::BasicBlock const& block)
        {
            // Iterate through each instruction in the block.
            for (auto const& inst : block)
            {
                // Generate logic network nodes based on different LLVM
                // instruction types.
                //
                // The case statements are not exhaustive to illustrate this
                // sample, but in a real world application all possible LLVM
                // instructions should be handled.
                switch (inst.getOpcode())
                {
                default:
                    fmt::print("[e] unsupported op code {}\n", inst.getOpcodeName());
                    print(&inst);
                    std::abort();
                    break;

                case llvm::Instruction::And:
                {
                    auto const& lhs = get_signal(ntk, inst.getOperand(0u));
                    auto const& rhs = get_signal(ntk, inst.getOperand(1u));
                    std::vector<typename Ntk::signal> ands;
                    std::transform(
                        lhs.begin(), lhs.end(), rhs.begin(), std::back_inserter(ands),
                        [&](auto const& a, auto const& b) { return ntk.create_and(a, b); });
                    value_signals[&inst] = ands;
                }
                break;
                case llvm::Instruction::Or:
                {
                    auto const& lhs = get_signal(ntk, inst.getOperand(0u));
                    auto const& rhs = get_signal(ntk, inst.getOperand(1u));
                    std::vector<typename Ntk::signal> ors;
                    std::transform(
                        lhs.begin(), lhs.end(), rhs.begin(), std::back_inserter(ors),
                        [&](auto const& a, auto const& b) { return ntk.create_or(a, b); });
                    value_signals[&inst] = ors;
                }
                break;
                case llvm::Instruction::Xor:
                {
                    auto const& lhs = get_signal(ntk, inst.getOperand(0u));
                    auto const& rhs = get_signal(ntk, inst.getOperand(1u));
                    std::vector<typename Ntk::signal> xors;
                    std::transform(
                        lhs.begin(), lhs.end(), rhs.begin(), std::back_inserter(xors),
                        [&](auto const& a, auto const& b) { return ntk.create_xor(a, b); });
                    value_signals[&inst] = xors;
                }
                break;
                case llvm::Instruction::ICmp:
                {
                    auto const* cmpInst = llvm::dyn_cast<llvm::ICmpInst const>(&inst);
                    switch (cmpInst->getPredicate())
                    {
                    default:
                        fmt::print(
                            "[e] unsupported icmp predicate {}\n",
                            llvm::ICmpInst::getPredicateName(cmpInst->getPredicate()).str());
                        break;
                    case llvm::ICmpInst::Predicate::ICMP_EQ:
                    {
                        auto const& lhs = get_signal(ntk, inst.getOperand(0u));
                        auto const& rhs = get_signal(ntk, inst.getOperand(1u));
                        std::vector<typename Ntk::signal> xnors;
                        std::transform(
                            lhs.begin(), lhs.end(), rhs.begin(), std::back_inserter(xnors),
                            [&](auto const& a, auto const& b) { return ntk.create_xnor(a, b); });
                        value_signals[&inst] = {ntk.create_nary_and(xnors)};
                    }
                    break;
                    case llvm::ICmpInst::Predicate::ICMP_NE:
                    {
                        auto const& lhs = get_signal(ntk, inst.getOperand(0u));
                        auto const& rhs = get_signal(ntk, inst.getOperand(1u));
                        std::vector<typename Ntk::signal> xors;
                        std::transform(
                            lhs.begin(), lhs.end(), rhs.begin(), std::back_inserter(xors),
                            [&](auto const& a, auto const& b) { return ntk.create_xor(a, b); });
                        value_signals[&inst] = {ntk.create_nary_or(xors)};
                    }
                    break;
                    case llvm::ICmpInst::Predicate::ICMP_SGT:
                    {
                        auto carry = ntk.get_constant(true);
                        auto copy = get_signal(ntk, inst.getOperand(1u));
                        mockturtle::carry_ripple_subtractor_inplace(
                            ntk, copy, get_signal(ntk, inst.getOperand(0u)), carry);
                        value_signals[&inst] = {carry};
                    }
                    break;
                    }
                }
                break;

                case llvm::Instruction::Select:
                {
                    auto const* selectInst = llvm::dyn_cast<llvm::SelectInst const>(&inst);

                    // It can be a single-bit MUX or a multi-bit MUX
                    if (selectInst->getType()->isIntegerTy(1))
                    {
                        value_signals[&inst] = {ntk.create_ite(
                            value_signals[inst.getOperand(0u)].front(), value_signals[inst.getOperand(1u)].front(),
                            value_signals[inst.getOperand(2u)].front())};
                    }
                    else if (selectInst->getType()->isIntegerTy(64))
                    {
                        value_signals[&inst] = mockturtle::mux(
                            ntk, get_signal(ntk, selectInst->getCondition()).front(),
                            get_signal(ntk, selectInst->getTrueValue()), get_signal(ntk, selectInst->getFalseValue()));
                    }
                    else
                    {
                        fmt::print("[e] unsupported select operation: ");
                        print(selectInst);
                        std::abort();
                    }
                }
                break;

                 // Signed remainder operation
                case llvm::Instruction::SRem:
                {
                    // Get the previous instruction
                    const llvm::Instruction* prevInst = inst.getPrevNode();
                    if (prevInst) {
                        // Check the opcode of the previous instruction
                        unsigned int prevOpcode = prevInst->getOpcode();
                        
                        if (prevOpcode == llvm::Instruction::Add)
                        {
                            // Perform modular addition inplace
                            auto const* op0 = prevInst -> getOperand(0u);
                            auto const* op1 = prevInst -> getOperand(1u);
                            auto const* ty0 = op0->getType();
                            auto const* ty1 = op1->getType();
                            auto const* op2 = inst.getOperand(1u);

                            value_signals[&inst] = value_signals[op0];

                            // Check if the operand is a constant integer
                            if (const llvm::ConstantInt* constantInt = llvm::dyn_cast<llvm::ConstantInt>(op2)) {
                                // Get the unsigned value of the constant
                                llvm::APInt intValue = constantInt->getValue();
                                uint64_t value = intValue.getZExtValue();

                                // The op2 value is converted to uint64_t in the 'value' variable
                                modular_adder_inplace(ntk, value_signals[&inst], value_signals[op1], value);
                            } else {
                                // Handle the case when op2 is not a constant integer
                                fmt::print("op2 is not a constant integer\n");
                                std::abort();
                            }
                            
                            
                        }

                        else if (prevOpcode == llvm::Instruction::Mul) {
                          // Get the operands from the previous instruction
                            auto const* op0 = prevInst->getOperand(0u);
                            auto const* op1 = prevInst->getOperand(1u);
                            
                            // Get the operands from the current instruction
                            auto const* op2 = inst.getOperand(1u);
                            auto const* ty0 = op0->getType();
                            auto const* ty1 = op1->getType();
                            auto const* ty2 = op2->getType();
                            
                            if (ty0->isIntegerTy(64) && ty1->isIntegerTy(64) && ty2->isIntegerTy(64))
                            {
                                auto signal0 = get_signal(ntk, op0);
                                auto signal1 = get_signal(ntk, op1);
                                const auto size = std::max(signal0.size(), signal1.size());
                                value_signals[&inst] = value_signals[op0];

                                if (const llvm::ConstantInt* constantInt = llvm::dyn_cast<llvm::ConstantInt>(op2))
                                {
                                    // Get the unsigned value of the constant
                                    llvm::APInt intValue = constantInt->getValue();
                                    uint64_t value = intValue.getZExtValue();

                                    // Now you have the op2 value converted to uint64_t in the 'value' variable
                                    // You can use it as needed in your code
                                    modular_multiplication_inplace(ntk, value_signals[&inst], value_signals[op1], value); 
                                } 
                                else 
                                {
                                    // Handle the case when op2 is not a constant integer
                                    fmt::print("op2 is not a constant integer\n");
                                    std::abort();
                                }
                            }
                        }
                        
                        else
                        {
                            fmt::print("Unsupported previous opcode: {}\n", prevOpcode);
                            std::abort();
                        }
                    }
                    else {
                        fmt::print("No previous instruction found\n");
                        std::abort();
                    }
                }
                break;

                // Multiplication operation
                case llvm::Instruction::Mul:
                {
                    auto const* op0 = inst.getOperand(0u);
                    auto const* op1 = inst.getOperand(1u);
                    auto const* ty0 = op0->getType();
                    auto const* ty1 = op1->getType();
                    
                    if (ty0->isIntegerTy(64) && ty1->isIntegerTy(64))
                    {
                        auto signal0 = get_signal(ntk, op0);
                        auto signal1 = get_signal(ntk, op1);
                        const auto size = std::max(signal0.size(), signal1.size());
                        value_signals[&inst] = value_signals[inst.getOperand(0u)];
                        modular_multiplication_inplace(ntk, value_signals[&inst], value_signals[inst.getOperand(1u)], 11); 
                    }
                    else
                    {
                    fmt::print("Not Implemented");
                    std::abort();
                    }
                    
                }
                break;

                // Addition operation
                case llvm::Instruction::Add:
                {
                    auto const* op0 = inst.getOperand(0u);
                    auto const* op1 = inst.getOperand(1u);
                    auto const* ty0 = op0->getType();
                    auto const* ty1 = op1->getType();
                    value_signals[&inst] = value_signals[inst.getOperand(0u)];

                    if (ty0->isIntegerTy(64) && ty1->isIntegerTy(64))
                    {
                        modular_adder_inplace(ntk, value_signals[&inst], value_signals[inst.getOperand(1u)], 11);

                    }
                    else
                    {
                        modular_adder_inplace(ntk, value_signals[&inst], value_signals[inst.getOperand(1u)]);
                    }
                }
                break;

                case llvm::Instruction::Br:
                {
                    auto const* branchInst = llvm::dyn_cast<llvm::BranchInst const>(&inst);
                    auto const successorCount = branchInst->getNumSuccessors();
                    if (successorCount == 1u)
                    {
                        value_signals[&inst] = process_block(ntk, *branchInst->getSuccessor(0u));
                    }
                    else if (successorCount == 2u)
                    {
                        value_signals[&inst] = {ntk.create_ite(
                            value_signals[branchInst->getCondition()].front(),
                            process_block(ntk, *branchInst->getSuccessor(0u)).front(),
                            process_block(ntk, *branchInst->getSuccessor(1u)).front())};
                    }
                    else
                    {
                        fmt::print(
                            "[e] expecting one or two successors for branch instructions, got {}\n", successorCount);
                        std::abort();
                    }
                }
                break;

                case llvm::Instruction::Ret:
                    value_signals[&inst] = get_signal(ntk, inst.getOperand(0u));
                    break;

                case llvm::Instruction::Call:
                {
                    auto const* callInst = llvm::dyn_cast<llvm::CallInst const>(&inst);
                    auto* callFunc = callInst->getCalledFunction();
                    const auto name = callFunc->getName().str();
                    if (name == "__quantum__rt__tuple_create")
                    {
                        auto const* argExpr = llvm::dyn_cast<llvm::ConstantExpr const>(callInst->getArgOperand(0u));

                        if (!argExpr)
                        {
                            fmt::print("[e] unexpected expression to __quantum__rt__tuple_create call: ");
                            print(callInst->getArgOperand(0u));
                            std::abort();
                        }

                        auto const* argInst = argExpr->getAsInstruction();
                        llvm::ConstantInt const* tupleSizeValue = nullptr;
                        if (argInst->getNumOperands() != 2u || (tupleSizeValue = llvm::dyn_cast<llvm::ConstantInt const>(argInst->getOperand(1u))) == nullptr)
                        {
                            fmt::print("[e] unexpected expression to __quantum__rt__tuple_create call: ");
                            print(callInst->getArgOperand(0u));
                            std::abort();
                        }

                        const auto tupleSize = tupleSizeValue->getSExtValue();
                        value_signals[&inst] = std::vector<typename Ntk::signal>(tupleSize);
                    }
                    else if (analyze_function_signature(*callFunc))
                    {
                        for (auto i = 0u; i < callInst->getNumArgOperands(); ++i)
                        {
                            value_signals[callFunc->getArg(i)] = value_signals[callInst->getArgOperand(i)];
                        }

                        value_signals[&inst] = process_function(ntk, *callFunc);
                    }
                    else
                    {
                        fmt::print("[e] unsupported function call to {}\n", name);
                        std::abort();
                    }
                }
                break;

                case llvm::Instruction::Alloca:
                {
                    auto const* allocaInst = llvm::dyn_cast<llvm::AllocaInst const>(&inst);
                    if (allocaInst->isArrayAllocation() || !allocaInst->getAllocatedType()->isIntegerTy(1))
                    {
                        fmt::print("[e] unsupported alloca instruction: ");
                        print(&inst);
                        std::abort();
                    }

                    value_signals[&inst] = {ntk.get_constant(false)};
                }
                break;

                case llvm::Instruction::Load:
                {
                    value_signals[&inst] = value_signals[inst.getOperand(0)];
                }
                break;

                case llvm::Instruction::BitCast:
                {
                    if (const auto it = value_signals.find(inst.getOperand(0u)); it != value_signals.end())
                    {
                        tuple_headers[&inst] = it->first;
                    }
                    else if (auto const* const_val = llvm::dyn_cast<llvm::ConstantInt const>(inst.getOperand(0u));
                             const_val && inst.getType()->isIntegerTy())
                    {
                        const auto int_val = const_val->getValue().getSExtValue();
                        const auto bitwidth = inst.getType()->getIntegerBitWidth();
                        value_signals[&inst] = mockturtle::constant_word(ntk, int_val, bitwidth);
                    }
                    else
                    {
                        fmt::print("[e] unsupported bitcast instruction: ");
                        print(&inst);
                        std::abort();
                    }
                }
                break;

                case llvm::Instruction::GetElementPtr:
                {
                    auto const* gepInst = llvm::dyn_cast<llvm::GetElementPtrInst const>(&inst);
                    bool error = false;
                    do
                    {
                        const auto it = tuple_headers.find(gepInst->getPointerOperand());
                        if (it == tuple_headers.end())
                        {
                            error = true;
                            break;
                        }

                        if (gepInst->getNumIndices() != 2u || !gepInst->hasAllConstantIndices())
                        {
                            error = true;
                            break;
                        }

                        auto itIdx = gepInst->idx_begin();
                        auto const* i1 = llvm::dyn_cast<llvm::ConstantInt const>(itIdx->get());
                        itIdx++;
                        auto const* i2 = llvm::dyn_cast<llvm::ConstantInt const>(itIdx->get());

                        if (!i1->isZero())
                        {
                            error = true;
                            break;
                        }

                        tuple_header_elements[&inst] = value_signals[it->second].begin() + (i2->getZExtValue() - 1);
                    } while (false);

                    if (error)
                    {
                        fmt::print("[i] unsupported getelementptr instruction: ");
                        print(&inst);
                        std::abort();
                    }
                }
                break;

                case llvm::Instruction::Store:
                {
                    if (const auto it = tuple_header_elements.find(inst.getOperand(1u));
                        it != tuple_header_elements.end())
                    {
                        *(it->second) = get_signal(ntk, inst.getOperand(0u)).front();
                    }
                    else
                    {
                        value_signals[inst.getOperand(1u)] = get_signal(ntk, inst.getOperand(0u));
                    }
                }
                break;
                }
            }

            return get_signal(ntk, block.getTerminator());
        }

        /*! \brief Checks whether the type is a pointer to a tuple of Booleans or 64-bit integers.
         *
         * This checks whether a type corresponds to a Q# tuple in which all
         * types are either `Bool` or `Int`.
         */
        bool is_valid_tuple_pointer_type(llvm::Type const* ty) const
        {
            if (!ty->isPointerTy())
            {
                return false;
            }

            auto const* elemTy = ty->getPointerElementType();
            if (!elemTy->isAggregateType() || !elemTy->isStructTy())
            {
                return false;
            }

            auto const* aggrTy = llvm::dyn_cast<llvm::StructType const>(elemTy);

            for (auto c = 0u; c < aggrTy->getNumContainedTypes(); ++c)
            {
                if (!aggrTy->getContainedType(c)->isIntegerTy(1u))
                {
                    return false;
                }
            }

            return true;
        }

        /*! \brief Checks whether the function signature is supported. */
        bool analyze_function_signature(llvm::Function const& f) const
        {
            /* input type */
            for (const auto& arg : f.args())
            {
                if (arg.getType()->isIntegerTy(64) || arg.getType()->isIntegerTy(1u))
                {
                    continue;
                }
                return false;
            }

            /* output type */
            auto const* retTy = f.getReturnType();

            return retTy->isIntegerTy(64) || retTy->isIntegerTy(1u) || is_valid_tuple_pointer_type(retTy);
        }

      private:
        void print(llvm::Value const* value) const
        {
            llvm::raw_os_ostream os(std::cout);
            os << *value << "\n";
        }

        void print(llvm::Type const* type) const
        {
            llvm::raw_os_ostream os(std::cout);
            os << *type << "\n";
        }

      private:
        llvm::Module& module;
        llvm::Function& function;

        std::unordered_map<llvm::Value const*, std::vector<typename Ntk::signal>> value_signals;

        // These data structures help for storing and accessing elements in tuples
        std::unordered_map<llvm::Value const*, llvm::Value const*> tuple_headers;
        std::unordered_map<llvm::Value const*, typename std::vector<typename Ntk::signal>::iterator>
            tuple_header_elements;
    };

} // namespace detail

template <class Ntk> Ntk read_qir(llvm::Module& module, llvm::Function& function)
{
    return ::detail::read_qir_impl<Ntk>{module, function}.run();
}
