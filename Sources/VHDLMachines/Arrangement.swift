//
//  File.swift
//  
//
//  Created by Morgan McColl on 14/4/21.
//

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
public struct Arrangement: Equatable, Hashable, Codable, Sendable {

    /// All machines in the arrangement.
    public let machines: [MachineInstance: MachineMapping]

    /// The external signals in the arrangement that map to physical pins.
    public let externalSignals: [PortSignal]

    /// The signals local to every machine in the arrangement, but do not map to external devices.
    public let signals: [LocalSignal]

    /// The clocks in the arrangement available to every machine.
    public let clocks: [Clock]

    /// This initialiser will attempt to create an arrangement with the given mapping and signals. Please note
    /// that the types in ``MachineInstance`` (the keys in the `mappings`) must point to the same ``Machine``.
    /// This initialiser will return nil if this is not the case.
    /// - Parameters:
    ///   - mappings: The signal mappings for each machine instance.
    ///   - externalSignals: The external signals in the arrangement.
    ///   - signals: The local (global in machine scope) signals to the arrangement.
    ///   - clocks: The clocks in the arrangement. It is assumed that clocks are not local to the arrangement.
    /// If you are synthesising clocks (i.e. through PLL or DCM) within the arrangement, then use local
    /// `signals`.
    @inlinable
    public init?(
        mappings: [MachineInstance: MachineMapping],
        externalSignals: [PortSignal],
        signals: [LocalSignal],
        clocks: [Clock]
    ) {
        var mappingsDictionary: [VariableName: [MachineMapping]] = [:]
        mappings.forEach { instance, mapping in
            guard let oldMappings = mappingsDictionary[instance.type] else {
                mappingsDictionary[instance.type] = [mapping]
                return
            }
            mappingsDictionary[instance.type] = oldMappings + [mapping]
        }
        guard mappingsDictionary.allSatisfy({ Set($1).count == 1 }) else {
            return nil
        }
        self.init(machines: mappings, externalSignals: externalSignals, signals: signals, clocks: clocks)
    }

    /// Initialises the arrangement with the given values.
    /// - Parameters:
    ///   - machines: The machine mappings in the arrangement.
    ///   - externalSignals: The external signals in the arrangement.
    ///   - signals: The local signals in the arrangement.
    ///   - clocks: The clocks in the arrangement.
    @inlinable
    init(
        machines: [MachineInstance: MachineMapping],
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
