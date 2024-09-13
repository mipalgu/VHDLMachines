// Time.swift
// VHDLMachines
//
// Created by Morgan McColl.
// Copyright © 2024 Morgan McColl. All rights reserved.
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

/// A type that represents a time value.
public enum Time: Equatable, Hashable, Codable, Sendable, Comparable {

    /// The value is represented in `seconds`.
    case seconds(_ value: Double)

    /// The value is represented in `milliseconds`.
    case milliseconds(_ value: Double)

    /// The value is represented in `microseconds`.
    case microseconds(_ value: Double)

    /// The value is represented in `nanoseconds`.
    case nanoseconds(_ value: Double)

    /// The value is represented in `picoseconds`.
    case picoseconds(_ value: Double)

    /// The value in seconds.
    @inlinable public var seconds: Double {
        switch self {
        case .seconds(let value):
            return value
        case .milliseconds(let value):
            return value / 1_000
        case .microseconds(let value):
            return value / 1_000_000
        case .nanoseconds(let value):
            return value / 1_000_000_000
        case .picoseconds(let value):
            return value / 1_000_000_000_000
        }
    }

    /// The value in milliseconds.
    @inlinable public var milliseconds: Double {
        switch self {
        case .seconds(let value):
            return value * 1_000
        case .milliseconds(let value):
            return value
        case .microseconds(let value):
            return value / 1_000
        case .nanoseconds(let value):
            return value / 1_000_000
        case .picoseconds(let value):
            return value / 1_000_000_000
        }
    }

    /// The value in microseconds.
    @inlinable public var microseconds: Double {
        switch self {
        case .seconds(let value):
            return value * 1_000_000
        case .milliseconds(let value):
            return value * 1_000
        case .microseconds(let value):
            return value
        case .nanoseconds(let value):
            return value / 1_000
        case .picoseconds(let value):
            return value / 1_000_000
        }
    }

    /// The value in nanoseconds.
    @inlinable public var nanoseconds: Double {
        switch self {
        case .seconds(let value):
            return value * 1_000_000_000
        case .milliseconds(let value):
            return value * 1_000_000
        case .microseconds(let value):
            return value * 1_000
        case .nanoseconds(let value):
            return value
        case .picoseconds(let value):
            return value / 1_000
        }
    }

    /// The value in picoseconds.
    @inlinable public var picoseconds: Double {
        switch self {
        case .seconds(let value):
            return value * 1_000_000_000_000
        case .milliseconds(let value):
            return value * 1_000_000_000
        case .microseconds(let value):
            return value * 1_000_000
        case .nanoseconds(let value):
            return value * 1_000
        case .picoseconds(let value):
            return value
        }
    }

    /// Compares 2 time values.
    @inlinable
    public static func < (lhs: Time, rhs: Time) -> Bool {
        lhs.picoseconds < rhs.picoseconds
    }

}
