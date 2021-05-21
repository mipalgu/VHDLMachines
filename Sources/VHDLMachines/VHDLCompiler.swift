//
//  File.swift
//  
//
//  Created by Morgan McColl on 19/5/21.
//

import Foundation
import IO

public struct VHDLCompiler {
    
    var helper: FileHelpers = FileHelpers()
    
    var internalStates: String {
        foldWithNewLine(
            components: [
                "constant ReadSnapshot: std_logic_vector(3 downto 0) := \"0000\";",
                "constant OnSuspend: std_logic_vector(3 downto 0) := \"0001\";",
                "constant OnResume: std_logic_vector(3 downto 0) := \"0010\";",
                "constant OnEntry: std_logic_vector(3 downto 0) := \"0011\";",
                "constant NoOnEntry: std_logic_vector(3 downto 0) := \"0100\";",
                "constant CheckTransition: std_logic_vector(3 downto 0) := \"0101\";",
                "constant OnExit: std_logic_vector(3 downto 0) := \"0110\";",
                "constant Internal: std_logic_vector(3 downto 0) := \"0111\";",
                "constant WriteSnapshot: std_logic_vector(3 downto 0) := \"1000\";",
                "signal internalState: std_logic_vector(3 downto 0) := ReadSnapshot;"
            ],
            initial: "-- Internal State Representation Bits",
            indentation: 1
        )
    }
    
    var suspensionCommands: String {
        foldWithNewLine(
            components: [
                "constant COMMAND_NULL: std_logic_vector(1 downto 0) := \"00\";",
                "constant COMMAND_RESTART: std_logic_vector(1 downto 0) := \"01\";",
                "constant COMMAND_SUSPEND: std_logic_vector(1 downto 0) := \"10\";",
                "constant COMMAND_RESUME: std_logic_vector(1 downto 0) := \"11\";"
            ],
            initial: "-- Suspension Commands",
            indentation: 1
        )
    }
    
    private func afterVariables(driving clock: Clock) -> String {
        foldWithNewLine(
            components: [
                "shared variable ringlet_counter: natural := 0;",
                "constant clockPeriod: real := \( String(format: "%0.2f", clock.period * 1_000_000_000 )); -- ns",
                "constant ringletLength: real := 5.0 * clockPeriod;",
                "constant RINGLETS_PER_NS: real := 1.0 / ringletLength;",
                "constant RINGLETS_PER_US: real := 1000.0 * RINGLETS_PER_NS;",
                "constant RINGLETS_PER_MS: real := 1000000.0 * RINGLETS_PER_NS;",
                "constant RINGLETS_PER_S: real := 1000000000.0 * RINGLETS_PER_NS;"
            ],
            initial: "-- After Variables",
            indentation: 1
        )
    }
    
    public func compile(_ machine: Machine) -> Bool {
        let format = foldWithNewLine(
            components: [
                createIncludes(includes: machine.includes) + "\n",
                createEntity(machine: machine) + "\n\n",
                createArhictecure(machine: machine)
            ],
            initial: ""
        )
        let fileName = "\(machine.name).vhd"
        return helper.createFile(fileName, inDirectory: machine.path, withContents: format + "\n") != nil
    }
    
    private func createIncludes(includes: [String]) -> String {
        return includes.reduce("") {
            if $0 == $1 && $0 == "" {
                return ""
            }
            if $0 == "" {
                return String($1)
            }
            return $0 + "\n" + $1
        }
    }
    
    private func createEntity(machine: Machine) -> String {
        """
         entity \(machine.name) is
         \(foldWithNewLine(components: [createGenericsBlock(variables: machine.generics), createPortBlock(clocks: machine.clocks, signals: machine.externalSignals, variables: machine.externalVariables)], initial: ""))
         end \(machine.name);
         """
    }
    
    private func createGenericsBlock(variables: [VHDLVariable]) -> String {
        guard !variables.isEmpty else {
            return ""
        }
        return """
             generic (
         \(foldWithNewLine(
            components: variables.indices.map {
                if $0 == variables.count - 1 {
                    return variableToGeneric(variable: variables[$0], withSemicolon: false)
                }
                return variableToGeneric(variable: variables[$0], withSemicolon: true)
             },
             initial: "",
            indentation: 2
         )
         )
             );
         """
    }
    
    private func variableToGeneric(variable: VHDLVariable, withSemicolon: Bool) -> String {
        let semiColon = withSemicolon ? ";" : ""
        guard let range = variable.range else {
            guard let defaultValue = variable.defaultValue else {
                return "\(variable.name): \(variable.type)\(semiColon)" + (variable.comment == nil ? "" : " -- \(variable.comment!)")
            }
            return "\(variable.name): \(variable.type) := \(defaultValue)\(semiColon)" + (variable.comment == nil ? "" : " -- \(variable.comment!)")
        }
        guard let defaultValue = variable.defaultValue else {
            return "\(variable.name): \(variable.type) range \(range.0) to \(range.1)\(semiColon)" + (variable.comment == nil ? "" : " -- \(variable.comment!)")
        }
        return "\(variable.name): \(variable.type) range \(range.0) to \(range.1) := \(defaultValue)\(semiColon)" + (variable.comment == nil ? "" : " -- \(variable.comment!)")
    }
    
    private func createPortBlock(clocks: [Clock], signals: [ExternalSignal], variables: [VHDLVariable]) -> String {
        guard !clocks.isEmpty else {
            fatalError("No clock found for machine")
        }
        return """
             port (
         \(foldWithNewLine(components: clocks.map { clockToSignal(clk: $0) }, initial: "", indentation: 2));
         \(foldWithNewLine(components: signals.map { signalToEntityDeclaration(signal: $0) }, initial: indent(count: 2) + "suspended: out std_logic;", indentation: 2))
         \(foldWithNewLine(
            components: variables.map { (variable: VHDLVariable) -> VHDLVariable in
                var newVar = variable
                newVar.name = toExternal(name: newVar.name)
                return newVar
            }.enumerated().map {
                return variableToGeneric(variable: $1, withSemicolon: true)
            },
             initial: "",
            indentation: 2
         ))
                 command: in std_logic_vector(1 downto 0)
             );
         """
    }
    
    private func toExternal(name: String) -> String {
        "EXTERNAL_\(name)"
    }
    
    private func clockToSignal(clk: Clock) -> String {
        "\(clk.name): in std_logic"
    }
    
    private func foldWithNewLine(components: [String], initial: String, indentation: Int = 0) -> String {
        return components.reduce(initial) {
            if $0 == "" && $1 == "" {
                return ""
            }
            if $0 == "" {
                return String(indent(count: indentation)) + $1
            }
            if $1 == "" {
                return $0
            }
            return $0 + "\n\(indent(count: indentation))" + $1
        }
    }
    
    private func signalToEntityDeclaration(signal: ExternalSignal) -> String {
        let name = toExternal(name: signal.name)
        guard let defaultValue = signal.defaultValue else {
            return "\(name): \(signal.mode.rawValue) \(signal.type);" + (signal.comment == nil ? "" : " -- \(signal.comment!)")
        }
        return "\(name): \(signal.mode.rawValue) \(signal.type) := \(defaultValue);" + (signal.comment == nil ? "" : " -- \(signal.comment!)")
    }
    
    private func signalToArchitectureDeclaration<T: Variable>(signal: T, with value: Bool = false, and comment: Bool = false) -> String where T.T == SignalType {
        let comment = comment ? " -- \(signal.comment ?? "")" : ""
        guard let defaultVal = signal.defaultValue else {
            return "signal \(signal.name): \(signal.type);\(comment)"
        }
        if value {
            return "signal \(signal.name): \(signal.type) := \(defaultVal);\(comment)"
        }
        return "signal \(signal.name): \(signal.type);\(comment)"
    }
    
    private func findBinaryLength(count: Int) -> Int {
        if count <= 1 {
            return 1
        }
        if count % 2 == 0 {
            return Int(ceil(log2(Double(count + 1))))
        }
        return Int(ceil(log2(Double(count))))
    }
    
    private func toStateName(name: String) -> String {
        "STATE_\(name)"
    }
    
    private func toBinary(number: Int, binaryPosition: Int) -> String {
        if number <= 0 && binaryPosition >= 0 {
            return "0" + toBinary(number: number, binaryPosition: binaryPosition - 1)
        }
        if binaryPosition < 0 {
            return ""
        }
        let length = findBinaryLength(count: number)
        print(number)
        print("Length for \(number): \(length)")
        print("Binary position: \(binaryPosition)")
        if length - 1 == binaryPosition {
            return "1" + toBinary(number: number - Int(pow(2, Double(binaryPosition))), binaryPosition: binaryPosition - 1)
        }
        return "0" + toBinary(number: number, binaryPosition: binaryPosition - 1)
    }
    
    private func toStateVar(name: String, length: Int, index: Int) -> String {
        let l = max(1, length)
        print(name)
        return "constant \(toStateName(name: name)): std_logic_vector(\(l - 1) downto 0) := \"\(toBinary(number: index, binaryPosition: l - 1))\""
    }
    
    private func stateRepresenation(states: [State], initialState: String) -> String {
        let stateLength = findBinaryLength(count: states.count)
        return """
         -- State Representation Bits
         \(foldWithNewLine(
            components: states.indices.map { toStateVar(name: states[$0].name, length: stateLength, index: $0) },
            initial: "",
            indentation: 1)
         )
         \(
         foldWithNewLine(
            components: [
                "signal currentState: std_logic_vector(1 downto 0) := \(toStateName(name: initialState));",
                "signal targetState: std_logic_vector(1 downto 0) := \(toStateName(name: initialState));",
                "signal previousRinglet: std_logic_vector(1 downto 0) := \"ZZ\";",
                "signal suspendedFrom: std_logic_vector(1 downto 0) := \(toStateName(name: initialState));"
            ],
            initial: "",
            indentation: 1
         ))
         """
    }
    
    private func variableToArchitectureDeclaration<T: Variable>(variable: T) -> String {
        let comment = nil == variable.comment ? "" : " -- \(variable.comment!)"
        return "shared variable \(variable.name): \(variable.type);\(comment)"
    }
    
    
    private func snapshots(signals: [ExternalSignal], variables: [VHDLVariable]) -> String {
        foldWithNewLine(
            components: variables.map { variableToArchitectureDeclaration(variable: $0) },
            initial: foldWithNewLine(
                components: signals.map{ signalToArchitectureDeclaration(signal: $0) },
                initial: "-- Snapshot of External Signals and Variables",
                indentation: 1
            ),
            indentation: 1
        )
    }
    
    private func machineVariables(signals: [MachineSignal], variables: [VHDLVariable]) -> String {
        foldWithNewLine(
            components: variables.map { variableToArchitectureDeclaration(variable: $0) },
            initial: foldWithNewLine(
                components: signals.map { signalToArchitectureDeclaration(signal: $0, with: $0.defaultValue != nil, and: $0.comment != nil) },
                initial: "-- Machine Signals and Variables",
                indentation: 1
            ),
            indentation: 1
        )
    }
    
    private func indent(count: Int) -> String {
        String(repeating: "    ", count: count)
    }
    
    private func architectureHead(head: String?) -> String {
        guard let head = head else {
            return ""
        }
        return foldWithNewLine(
            components: head.split(separator: "\n").map { String($0) },
            initial: "-- User-Specific Code for Architecture Head",
            indentation: 1
        )
    }
    
    private func architectureBody(body: String?) -> String {
        guard let body = body else {
            return ""
        }
        return foldWithNewLine(
            components: body.split(separator: "\n").map { String($0) },
            initial: "-- User-Specific Code for Architecture Body",
            indentation: 1
        ) + "\n"
    }
    
    private func createArchitectureBody(machine: Machine) -> String {
        foldWithNewLine(
            components: [
                "if (rising_edge(\(machine.clocks[machine.drivingClock].name))) then",
                foldWithNewLine(
                    components: [
                        "case internalState is",
                        "end case;"
                    ],
                    initial: "",
                    indentation: 3
                ),
                "end if;"
            ],
            initial: "",
            indentation: 2
        )
    }
    
    private func createArhictecure(machine: Machine) -> String {
        return foldWithNewLine(
            components: [
                internalStates,
                stateRepresenation(states: machine.states, initialState: machine.states[machine.initialState].name),
                suspensionCommands,
                afterVariables(driving: machine.clocks[machine.drivingClock]),
                snapshots(signals: machine.externalSignals, variables: machine.externalVariables),
                machineVariables(signals: machine.machineSignals, variables: machine.machineVariables),
                architectureHead(head: machine.architectureHead)
            ],
            initial: "architecture Behavioral of \(machine.name) is",
            indentation: 1
        ) + "\nbegin\n" + foldWithNewLine(
            components: [
                "process",
                "begin",
                createArchitectureBody(machine: machine),
                "end process;"
            ],
            initial: foldWithNewLine(
                components: [
                    architectureBody(body: machine.architectureBody)
                ],
                initial: "",
                indentation: 1
            ),
            indentation: 1
        ) + "\nend Behavioral;\n"
    }
    
}
