// VariableName.swift
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
// General License as published by the Free Software Foundation;
// either version 2 of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General License for more details.
//
// You should have received a copy of the GNU General License
// along with this program; if not, see http://www.gnu.org/licenses/
// or write to the Free Software Foundation, Inc., 51 Franklin Street,
// Fifth Floor, Boston, MA  02110-1301, USA.
//

import Foundation
import VHDLParsing

/// Add common names from machine generation.
extension VariableName {

    // swiftlint:disable force_unwrapping

    /// The `Behavioral` variable.
    @usableFromInline static let behavioral = VariableName(rawValue: "Behavioral")!

    /// The `clk` variable.
    @usableFromInline static let clk = VariableName(rawValue: "clk")!

    /// The clock period.
    @usableFromInline static let clockPeriod = VariableName(rawValue: "clockPeriod")!

    /// The initial state name.
    @usableFromInline static let initial = VariableName(rawValue: "Initial")!

    /// The suspended state name.
    @usableFromInline static let suspendedState = VariableName(rawValue: "Suspended")!

    /// The ringlet length variable.
    @usableFromInline static let ringletLength = VariableName(rawValue: "ringletLength")!

    /// The ringlets per ps constant.
    @usableFromInline static let ringletPerPs = VariableName(rawValue: "RINGLETS_PER_PS")!

    /// The ringlets per ns constant.
    @usableFromInline static let ringletPerNs = VariableName(rawValue: "RINGLETS_PER_NS")!

    /// The ringlets per us constant.
    @usableFromInline static let ringletPerUs = VariableName(rawValue: "RINGLETS_PER_US")!

    /// The ringlets per ms constant.
    @usableFromInline static let ringletPerMs = VariableName(rawValue: "RINGLETS_PER_MS")!

    /// The ringlets per s constant.
    @usableFromInline static let ringletPerS = VariableName(rawValue: "RINGLETS_PER_S")!

    /// The ringlet counter variable.
    @usableFromInline static let ringletCounter = VariableName(rawValue: "ringlet_counter")!

    /// The suspended flag.
    @usableFromInline static let suspended = VariableName(rawValue: "suspended")!

    /// The command signal.
    @usableFromInline static let command = VariableName(rawValue: "command")!

    /// The current state variable.
    @usableFromInline static let currentState = VariableName(rawValue: "currentState")!

    /// The target state variable.
    @usableFromInline static let targetState = VariableName(rawValue: "targetState")!

    /// The previous state variable.
    @usableFromInline static let previousRinglet = VariableName(rawValue: "previousRinglet")!

    /// The suspended from variable.
    @usableFromInline static let suspendedFrom = VariableName(rawValue: "suspendedFrom")!

    /// The internal state variable.
    @usableFromInline static let internalState = VariableName(rawValue: "internalState")!

    /// The read snapshot constant.
    @usableFromInline static let readSnapshot = VariableName(rawValue: "ReadSnapshot")!

    /// The write snapshot constant.
    @usableFromInline static let writeSnapshot = VariableName(rawValue: "WriteSnapshot")!

    /// The check transition constant.
    @usableFromInline static let checkTransition = VariableName(rawValue: "CheckTransition")!

    /// The no on entry constant.
    @usableFromInline static let noOnEntry = VariableName(rawValue: "NoOnEntry")!

    /// The on entry constant.
    @usableFromInline static let onEntry = VariableName(rawValue: "OnEntry")!

    /// The on exit constant.
    @usableFromInline static let onExit = VariableName(rawValue: "OnExit")!

    /// The on resume constant.
    @usableFromInline static let onResume = VariableName(rawValue: "OnResume")!

    /// The on suspend constant.
    @usableFromInline static let onSuspend = VariableName(rawValue: "OnSuspend")!

    /// The internal constant.
    @usableFromInline static let `internal` = VariableName(rawValue: "Internal")!

    /// The null command constant.
    @usableFromInline static let nullCommand = VariableName(rawValue: "COMMAND_NULL")!

    /// The restart command constant.
    @usableFromInline static let restartCommand = VariableName(rawValue: "COMMAND_RESTART")!

    /// The resume command constant.
    @usableFromInline static let resumeCommand = VariableName(rawValue: "COMMAND_RESUME")!

    /// The suspend command constant.
    @usableFromInline static let suspendCommand = VariableName(rawValue: "COMMAND_SUSPEND")!

    /// The name for the given states constant bit representation.
    /// - Parameter state: The state to get the name for.
    /// - Returns: The name of the constant bit representation for this state.
    @inlinable
    public static func name(for state: State) -> VariableName {
        VariableName(rawValue: "STATE_\(state.name.rawValue)")!
    }

    /// The name for an external variable.
    /// - Parameter external: The port signal to convert to an external variable.
    /// - Returns: The external variables name.
    @inlinable
    public static func name(for external: PortSignal) -> VariableName {
        VariableName(rawValue: "EXTERNAL_\(external.name.rawValue)")!
    }

    /// The name for a parameter.
    /// - Parameter parameter: The parameter to get the name for.
    /// - Returns: The name of the parameter.
    @inlinable
    public static func name(for parameter: Parameter) -> VariableName {
        VariableName(rawValue: "PARAMETER_\(parameter.name.rawValue)")!
    }

    /// The name for a returnable variable.
    /// - Parameter returnable: The returnable variable to get the name for.
    /// - Returns: The name of the returnable variable.
    @inlinable
    public static func name(for returnable: ReturnableVariable) -> VariableName {
        VariableName(rawValue: "OUTPUT_\(returnable.name.rawValue)")!
    }

    // swiftlint:enable force_unwrapping

}
