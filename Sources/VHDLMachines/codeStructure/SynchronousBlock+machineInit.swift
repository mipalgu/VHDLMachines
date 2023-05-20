// SynchronousBlock+machineInit.swift
// Machines
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

/// Add init for top-level if-statement in process block.
extension SynchronousBlock {

    /// Create the top-level if-statement for the rising edge of the driving clock in the machine. This
    /// block contains all of the logic of the machine.
    /// - Parameter machine: The machine to create the if-statement for.
    init?(machine: Machine) {
        guard
            machine.drivingClock >= 0,
            machine.drivingClock < machine.clocks.count,
            let caseStatement = CaseStatement(machine: machine)
        else {
            return nil
        }
        let clock = machine.clocks[machine.drivingClock].name
        let code = IfBlock.ifStatement(
            condition: .conditional(
                condition: .edge(value: .rising(expression: .reference(variable: .variable(name: clock))))
            ),
            ifBlock: .caseStatement(block: caseStatement)
        )
        self = .ifStatement(block: code)
    }

    init?(block: SynchronousBlock, replacing variable: VariableName, with value: VariableName) {
        switch block {
        case .blocks(let blocks):
            let newBlocks = blocks.compactMap {
                SynchronousBlock(block: $0, replacing: variable, with: value)
            }
            guard newBlocks.count == blocks.count else {
                return nil
            }
            self = .blocks(blocks: newBlocks)
        case .caseStatement(let block):
            let newCases = block.cases.compactMap {
                WhenCase(whenCase: $0, replacing: variable, with: value)
            }
            guard
                newCases.count == block.cases.count,
                let condition = Expression(expression: block.condition, replacing: variable, with: value)
            else {
                return nil
            }
            self = .caseStatement(block: CaseStatement(condition: condition, cases: newCases))
        }
    }

}

extension WhenCase {

    init?(whenCase: WhenCase, replacing variable: VariableName, with value: VariableName) {
        guard
            let newCondition = WhenCondition(condition: whenCase.condition, replacing: variable, with: value),
            let newCode = SynchronousBlock(block: whenCase.code, replacing: variable, with: value)
        else {
            return nil
        }
        self.init(condition: newCondition, code: newCode)
    }

}

extension WhenCondition {

    init?(condition: WhenCondition, replacing variable: VariableName, with value: VariableName) {
        switch condition {
        case .expression(let expression):
            guard let newExpression = Expression(
                expression: expression, replacing: variable, with: value
            ) else {
                return nil
            }
            self = .expression(expression: newExpression)
        case .others:
            self = .others
        case .range(let range):
            guard let newRange = VectorSize(size: range, replacing: variable, with: value) else {
                return nil
            }
            self = .range(range: newRange)
        case .selection(let expressions):
            let newExpressions = expressions.compactMap {
                Expression(expression: $0, replacing: variable, with: value)
            }
            guard newExpressions.count == expressions.count else {
                return nil
            }
            self = .selection(expressions: newExpressions)
        }
    }

}

extension VectorSize {

    init?(size: VectorSize, replacing variable: VariableName, with value: VariableName) {
        switch size {
        case .downto(let upper, let lower):
            guard
                let newUpper = Expression(expression: upper, replacing: variable, with: value),
                let newLower = Expression(expression: lower, replacing: variable, with: value)
            else {
                return nil
            }
            self = .downto(upper: newUpper, lower: newLower)
        case .to(let lower, let upper):
            guard
                let newLower = Expression(expression: lower, replacing: variable, with: value),
                let newUpper = Expression(expression: upper, replacing: variable, with: value)
            else {
                return nil
            }
            self = .to(lower: newLower, upper: newUpper)
        }
    }

}

extension Expression {

    init?(expression: Expression, replacing variable: VariableName, with value: VariableName) {
        switch expression {
        case .binary(let operation):
            guard
                let newOperation = BinaryOperation(operation: operation, replacing: variable, with: value)
            else {
                return nil
            }
            self = .binary(operation: newOperation)
        case .cast(let cast):
            guard let newCast = CastOperation(operation: cast, replacing: variable, with: value) else {
                return nil
            }
            self = .cast(operation: newCast)
        case .conditional(let condition):
            guard let newCondition = ConditionalExpression(
                expression: condition, replacing: variable, with: value
            ) else {
                return nil
            }
            self = .conditional(condition: newCondition)
        case .functionCall(let call):
            guard let newCall = FunctionCall(call: call, replacing: variable, with: value) else {
                return nil
            }
            self = .functionCall(call: newCall)
        case .literal:
            self = expression
        case .logical(let operation):
            guard let newOperation = BooleanExpression(
                expression: operation, replacing: variable, with: value
            ) else {
                return nil
            }
            self = .logical(operation: newOperation)
        case .precedence(let expression):
            guard let newValue = Expression(expression: expression, replacing: variable, with: value) else {
                return nil
            }
            self = .precedence(value: newValue)
        case .reference(let reference):
            self = .reference(variable: VariableReference(
                reference: reference, replacing: variable, with: value
            ))
        }
    }

}

extension VariableReference {

    init(reference: VariableReference, replacing variable: VariableName, with value: VariableName) {
        switch reference {
        case .indexed(let name, let index):
            guard name == variable else {
                self = reference
                return
            }
            self = .indexed(name: value, index: index)
        case .variable(let name):
            guard name == variable else {
                self = reference
                return
            }
            self = .variable(name: value)
        }
    }

}

extension BooleanExpression {

    init?(expression: BooleanExpression, replacing variable: VariableName, with value: VariableName) {
        switch expression {
        case .and(let lhs, let rhs):
            guard
                let newLhs = Expression(expression: lhs, replacing: variable, with: value),
                let newRhs = Expression(expression: rhs, replacing: variable, with: value)
            else {
                return nil
            }
            self = .and(lhs: newLhs, rhs: newRhs)
        case .nand(let lhs, let rhs):
            guard
                let newLhs = Expression(expression: lhs, replacing: variable, with: value),
                let newRhs = Expression(expression: rhs, replacing: variable, with: value)
            else {
                return nil
            }
            self = .nand(lhs: newLhs, rhs: newRhs)
        case .nor(let lhs, let rhs):
            guard
                let newLhs = Expression(expression: lhs, replacing: variable, with: value),
                let newRhs = Expression(expression: rhs, replacing: variable, with: value)
            else {
                return nil
            }
            self = .nor(lhs: newLhs, rhs: newRhs)
        case .not(let expression):
            guard let newValue = Expression(expression: expression, replacing: variable, with: value) else {
                return nil
            }
            self = .not(value: newValue)
        case .or(let lhs, let rhs):
            guard
                let newLhs = Expression(expression: lhs, replacing: variable, with: value),
                let newRhs = Expression(expression: rhs, replacing: variable, with: value)
            else {
                return nil
            }
            self = .or(lhs: newLhs, rhs: newRhs)
        case .xnor(let lhs, let rhs):
            guard
                let newLhs = Expression(expression: lhs, replacing: variable, with: value),
                let newRhs = Expression(expression: rhs, replacing: variable, with: value)
            else {
                return nil
            }
            self = .xnor(lhs: newLhs, rhs: newRhs)
        case .xor(let lhs, let rhs):
            guard
                let newLhs = Expression(expression: lhs, replacing: variable, with: value),
                let newRhs = Expression(expression: rhs, replacing: variable, with: value)
            else {
                return nil
            }
            self = .xor(lhs: newLhs, rhs: newRhs)
        }
    }

}

extension FunctionCall {

    init?(call: FunctionCall, replacing variable: VariableName, with value: VariableName) {
        switch call {
        case .custom(let function):
            let newArguments = function.arguments.compactMap {
                Expression(expression: $0, replacing: variable, with: value)
            }
            guard newArguments.count == function.arguments.count else {
                return nil
            }
            self = .custom(function: CustomFunctionCall(name: function.name, arguments: newArguments))
        case .mathReal(let function):
            guard let newFunction = MathRealFunctionCalls(
                function: function, replacing: variable, with: value
            ) else {
                return nil
            }
            self = .mathReal(function: newFunction)
        }
    }

}

extension MathRealFunctionCalls {

    init?(function: MathRealFunctionCalls, replacing variable: VariableName, with value: VariableName) {
        switch function {
        case .ceil(let expression):
            guard let newExpression = Expression(
                expression: expression, replacing: variable, with: value
            ) else {
                return nil
            }
            self = .ceil(expression: newExpression)
        case .floor(let expression):
            guard let newExpression = Expression(
                expression: expression, replacing: variable, with: value
            ) else {
                return nil
            }
            self = .floor(expression: newExpression)
        case .fmax(let arg0, let arg1):
            guard
                let newArg0 = Expression(expression: arg0, replacing: variable, with: value),
                let newArg1 = Expression(expression: arg1, replacing: variable, with: value)
            else {
                return nil
            }
            self = .fmax(arg0: newArg0, arg1: newArg1)
        case .fmin(let arg0, let arg1):
            guard
                let newArg0 = Expression(expression: arg0, replacing: variable, with: value),
                let newArg1 = Expression(expression: arg1, replacing: variable, with: value)
            else {
                return nil
            }
            self = .fmin(arg0: newArg0, arg1: newArg1)
        case .round(let expression):
            guard let newExpression = Expression(
                expression: expression, replacing: variable, with: value
            ) else {
                return nil
            }
            self = .round(expression: newExpression)
        case .sign(let expression):
            guard let newExpression = Expression(
                expression: expression, replacing: variable, with: value
            ) else {
                return nil
            }
            self = .sign(expression: newExpression)
        case .sqrt(let expression):
            guard let newExpression = Expression(
                expression: expression, replacing: variable, with: value
            ) else {
                return nil
            }
            self = .sqrt(expression: newExpression)
        }
    }

}

extension BinaryOperation {

    init?(operation: BinaryOperation, replacing variable: VariableName, with value: VariableName) {
        switch operation {
        case .addition(let lhs, let rhs):
            guard
                let newLhs = Expression(expression: lhs, replacing: variable, with: value),
                let newRhs = Expression(expression: rhs, replacing: variable, with: value)
            else {
                return nil
            }
            self = .addition(lhs: newLhs, rhs: newRhs)
        case .division(let lhs, let rhs):
            guard
                let newLhs = Expression(expression: lhs, replacing: variable, with: value),
                let newRhs = Expression(expression: rhs, replacing: variable, with: value)
            else {
                return nil
            }
            self = .division(lhs: newLhs, rhs: newRhs)
        case .subtraction(let lhs, let rhs):
            guard
                let newLhs = Expression(expression: lhs, replacing: variable, with: value),
                let newRhs = Expression(expression: rhs, replacing: variable, with: value)
            else {
                return nil
            }
            self = .subtraction(lhs: newLhs, rhs: newRhs)
        case .multiplication(let lhs, let rhs):
            guard
                let newLhs = Expression(expression: lhs, replacing: variable, with: value),
                let newRhs = Expression(expression: rhs, replacing: variable, with: value)
            else {
                return nil
            }
            self = .multiplication(lhs: newLhs, rhs: newRhs)
        }
    }

}

extension CastOperation {

    init?(operation: CastOperation, replacing variable: VariableName, with value: VariableName) {
        switch operation {
        case .bit(let expression):
            guard let newExpression = Expression(
                expression: expression, replacing: variable, with: value
            ) else {
                return nil
            }
            self = .bit(expression: newExpression)
        case .bitVector(let expression):
            guard let newExpression = Expression(
                expression: expression, replacing: variable, with: value
            ) else {
                return nil
            }
            self = .bitVector(expression: newExpression)
        case .boolean(let expression):
            guard let newExpression = Expression(
                expression: expression, replacing: variable, with: value
            ) else {
                return nil
            }
            self = .boolean(expression: newExpression)
        case .integer(let expression):
            guard let newExpression = Expression(
                expression: expression, replacing: variable, with: value
            ) else {
                return nil
            }
            self = .integer(expression: newExpression)
        case .natural(let expression):
            guard let newExpression = Expression(
                expression: expression, replacing: variable, with: value
            ) else {
                return nil
            }
            self = .natural(expression: newExpression)
        case .positive(let expression):
            guard let newExpression = Expression(
                expression: expression, replacing: variable, with: value
            ) else {
                return nil
            }
            self = .positive(expression: newExpression)
        case .real(let expression):
            guard let newExpression = Expression(
                expression: expression, replacing: variable, with: value
            ) else {
                return nil
            }
            self = .real(expression: newExpression)
        case .signed(let expression):
            guard let newExpression = Expression(
                expression: expression, replacing: variable, with: value
            ) else {
                return nil
            }
            self = .signed(expression: newExpression)
        case .stdLogic(let expression):
            guard let newExpression = Expression(
                expression: expression, replacing: variable, with: value
            ) else {
                return nil
            }
            self = .stdLogic(expression: newExpression)
        case .stdLogicVector(let expression):
            guard let newExpression = Expression(
                expression: expression, replacing: variable, with: value
            ) else {
                return nil
            }
            self = .stdLogicVector(expression: newExpression)
        case .stdULogic(let expression):
            guard let newExpression = Expression(
                expression: expression, replacing: variable, with: value
            ) else {
                return nil
            }
            self = .stdULogic(expression: newExpression)
        case .stdULogicVector(let expression):
            guard let newExpression = Expression(
                expression: expression, replacing: variable, with: value
            ) else {
                return nil
            }
            self = .stdULogicVector(expression: newExpression)
        case .unsigned(let expression):
            guard let newExpression = Expression(
                expression: expression, replacing: variable, with: value
            ) else {
                return nil
            }
            self = .unsigned(expression: newExpression)
        }
    }

}

extension ComparisonOperation {

    init?(operation: ComparisonOperation, replacing variable: VariableName, with value: VariableName) {
        switch operation {
        case .equality(let lhs, let rhs):
            guard
                let newLhs = Expression(expression: lhs, replacing: variable, with: value),
                let newRhs = Expression(expression: rhs, replacing: variable, with: value)
            else {
                return nil
            }
            self = .equality(lhs: newLhs, rhs: newRhs)
        case .greaterThan(let lhs, let rhs):
            guard
                let newLhs = Expression(expression: lhs, replacing: variable, with: value),
                let newRhs = Expression(expression: rhs, replacing: variable, with: value)
            else {
                return nil
            }
            self = .greaterThan(lhs: newLhs, rhs: newRhs)
        case .greaterThanOrEqual(let lhs, let rhs):
            guard
                let newLhs = Expression(expression: lhs, replacing: variable, with: value),
                let newRhs = Expression(expression: rhs, replacing: variable, with: value)
            else {
                return nil
            }
            self = .greaterThanOrEqual(lhs: newLhs, rhs: newRhs)
        case .lessThan(let lhs, let rhs):
            guard
                let newLhs = Expression(expression: lhs, replacing: variable, with: value),
                let newRhs = Expression(expression: rhs, replacing: variable, with: value)
            else {
                return nil
            }
            self = .lessThan(lhs: newLhs, rhs: newRhs)
        case .lessThanOrEqual(let lhs, let rhs):
            guard
                let newLhs = Expression(expression: lhs, replacing: variable, with: value),
                let newRhs = Expression(expression: rhs, replacing: variable, with: value)
            else {
                return nil
            }
            self = .lessThanOrEqual(lhs: newLhs, rhs: newRhs)
        case .notEquals(let lhs, let rhs):
            guard
                let newLhs = Expression(expression: lhs, replacing: variable, with: value),
                let newRhs = Expression(expression: rhs, replacing: variable, with: value)
            else {
                return nil
            }
            self = .notEquals(lhs: newLhs, rhs: newRhs)
        }
    }

}

extension ConditionalExpression {

    init?(expression: ConditionalExpression, replacing variable: VariableName, with value: VariableName) {
        switch expression {
        case .comparison(let operation):
            guard let newOperation = ComparisonOperation(
                operation: operation, replacing: variable, with: value
            ) else {
                return nil
            }
            self = .comparison(value: newOperation)
        case .edge(let condition):
            guard let newCondition = EdgeCondition(
                condition: condition, replacing: variable, with: value
            ) else {
                return nil
            }
            self = .edge(value: newCondition)
        case .literal(let literal):
            self = .literal(value: literal)
        }
    }

}

extension EdgeCondition {

    init?(condition: EdgeCondition, replacing variable: VariableName, with value: VariableName) {
        switch condition {
        case .rising(let expression):
            guard let newExpression = Expression(
                expression: expression, replacing: variable, with: value
            ) else {
                return nil
            }
            self = .rising(expression: newExpression)
        case .falling(let expression):
            guard let newExpression = Expression(
                expression: expression, replacing: variable, with: value
            ) else {
                return nil
            }
            self = .falling(expression: newExpression)
        }
    }

}
