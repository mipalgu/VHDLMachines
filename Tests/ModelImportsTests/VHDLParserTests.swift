// VHDLParserTests.swift
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
#if os(Linux)
import IO
#endif
import LLFSMModel
@testable import ModelImports
import TestUtils
import VHDLMachines
import XCTest

/// Test class for ``VHDLParser`` extensions.
final class VHDLParserTests: XCTestCase {

    /// The machines folder in this test target.
    let machinesFolder = URL(
        fileURLWithPath: String(PingPongArrangement().packageRootPath) + "/Tests/ModelImportsTests/machines",
        isDirectory: true
    )

    /// A parser under test.
    let parser = VHDLParser()

    /// Test parser correctly constructs machine from model file.
    func testParser() throws {
        let model = LLFSMModel.Machine(
            externalVariables: [
                ExternalVariable(mode: .output, name: "ping", type: "std_logic"),
                ExternalVariable(mode: .input, name: "pong", type: "std_logic")
            ],
            globalVariables: [Variable(name: "clk", type: "{\"frequency\":50,\"unit\":\"MHz\"}")],
            initialState: "Ping",
            name: "PingMachine",
            parameters: [],
            returnables: [],
            states: [
                LLFSMModel.State(
                    actions: ["OnExit": "ping <= '1';"],
                    externalVariables: ["ping", "pong"],
                    name: "Ping",
                    transitions: [
                        LLFSMModel.Transition(target: "Check", condition: "true")
                    ],
                    variables: []
                ),
                LLFSMModel.State(
                    actions: ["OnExit": "ping <= '0';"],
                    externalVariables: ["ping", "pong"],
                    name: "Check",
                    transitions: [
                        LLFSMModel.Transition(target: "Ping", condition: "pong = '1'")
                    ],
                    variables: []
                )
            ],
            variables: []
        )
        guard let expectedMachine = VHDLMachines.Machine(machine: model) else {
            XCTFail("Failed to convert machine!")
            return
        }
        XCTAssertNotNil(expectedMachine)
        let encoder = JSONEncoder()
        let data = try encoder.encode(model)
        let decoder = JSONDecoder()
        let newModel = try decoder.decode(LLFSMModel.Machine.self, from: data)
        guard let decodedMachine = VHDLMachines.Machine(machine: newModel) else {
            XCTFail("failed to decode machine!")
            return
        }
        XCTAssertEqual(model, newModel)
        XCTAssertEqual(expectedMachine, decodedMachine)
        let wrapper = FileWrapper(regularFileWithContents: data)
        // print(String(data: data, encoding: .utf8) ?? "Invalid Data")
        let machine = parser.parseModel(model: wrapper)
        XCTAssertEqual(machine, expectedMachine)
    }

    /// Test parser returns nil for invalid model.
    func testInvalidModel() {
        guard let model = "{}".data(using: .utf8) else {
            XCTFail("Failed to create model!")
            return
        }
        let wrapper = FileWrapper(regularFileWithContents: model)
        XCTAssertNil(parser.parseModel(model: wrapper))
    }

}
