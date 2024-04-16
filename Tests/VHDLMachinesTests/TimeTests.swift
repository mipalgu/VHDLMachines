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

@testable import VHDLMachines
import XCTest

/// Test class for ``Time``.
final class TimeTests: XCTestCase {

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
    func testSeconds() {
        XCTAssertEqual(seconds.seconds, 1000)
        XCTAssertEqual(milliseconds.seconds, 1)
        XCTAssertEqual(microseconds.seconds, 0.001)
        XCTAssertEqual(nanoseconds.seconds, 0.000_001)
        XCTAssertEqual(picoseconds.seconds, 0.000_000_001)
    }

    /// Test `milliseconds` conversion.
    func testMilliseconds() {
        XCTAssertEqual(seconds.milliseconds, 1_000_000)
        XCTAssertEqual(milliseconds.milliseconds, 1000)
        XCTAssertEqual(microseconds.milliseconds, 1)
        XCTAssertEqual(nanoseconds.milliseconds, 0.001)
        XCTAssertEqual(picoseconds.milliseconds, 0.000_001)
    }

    /// Test `microseconds` conversion.
    func testMicroseconds() {
        XCTAssertEqual(seconds.microseconds, 1_000_000_000)
        XCTAssertEqual(milliseconds.microseconds, 1_000_000)
        XCTAssertEqual(microseconds.microseconds, 1_000)
        XCTAssertEqual(nanoseconds.microseconds, 1)
        XCTAssertEqual(picoseconds.microseconds, 0.001)
    }

    /// Test `nanoseconds` conversion.
    func testNanoseconds() {
        XCTAssertEqual(seconds.nanoseconds, 1_000_000_000_000)
        XCTAssertEqual(milliseconds.nanoseconds, 1_000_000_000)
        XCTAssertEqual(microseconds.nanoseconds, 1_000_000)
        XCTAssertEqual(nanoseconds.nanoseconds, 1_000)
        XCTAssertEqual(picoseconds.nanoseconds, 1)
    }

    /// Test `picoseconds` conversion.
    func testPicoseconds() {
        XCTAssertEqual(seconds.picoseconds, 1_000_000_000_000_000)
        XCTAssertEqual(milliseconds.picoseconds, 1_000_000_000_000)
        XCTAssertEqual(microseconds.picoseconds, 1_000_000_000)
        XCTAssertEqual(nanoseconds.picoseconds, 1_000_000)
        XCTAssertEqual(picoseconds.picoseconds, 1_000)
    }

    /// Test `Time` is `Comparable`.
    func testComparableConformance() {
        XCTAssertLessThan(picoseconds, nanoseconds)
        XCTAssertLessThan(nanoseconds, microseconds)
        XCTAssertLessThan(microseconds, milliseconds)
        XCTAssertLessThan(milliseconds, seconds)
    }

}
