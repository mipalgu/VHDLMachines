// EntityTests.swift
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

import Foundation
@testable import VHDLMachines
import VHDLParsing
import XCTest

/// Test class for `Entity` extension.
final class EntityTests: XCTestCase {

    /// Test machine init.
    func testMachineInit() {
        guard
            var machine = Machine.initial(path: URL(fileURLWithPath: "/tmp/New.machine", isDirectory: false))
        else {
            XCTFail("Failed to create machine.")
            return
        }
        let original = PortSignal(type: .stdLogic, name: .x, mode: .input)
        let signal = PortSignal(type: .stdLogic, name: original.externalName, mode: .input)
        machine.externalSignals = [original]
        guard let entity = Entity(machine: machine) else {
            XCTFail("Failed to create entity from machine.")
            return
        }
        XCTAssertEqual(entity.name, VariableName(rawValue: "New"))
        XCTAssertEqual(
            entity.port, PortBlock(signals: [
                PortSignal(type: .stdLogic, name: .clk, mode: .input),
                signal,
                PortSignal(type: .stdLogic, name: .suspended, mode: .output),
                PortSignal(
                    type: .ranged(type: .stdLogicVector(size: .downto(upper: 1, lower: 0))),
                    name: .command,
                    mode: .input
                )
            ])
        )
    }

    // swiftlint:disable function_body_length
    // swiftlint:disable force_unwrapping

    /// Test machine init when machine is parameterised.
    func testParameterisedMachine() {
        let machine = Machine.testMachine()
        guard let entity = Entity(machine: machine) else {
            XCTFail("Failed to create entity from machine.")
            return
        }
        XCTAssertEqual(entity.name, VariableName(rawValue: "TestMachine"))
        XCTAssertEqual(
            entity.port,
            PortBlock(signals: [
                PortSignal(type: .stdLogic, name: .clk, mode: .input),
                PortSignal(type: .stdLogic, name: .clk2, mode: .input),
                PortSignal(
                    type: .stdLogic,
                    name: VariableName(rawValue: "EXTERNAL_x")!,
                    mode: .input,
                    defaultValue: .literal(value: .bit(value: .high)),
                    comment: Comment(rawValue: "-- A std_logic variable.")!
                ),
                PortSignal(
                    type: .ranged(type: .stdLogicVector(size: .downto(upper: 1, lower: 0))),
                    name: VariableName(rawValue: "EXTERNAL_xx")!,
                    mode: .output,
                    defaultValue: .literal(value: .vector(
                        value: .bits(value: BitVector(values: [.low, .low]))
                    )),
                    comment: Comment(rawValue: "-- A variable called xx.")!
                ),
                PortSignal(
                    type: .stdLogic,
                    name: VariableName(rawValue: "PARAMETER_parX")!,
                    mode: .input,
                    defaultValue: .literal(value: .bit(value: .high)),
                    comment: Comment(rawValue: "-- Parameter parX")!
                ),
                PortSignal(
                    type: .ranged(type: .stdLogicVector(size: .downto(upper: 1, lower: 0))),
                    name: VariableName(rawValue: "PARAMETER_parXs")!,
                    mode: .input,
                    defaultValue: .literal(value: .vector(
                        value: .bits(value: BitVector(values: [.low, .high]))
                    )),
                    comment: Comment(rawValue: "-- Parameter parXs")!
                ),
                PortSignal(
                    type: .stdLogic,
                    name: VariableName(rawValue: "OUTPUT_retX")!,
                    mode: .output,
                    defaultValue: nil,
                    comment: Comment(rawValue: "-- Returnable retX")!
                ),
                PortSignal(
                    type: .ranged(type: .stdLogicVector(size: .downto(upper: 1, lower: 0))),
                    name: VariableName(rawValue: "OUTPUT_retXs")!,
                    mode: .output,
                    defaultValue: nil,
                    comment: Comment(rawValue: "-- Returnable retXs")!
                ),
                PortSignal(
                    type: .stdLogic,
                    name: .suspended,
                    mode: .output,
                    defaultValue: nil,
                    comment: nil
                ),
                PortSignal(
                    type: .ranged(type: .stdLogicVector(size: .downto(upper: 1, lower: 0))),
                    name: .command,
                    mode: .input,
                    defaultValue: nil,
                    comment: nil
                )
            ])
        )
    }

    // swiftlint:enable force_unwrapping
    // swiftlint:enable function_body_length

}
