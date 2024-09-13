// CastOperation+replaceInit.swift
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

import VHDLParsing

/// Add replace initialiser.
extension CastOperation {

    // swiftlint:disable function_body_length
    // swiftlint:disable cyclomatic_complexity

    /// Replace all occurances of `variable` in `operation` with a new `value`.
    /// - Parameters:
    ///   - operation: The operation containing the `variable`'s to replace.
    ///   - variable: The variable to replace.
    ///   - value: The new value to replace the `variable` with.
    @inlinable
    init?(operation: CastOperation, replacing variable: VariableName, with value: VariableName) {
        switch operation {
        case .bit(let expression):
            guard
                let newExpression = Expression(
                    expression: expression,
                    replacing: variable,
                    with: value
                )
            else {
                return nil
            }
            self = .bit(expression: newExpression)
        case .bitVector(let expression):
            guard
                let newExpression = Expression(
                    expression: expression,
                    replacing: variable,
                    with: value
                )
            else {
                return nil
            }
            self = .bitVector(expression: newExpression)
        case .boolean(let expression):
            guard
                let newExpression = Expression(
                    expression: expression,
                    replacing: variable,
                    with: value
                )
            else {
                return nil
            }
            self = .boolean(expression: newExpression)
        case .integer(let expression):
            guard
                let newExpression = Expression(
                    expression: expression,
                    replacing: variable,
                    with: value
                )
            else {
                return nil
            }
            self = .integer(expression: newExpression)
        case .natural(let expression):
            guard
                let newExpression = Expression(
                    expression: expression,
                    replacing: variable,
                    with: value
                )
            else {
                return nil
            }
            self = .natural(expression: newExpression)
        case .positive(let expression):
            guard
                let newExpression = Expression(
                    expression: expression,
                    replacing: variable,
                    with: value
                )
            else {
                return nil
            }
            self = .positive(expression: newExpression)
        case .real(let expression):
            guard
                let newExpression = Expression(
                    expression: expression,
                    replacing: variable,
                    with: value
                )
            else {
                return nil
            }
            self = .real(expression: newExpression)
        case .signed(let expression):
            guard
                let newExpression = Expression(
                    expression: expression,
                    replacing: variable,
                    with: value
                )
            else {
                return nil
            }
            self = .signed(expression: newExpression)
        case .stdLogic(let expression):
            guard
                let newExpression = Expression(
                    expression: expression,
                    replacing: variable,
                    with: value
                )
            else {
                return nil
            }
            self = .stdLogic(expression: newExpression)
        case .stdLogicVector(let expression):
            guard
                let newExpression = Expression(
                    expression: expression,
                    replacing: variable,
                    with: value
                )
            else {
                return nil
            }
            self = .stdLogicVector(expression: newExpression)
        case .stdULogic(let expression):
            guard
                let newExpression = Expression(
                    expression: expression,
                    replacing: variable,
                    with: value
                )
            else {
                return nil
            }
            self = .stdULogic(expression: newExpression)
        case .stdULogicVector(let expression):
            guard
                let newExpression = Expression(
                    expression: expression,
                    replacing: variable,
                    with: value
                )
            else {
                return nil
            }
            self = .stdULogicVector(expression: newExpression)
        case .unsigned(let expression):
            guard
                let newExpression = Expression(
                    expression: expression,
                    replacing: variable,
                    with: value
                )
            else {
                return nil
            }
            self = .unsigned(expression: newExpression)
        }
    }

    // swiftlint:enable cyclomatic_complexity
    // swiftlint:enable function_body_length

}
