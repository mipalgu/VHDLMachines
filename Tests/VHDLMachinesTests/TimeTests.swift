// TimeTests.swift
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

import Foundation
import Testing
@testable import VHDLMachines

/// Test class for ``Time``.
@Suite
struct TimeTests {

    /// The seconds to test.
    let seconds = Time.seconds(1000)

    /// The milliseconds to test.
    let milliseconds = Time.milliseconds(1000)

    /// The microseconds to test.
    let microseconds = Time.microseconds(1000)

    /// The nanoseconds to test.
    let nanoseconds = Time.nanoseconds(1000)

    /// The picoseconds to test.
    let picoseconds = Time.picoseconds(1000)

    /// Test `seconds` conversion.
    @Test
    func testSeconds() {
        #expect(seconds.seconds == 1000)
        #expect(milliseconds.seconds == 1)
        #expect(microseconds.seconds == 0.001)
        #expect(nanoseconds.seconds == 0.000_001)
        #expect(picoseconds.seconds == 0.000_000_001)
    }

    /// Test `milliseconds` conversion.
    @Test
    func testMilliseconds() {
        #expect(seconds.milliseconds == 1_000_000)
        #expect(milliseconds.milliseconds == 1000)
        #expect(microseconds.milliseconds == 1)
        #expect(nanoseconds.milliseconds == 0.001)
        #expect(picoseconds.milliseconds == 0.000_001)
    }

    /// Test `microseconds` conversion.
    @Test
    func testMicroseconds() {
        #expect(seconds.microseconds == 1_000_000_000)
        #expect(milliseconds.microseconds == 1_000_000)
        #expect(microseconds.microseconds == 1_000)
        #expect(nanoseconds.microseconds == 1)
        #expect(picoseconds.microseconds == 0.001)
    }

    /// Test `nanoseconds` conversion.
    @Test
    func testNanoseconds() {
        #expect(seconds.nanoseconds == 1_000_000_000_000)
        #expect(milliseconds.nanoseconds == 1_000_000_000)
        #expect(microseconds.nanoseconds == 1_000_000)
        #expect(nanoseconds.nanoseconds == 1_000)
        #expect(picoseconds.nanoseconds == 1)
    }

    /// Test `picoseconds` conversion.
    @Test
    func testPicoseconds() {
        #expect(seconds.picoseconds == 1_000_000_000_000_000)
        #expect(milliseconds.picoseconds == 1_000_000_000_000)
        #expect(microseconds.picoseconds == 1_000_000_000)
        #expect(nanoseconds.picoseconds == 1_000_000)
        #expect(picoseconds.picoseconds == 1_000)
    }

    /// Test `Time` is `Comparable`.
    @Test
    func testComparableConformance() {
        #expect(picoseconds < nanoseconds)
        #expect(nanoseconds < microseconds)
        #expect(microseconds < milliseconds)
        #expect(milliseconds < seconds)
    }

    /// Test `Time` is `Codable`.
    @Test
    func testCodableConformance() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        #expect(seconds == (try decoder.decode(Time.self, from: try encoder.encode(seconds))))
        #expect(milliseconds == (try decoder.decode(Time.self, from: try encoder.encode(milliseconds))))
        #expect(microseconds == (try decoder.decode(Time.self, from: try encoder.encode(microseconds))))
        #expect(nanoseconds == (try decoder.decode(Time.self, from: try encoder.encode(nanoseconds))))
        #expect(picoseconds == (try decoder.decode(Time.self, from: try encoder.encode(picoseconds))))
    }

}
