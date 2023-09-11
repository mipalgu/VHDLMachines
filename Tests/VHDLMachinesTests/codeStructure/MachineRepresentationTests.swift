// MachineRepresentationTests.swift
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

@testable import VHDLMachines
import VHDLParsing
import XCTest

/// Test class for ``MachineRepresentation``.
final class MachineRepresentationTests: XCTestCase {

    /// Test the machine initialiser creates the stored properties correctly.
    func testMachineInit() {
        let machine = Machine.testMachine()
        let representation = MachineRepresentation(machine: machine)
        guard
            let newMachine = Machine(replacingStateRefsIn: machine),
            let entity = Entity(machine: newMachine),
            let name = VariableName(rawValue: "Behavioral"),
            let head = ArchitectureHead(machine: newMachine),
            let body = AsynchronousBlock(machine: newMachine)
        else {
            XCTFail("Invalid data.")
            return
        }
        XCTAssertEqual(representation?.entity, entity)
        XCTAssertEqual(representation?.architectureName, name)
        XCTAssertEqual(representation?.architectureHead, head)
        XCTAssertEqual(representation?.architectureBody, body)
        XCTAssertEqual(representation?.machine, newMachine)
        XCTAssertEqual(representation?.includes, newMachine.includes)
    }

    /// Test that duplicate variables in machine return nil.
    func testDuplicateVariablesReturnsNil() {
        var machine = Machine.testMachine()
        machine.externalSignals += [PortSignal(type: .stdLogic, name: .x, mode: .input)]
        machine.machineSignals += [LocalSignal(type: .stdLogic, name: .x)]
        XCTAssertNil(MachineRepresentation(machine: machine))
        machine = Machine.testMachine()
        guard let var1 = VariableName(rawValue: "duplicateVar") else {
            XCTFail("Failed to create test variables.")
            return
        }
        machine.states[0].signals = [LocalSignal(type: .stdLogic, name: var1)]
        machine.states[1].signals = [LocalSignal(type: .stdLogic, name: var1)]
        let representation = MachineRepresentation(machine: machine)
        XCTAssertNotNil(representation)
        representation?.architectureBody.rawValue.components(separatedBy: .newlines).forEach {
            print($0)
        }
        machine.machineSignals += [LocalSignal(type: .stdLogic, name: var1)]
        XCTAssertNil(MachineRepresentation(machine: machine))
    }

}
