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

    @usableFromInline
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
            guard let newCase = CaseStatement(statement: block, replacing: variable, with: value) else {
                return nil
            }
            self = .caseStatement(block: newCase)
        case .forLoop(let loop):
            guard let newLoop = ForLoop(loop: loop, replacing: variable, with: value) else {
                return nil
            }
            self = .forLoop(loop: newLoop)
        case .ifStatement(let block):
            guard let newIf = IfBlock(block: block, replacing: variable, with: value) else {
                return nil
            }
            self = .ifStatement(block: newIf)
        case .statement(let statement):
            guard let newStatement = Statement(statement: statement, replacing: variable, with: value) else {
                return nil
            }
            self = .statement(statement: newStatement)
        }
    }

}

extension Machine {

    @usableFromInline
    init?(replacingStateRefsIn machine: Machine) {
        let newStates: [State] = machine.states.compactMap { State(replacingStateVariablesIn: $0) }
        guard newStates.count == machine.states.count else {
            return nil
        }
        self.init(
            actions: machine.actions,
            name: machine.name,
            path: machine.path,
            includes: machine.includes,
            externalSignals: machine.externalSignals,
            clocks: machine.clocks,
            drivingClock: machine.drivingClock,
            dependentMachines: machine.dependentMachines,
            machineSignals: machine.machineSignals,
            isParameterised: machine.isParameterised,
            parameterSignals: machine.parameterSignals,
            returnableSignals: machine.returnableSignals,
            states: newStates,
            transitions: machine.transitions,
            initialState: machine.initialState,
            suspendedState: machine.suspendedState,
            architectureHead: machine.architectureHead,
            architectureBody: machine.architectureBody
        )
    }

}

extension State {

    @usableFromInline
    init?(replacingStateVariablesIn state: State) {
        let newActions: [(VariableName, SynchronousBlock)] = state.actions
        .compactMap { (action: VariableName, code: SynchronousBlock) in
            guard let newCode = state.signals.reduce(Optional.some(code), {
                guard
                    let code = $0,
                    let newName = VariableName(
                        rawValue: "STATE_\(state.name.rawValue)_\($1.name.rawValue)"
                    ),
                    let newCode = SynchronousBlock(block: code, replacing: $1.name, with: newName)
                else {
                    return nil
                }
                return newCode
            }) else {
                return nil
            }
            return (action, newCode)
        }
        guard newActions.count == state.actions.count else {
            return nil
        }
        let newActionsDictionary = Dictionary(uniqueKeysWithValues: newActions)
        self.init(
            name: state.name,
            actions: newActionsDictionary,
            signals: state.signals,
            externalVariables: state.externalVariables
        )
    }

}

extension Statement {

    @usableFromInline
    init?(statement: Statement, replacing variable: VariableName, with value: VariableName) {
        switch statement {
        case .assignment(let name, let expression):
            let newName = VariableReference(reference: name, replacing: variable, with: value)
            guard
                let newExpression = Expression(expression: expression, replacing: variable, with: value)
            else {
                return nil
            }
            self = .assignment(name: newName, value: newExpression)
        case .comment, .null:
            self = statement
        }
    }

}

extension IfBlock {

    @usableFromInline
    init?(block: IfBlock, replacing variable: VariableName, with value: VariableName) {
        switch block {
        case .ifElse(let condition, let ifBlock, let elseBlock):
            guard
                let newCondition = Expression(expression: condition, replacing: variable, with: value),
                let newIfBlock = SynchronousBlock(block: ifBlock, replacing: variable, with: value),
                let newElseBlock = SynchronousBlock(block: elseBlock, replacing: variable, with: value)
            else {
                return nil
            }
            self = .ifElse(condition: newCondition, ifBlock: newIfBlock, elseBlock: newElseBlock)
        case .ifStatement(let condition, let ifBlock):
            guard
                let newCondition = Expression(expression: condition, replacing: variable, with: value),
                let newIfBlock = SynchronousBlock(block: ifBlock, replacing: variable, with: value)
            else {
                return nil
            }
            self = .ifStatement(condition: newCondition, ifBlock: newIfBlock)
        }
    }

}

extension CaseStatement {

    @usableFromInline
    init?(statement: CaseStatement, replacing variable: VariableName, with value: VariableName) {
        let newCases = statement.cases.compactMap {
            WhenCase(whenCase: $0, replacing: variable, with: value)
        }
        guard
            newCases.count == statement.cases.count,
            let condition = Expression(expression: statement.condition, replacing: variable, with: value)
        else {
            return nil
        }
        self.init(condition: condition, cases: newCases)
    }

}

extension ForLoop {

    @usableFromInline
    init?(loop: ForLoop, replacing variable: VariableName, with value: VariableName) {
        guard
            let newRange = VectorSize(size: loop.range, replacing: variable, with: value),
            let newBody = SynchronousBlock(block: loop.body, replacing: variable, with: value)
        else {
            return nil
        }
        self.init(iterator: loop.iterator, range: newRange, body: newBody)
    }

}

extension WhenCase {

    @usableFromInline
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

    @usableFromInline
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

extension Expression {

    @usableFromInline
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
