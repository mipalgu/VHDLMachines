// MachineTests.swift
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
@testable import ModelImports
import TestUtils
import VHDLMachines
import VHDLParsing
import XCTest

/// Test class for ``Machine`` extensions.
final class MachineTests: XCTestCase {

    /// The model to convert.
    let model = LLFSMModel.Machine.testMachine

    /// The expected result.
    var expected = VHDLMachines.Machine.testMachine()

    /// Initialise the expected value before every test.
    override func setUp() {
        expected = VHDLMachines.Machine.testMachine()
        expected.actions = expected.actions.sorted()
        expected.path = URL(
            fileURLWithPath: "\(FileManager().currentDirectoryPath)/\(expected.name.rawValue).machine",
            isDirectory: true
        )
        expected.externalSignals = expected.externalSignals.map {
            PortSignal(
                type: $0.type, name: $0.name, mode: $0.mode, defaultValue: $0.defaultValue, comment: nil
            )
        }
        expected.externalSignals[0].defaultValue = .literal(value: .bit(value: .high))
        expected.machineSignals = expected.machineSignals.map {
            LocalSignal(
                type: $0.type, name: $0.name, defaultValue: $0.defaultValue, comment: nil
            )
        }
        expected.parameterSignals = expected.parameterSignals.map {
            Parameter(
                type: $0.type, name: $0.name, defaultValue: $0.defaultValue, comment: nil
            )
        }
        expected.parameterSignals[0].defaultValue = .literal(value: .bit(value: .high))
        expected.returnableSignals = expected.returnableSignals.map {
            ReturnableVariable(type: $0.type, name: $0.name, comment: nil)
        }
        expected.states = expected.states.map {
            VHDLMachines.State(
                name: $0.name,
                actions: $0.actions,
                signals: $0.signals.map {
                    LocalSignal(type: $0.type, name: $0.name, defaultValue: $0.defaultValue, comment: nil)
                },
                externalVariables: $0.externalVariables
            )
        }
    }

    /// Test that `init(machine:)` converts the model correctly.
    func testInit() {
        guard let newMachine = VHDLMachines.Machine(machine: model) else {
            XCTFail("Failed to create machine!")
            return
        }
        XCTAssertEqual(newMachine, expected)
        expected.parameterSignals = []
        expected.returnableSignals = []
        expected.isParameterised = false
        expected.suspendedState = nil
        XCTAssertEqual(
            VHDLMachines.Machine(machine: LLFSMModel.Machine(
                externalVariables: model.externalVariables,
                globalVariables: model.globalVariables,
                initialState: model.initialState,
                name: model.name,
                parameters: [],
                returnables: [],
                states: model.states,
                suspendedState: nil,
                variables: model.variables
            )),
            expected
        )
    }

    /// Test that `init(machine:)` returns nil for invalid data.
    func testInitFails() {
        XCTAssertNil(VHDLMachines.Machine(machine: LLFSMModel.Machine(
                externalVariables: model.externalVariables,
                globalVariables: model.globalVariables,
                initialState: "NullState",
                name: model.name,
                parameters: model.parameters,
                returnables: model.returnables,
                states: model.states,
                suspendedState: model.suspendedState,
                variables: model.variables
        )))
        XCTAssertNil(VHDLMachines.Machine(machine: LLFSMModel.Machine(
                externalVariables: model.externalVariables,
                globalVariables: model.globalVariables,
                initialState: "Initial",
                name: "",
                parameters: model.parameters,
                returnables: model.returnables,
                states: model.states,
                suspendedState: model.suspendedState,
                variables: model.variables
        )))
        XCTAssertNil(VHDLMachines.Machine(machine: LLFSMModel.Machine(
                externalVariables: model.externalVariables,
                globalVariables: model.globalVariables,
                initialState: model.initialState,
                name: model.name,
                parameters: model.parameters,
                returnables: model.returnables,
                states: model.states,
                suspendedState: "NullState",
                variables: model.variables
        )))
    }

}
