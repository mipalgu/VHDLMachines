// ModelConvertible.swift
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
import VHDLMachines
import VHDLParsing

/// Add generic protocol for types that can be converted from other types.
protocol ModelConvertible {

    /// The type to convert from.
    associatedtype Convertible

    /// Initialise Self from a convertible type.
    /// - Parameter convert: The type to convert.
    init?(convert: Convertible)

}

/// Add ``ModelConvertible`` initialiser.
extension Array where Element: ModelConvertible {

    /// Create a new array from an array of ``ModelConvertible`` conforment types.
    /// - Parameter convert: The array to convert.
    init?<T>(convert: [T]) where T == Element.Convertible {
        var others = [Element]()
        for item in convert {
            guard let other = Element(convert: item) else {
                return nil
            }
            others.append(other)
        }
        self = others
    }

}

/// Add ``ModelConvertible`` conformance.
extension Clock: ModelConvertible {

    /// Create a new ``Clock`` from a `LLFSMModel.Variable`.
    /// - Parameter convert: The variable to convert.
    @inlinable
    init?(convert: Variable) {
        self.init(variable: convert)
    }

}

/// Add ``ModelConvertible`` conformance.
extension LocalSignal: ModelConvertible {

    /// Create a new ``LocalSignal`` from a `LLFSMModel.Variable`.
    /// - Parameter convert: The variable to convert.
    @inlinable
    init?(convert: Variable) {
        self.init(variable: convert)
    }

}

/// Add ``ModelConvertible`` conformance.
extension Parameter: ModelConvertible {

    /// Convert a `LLFSMModel.Variable` into a ``Parameter``.
    /// - Parameter convert: The variable to convert.
    @inlinable
    init?(convert: Variable) {
        self.init(parameter: convert)
    }

}

/// Add ``ModelConvertible`` conformance.
extension PortSignal: ModelConvertible {

    /// Convert a `LLFSMModel.ExternalVariable` into a ``PortSignal``.
    /// - Parameter convert: The variable to convert.
    @inlinable
    init?(convert: ExternalVariable) {
        self.init(variable: convert)
    }

}

/// Add ``ModelConvertible`` conformance.
extension ReturnableVariable: ModelConvertible {

    /// Convert an `LLFSMModel.Variable` into a ``ReturnableVariable``.
    /// - Parameter convert: The variable to convert.
    @inlinable
    init?(convert: Variable) {
        self.init(variable: convert)
    }

}
