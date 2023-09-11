// SynchronousBlock+allVariables.swift
// VHDLMachines
// 
// Created by Morgan McColl.
// Copyright © 2023 Morgan McColl. All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
// 
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
// 
// 2. Redistributions in binary form must reproduce the above
//    copyright notice, this list of conditions and the following
//    disclaimer in the documentation and/or other materials
//    provided with the distribution.
// 
// 3. All advertising materials mentioning features or use of this
//    software must display the following acknowledgement:
// 
//    This product includes software developed by Morgan McColl.
// 
// 4. Neither the name of the author nor the names of contributors
//    may be used to endorse or promote products derived from this
//    software without specific prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
// A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER
// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
// EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
// PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
// LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
// NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
// 
// -----------------------------------------------------------------------
// This program is free software; you can redistribute it and/or
// modify it under the above terms or under the terms of the GNU
// General Public License as published by the Free Software Foundation;
// either version 2 of the License, or (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program; if not, see http://www.gnu.org/licenses/
// or write to the Free Software Foundation, Inc., 51 Franklin Street,
// Fifth Floor, Boston, MA  02110-1301, USA.
// 

import VHDLParsing

extension SynchronousBlock {

    var allVariables: Set<VariableName> {
        switch self {
        case .blocks(let blocks):
            return blocks.reduce(Set<VariableName>()) { $0.union($1.allVariables) }
        case .caseStatement(let block):
            return block.allVariables
        case .forLoop(let loop):
            return loop.allVariables
        case .ifStatement(let block):
            return block.allVariables
        case .statement(let statement):
            return statement.allVariables
        }
    }

}

extension Statement {

    var allVariables: Set<VariableName> {
        switch self {
        case .assignment(let name, let value):
            return value.allVariables.union(name.allVariables)
        case .comment, .exit, .null:
            return []
        case .returns(let expression):
            return expression.allVariables
        }
    }

}

extension IfBlock {

    var allVariables: Set<VariableName> {
        switch self {
        case .ifElse(let condition, let ifBlock, let elseBlock):
            return condition.allVariables.union(ifBlock.allVariables).union(elseBlock.allVariables)
        case .ifStatement(let condition, let ifBlock):
            return condition.allVariables.union(ifBlock.allVariables)
        }
    }

}

extension ForLoop {

    var allVariables: Set<VariableName> {
        self.body.allVariables.union([self.iterator]).union(self.range.allVariables)
    }

}

extension CaseStatement {

    var allVariables: Set<VariableName> {
        self.cases.reduce(self.condition.allVariables) { $0.union($1.allVariables) }
    }

}

extension WhenCase {

    var allVariables: Set<VariableName> {
        self.code.allVariables.union(self.condition.allVariables)
    }

}

extension WhenCondition {

    var allVariables: Set<VariableName> {
        switch self {
        case .expression(let expression):
            return expression.allVariables
        case .others:
            return []
        case .range(let size):
            return size.allVariables
        case .selection(let expressions):
            return expressions.reduce(Set<VariableName>()) { $0.union($1.allVariables) }
        }
    }

}

extension Expression {

    var allVariables: Set<VariableName> {
        switch self {
        case .binary(let operation):
            return operation.allVariables
        case .cast(let operation):
            return operation.allVariables
        case .conditional(let condition):
            return condition.allVariables
        case .functionCall(let call):
            return call.allVariables
        case .literal:
            return []
        case .logical(let operation):
            return operation.allVariables
        case .precedence(let value):
            return value.allVariables
        case .reference(let ref):
            return ref.allVariables
        }
    }

}

extension VariableReference {

    var allVariables: Set<VariableName> {
        switch self {
        case .indexed(let name, let index):
            return index.allVariables.union([name])
        case .variable(let ref):
            return ref.allVariables
        }
    }

}

extension DirectReference {

    var allVariables: Set<VariableName> {
        switch self {
        case .member(let access):
            return access.allVariables
        case .variable(let name):
            return [name]
        }
    }

}

extension MemberAccess {

    var allVariables: Set<VariableName> {
        self.member.allVariables.union([self.record])
    }

}

extension VectorIndex {

    var allVariables: Set<VariableName> {
        switch self {
        case .index(let value):
            return value.allVariables
        case .others:
            return []
        case .range(let size):
            return size.allVariables
        }
    }

}

extension VectorSize {

    var allVariables: Set<VariableName> {
        self.max.allVariables.union(self.min.allVariables)
    }

}

extension BooleanExpression {

    var operands: [Expression] {
        switch self {
        case .and(let lhs, let rhs):
            return [lhs, rhs]
        case .nand(let lhs, let rhs):
            return [lhs, rhs]
        case .nor(let lhs, let rhs):
            return [lhs, rhs]
        case .not(let expression):
            return [expression]
        case .or(let lhs, let rhs):
            return [lhs, rhs]
        case .xnor(let lhs, let rhs):
            return [lhs, rhs]
        case .xor(let lhs, let rhs):
            return [lhs, rhs]
        }
    }

    var allVariables: Set<VariableName> {
        self.operands.reduce(Set<VariableName>()) { $0.union($1.allVariables) }
    }

}

extension BinaryOperation {

    var allVariables: Set<VariableName> {
        switch self {
        case .addition(let lhs, let rhs):
            return lhs.allVariables.union(rhs.allVariables)
        case .division(let lhs, let rhs):
            return lhs.allVariables.union(rhs.allVariables)
        case .multiplication(let lhs, let rhs):
            return lhs.allVariables.union(rhs.allVariables)
        case .subtraction(let lhs, let rhs):
            return lhs.allVariables.union(rhs.allVariables)
        }
    }

}

extension CastOperation {

    var allVariables: Set<VariableName> {
        self.expression.allVariables
    }

}

extension ConditionalExpression {

    var allVariables: Set<VariableName> {
        switch self {
        case .comparison(let value):
            return value.allVariables
        case .edge(let value):
            return value.allVariables
        case .literal:
            return []
        }
    }

}

extension ComparisonOperation {

    var allVariables: Set<VariableName> {
        switch self {
        case .equality(let lhs, let rhs):
            return lhs.allVariables.union(rhs.allVariables)
        case .greaterThan(let lhs, let rhs):
            return lhs.allVariables.union(rhs.allVariables)
        case .greaterThanOrEqual(let lhs, let rhs):
            return lhs.allVariables.union(rhs.allVariables)
        case .lessThan(let lhs, let rhs):
            return lhs.allVariables.union(rhs.allVariables)
        case .lessThanOrEqual(let lhs, let rhs):
            return lhs.allVariables.union(rhs.allVariables)
        case .notEquals(let lhs, let rhs):
            return lhs.allVariables.union(rhs.allVariables)
        }
    }

}

extension EdgeCondition {

    var allVariables: Set<VariableName> {
        self.expression.allVariables
    }

}

extension FunctionCall {

    var allVariables: Set<VariableName> {
        switch self {
        case .custom(let function):
            return function.arguments.reduce(Set<VariableName>()) { $0.union($1.allVariables) }
                .union([function.name])
        case .mathReal(let function):
            return function.arguments.reduce(Set<VariableName>()) { $0.union($1.allVariables) }
        }
    }

}

extension MathRealFunctionCalls {

    var arguments: [Expression] {
        switch self {
        case .ceil(let expression):
            return [expression]
        case .floor(let expression):
            return [expression]
        case .fmax(let arg0, let arg1):
            return [arg0, arg1]
        case .fmin(let arg0, let arg1):
            return [arg0, arg1]
        case .round(let expression):
            return [expression]
        case .sign(let expression):
            return [expression]
        case .sqrt(let expression):
            return [expression]
        }
    }

}
