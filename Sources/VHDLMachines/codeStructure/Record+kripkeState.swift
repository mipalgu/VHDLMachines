// Record+kripkeState.swift
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

extension Record {

    public init?(readKripke state: State, machine: Machine) {
        guard
            let name = VariableName(
                rawValue: "\(machine.name.rawValue)_\(VariableName.name(for: state).rawValue)_Read"
            ),
            let stateIndex = machine.states.firstIndex(of: state)
        else {
            return nil
        }
        let stateSignals = Set(state.externalVariables)
        let externals = machine.externalSignals.filter { stateSignals.contains($0.name) }
        guard externals.count == stateSignals.count else {
            return nil
        }
        let readExternals = externals.filter { $0.mode != .output }
        let externalTypes = readExternals.map {
            RecordTypeDeclaration(name: .name(for: $0), type: .signal(type: $0.type))
        }
        let machineTypes = machine.machineSignals.map {
            RecordTypeDeclaration(name: $0.name, type: $0.type)
        }
        let stateTypes = state.signals.map {
            RecordTypeDeclaration(name: $0.name, type: $0.type)
        }
        var allDeclarations = externalTypes + machineTypes + stateTypes
        let stateTransitions = machine.transitions.filter { $0.source == stateIndex }
        if stateTransitions.contains(where: { $0.condition.hasAfter }) {
            allDeclarations += [RecordTypeDeclaration(name: .ringletCounter, type: .signal(type: .natural))]
        }
        if machine.isParameterised, machine.states[machine.initialState] == state {
            allDeclarations += machine.parameterSignals.map {
                RecordTypeDeclaration(name: $0.name, type: .signal(type: $0.type))
            }
        }
        guard
            machine.isSuspensible,
            let suspendedState = machine.suspendedState,
            machine.states[suspendedState] == state
        else {
            self.init(name: name, types: allDeclarations)
            return
        }
        guard let bitsRequired = BitLiteral.bitsRequired(for: machine.states.count - 1) else {
            return nil
        }
        allDeclarations += [
            RecordTypeDeclaration(
                name: .suspendedFrom,
                type: .signal(type: .ranged(type: .stdLogicVector(size: .downto(
                    upper: .literal(value: .integer(value: bitsRequired - 1)),
                    lower: .literal(value: .integer(value: 0))
                ))))
            )
        ]
        self.init(name: name, types: allDeclarations)
    }

    public init?(writeKripke state: State, machine: Machine) {
        guard
            let name = VariableName(
                rawValue: "\(machine.name.rawValue)_\(VariableName.name(for: state).rawValue)_Read"
            ),
            let stateIndex = machine.states.firstIndex(of: state)
        else {
            return nil
        }
        let stateSignals = Set(state.externalVariables)
        let externals = machine.externalSignals.filter { stateSignals.contains($0.name) }
        guard externals.count == stateSignals.count else {
            return nil
        }
        let writeExternals = externals.filter { $0.mode != .input }
        let externalTypes = writeExternals.map {
            RecordTypeDeclaration(name: .name(for: $0), type: .signal(type: $0.type))
        }
        let machineTypes = machine.machineSignals.map {
            RecordTypeDeclaration(name: $0.name, type: $0.type)
        }
        let stateTypes = state.signals.map {
            RecordTypeDeclaration(name: $0.name, type: $0.type)
        }
        var allDeclarations = externalTypes + machineTypes + stateTypes
        let stateTransitions = machine.transitions.filter { $0.source == stateIndex }
        if stateTransitions.contains(where: { $0.condition.hasAfter }) {
            allDeclarations += [RecordTypeDeclaration(name: .ringletCounter, type: .signal(type: .natural))]
        }
        guard
            machine.isSuspensible,
            let suspendedState = machine.suspendedState,
            machine.states[suspendedState] == state
        else {
            self.init(name: name, types: allDeclarations)
            return
        }
        guard let bitsRequired = BitLiteral.bitsRequired(for: machine.states.count - 1) else {
            return nil
        }
        allDeclarations += [
            RecordTypeDeclaration(
                name: .suspendedFrom,
                type: .signal(type: .ranged(type: .stdLogicVector(size: .downto(
                    upper: .literal(value: .integer(value: bitsRequired - 1)),
                    lower: .literal(value: .integer(value: 0))
                ))))
            )
        ]
        guard machine.isParameterised else {
            self.init(name: name, types: allDeclarations)
            return
        }
        let returnables = machine.returnableSignals.map {
            RecordTypeDeclaration(name: $0.name, type: .signal(type: $0.type))
        }
        self.init(name: name, types: allDeclarations + returnables)
    }

}
