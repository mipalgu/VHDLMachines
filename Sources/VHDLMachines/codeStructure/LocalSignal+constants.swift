//
//  File.swift
//
//
//  Created by Morgan McColl on 14/4/21.
//

import Foundation
import VHDLParsing

/// Add helpers for representation creation.
extension LocalSignal {

    /// The ringlet counter variable.
    @usableFromInline static let ringletCounter = LocalSignal(
        type: .natural,
        name: .ringletCounter,
        defaultValue: .literal(value: .integer(value: 0)),
        comment: nil
    )

    // static func internalState(actionType: SignalType) -> LocalSignal {
    //     LocalSignal(
    //         type: actionType,
    //         name: .internalState,
    //         defaultValue: .variable(name: .readSnapshot),
    //         comment: nil
    //     )
    // }

    /// Create a local snapshot for an external variable.
    /// - Parameter signal: The signal to convert into a snapshot.
    @inlinable
    init(snapshot signal: PortSignal) {
        self.init(type: signal.type, name: signal.name, defaultValue: nil, comment: nil)
    }

    /// Create a local snapshot for a parameter.
    /// - Parameter parameter: The parameter to convert into a snapshot.
    @inlinable
    init(snapshot parameter: Parameter) {
        self.init(type: parameter.type, name: parameter.name, defaultValue: nil, comment: nil)
    }

    /// Create a local snapshot for an output parameter.
    /// - Parameter output: The output parameter to convert into a snapshot.
    @inlinable
    init(snapshot output: ReturnableVariable) {
        self.init(type: output.type, name: output.name, defaultValue: nil, comment: nil)
    }

    // swiftlint:disable function_body_length

    /// Create the signals that track the internal states of the machine.
    /// - Parameter machine: The machine to create the trackers for.
    /// - Returns: The signals that track which state is executing.
    @inlinable
    static func stateTrackers(machine: Machine) -> [LocalSignal]? {
        let states = machine.states
        guard
            let bitsRequired = BitLiteral.bitsRequired(for: states.count - 1),
            bitsRequired > 0,
            machine.initialState >= 0,
            machine.initialState < states.count
        else {
            return nil
        }
        let range = VectorSize.downto(
            upper: .literal(value: .integer(value: bitsRequired - 1)),
            lower: .literal(value: .integer(value: 0))
        )
        let stateType = SignalType.ranged(type: .stdLogicVector(size: range))
        let initialState = Expression.reference(
            variable: .variable(reference: .variable(name: .name(for: states[machine.initialState])))
        )
        guard let size = range.size else {
            return nil
        }
        let previousRinglet = LocalSignal(
            type: stateType,
            name: .previousRinglet,
            defaultValue: .literal(
                value: .vector(
                    value: .logics(
                        value: LogicVector(
                            values: [LogicLiteral](repeating: .highImpedance, count: size)
                        )
                    )
                )
            ),
            comment: nil
        )
        guard
            let suspendedStateIndex = machine.suspendedState,
            suspendedStateIndex >= 0,
            suspendedStateIndex < states.count
        else {
            guard !machine.isParameterised else {
                return nil
            }
            return [
                LocalSignal(
                    type: stateType,
                    name: .currentState,
                    defaultValue: initialState,
                    comment: nil
                ),
                LocalSignal(
                    type: stateType,
                    name: .targetState,
                    defaultValue: initialState,
                    comment: nil
                ),
                previousRinglet,
            ]
        }
        let suspendedState = Expression.reference(
            variable: .variable(reference: .variable(name: .name(for: states[suspendedStateIndex])))
        )
        let defaultState = machine.isParameterised ? suspendedState : initialState
        return [
            LocalSignal(
                type: stateType,
                name: .currentState,
                defaultValue: defaultState,
                comment: nil
            ),
            LocalSignal(
                type: stateType,
                name: .targetState,
                defaultValue: defaultState,
                comment: nil
            ),
            previousRinglet,
            LocalSignal(
                type: stateType,
                name: .suspendedFrom,
                defaultValue: initialState,
                comment: nil
            ),
        ]
    }

    // swiftlint:enable function_body_length

}
