// Variable+testConstants.swift
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

// swiftlint:disable force_unwrapping

// swiftlint:disable missing_docs

// swift-format-ignore: AllPublicDeclarationsHaveDocumentation

/// Add test constants.
extension VariableName {

    public static var a: VariableName { VariableName(rawValue: "A")! }

    public static let arrangement1 = VariableName(rawValue: "Arrangement1")!

    public static var clk2: VariableName { VariableName(rawValue: "clk2")! }

    public static let externalPing = VariableName(rawValue: "EXTERNAL_ping")!

    public static let externalPong = VariableName(rawValue: "EXTERNAL_pong")!

    public static var g: VariableName { VariableName(rawValue: "g")! }

    public static var initialX: VariableName { VariableName(rawValue: "initialX")! }

    public static var p: VariableName { VariableName(rawValue: "p")! }

    public static var r: VariableName { VariableName(rawValue: "r")! }

    public static var s: VariableName { VariableName(rawValue: "s")! }

    public static var x: VariableName { VariableName(rawValue: "x")! }

    public static var xx: VariableName { VariableName(rawValue: "xx")! }

    public static var xs: VariableName { VariableName(rawValue: "xs")! }

    public static var y: VariableName { VariableName(rawValue: "y")! }

    public static var z: VariableName { VariableName(rawValue: "z")! }

    public static var s0: VariableName { VariableName(rawValue: "S0")! }

    public static var s1: VariableName { VariableName(rawValue: "S1")! }

    public static var state0: VariableName { VariableName(rawValue: "State0")! }

    public static var parX: VariableName { VariableName(rawValue: "parX")! }

    public static var ping: VariableName { VariableName(rawValue: "ping")! }

    public static var pong: VariableName { VariableName(rawValue: "pong")! }

    public static let pingMachine = VariableName(rawValue: "PingMachine")!

    public static let pongMachine = VariableName(rawValue: "PongMachine")!

    public static var parXs: VariableName { VariableName(rawValue: "parXs")! }

    public static var retX: VariableName { VariableName(rawValue: "retX")! }

    public static var retXs: VariableName { VariableName(rawValue: "retXs")! }

    public static var machineSignal1: VariableName { VariableName(rawValue: "machineSignal1")! }

    public static var machineSignal2: VariableName { VariableName(rawValue: "machineSignal2")! }

    public static let testMachine = VariableName(rawValue: "TestMachine")!

}

// swiftlint:enable missing_docs

// swiftlint:enable force_unwrapping
