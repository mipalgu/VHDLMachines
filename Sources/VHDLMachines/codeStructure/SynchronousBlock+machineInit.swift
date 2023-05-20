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

    init?(block: SynchronousBlock, stateVariables: [VariableName]) {
        switch block {
        case .blocks(let blocks):
            let newBlocks = blocks.compactMap { SynchronousBlock(block: $0, stateVariables: stateVariables) }
            guard newBlocks.count == blocks.count else {
                return nil
            }
            self = .blocks(blocks: newBlocks)
        case .caseStatement(let block):
            block.
        }
    }

}

extension Expression {

    init?(expression: Expression, stateVariables: [VariableName]) {
        switch expression {
        case .binary(let operation):
            guard
                let newOperation = BinaryOperation(operation: operation, stateVariables: stateVariables)
            else {
                return nil
            }
            self = .binary(operation: newOperation)
        case .cast(let cast):
            guard let newCast = CastOperation(operation: cast, stateVariables: stateVariables) else {
                return nil
            }
            self = .cast(operation: newCast)
        case .conditional(let condition):
            
        }
    }

}

extension BinaryOperation {

    init?(operation: BinaryOperation, stateVariables: [VariableName]) {
        switch operation {
        case .addition(let lhs, let rhs):
            guard
                let newLhs = Expression(expression: lhs, stateVariables: stateVariables),
                let newRhs = Expression(expression: rhs, stateVariables: stateVariables)
            else {
                return nil
            }
            self = .addition(lhs: newLhs, rhs: newRhs)
        case .division(let lhs, let rhs):
            guard
                let newLhs = Expression(expression: lhs, stateVariables: stateVariables),
                let newRhs = Expression(expression: rhs, stateVariables: stateVariables)
            else {
                return nil
            }
            self = .division(lhs: newLhs, rhs: newRhs)
        case .subtraction(let lhs, let rhs):
            guard
                let newLhs = Expression(expression: lhs, stateVariables: stateVariables),
                let newRhs = Expression(expression: rhs, stateVariables: stateVariables)
            else {
                return nil
            }
            self = .subtraction(lhs: newLhs, rhs: newRhs)
        case .multiplication(let lhs, let rhs):
            guard
                let newLhs = Expression(expression: lhs, stateVariables: stateVariables),
                let newRhs = Expression(expression: rhs, stateVariables: stateVariables)
            else {
                return nil
            }
            self = .multiplication(lhs: newLhs, rhs: newRhs)
        }
    }

}

extension CastOperation {

    init?(operation: CastOperation, stateVariables: [VariableName]) {
        switch operation {
        case .bit(let expression):
            guard let newExpression = Expression(
                expression: expression, stateVariables: stateVariables
            ) else {
                return nil
            }
            self = .bit(expression: newExpression)
        case .bitVector(let expression):
            guard let newExpression = Expression(
                expression: expression, stateVariables: stateVariables
            ) else {
                return nil
            }
            self = .bitVector(expression: newExpression)
        case .boolean(let expression):
            guard let newExpression = Expression(
                expression: expression, stateVariables: stateVariables
            ) else {
                return nil
            }
            self = .boolean(expression: newExpression)
        case .integer(let expression):
            guard let newExpression = Expression(
                expression: expression, stateVariables: stateVariables
            ) else {
                return nil
            }
            self = .integer(expression: newExpression)
        case .natural(let expression):
            guard let newExpression = Expression(
                expression: expression, stateVariables: stateVariables
            ) else {
                return nil
            }
            self = .natural(expression: newExpression)
        case .positive(let expression):
            guard let newExpression = Expression(
                expression: expression, stateVariables: stateVariables
            ) else {
                return nil
            }
            self = .positive(expression: newExpression)
        case .real(let expression):
            guard let newExpression = Expression(
                expression: expression, stateVariables: stateVariables
            ) else {
                return nil
            }
            self = .real(expression: newExpression)
        case .signed(let expression):
            guard let newExpression = Expression(
                expression: expression, stateVariables: stateVariables
            ) else {
                return nil
            }
            self = .signed(expression: newExpression)
        case .stdLogic(let expression):
            guard let newExpression = Expression(
                expression: expression, stateVariables: stateVariables
            ) else {
                return nil
            }
            self = .stdLogic(expression: newExpression)
        case .stdLogicVector(let expression):
            guard let newExpression = Expression(
                expression: expression, stateVariables: stateVariables
            ) else {
                return nil
            }
            self = .stdLogicVector(expression: newExpression)
        case .stdULogic(let expression):
            guard let newExpression = Expression(
                expression: expression, stateVariables: stateVariables
            ) else {
                return nil
            }
            self = .stdULogic(expression: newExpression)
        case .stdULogicVector(let expression):
            guard let newExpression = Expression(
                expression: expression, stateVariables: stateVariables
            ) else {
                return nil
            }
            self = .stdULogicVector(expression: newExpression)
        case .unsigned(let expression):
            guard let newExpression = Expression(
                expression: expression, stateVariables: stateVariables
            ) else {
                return nil
            }
            self = .unsigned(expression: newExpression)
        }
    }

}

extension ComparisonOperation {

    init?(operation: ComparisonOperation, stateVariables: [VariableName]) {
        switch operation {
        case .equality(let lhs, let rhs):
            guard
                let newLhs = Expression(expression: lhs, stateVariables: stateVariables),
                let newRhs = Expression(expression: rhs, stateVariables: stateVariables)
            else {
                return nil
            }
            self = .equality(lhs: newLhs, rhs: newRhs)
        case .greaterThan(let lhs, let rhs):
            guard
                let newLhs = Expression(expression: lhs, stateVariables: stateVariables),
                let newRhs = Expression(expression: rhs, stateVariables: stateVariables)
            else {
                return nil
            }
            self = .greaterThan(lhs: newLhs, rhs: newRhs)
        }
    }

}

extension ConditionalExpression {

    init(expression: ConditionalExpression, stateVariables: [VariableName]) {
        switch expression {
        case .comparison(value: ComparisonOperation)
        }
    }

}
