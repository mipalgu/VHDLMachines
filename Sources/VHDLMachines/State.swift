//
//  File.swift
//
//
//  Created by Morgan McColl on 14/4/21.
//

import Foundation
import VHDLParsing

/// A state in a machine.
public struct State: Codable, Equatable, Hashable, Sendable {

    /// The name of the state.
    public var name: VariableName

    /// The actions in the state.
    ///
    /// This property includes the code in each action.
    public var actions: [ActionName: SynchronousBlock]

    /// The machine signals in the state.
    public var signals: [LocalSignal]

    /// The name of the external variables accessed in the state.
    ///
    /// These variables are defined in the arrangement.
    public var externalVariables: [VariableName]

    /// Initialises a state with the given properties.
    ///
    /// - Parameters:
    ///   - name: The name of the state.
    ///   - actions: The actions in the state. This property includes the code in each action.
    ///   - actionOrder: The order in which the actions should be executed.
    ///   - signals: The machine signals in the state.
    ///   - variables: The machine variables in the state. These variable are not signals and
    /// cannot be used to
    /// represent real signals in the hardware.
    ///   - externalVariables: The name of the external variables accessed in the state. These variables are
    /// defined in the arrangement.
    @inlinable
    public init(
        name: VariableName,
        actions: [ActionName: SynchronousBlock],
        signals: [LocalSignal],
        externalVariables: [VariableName]
    ) {
        self.name = name
        self.actions = actions
        self.signals = signals
        self.externalVariables = externalVariables
    }

}
