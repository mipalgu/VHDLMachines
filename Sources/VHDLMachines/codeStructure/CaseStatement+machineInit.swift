// CaseStatement+machineInit.swift
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

/// Add init for default machine format.
extension CaseStatement {

    /// Create the case statement for the actions in a machine.
    /// - Parameter machine: The machine to create the case statement from.
    init?(machine: Machine) {
        var actions =
            (machine.actions + [
                VariableName.noOnEntry,
                VariableName.readSnapshot,
                VariableName.writeSnapshot,
                VariableName.checkTransition,
            ])
            .sorted()
        if !machine.isSuspensible {
            actions = actions.filter { $0 != VariableName.onResume && $0 != VariableName.onSuspend }
        }
        let cases = actions.compactMap { WhenCase(machine: machine, action: $0) }
        guard cases.count == actions.count else {
            return nil
        }
        self.init(
            condition: .reference(variable: .variable(reference: .variable(name: .internalState))),
            cases: cases + [.othersNull]
        )
    }

    /// Create the code that selectively takes snapshots of external variables.
    ///
    /// This statement creates snapshots based on the current state the machine is in. The snapshots
    /// that are selected are based on the ``State.externalVariables`` property.
    /// - Parameter machine: The machine to create the case-statement for.
    init?(readSnapshotsFor machine: Machine) {
        let variables = Set(machine.externalSignals.filter { $0.mode != .output }.map(\.name))
        let states = machine.states.filter {
            $0.externalVariables.contains { variable in variables.contains(variable) }
        }
        let cases: [WhenCase] = states.compactMap {
            let snapshots = $0.externalVariables.filter { variable in variables.contains(variable) }
            let statements: [SynchronousBlock] = snapshots.compactMap {
                guard let externalName = VariableName(rawValue: "EXTERNAL_\($0.rawValue)") else {
                    return nil
                }
                return SynchronousBlock.statement(
                    statement: .assignment(
                        name: .variable(reference: .variable(name: $0)),
                        value: .reference(variable: .variable(reference: .variable(name: externalName)))
                    )
                )
            }
            guard statements.count == snapshots.count else {
                return nil
            }
            let condition = WhenCondition.expression(
                expression: .reference(variable: .variable(reference: .variable(name: .name(for: $0))))
            )
            guard statements.count != 1 else {
                return WhenCase(condition: condition, code: statements[0])
            }
            return WhenCase(condition: condition, code: .blocks(blocks: statements))
        }
        guard cases.count == states.count else {
            return nil
        }
        self.init(
            condition: .reference(variable: .variable(reference: .variable(name: .currentState))),
            cases: cases + [.othersNull]
        )
    }

    /// Create the code that selectively writes snapshots of external variables.
    ///
    /// This statement creates snapshots based on the current state the machine is in. The snapshots
    /// that are selected are based on the ``State.externalVariables`` property.
    /// - Parameter machine: The machine to create the case-statement for.
    init?(writeSnapshotsFor machine: Machine) {
        let variables = Set(machine.externalSignals.filter { $0.mode != .input }.map(\.name))
        let states = machine.states.filter {
            $0.externalVariables.contains { variable in variables.contains(variable) }
        }
        let cases: [WhenCase] = states.compactMap {
            let snapshots = $0.externalVariables.filter { variable in variables.contains(variable) }
            let statements: [SynchronousBlock] = snapshots.compactMap {
                guard let externalName = VariableName(rawValue: "EXTERNAL_\($0.rawValue)") else {
                    return nil
                }
                return SynchronousBlock.statement(
                    statement: .assignment(
                        name: .variable(reference: .variable(name: externalName)),
                        value: .reference(variable: .variable(reference: .variable(name: $0)))
                    )
                )
            }
            guard statements.count == snapshots.count else {
                return nil
            }
            let condition = WhenCondition.expression(
                expression: .reference(variable: .variable(reference: .variable(name: .name(for: $0))))
            )
            guard statements.count != 1 else {
                return WhenCase(condition: condition, code: statements[0])
            }
            return WhenCase(condition: condition, code: .blocks(blocks: statements))
        }
        guard cases.count == states.count else {
            return nil
        }
        self.init(
            condition: .reference(variable: .variable(reference: .variable(name: .currentState))),
            cases: cases + [.othersNull]
        )
    }

}
