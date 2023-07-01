// Machine+machineInit.swift
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

import Foundation
import LLFSMModel
import VHDLMachines
import VHDLParsing

extension VHDLMachines.Machine {

    public init?(machine: LLFSMModel.Machine) {
        guard
            let name = VariableName(rawValue: machine.name),
            let initialStateName = VariableName(rawValue: machine.initialState),
            let externalVariables = [PortSignal](convert: machine.externalVariables),
            let machineVariables = [LocalSignal](convert: machine.variables),
            let clocks = [Clock](convert: machine.globalVariables),
            !clocks.isEmpty,
            let parameters = [Parameter](convert: machine.parameters),
            let returnables = [ReturnableVariable](convert: machine.returnables)
        else {
            return nil
        }
        let states = machine.states.compactMap {
            VHDLMachines.State(state: $0, externalVariables: externalVariables)
        }
        guard
            states.count == machine.states.count,
            let initialStateIndex = states.firstIndex(where: { $0.name == initialStateName }),
            let transitions = [VHDLMachines.Transition](states: states, machine: machine)
        else {
            return nil
        }
        let suspendedState: Int?
        if let suspendedStateRaw = machine.suspendedState {
            guard let suspendedStateIndex = Int(state: suspendedStateRaw, states: states) else {
                return nil
            }
            suspendedState = suspendedStateIndex
        } else {
            suspendedState = nil
        }
        let allActions = states.reduce(into: Set<ActionName>()) { $0.formUnion($1.actions.keys) }.sorted()
        self.init(
            actions: allActions,
            name: name,
            path: URL(
                fileURLWithPath: "\(FileManager().currentDirectoryPath)/\(name).machine", isDirectory: true
            ),
            includes: [
                .library(value: "IEEE"),
                .include(value: "IEEE.std_logic_1164.ALL"),
                .include(value: "IEEE.math_real.ALL")
            ],
            externalSignals: externalVariables,
            clocks: clocks,
            drivingClock: 0,
            dependentMachines: [:],
            machineSignals: machineVariables,
            isParameterised: (!parameters.isEmpty || !returnables.isEmpty) && suspendedState != nil,
            parameterSignals: parameters,
            returnableSignals: returnables,
            states: states,
            transitions: transitions,
            initialState: initialStateIndex,
            suspendedState: suspendedState
        )
    }

}

/// Add `numberOfTransitions` to `LLFSMModel.Machine`.
extension LLFSMModel.Machine {

    /// The total number of transitions in the machine.
    @inlinable public var numberOfTransitions: Int {
        self.states.reduce(0) {
            $0 + $1.transitions.count
        }
    }

}

/// Add init to find index in states array.
extension Int {

    /// Find the index of a state in an array of states.
    /// - Parameters:
    ///   - state: The name of the state to find.
    ///   - states: The array containing the state.
    @inlinable
    init?(state: String, states: [VHDLMachines.State]) {
        guard
            let name = VariableName(rawValue: state),
            let index = states.firstIndex(where: { $0.name == name })
        else {
            return nil
        }
        self = index
    }

}

/// Add initialiser to create transitions array.
extension Array where Element == VHDLMachines.Transition {

    /// Create an array of `VHDLMachines.Transition` from an `LLFSMModel.Machine`.
    /// - Parameters:
    ///   - states: The converted states from the `machine`.
    ///   - machine: The machine to dervice the transitions from.
    @inlinable
    init?(states: [VHDLMachines.State], machine: LLFSMModel.Machine) {
        let transitions = machine.states.flatMap { state in
            state.transitions.compactMap {
                VHDLMachines.Transition(transition: $0, source: state.name, states: states)
            }
        }
        guard transitions.count == machine.numberOfTransitions else {
            return nil
        }
        self = transitions
    }

}
