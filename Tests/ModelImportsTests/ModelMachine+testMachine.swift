// ModelMachine+testMachine.swift
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

import LLFSMModel

/// Add test machine.
extension Machine {

    /// A test machine based on the `VHDLMachines.Machine` test machine.
    static let testMachine = Machine(
        externalVariables: [
            ExternalVariable(defaultValue: "'1'", mode: .input, name: "x", type: "std_logic"),
            ExternalVariable(
                defaultValue: "\"00\"", mode: .output, name: "xx", type: "std_logic_vector(1 downto 0)"
            )
        ],
        globalVariables: [
            Variable(name: "clk", type: "{\"frequency\":50,\"unit\":\"MHz\"}"),
            Variable(name: "clk2", type: "{\"frequency\":20,\"unit\":\"kHz\"}")
        ],
        initialState: "Initial",
        name: "TestMachine",
        parameters: [
            Variable(defaultValue: "'1'", name: "parX", type: "std_logic"),
            Variable(defaultValue: "\"01\"", name: "parXs", type: "std_logic_vector(1 downto 0)")
        ],
        returnables: [
            Variable(name: "retX", type: "std_logic"),
            Variable(name: "retXs", type: "std_logic_vector(1 downto 0)")
        ],
        states: [
            State(
                actions: [
                    "OnEntry": "z <= '0';",
                    "OnExit": "x <= '0'; -- Initial OnExit",
                    "OnResume": "x <= '0'; -- Initial OnResume",
                    "OnSuspend": "xx <= \"11\"; -- Initial onSuspend",
                    "Internal": "x <= '1'; -- Initial Internal"
                ],
                externalVariables: ["x", "xx"],
                name: "Initial",
                transitions: [
                    Transition(target: "Suspended", condition: "z = '1'"),
                    Transition(target: "Suspended", condition: "false"),
                    Transition(
                        target: "Suspended", condition: "after_ms(50.0) or after(2.0) or after_rt(20000.0)"
                    ),
                    Transition(target: "Suspended", condition: "true")
                ],
                variables: [
                    Variable(name: "initialX", type: "std_logic"),
                    Variable(name: "z", type: "std_logic")
                ]
            ),
            State(
                actions: [
                    "OnEntry": "x <= '1';\nxx <= \"00\"; -- Suspended onEntry",
                    "OnExit": "x <= '0'; -- Suspended OnExit",
                    "OnResume": "x <= '0'; -- Suspended OnResume",
                    "OnSuspend": "xx <= \"11\"; -- Suspended onSuspend",
                    "Internal": "x <= '1'; -- Suspended Internal"
                ],
                externalVariables: ["x", "xx"],
                name: "Suspended",
                transitions: [
                    Transition(target: "State0", condition: "xx = \"11\""),
                    Transition(target: "State0", condition: "x = '1'"),
                    Transition(target: "Initial", condition: "true")
                ],
                variables: []
            ),
            State(
                actions: [
                    "OnEntry": "x <= '1';\nxx <= \"00\"; -- State0 onEntry",
                    "OnExit": "x <= '0'; -- State0 OnExit",
                    "OnResume": "x <= '0'; -- State0 OnResume",
                    "OnSuspend": "xx <= \"11\"; -- State0 onSuspend",
                    "Internal": "x <= '1'; -- State0 Internal"
                ],
                externalVariables: ["x", "xx"],
                name: "State0",
                transitions: [],
                variables: []
            ),
        ],
        suspendedState: "Suspended",
        variables: [
            Variable(defaultValue: nil, name: "machineSignal1", type: "std_logic"),
            Variable(defaultValue: "\"111\"", name: "machineSignal2", type: "std_logic_vector(2 downto 0)")
        ]
    )

}
