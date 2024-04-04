//
//  File.swift
//  
//
//  Created by Morgan McColl on 14/4/21.
//

import Foundation
import VHDLParsing

/// The VHDL implementation of an LLFSM.
public struct Machine: Codable, Equatable, Hashable, Sendable {

    // swiftlint:disable closure_body_length

    /// Creates an initial machine containing an Initial state
    /// with the default actions (OnEntry, OnExit, Internald). This new
    /// machine is not parameterised or suspensible.
    public static let initial: Machine = {
        guard
            let ieee = VariableName(rawValue: "IEEE"),
            let stdLogicImport = UseStatement(rawValue: "use IEEE.std_logic_1164.all;"),
            let mathRealImport = UseStatement(rawValue: "use IEEE.math_real.all;")
        else {
            fatalError("VHDL Modules are invalid.")
        }
        let defaultActions = [
            VariableName.onEntry,
            VariableName.onExit,
            VariableName.internal
        ]
        return Machine(
            actions: defaultActions,
            includes: [
                .library(value: ieee),
                .include(statement: stdLogicImport),
                .include(statement: mathRealImport)
            ],
            externalSignals: [],
            clocks: [Clock(name: VariableName.clk, frequency: 50, unit: .MHz)],
            drivingClock: 0,
            machineSignals: [],
            isParameterised: false,
            parameterSignals: [],
            returnableSignals: [],
            states: [
                State(
                    name: VariableName.initial,
                    actions: [:],
                    signals: [],
                    externalVariables: []
                )
            ],
            transitions: [],
            initialState: 0,
            suspendedState: nil
        )
    }()

    /// Creates an initial machine containing an Initial and
    /// Suspended state with the default actions (OnEntry, OnExit, Internal, OnResume, OnSuspend). This new
    /// machine is not parameterised, but does include the suspension semantics.
    public static let initialSuspensible: Machine = {
        guard
            let ieee = VariableName(rawValue: "IEEE"),
            let stdLogicImport = UseStatement(rawValue: "use IEEE.std_logic_1164.all;"),
            let mathRealImport = UseStatement(rawValue: "use IEEE.math_real.all;")
        else {
            fatalError("VHDL Modules are invalid.")
        }
        let defaultActions = [
            VariableName.onEntry,
            VariableName.onExit,
            VariableName.internal,
            VariableName.onResume,
            VariableName.onSuspend
        ]
        return Machine(
            actions: defaultActions,
            includes: [
                .library(value: ieee),
                .include(statement: stdLogicImport),
                .include(statement: mathRealImport)
            ],
            externalSignals: [],
            clocks: [Clock(name: VariableName.clk, frequency: 50, unit: .MHz)],
            drivingClock: 0,
            machineSignals: [],
            isParameterised: false,
            parameterSignals: [],
            returnableSignals: [],
            states: [
                State(
                    name: VariableName.initial,
                    actions: [:],
                    signals: [],
                    externalVariables: []
                ),
                State(
                    name: VariableName.suspendedState,
                    actions: [:],
                    signals: [],
                    externalVariables: []
                )
            ],
            transitions: [],
            initialState: 0,
            suspendedState: 1
        )
    }()

    // swiftlint:enable closure_body_length

    /// The actions in the machine.
    public var actions: [VariableName]

    /// The includes for the machine.
    public var includes: [Include]

    /// The external signals for the machine.
    public var externalSignals: [PortSignal]

    /// The clocks for the machine.
    public var clocks: [Clock]

    /// The index of the driving clock.
    public var drivingClock: Int

    /// The machine signals for the machine.
    public var machineSignals: [LocalSignal]

    /// The parameters for the machine.
    public var parameterSignals: [Parameter]

    /// The returnable variables for the machine.
    public var returnableSignals: [ReturnableVariable]

    /// The states for the machine.
    public var states: [State]

    /// The transitions for the machine.
    public var transitions: [Transition]

    /// The index of the initial state for the machine.
    public var initialState: Int

    /// The index of the suspended state for the machine.
    public var suspendedState: Int?

    /// Extra VHDL code to be added to the architecture head.
    public var architectureHead: [HeadStatement]?

    /// Extra VHDL code to be added to the architecture body.
    public var architectureBody: AsynchronousBlock?

    /// Whether the machine is parameterised.
    private var _isParameterised: Bool

    /// Whether the machine is parameterised. Setting this value to `true` will not necessarily make the
    /// machine parameterised. The machine must also have a suspended state for this to be `true`.
    public var isParameterised: Bool {
        get {
            _isParameterised && suspendedState != nil
        }
        set {
            if suspendedState != nil {
                _isParameterised = newValue
            }
        }
    }

    /// Whether the machine can be suspended.
    @inlinable public var isSuspensible: Bool {
        suspendedState != nil
    }

    /// Initialise a machine
    /// - Parameters:
    ///   - actions: The actions in the machine.
    ///   - name: The name of the machine.
    ///   - path: The location of the machine in the file system.
    ///   - includes: The includes for the machine.
    ///   - PortSignals: The external signals for the machine.
    ///   - clocks: The clocks for the machine.
    ///   - drivingClock: The index of the driving clock.
    ///   - dependentMachines: The machines this machine depends on.
    ///   - machineVariables: The machine variables for the machine.
    ///   - machineSignals: The machine signals for the machine.
    ///   - isParameterised: Whether the machine is parameterised.
    ///   - parameterSignals: The parameters for the machine.
    ///   - returnableSignals: The returnable variables for the machine.
    ///   - states: The states for the machine.
    ///   - transitions: The transitions for the machine.
    ///   - initialState: The index of the initial state for the machine.
    ///   - suspendedState: The index of the suspended state for the machine.
    ///   - architectureHead: The extra asynchronous VHDL code to be added to the architecture.
    ///   - architectureBody: The extra synchronous VHDL code to be added to the architecture.
    public init(
        actions: [VariableName],
        includes: [Include],
        externalSignals: [PortSignal],
        clocks: [Clock],
        drivingClock: Int,
        machineSignals: [LocalSignal],
        isParameterised: Bool,
        parameterSignals: [Parameter],
        returnableSignals: [ReturnableVariable],
        states: [State],
        transitions: [Transition],
        initialState: Int,
        suspendedState: Int?,
        architectureHead: [HeadStatement]? = nil,
        architectureBody: AsynchronousBlock? = nil
    ) {
        self.actions = actions
        self.includes = includes
        self.externalSignals = externalSignals
        self.clocks = clocks
        self.drivingClock = drivingClock
        self.machineSignals = machineSignals
        self._isParameterised = isParameterised
        self.parameterSignals = parameterSignals
        self.returnableSignals = returnableSignals
        self.states = states
        self.transitions = transitions
        self.initialState = initialState
        self.suspendedState = suspendedState
        self.architectureHead = architectureHead
        self.architectureBody = architectureBody
    }

}
