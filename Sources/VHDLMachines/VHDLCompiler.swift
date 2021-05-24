//
//  File.swift
//  
//
//  Created by Morgan McColl on 19/5/21.
//

import Foundation
import IO

public struct VHDLCompiler {
    
    private var helper: FileHelpers = FileHelpers()
    
    private var internalStates: String {
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
    
    private var suspensionCommands: String {
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
    
    private func readParameterLogic(machine: Machine) -> [String] {
        ["    if (command = COMMAND_RESTART) then"] +
            machine.parameterSignals.map { "    \($0.name) <= \(toParameter(name: $0.name));" } +
            machine.parameterVariables.map { "    \($0.name) := \(toParameter(name: $0.name));" } +
        ["end if;"]
    }
    
    private func readSnapshotLogic(machine: Machine, indentation: Int) -> String {
        let initialState = toStateName(name: machine.states[machine.initialState].name)
        let suspendedState = toStateName(name: machine.states[machine.suspendedState!].name)
        return foldWithNewLineExceptFirst(
            components: readParameterLogic(machine: machine) + [
                "if (command = COMMAND_RESTART and currentState /= \(initialState)) then",
                foldWithNewLineExceptFirst(
                    components: [
                        "    currentState <= \(initialState);",
                        "suspended <= '0';",
                        "suspendedFrom <= \(initialState);",
                        "targetState <= \(initialState);",
                        "if (previousRinglet = \(suspendedState)) then",
                        foldWithNewLine(components: ["internalState <= onResume;"], initial: "", indentation: 1),
                        "elsif (previousRinglet = \(initialState)) then",
                        foldWithNewLine(components: ["internalState <= noOnEntry;"], initial: "", indentation: 1),
                        "else",
                        foldWithNewLine(components: ["internalState <= onEntry;"], initial: "", indentation: 1),
                        "end if;"
                    ],
                    initial: "",
                    indentation: indentation + 1
                ),
                "elsif (command = COMMAND_RESUME and currentState = \(suspendedState) and suspendedFrom /= \(suspendedState)) then",
                foldWithNewLineExceptFirst(
                    components: [
                        "    suspended <= '0';",
                        "currentState <= suspendedFrom;",
                        "targetState <= suspendedFrom;",
                        "if (previousRinglet = suspendedFrom) then",
                        foldWithNewLine(components: ["internalState <= noOnEntry;"], initial: "", indentation: 1),
                        "else",
                        foldWithNewLine(components: ["internalState <= onResume;"], initial: "", indentation: 1),
                        "end if;"
                    ],
                    initial: "",
                    indentation: indentation + 1
                ),
                "elsif (command = COMMAND_SUSPEND and currentState /= \(suspendedState)) then",
                foldWithNewLineExceptFirst(
                    components: [
                        "    suspendedFrom <= currentState;",
                        "suspended <= '1';",
                        "currentState <= \(suspendedState);",
                        "targetState <= \(suspendedState);",
                        "if (previousRinglet = \(suspendedState)) then",
                        foldWithNewLine(components: ["internalState <= noOnEntry;"], initial: "", indentation: 1),
                        "else",
                        foldWithNewLine(components: ["internalState <= onSuspend;"], initial: "", indentation: 1),
                        "end if;"
                    ],
                    initial: "",
                    indentation: indentation + 1
                ),
                "elsif (currentState = \(suspendedState)) then",
                foldWithNewLineExceptFirst(
                    components: [
                        "    suspended <= '1';",
                        "if (previousRinglet /= \(suspendedState)) then",
                        foldWithNewLine(components: ["internalState <= onSuspend;"], initial: "", indentation: 1),
                        "else",
                        foldWithNewLine(components: ["internalState <= noOnEntry;"], initial: "", indentation: 1),
                        "end if;"
                    ],
                    initial: "",
                    indentation: indentation + 1
                ),
                "elsif (previousRinglet = \(suspendedState)) then",
                foldWithNewLineExceptFirst(
                    components: [
                        "    internalState <= OnResume;",
                        "suspended <= '0';",
                        "suspendedFrom <= currentState;"
                    ],
                    initial: "",
                    indentation: indentation + 1
                ),
                "else",
                foldWithNewLineExceptFirst(
                    components: [
                        "    suspended <= '0';",
                        "suspendedFrom <= currentState;",
                        "if (previousRinglet /= currentState) then",
                        foldWithNewLine(components: ["internalState <= onEntry;"], initial: "", indentation: 1),
                        "else",
                        foldWithNewLine(components: ["internalState <= noOnEntry;"], initial: "", indentation: 1),
                        "end if;"
                    ],
                    initial: "",
                    indentation: indentation + 1
                ),
                "end if;"
            ],
            initial: "",
            indentation: indentation
        )
    }
    
    private func readSnapshotVariables(machine: Machine, indentation: Int) -> String {
        var signals = machine.externalSignals.filter { $0.mode == .input || $0.mode == .inputoutput || $0.mode == .buffer }.map { "\($0.name) <= \(toExternal(name: $0.name));" }
        var variables = machine.externalVariables.filter { $0.mode == .input || $0.mode == .inputoutput || $0.mode == .buffer }.map { "\($0.name) := \(toExternal(name: $0.name));" }
        if signals.count > 0 {
            signals[0] = "    " + signals[0]
        } else if variables.count > 0 {
            variables[0] = "    " + variables[0]
        } else {
            return ""
        }
        return foldWithNewLineExceptFirst(
            components: signals + variables,
            initial: "",
            indentation: indentation
        )
    }
    
    private func readSnapshot(machine: Machine, indentation: Int) -> String {
        foldWithNewLineExceptFirst(
            components: [
                readSnapshotVariables(machine: machine, indentation: indentation + 1),
                readSnapshotLogic(machine: machine, indentation: indentation + 1)
            ],
            initial: "",
            indentation: indentation
        )
    }
    
    private func codeForStatesStatement(names: [String], code: [String], indentation: Int, trailer: String, internalVar: String = "currentState", defaultCode: String = "null;") -> String {
        guard names.count == code.count else {
            fatalError("Invalid call of codeForStatesStatement. Size of parameters does not match")
        }
        if code.reduce(true, { $0 && ($1 == "") }) {
            return "    " + trailer
        }
        var data = names.indices.flatMap { (i: Int) -> [String] in
            guard code[i] != "" else {
                return [""]
            }
            return ["when \(toStateName(name: names[i])) =>"] + code[i].split(separator: "\n").map { "    " + String($0) }
        }
        if data.count == 0 {
            return ""
        }
        data[0] = "    " + data[0]
        data.append("when others =>")
        data.append("    \(defaultCode)")
        return foldWithNewLineExceptFirst(
            components: [
                "    case \(internalVar) is",
                foldWithNewLineExceptFirst(components: data, initial: "", indentation: indentation + 1),
                "end case;",
                trailer
            ],
            initial: "",
            indentation: indentation
        )
    }
    
    private func actionForStates(machine: Machine, actionName: String) -> [String] {
        machine.states.map { $0.actions[actionName] ?? "" }
    }
    
    private func onEntry(machine: Machine, indentation: Int) -> String {
        codeForStatesStatement(
            names: machine.states.map(\.name),
            code: actionForStates(machine: machine, actionName: "OnEntry"),
            indentation: indentation,
            trailer: "internalState <= CheckTransition;"
        )
    }
    
    private func onExit(machine: Machine, indentation: Int) -> String {
        codeForStatesStatement(
            names: machine.states.map(\.name),
            code: actionForStates(machine: machine, actionName: "OnExit"),
            indentation: indentation,
            trailer: "internalState <= WriteSnapshot;"
        )
    }
    
    private func internalAction(machine: Machine, indentation: Int) -> String {
        codeForStatesStatement(
            names: machine.states.map(\.name),
            code: actionForStates(machine: machine, actionName: "Internal"),
            indentation: indentation,
            trailer: "internalState <= WriteSnapshot;"
        )
    }
    
    private func actionsForStates(machine: Machine, actionsNames: [String]) -> [String] {
        machine.states.map { state in
            let actions = actionsNames.map { name in
                state.actions[name] ?? ""
            }
            return foldWithNewLine(components: actions)
        }
    }
    
    private func onResume(machine: Machine, indentation: Int) -> String {
        codeForStatesStatement(
            names: machine.states.map(\.name),
            code: actionsForStates(machine: machine, actionsNames: ["OnResume", "OnEntry"]),
            indentation: indentation,
            trailer: "internalState <= CheckTransition;"
        )
    }
    
    private func onSuspend(machine: Machine, indentation: Int) -> String {
        let onEntry = (machine.states[machine.suspendedState!].actions["OnEntry"] ?? "").split(separator: "\n").map { String($0) }
//        if onEntry.count > 0 {
//            onEntry[0] = "    " + onEntry[0]
//        }
        let actions = actionForStates(machine: machine, actionName: "OnSuspend")
        return codeForStatesStatement(
            names: machine.states.map(\.name),
            code: actions,
            indentation: indentation,
            trailer: foldWithNewLineExceptFirst(components: onEntry + ["internalState <= CheckTransition;"], initial: "", indentation: indentation),
            internalVar: "suspendedFrom"
        )
    }
    
    private func writeSnapshot(machine: Machine, indentation: Int) -> String {
        let externalSignals = machine.externalSignals.filter { $0.mode == .output || $0.mode == .inputoutput || $0.mode == .buffer }.map {
            "\(toExternal(name: $0.name)) <= \($0.name);"
        }
        let externalVariables = machine.externalVariables.filter { $0.mode == .output || $0.mode == .inputoutput || $0.mode == .buffer }.map {
            "\(toExternal(name: $0.name)) := \($0.name);"
        }
        var combined = externalSignals + externalVariables + [
            "internalState <= ReadSnapshot;",
            "previousRinglet <= currentState;",
            "currentState <= targetState;"
        ]
        combined[0] = "    " + combined[0]
        return foldWithNewLineExceptFirst(components: combined, initial: "", indentation: indentation)
    }
    
    private struct VHDLTransition {
        
        var source: String
        
        var target: String
        
        var condition: String
        
        init(source: String, target: String, condition: String) {
            self.source = source
            self.target = target
            self.condition = condition
        }
        
        init(transition: Transition, machine: Machine) {
            self.init(
                source: machine.states[transition.source].name,
                target: machine.states[transition.target].name,
                condition: transition.condition
            )
        }
        
    }
    
    private func transitionExpression(expression: String, transitionBefore: String?) -> String {
        guard let before = transitionBefore else {
            return expression
        }
        return "\(expression) and (not (\(before)))"
    }
    
    private func transitionsToCode(transitions: [VHDLTransition]) -> String {
        if transitions.count == 0 {
            return "internalState <= Internal;"
        }
        if transitions.count == 1 && transitions[0].condition.lowercased() == "true" {
            return "targetState <= \(toStateName(name: transitions[0].target));\ninternalState <= OnExit;"
        }
        var previous: String = ""
        let expressions = transitions.indices.map { (i: Int) -> String in
            if i == 0 {
                previous = transitionExpression(expression: transitions[i].condition, transitionBefore: nil)
                return previous
            }
            previous = transitionExpression(expression: transitions[i].condition, transitionBefore: previous)
            return previous
        }
        let ifCases = expressions.indices.map { (i: Int) -> String in
            if i == 0 {
                return "if (\(expressions[i])) then"
            }
            return "elsif (\(expressions[i])) then"
        }
        let code = expressions.indices.flatMap { (i: Int) -> [String] in
            [
                ifCases[i],
                "    targetState <= \(toStateName(name: transitions[i].target));",
                "    internalState <= OnExit;"
            ]
        }
        return foldWithNewLine(components: code + ["else", "    internalState <= Internal;", "end if;"])
    }
    
    private func checkTransition(machine: Machine, indentation: Int) -> String {
        guard machine.transitions.count > 0 else {
            return "    internalState <= Internal;"
        }
        let transitions = machine.transitions.map { VHDLTransition(transition: $0, machine: machine) }
        let groupedTransitions = transitions.grouped(by: { $0.source == $1.source })
        let code: Dictionary<String, [VHDLTransition]> = Dictionary(uniqueKeysWithValues: groupedTransitions.map { ($0[0].source, $0) })
        let keys: [String] = Array(code.keys)
        let vhdlCode = keys.map { transitionsToCode(transitions: code[$0]!) }
        return codeForStatesStatement(
            names: keys,
            code: vhdlCode,
            indentation: indentation,
            trailer: "",
            defaultCode: "internalState <= Internal;"
        )
    }
    
    private func actionCase(machine: Machine, indentation: Int) -> String {
        let components = [
            "    when ReadSnapshot =>",
            readSnapshot(machine: machine, indentation: indentation),
            "when OnSuspend =>",
            onSuspend(machine: machine, indentation: indentation + 1),
            "when OnResume =>",
            onResume(machine: machine, indentation: indentation + 1),
            "when OnEntry =>",
            onEntry(machine: machine, indentation: indentation + 1),
            "when NoOnEntry =>",
            "    internalState <= CheckTransition;",
            "when CheckTransition =>",
            checkTransition(machine: machine, indentation: indentation + 1),
            "when OnExit =>",
            onExit(machine: machine, indentation: indentation + 1),
            "when Internal =>",
            internalAction(machine: machine, indentation: indentation + 1),
            "when WriteSnapshot",
            writeSnapshot(machine: machine, indentation: indentation + 1),
            "when others =>",
            "    null;"
        ]
        return foldWithNewLineExceptFirst(components: components, initial: "", indentation: indentation)
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
         \(foldWithNewLine(components: [createGenericsBlock(variables: machine.generics), createPortBlock(machine: machine)], initial: ""))
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
    
    private func variableToPort(variable: ExternalVariable, withSemicolon: Bool) -> String {
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
    
    private func createPortBlock(machine: Machine) -> String {
        guard !machine.clocks.isEmpty else {
            fatalError("No clock found for machine")
        }
        return """
             port (
         \(foldWithNewLine(components: machine.clocks.map { clockToSignal(clk: $0) }, initial: "", indentation: 2));
         \(foldWithNewLine(components: machine.externalSignals.map { signalToEntityDeclaration(signal: $0) }, initial: indent(count: 2) + "suspended: out std_logic;", indentation: 2))
         \(foldWithNewLine(
            components: machine.externalVariables.map { (variable: ExternalVariable) -> ExternalVariable in
                var newVar = variable
                newVar.name = toExternal(name: newVar.name)
                newVar.type = "\(variable.mode.rawValue) \(newVar.type)"
                return newVar
            }.enumerated().map {
                return variableToPort(variable: $1, withSemicolon: true)
            },
             initial: "",
            indentation: 2
         ))
         \(foldWithNewLine(
            components: machine.parameterSignals.map { toParameterDeclaration(parameter: $0) },
            initial: "",
            indentation: 2
         ))
         \(foldWithNewLine(
            components: machine.parameterVariables.map { toParameterDeclaration(parameter: $0) },
            initial: "",
            indentation: 2
         ))
         \(foldWithNewLine(
             components: machine.returnableSignals.map(toReturnDeclaration),
             initial: "",
             indentation: 2
         ))
         \(foldWithNewLine(
              components: machine.returnableVariables.map(toReturnDeclaration),
              initial: "",
              indentation: 2
         ))
                 command: in std_logic_vector(1 downto 0)
             );
         """
    }
    
    private func toParameterDeclaration(parameter: Parameter) -> String {
        let name = toParameter(name: parameter.name)
        guard let defaultValue = parameter.defaultValue else {
            return "\(name): in \(parameter.type);" + (parameter.comment == nil ? "" : " -- \(parameter.comment!)")
        }
        return "\(name): in \(parameter.type) := \(defaultValue);" + (parameter.comment == nil ? "" : " -- \(parameter.comment!)")
    }
    
    private func toReturnDeclaration(returnable: ReturnableVariable) -> String {
        let name = toReturnable(name: returnable.name)
        return "\(name): out \(returnable.type);" + (returnable.comment == nil ? "" : " -- \(returnable.comment!)")
    }
    
    private func toReturnable(name: String) -> String {
        "OUTPUT_\(name)"
    }
    
    private func toParameter(name: String) -> String {
        "PARAMETER_\(name)"
    }
    
    private func toExternal(name: String) -> String {
        "EXTERNAL_\(name)"
    }
    
    private func clockToSignal(clk: Clock) -> String {
        "\(clk.name): in std_logic"
    }
    
    private func foldWithNewLine(components: [String], initial: String = "", indentation: Int = 0) -> String {
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
    
    
    private func snapshots(machine: Machine) -> String {
        foldWithNewLine(
            components: machine.externalVariables.map { variableToArchitectureDeclaration(variable: $0) },
            initial: foldWithNewLine(
                components: machine.externalSignals.map{ signalToArchitectureDeclaration(signal: $0) },
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
        foldWithNewLineExceptFirst(
            components: [
                "    if (rising_edge(\(machine.clocks[machine.drivingClock].name))) then",
                foldWithNewLineExceptFirst(
                    components: [
                        "    case internalState is",
                        actionCase(machine: machine, indentation: 4),
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
    
    private func parameters(machine: Machine) -> String {
        foldWithNewLine(
            components: machine.parameterVariables.map { variableToArchitectureDeclaration(variable: $0) },
            initial: foldWithNewLine(
                components: machine.parameterSignals.map{ signalToArchitectureDeclaration(signal: $0) },
                initial: "-- Snapshot of Parameter Signals and Variables",
                indentation: 1
            ),
            indentation: 1
        )
    }
    
    private func returnableSignalToArchitectureDeclaration(signal: ReturnableVariable) -> String {
        "signal \(signal.name): \(signal.type);"
    }
    
    private func returnableVariableToArchitectureDeclaration(variable: ReturnableVariable) -> String {
        "shared variable \(variable.name): \(variable.type);"
    }
    
    private func outputs(machine: Machine) -> String {
        foldWithNewLine(
            components: machine.returnableVariables.map { returnableVariableToArchitectureDeclaration(variable: $0) },
            initial: foldWithNewLine(
                components: machine.returnableSignals.map{ returnableSignalToArchitectureDeclaration(signal: $0) },
                initial: "-- Snapshot of Output Signals and Variables",
                indentation: 1
            ),
            indentation: 1
        )
    }
    
    private func createArhictecure(machine: Machine) -> String {
        return foldWithNewLine(
            components: [
                internalStates,
                stateRepresenation(states: machine.states, initialState: machine.states[machine.initialState].name),
                suspensionCommands,
                afterVariables(driving: machine.clocks[machine.drivingClock]),
                snapshots(machine: machine),
                parameters(machine: machine),
                outputs(machine: machine),
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
    
    private func foldWithNewLineExceptFirst(components: [String], initial: String = "", indentation: Int = 0) -> String {
        if components.count == 0 {
            return initial
        }
        guard components.count > 1 else {
            return components[0]
        }
        let newList = Array(components[1..<components.count])
        return foldWithNewLine(components: [components[0]], initial: initial, indentation: 0) +
            "\n" + foldWithNewLine(components: newList, initial: "", indentation: indentation)
    }
    
}
