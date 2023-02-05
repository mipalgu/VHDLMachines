// MachineSignalTests.swift
// Machines
// 
// Created by Morgan McColl.
// Copyright © 2022 Morgan McColl. All rights reserved.
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

/// Tests the `LocalSignal` extensions.
final class LocalSignalTests: XCTestCase {

    /// Test the state trackers are generated correctly for a machine.
    func testStateTrackers() {
        let machine = Machine.testMachine()
        let trackers = LocalSignal.stateTrackers(machine: machine)
        let states = machine.states
        guard
            states.count == 3,
            let index = machine.suspendedState,
            index >= 0,
            index < 3,
            machine.initialState >= 0,
            machine.initialState < 3
        else {
            XCTFail("Failed to create trackers.")
            return
        }
        let initialState = states[machine.initialState]
        let suspendedState = states[index]
        let type = SignalType.ranged(type: .stdLogicVector(size: .downto(upper: 1, lower: 0)))
        XCTAssertEqual(
            trackers,
            [
                LocalSignal(
                    type: type,
                    name: .currentState,
                    defaultValue: .variable(name: VariableName.name(for: suspendedState)),
                    comment: nil
                ),
                LocalSignal(
                    type: type,
                    name: .targetState,
                    defaultValue: .variable(name: VariableName.name(for: suspendedState)),
                    comment: nil
                ),
                LocalSignal(
                    type: type,
                    name: .previousRinglet,
                    defaultValue: .literal(value: .vector(
                        value: .logics(value: LogicVector(values: [.highImpedance, .highImpedance]))
                    )),
                    comment: nil
                ),
                LocalSignal(
                    type: type,
                    name: .suspendedFrom,
                    defaultValue: .variable(name: VariableName.name(for: initialState)),
                    comment: nil
                )
            ]
        )
    }

    /// Test snapshot is created correctly.
    func testPortInit() {
        let external = PortSignal(type: .stdLogic, name: .x, mode: .input)
        let result = LocalSignal(snapshot: external)
        XCTAssertEqual(result, LocalSignal(type: .stdLogic, name: .x, defaultValue: nil, comment: nil))
    }

}
