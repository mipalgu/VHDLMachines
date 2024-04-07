// ArrangementRepresentationTests.swift
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
import TestUtils
@testable import VHDLMachines
import VHDLParsing
import XCTest

/// Test class for ``ArrangementRepresentation``.
final class ArrangementRepresentationTests: XCTestCase {

    /// A test arrangement
    let arrangement = Arrangement.testArrangement

    /// The architecture of `arrangement`.
    var architecture: Architecture {
        // swiftlint:disable force_unwrapping
        Architecture(
            arrangement: arrangement, machines: machinesDictionary, name: .arrangement1
        )!
        // swiftlint:enable force_unwrapping
    }

    /// The entity of the arrangement.
    var entity: Entity {
        // swiftlint:disable:next force_unwrapping
        Entity(arrangement: arrangement, name: .arrangement1)!
    }

    /// The expected representation.
    var expected: ArrangementRepresentation {
        ArrangementRepresentation(
            name: .arrangement1,
            arrangement: arrangement,
            machines: machines,
            entity: entity,
            architecture: architecture,
            includes: includes
        )
    }

    // swiftlint:disable force_unwrapping

    /// The includes in the representation.
    var includes: [Include] {
        [
            .library(value: VariableName(rawValue: "IEEE")!),
            .include(statement: UseStatement(rawValue: "use IEEE.std_logic_1164.all;")!),
            .include(statement: UseStatement(rawValue: "use IEEE.math_real.all;")!)
        ]
    }

    // swiftlint:enable force_unwrapping

    /// An array of machine representations.
    var machines: [MachineRepresentation] {
        arrangement.machines.sorted { $0.key.name < $1.key.name }.compactMap {
            MachineRepresentation(machine: $0.value.machine, name: $0.key.type)
        }
    }

    /// A dictionary of `machines`.
    var machinesDictionary: [VariableName: MachineRepresentation] {
        Dictionary(uniqueKeysWithValues: machines.map {
            ($0.entity.name, $0)
        })
    }

    /// The representation of `arrangement`.
    var representation: ArrangementRepresentation {
        // swiftlint:disable:next force_unwrapping
        ArrangementRepresentation(arrangement: arrangement, name: .arrangement1)!
    }

    /// Test arrangement.
    func testArrangement() {
        XCTAssertEqual(representation.architecture, expected.architecture)
        XCTAssertEqual(representation.entity, expected.entity)
        XCTAssertEqual(representation.includes, expected.includes)
        XCTAssertEqual(representation.machines as? [MachineRepresentation], machines)
        XCTAssertEqual(representation.name, expected.name)
        XCTAssertEqual(representation.arrangement, expected.arrangement)
    }

    /// Test property init sets stored-properties correctly.
    func testPropertyInit() {
        XCTAssertEqual(expected.name, .arrangement1)
        XCTAssertEqual(expected.arrangement, arrangement)
        XCTAssertEqual(expected.machines as? [MachineRepresentation], machines)
        XCTAssertEqual(expected.architecture, architecture)
        XCTAssertEqual(expected.entity, entity)
        XCTAssertEqual(expected.includes, includes)
    }

}
