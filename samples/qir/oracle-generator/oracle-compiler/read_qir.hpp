#pragma once

#include <iostream>
#include <unordered_map>

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

    template <typename Ntk> struct read_qir_impl
    {
        read_qir_impl(llvm::Module& module, llvm::Function& function)
            : module(module)
            , function(function)
        {
        }

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

            // TODO analyze return value
            if (!analyze_function_signature(function))
            {
                fmt::print("[e] function signature not supported: inputs must be Bool and return type must be Bool or "
                           "TupleHeader*\n");
                std::abort();
            }

            for (auto const& f : process_function(ntk, function))
            {
                ntk.create_po(f);
            }

            return cleanup_dangling(ntk);
        }

      private:
        typename std::vector<typename Ntk::signal> process_function(Ntk& ntk, llvm::Function& function)
        {
            llvm::legacy::FunctionPassManager mgr(function.getParent());
            mgr.add(llvm::createDemoteRegisterToMemoryPass());
            mgr.doInitialization();
            mgr.run(function);
            mgr.doFinalization();

            return process_block(ntk, function.getEntryBlock());
        }

        typename std::vector<typename Ntk::signal> const& get_signal(Ntk& ntk, llvm::Value const* value)
        {
            llvm::ConstantInt const* constant = nullptr;
            const auto it = value_signals.find(value);

            if (it != value_signals.end())
            {
                return it->second;
            }
            else if (value->getType()->isIntegerTy(64u) && (constant = llvm::dyn_cast<llvm::ConstantInt const>(value)))
            {
                value_signals[value] = constant_word(ntk, constant->getValue().getZExtValue(), 64u);
                return value_signals[value];
            }
            else
            {
                fmt::print("[e] cannot find value");
                print(value);
                std::abort();
            }
        }

        typename std::vector<typename Ntk::signal> process_block(Ntk& ntk, llvm::BasicBlock const& block)
        {
            for (auto const& inst : block)
            {
                switch (inst.getOpcode())
                {
                default:
                    fmt::print("[e] unsupported op code {}\n", inst.getOpcodeName());
                    break;

                case llvm::Instruction::And:
                    value_signals[&inst] = {ntk.create_and(
                        value_signals[inst.getOperand(0u)].front(), value_signals[inst.getOperand(1u)].front())};
                    break;

                case llvm::Instruction::Or:
                    value_signals[&inst] = {ntk.create_or(
                        value_signals[inst.getOperand(0u)].front(), value_signals[inst.getOperand(1u)].front())};
                    break;

                case llvm::Instruction::Xor:
                    value_signals[&inst] = {ntk.create_xor(
                        value_signals[inst.getOperand(0u)].front(), value_signals[inst.getOperand(1u)].front())};
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
                        // TODO multi-bit comparison
                        value_signals[&inst] = {ntk.create_xnor(
                            value_signals[inst.getOperand(0u)].front(), value_signals[inst.getOperand(1u)].front())};
                        break;
                    case llvm::ICmpInst::Predicate::ICMP_NE:
                        // TODO multi-bit comparison
                        value_signals[&inst] = {ntk.create_xor(
                            value_signals[inst.getOperand(0u)].front(), value_signals[inst.getOperand(1u)].front())};
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

                case llvm::Instruction::Add:
                    value_signals[&inst] = value_signals[inst.getOperand(0u)];
                    modular_adder_inplace(ntk, value_signals[&inst], value_signals[inst.getOperand(1u)]);
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
                    value_signals[&inst] = value_signals[inst.getOperand(0u)];
                    break;

                case llvm::Instruction::Call:
                {
                    auto const* callInst = llvm::dyn_cast<llvm::CallInst const>(&inst);
                    auto* callFunc = callInst->getCalledFunction();
                    const auto name = callFunc->getName().str();
                    if (name == "__quantum__rt__tuple_create")
                    {
                        // need to get the tuple header structure
                        auto const* arg0 = llvm::dyn_cast<llvm::PtrToIntOperator const>(callInst->getArgOperand(0u));
                        auto const* tupleHeader = arg0->getPointerOperandType()->getPointerElementType();

                        // number of potential Bool elements
                        const auto tupleSize = tupleHeader->getStructNumElements() - 1;
                        for (auto i = 1u; i <= tupleSize; ++i)
                        {
                            if (!tupleHeader->getStructElementType(i)->isIntegerTy(1u))
                            {
                                fmt::print("[e] only Boolean tuples are currently supported");
                                std::abort();
                            }
                        }

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
                        *(it->second) = value_signals[inst.getOperand(0u)].front();
                    }
                    else
                    {
                        // TODO: check if value exists
                        auto const* storeInst = llvm::dyn_cast<llvm::StoreInst const>(&inst);
                        value_signals[inst.getOperand(1u)] = value_signals[inst.getOperand(0u)];
                    }
                }
                break;
                }
            }

            return value_signals[block.getTerminator()];
        }

        /*! \brief Checks whether the function signature is supported. */
        bool analyze_function_signature(llvm::Function const& f) const
        {
            /* input type */
            for (const auto& arg : f.args())
            {
                if (arg.getType()->isIntegerTy(1u))
                {
                    continue;
                }
                else if (arg.getType()->isIntegerTy(64u))
                {
                    continue;
                }
                return false;
            }

            /* output type */
            auto const* retTy = f.getReturnType();
            if (retTy->isIntegerTy(1u))
            {
                return true;
            }
            else if (retTy->isIntegerTy(64u))
            {
                return true;
            }
            else if (
                retTy->isPointerTy() && retTy->getPointerElementType()->isStructTy() &&
                retTy->getPointerElementType()->getStructName().equals("TupleHeader"))
            {
                /* TODO we cannot verify which kind of tuple the return type is at this point */
                return true;
            }
            else
            {
                return false;
            }
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
