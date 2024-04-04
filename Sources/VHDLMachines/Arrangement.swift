//
//  File.swift
//  
//
//  Created by Morgan McColl on 14/4/21.
//

import Foundation
import VHDLParsing

/// An arrangement represents a collection of machines that are executing together. An arrangment has a set of
/// parent machines which act as entry points into the program. This structure does not infer any execution
/// order for the machines in this arrangement. Instead, this arrangement simply defines the machines and the
/// capability of each machine (Suspensible, Parameterised, Custom Ringlets etc).
/// 
/// A machine is represented with a name and URL to it's location in the file system. From the arrangements
/// perspective, the only variables defined here are the external variables (and signals), and clocks that
/// also act as a special external signal. The arrangment variables defined in this struct are available to
/// all machines within the same arrangement and act as variables with global scope.
public struct Arrangement: Equatable, Hashable, Codable {

    /// All machines in the arrangement.
    public var machines: [VariableName: MachineMapping]

    /// The external signals in the arrangement that map to physical pins.
    public var externalSignals: [PortSignal]

    /// The signals local to every machine in the arrangement, but do not map to external devices.
    public var signals: [LocalSignal]

    /// The clocks in the arrangement available to every machine.
    public var clocks: [Clock]

    /// Initialises the arrangement with the given values.
    /// - Parameters:
    ///   - machines: The machine mappings in the arrangement.
    ///   - externalSignals: The external signals in the arrangement.
    ///   - signals: The local signals in the arrangement.
    ///   - clocks: The clocks in the arrangement.
    @inlinable
    public init(
        machines: [VariableName: MachineMapping],
        externalSignals: [PortSignal],
        signals: [LocalSignal],
        clocks: [Clock]
    ) {
        self.machines = machines
        self.externalSignals = externalSignals
        self.signals = signals
        self.clocks = clocks
    }

}
