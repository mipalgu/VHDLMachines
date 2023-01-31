//
//  File.swift
//  
//
//  Created by Morgan McColl on 19/5/21.
//

import Foundation
import IO
@testable import Machines
@testable import VHDLMachines
import VHDLParsing
import XCTest

// swiftlint:disable file_length
// swiftlint:disable type_body_length

/// Test class for ``VHDLCompiler``.
class VHDLMachinesCompilerTests: XCTestCase {

    /// The compiler under test.
    let compiler = VHDLCompiler()

    /// The test machine filePath.
    var testMachinePath: URL {
        factory.machinePath.appendingPathComponent("TestMachine.machine", isDirectory: true)
    }

    /// A test machine.
    var machine: VHDLMachines.Machine {
        VHDLMachines.Machine(
            name: "TestMachine",
            path: testMachinePath,
            includes: [.library(value: "IEEE"), .include(value: "IEEE.std_logic_1164.ALL")],
            externalSignals: [
                PortSignal(
                    type: .stdLogic,
                    name: VariableName.x,
                    mode: .input,
                    defaultValue: .literal(value: .logic(value: .high)),
                    comment: Comment(rawValue: "-- A std_logic variable.")!
                ),
                PortSignal(
                    type: .ranged(type: .stdLogicVector(size: .downto(upper: 1, lower: 0))),
                    name: VariableName(rawValue: "xx")!,
                    mode: .output,
                    defaultValue: .literal(value: .vector(value: .bits(
                        value: BitVector(values: [.low, .low])
                    ))),
                    comment: Comment(rawValue: "-- A variable called xx.")!
                )
            ],
            generics: [
                LocalSignal(
                    type: SignalType.ranged(type: .integer(size: .to(lower: 0, upper: 65535))),
                    name: VariableName.y,
                    defaultValue: .literal(value: .integer(value: 0)),
                    comment: Comment(rawValue: "-- A uint16 variable called y.")!
                ),
                LocalSignal(
                    type: .boolean,
                    name: VariableName(rawValue: "yy")!,
                    defaultValue: .literal(value: .boolean(value: false)),
                    comment: Comment(rawValue: "-- A variable called yy")!
                )
            ],
            clocks: [
                Clock(name: VariableName.clk, frequency: 50, unit: .MHz),
                Clock(name: VariableName.clk2, frequency: 20, unit: .kHz)
            ],
            drivingClock: 0,
            dependentMachines: [:],
            machineSignals: [
                LocalSignal(
                    type: .stdLogic,
                    name: VariableName(rawValue: "machineSignal1")!,
                    defaultValue: nil,
                    comment: nil
                ),
                LocalSignal(
                    type: .ranged(type: .stdLogicVector(size: .downto(upper: 2, lower: 0))),
                    name: VariableName(rawValue: "machineSignal2")!,
                    defaultValue: .literal(value: .vector(value: .bits(
                        value: BitVector(values: [.high, .high, .high])
                    ))),
                    comment: Comment(rawValue: "-- machine signal 2")!
                )
            ],
            isParameterised: true,
            parameterSignals: [
                Parameter(
                    type: .stdLogic,
                    name: VariableName(rawValue: "parX")!,
                    defaultValue: .literal(value: .logic(value: .high)),
                    comment: Comment(rawValue: "-- Parameter parX")!
                ),
                Parameter(
                    type: .ranged(type: .stdLogicVector(size: .downto(upper: 1, lower: 0))),
                    name: VariableName(rawValue: "parXs")!,
                    defaultValue: .literal(value: .vector(value: .bits(
                        value: BitVector(values: [.low, .high])
                    ))),
                    comment: Comment(rawValue: "-- Parameter parXs")!
                )
            ],
            returnableSignals: [
                ReturnableVariable(
                    type: .stdLogic,
                    name: VariableName(rawValue: "retX")!,
                    comment: Comment(rawValue: "-- Returnable retX")!
                ),
                ReturnableVariable(
                    type: .ranged(type: .stdLogicVector(size: .downto(upper: 1, lower: 0))),
                    name: VariableName(rawValue: "retXs")!,
                    comment: Comment(rawValue: "-- Returnable retXs")!
                )
            ],
            states: [
                defaultState(name: "Initial"), defaultState(name: "Suspended"), defaultState(name: "State0")
            ],
            transitions: [
                VHDLMachines.Transition(
                    condition: .conditional(condition: .literal(value: false)), source: 0, target: 1
                ),
                VHDLMachines.Transition(
                    // "after_ms(50) or after(2) or after_rt(20000)"
                    condition: .or(
                        lhs: .after(statement: AfterStatement(
                            amount: .literal(value: .decimal(value: 50)), period: .ms
                        )),
                        rhs: .or(
                            lhs: .after(statement: AfterStatement(
                                amount: .literal(value: .decimal(value: 2)), period: .s
                            )),
                            rhs: .after(statement: AfterStatement(
                                amount: .literal(value: .decimal(value: 20000)), period: .ringlet
                            ))
                        )
                    ),
                    source: 0,
                    target: 1
                ),
                VHDLMachines.Transition(
                    condition: TransitionCondition.conditional(condition: .literal(value: true)),
                    source: 0,
                    target: 1
                ),
                VHDLMachines.Transition(
                    // "xx = '1'"
                    condition: .conditional(condition: .comparison(
                        value: .equality(lhs: .variable(name: .xx), rhs: .literal(value: .bit(value: .high)))
                    )),
                    source: 1,
                    target: 2
                ),
                VHDLMachines.Transition(
                    // // "x = '1'"
                    condition: .conditional(condition: .comparison(
                        value: .equality(lhs: .variable(name: .x), rhs: .literal(value: .bit(value: .high)))
                    )),
                    source: 1,
                    target: 2
                ),
                VHDLMachines.Transition(
                    condition: .conditional(condition: .literal(value: true)), source: 1, target: 0
                )
            ],
            initialState: 0,
            suspendedState: 1,
            architectureHead: "",
            architectureBody: ""
        )
    }

    /// Factory generating PingPong arrangements.
    let factory = PingPongArrangement()

    /// IO Helper.
    let helper = FileHelpers()

    /// FileWrapper for the test machine.
    var testMachineFileWrapper: FileWrapper? {
        VHDLGenerator().generate(machine: machine)
    }

    // swiftlint:disable type_contents_order

    /// Create test paths for machines.
    override func setUp() {
        if !helper.directoryExists(factory.machinesFolder) {
            _ = helper.createDirectory(atPath: factory.machinePath)
        }
        if !helper.directoryExists(factory.pingMachinePath.path) {
            _ = helper.createDirectory(atPath: factory.pingMachinePath)
        }
        if !helper.directoryExists(testMachinePath.path) {
            guard let wrapper = testMachineFileWrapper else {
                return
            }
            _ = try? wrapper.write(to: factory.machinePath, originalContentsURL: nil)
        }
    }

    /// Remove test machines.
    override func tearDown() {
        _ = helper.deleteItem(atPath: testMachinePath)
        _ = helper.deleteItem(atPath: factory.pingMachinePath)
    }

    /// Default state creation.
    private func defaultState(name: String) -> VHDLMachines.State {
        VHDLMachines.State(
            name: VariableName(rawValue: name)!,
            actions: [
                VariableName.onEntry: "x <= '1';\nxx <= \"00\"; -- \(name) onEntry",
                VariableName.onExit: "x <= '0'; -- \(name) OnExit",
                VariableName.onResume: "x <= '0'; -- \(name) OnResume",
                VariableName.onSuspend: "xx <= \"11\"; -- \(name) onSuspend",
                VariableName.internal: "x <= '1'; -- \(name) Internal"
            ],
            actionOrder: [
                [VariableName.onResume, VariableName.onEntry],
                [VariableName.onExit, VariableName.internal],
                [VariableName.onSuspend]
            ],
            signals: [],
            externalVariables: []
        )
    }

    /// Test can compile initial machine.
    func testInitialMachine() {
        XCTAssertTrue(compiler.compile(machine))
    }

    /// Test compiler overwrite parent folder.
    func testCompileWorksWhenParentFolderExists() {
        if !helper.directoryExists(testMachinePath.path) {
            guard helper.createDirectory(atPath: testMachinePath) else {
                XCTFail("Failed to create directory!")
                return
            }
        }
        XCTAssertTrue(compiler.compile(machine))
    }

    /// Test compilation overwrites existing file.
    func testCompileWorksWhenFileIsPresent() {
        if !helper.directoryExists(testMachinePath.path) {
            guard helper.createDirectory(atPath: testMachinePath) else {
                XCTFail("Failed to create directory!")
                return
            }
        }
        let vhdFile = testMachinePath.path + "/\(machine.name).vhd"
        if !helper.fileExists(vhdFile) {
            XCTAssertTrue(
                helper.createFile(
                    atPath: URL(fileURLWithPath: vhdFile, isDirectory: false), withContents: "Test Data\n"
                )
            )
        }
        XCTAssertTrue(compiler.compile(machine))
    }

    /// Test compilation creates intermediate folder.
    func testCompileWorksInEmptySubdir() {
        var machine = factory.pingMachine
        let subdir = factory.machinePath.appendingPathComponent("subdir", isDirectory: true)
        let newPath = subdir.appendingPathComponent(
            "PingMachine.machine", isDirectory: true
        )
        machine.path = newPath
        XCTAssertTrue(compiler.compile(machine))
        defer { _ = helper.deleteItem(atPath: subdir) }
        XCTAssertTrue(helper.fileExists(newPath.path))
    }

    /// Test the VHDL code generation is correct for the Ping Machine.
    func testPingMachineCodeGeneration() {
        let machine = factory.pingMachine
        let code = compiler.generateVHDLFile(machine)
        XCTAssertEqual(code, factory.pingCode, "\(code.difference(from: factory.pingCode))")
    }

    /// Test VHDL compilation.
    func testCompilationForEmptyFolder() {
        if helper.directoryExists(factory.pingMachinePath.path) {
            _ = helper.deleteItem(atPath: factory.pingMachinePath)
        }
        let machine = factory.pingMachine
        XCTAssertTrue(compiler.compile(machine))
    }

    /// Test generated code matches expected.
    func testGenerateVHDLFile() {
        let code = compiler.generateVHDLFile(machine)
        XCTAssertEqual(code, vhdl, "\(code.difference(from: vhdl))")
    }

    // swiftlint:disable line_length

    /// The vhdl code for the test machine.
    private let vhdl = """
        library IEEE;
        use IEEE.std_logic_1164.ALL;

        entity TestMachine is
            generic (
                y: integer range 0 to 65535 := 0; -- A uint16 variable called y.
                yy: boolean := false -- A variable called yy
            );
            port (
                clk: in std_logic;
                clk2: in std_logic;
                EXTERNAL_x: in std_logic := '1'; -- A std_logic variable.
                EXTERNAL_xx: out std_logic_vector(1 downto 0) := "00"; -- A variable called xx.
                suspended: out std_logic;
                PARAMETER_parX: in std_logic := '1'; -- Parameter parX
                PARAMETER_parXs: in std_logic_vector(1 downto 0) := "01"; -- Parameter parXs
                OUTPUT_retX: out std_logic; -- Returnable retX
                OUTPUT_retXs: out std_logic_vector(1 downto 0); -- Returnable retXs
                command: in std_logic_vector(1 downto 0)
            );
        end TestMachine;


        architecture Behavioral of TestMachine is
            -- Internal State Representation Bits
            constant ReadSnapshot: std_logic_vector(3 downto 0) := "0000";
            constant OnSuspend: std_logic_vector(3 downto 0) := "0001";
            constant OnResume: std_logic_vector(3 downto 0) := "0010";
            constant OnEntry: std_logic_vector(3 downto 0) := "0011";
            constant NoOnEntry: std_logic_vector(3 downto 0) := "0100";
            constant CheckTransition: std_logic_vector(3 downto 0) := "0101";
            constant OnExit: std_logic_vector(3 downto 0) := "0110";
            constant Internal: std_logic_vector(3 downto 0) := "0111";
            constant WriteSnapshot: std_logic_vector(3 downto 0) := "1000";
            signal internalState: std_logic_vector(3 downto 0) := ReadSnapshot;
            -- State Representation Bits
            constant STATE_Initial: std_logic_vector(1 downto 0) := "00";
            constant STATE_Suspended: std_logic_vector(1 downto 0) := "01";
            constant STATE_State0: std_logic_vector(1 downto 0) := "10";
            signal currentState: std_logic_vector(1 downto 0) := STATE_Suspended;
            signal targetState: std_logic_vector(1 downto 0) := STATE_Suspended;
            signal previousRinglet: std_logic_vector(1 downto 0) := "ZZ";
            signal suspendedFrom: std_logic_vector(1 downto 0) := STATE_Initial;
            -- Suspension Commands
            constant COMMAND_NULL: std_logic_vector(1 downto 0) := "00";
            constant COMMAND_RESTART: std_logic_vector(1 downto 0) := "01";
            constant COMMAND_SUSPEND: std_logic_vector(1 downto 0) := "10";
            constant COMMAND_RESUME: std_logic_vector(1 downto 0) := "11";
            -- After Variables
            signal ringlet_counter: natural := 0;
            constant clockPeriod: real := 20000.00; -- ps
            constant ringletLength: real := 5.0 * clockPeriod;
            constant RINGLETS_PER_PS: real := 1.0 / ringletLength;
            constant RINGLETS_PER_NS: real := 1000.0 * RINGLETS_PER_PS;
            constant RINGLETS_PER_US: real := 1000000.0 * RINGLETS_PER_PS;
            constant RINGLETS_PER_MS: real := 1000000000.0 * RINGLETS_PER_PS;
            constant RINGLETS_PER_S: real := 1000000000000.0 * RINGLETS_PER_PS;
            constant ZERO: real := 0.0;
            -- Snapshot of External Signals and Variables
            signal x: std_logic;
            signal xx: std_logic_vector(1 downto 0);
            -- Snapshot of Parameter Signals and Variables
            signal parX: std_logic;
            signal parXs: std_logic_vector(1 downto 0);
            -- Snapshot of Output Signals and Variables
            signal retX: std_logic;
            signal retXs: std_logic_vector(1 downto 0);
            -- Machine Signals
            signal machineSignal1: std_logic;
            signal machineSignal2: std_logic_vector(2 downto 0) := "111"; -- machine signal 2
            -- User-Specific Code for Architecture Head
        begin
            -- User-Specific Code for Architecture Body
            process(clk)
                variable STATE_Initial_Transition0: boolean := false;
                variable STATE_Initial_Transition1: boolean := false;
                variable STATE_Initial_Transition2: boolean := false;
                variable STATE_Suspended_Transition0: boolean := false;
                variable STATE_Suspended_Transition1: boolean := false;
                variable STATE_Suspended_Transition2: boolean := false;
            begin
                if (rising_edge(clk)) then
                    case internalState is
                        when ReadSnapshot =>
                            x <= EXTERNAL_x;
                            if (command = COMMAND_RESTART) then
                                parX <= PARAMETER_parX;
                                parXs <= PARAMETER_parXs;
                            end if;
                            if (command = COMMAND_RESTART and currentState /= STATE_Initial) then
                                currentState <= STATE_Initial;
                                suspended <= '0';
                                suspendedFrom <= STATE_Initial;
                                targetState <= STATE_Initial;
                                if (previousRinglet = STATE_Suspended) then
                                    internalState <= onResume;
                                elsif (previousRinglet = STATE_Initial) then
                                    internalState <= NoOnEntry;
                                else
                                    internalState <= onEntry;
                                end if;
                            elsif (command = COMMAND_RESUME and currentState = STATE_Suspended and suspendedFrom /= STATE_Suspended) then
                                suspended <= '0';
                                currentState <= suspendedFrom;
                                targetState <= suspendedFrom;
                                if (previousRinglet = suspendedFrom) then
                                    internalState <= NoOnEntry;
                                else
                                    internalState <= onResume;
                                end if;
                            elsif (command = COMMAND_SUSPEND and currentState /= STATE_Suspended) then
                                suspendedFrom <= currentState;
                                suspended <= '1';
                                currentState <= STATE_Suspended;
                                targetState <= STATE_Suspended;
                                if (previousRinglet = STATE_Suspended) then
                                    internalState <= NoOnEntry;
                                else
                                    internalState <= onSuspend;
                                end if;
                            elsif (currentState = STATE_Suspended) then
                                suspended <= '1';
                                if (previousRinglet /= STATE_Suspended) then
                                    internalState <= onSuspend;
                                else
                                    internalState <= NoOnEntry;
                                end if;
                            elsif (previousRinglet = STATE_Suspended) then
                                internalState <= OnResume;
                                suspended <= '0';
                                suspendedFrom <= currentState;
                            else
                                suspended <= '0';
                                suspendedFrom <= currentState;
                                if (previousRinglet /= currentState) then
                                    internalState <= onEntry;
                                else
                                    internalState <= NoOnEntry;
                                end if;
                            end if;
                        when OnResume =>
                            case currentState is
                                when STATE_Initial =>
                                    x <= '0'; -- Initial OnResume
                                    x <= '1';
                                    xx <= "00"; -- Initial onEntry
                                    ringlet_counter <= 0;
                                when STATE_Suspended =>
                                    x <= '0'; -- Suspended OnResume
                                    x <= '1';
                                    xx <= "00"; -- Suspended onEntry
                                when STATE_State0 =>
                                    x <= '0'; -- State0 OnResume
                                    x <= '1';
                                    xx <= "00"; -- State0 onEntry
                                when others =>
                                    null;
                            end case;
                            internalState <= CheckTransition;
                        when OnSuspend =>
                            case suspendedFrom is
                                when STATE_Initial =>
                                    xx <= "11"; -- Initial onSuspend
                                when STATE_Suspended =>
                                    xx <= "11"; -- Suspended onSuspend
                                when STATE_State0 =>
                                    xx <= "11"; -- State0 onSuspend
                                when others =>
                                    null;
                            end case;
                            x <= '1';
                            xx <= "00"; -- Suspended onEntry
                            internalState <= CheckTransition;
                        when OnEntry =>
                            case currentState is
                                when STATE_Initial =>
                                    x <= '1';
                                    xx <= "00"; -- Initial onEntry
                                    ringlet_counter <= 0;
                                when STATE_Suspended =>
                                    x <= '1';
                                    xx <= "00"; -- Suspended onEntry
                                when STATE_State0 =>
                                    x <= '1';
                                    xx <= "00"; -- State0 onEntry
                                when others =>
                                    null;
                            end case;
                            internalState <= CheckTransition;
                        when NoOnEntry =>
                            internalState <= CheckTransition;
                        when CheckTransition =>
                            case currentState is
                                when STATE_Initial =>
                                    STATE_Initial_Transition0 := false;
                                    STATE_Initial_Transition1 := (((ringlet_counter >= natural((50.0) * RINGLETS_PER_MS)) or ((50.0) * RINGLETS_PER_MS < ZERO)) or ((ringlet_counter >= natural((2.0) * RINGLETS_PER_S)) or ((2.0) * RINGLETS_PER_S < ZERO)) or ((ringlet_counter >= natural((20000.0))) or ((20000.0) < ZERO))) and (not (STATE_Initial_Transition0));
                                    STATE_Initial_Transition2 := (true) and (not (STATE_Initial_Transition1));
                                    if (STATE_Initial_Transition0) then
                                        targetState <= STATE_Suspended;
                                        internalState <= OnExit;
                                    elsif (STATE_Initial_Transition1) then
                                        targetState <= STATE_Suspended;
                                        internalState <= OnExit;
                                    elsif (STATE_Initial_Transition2) then
                                        targetState <= STATE_Suspended;
                                        internalState <= OnExit;
                                    else
                                        internalState <= Internal;
                                    end if;
                                when STATE_Suspended =>
                                    STATE_Suspended_Transition0 := xx = "11";
                                    STATE_Suspended_Transition1 := (x = '1') and (not (STATE_Suspended_Transition0));
                                    STATE_Suspended_Transition2 := (true) and (not (STATE_Suspended_Transition1));
                                    if (STATE_Suspended_Transition0) then
                                        targetState <= STATE_State0;
                                        internalState <= OnExit;
                                    elsif (STATE_Suspended_Transition1) then
                                        targetState <= STATE_State0;
                                        internalState <= OnExit;
                                    elsif (STATE_Suspended_Transition2) then
                                        targetState <= STATE_Initial;
                                        internalState <= OnExit;
                                    else
                                        internalState <= Internal;
                                    end if;
                                when others =>
                                    internalState <= Internal;
                            end case;
                        when OnExit =>
                            case currentState is
                                when STATE_Initial =>
                                    x <= '0'; -- Initial OnExit
                                when STATE_Suspended =>
                                    x <= '0'; -- Suspended OnExit
                                when STATE_State0 =>
                                    x <= '0'; -- State0 OnExit
                                when others =>
                                    null;
                            end case;
                            internalState <= WriteSnapshot;
                        when Internal =>
                            case currentState is
                                when STATE_Initial =>
                                    x <= '1'; -- Initial Internal
                                    ringlet_counter <= ringlet_counter + 1;
                                when STATE_Suspended =>
                                    x <= '1'; -- Suspended Internal
                                when STATE_State0 =>
                                    x <= '1'; -- State0 Internal
                                when others =>
                                    null;
                            end case;
                            internalState <= WriteSnapshot;
                        when WriteSnapshot =>
                            EXTERNAL_xx <= xx;
                            internalState <= ReadSnapshot;
                            previousRinglet <= currentState;
                            currentState <= targetState;
                            if (currentState = STATE_Suspended) then
                                OUTPUT_retX <= retX;
                                OUTPUT_retXs <= retXs;
                            end if;
                        when others =>
                            null;
                    end case;
                end if;
            end process;
        end Behavioral;
        """

    // swiftlint:enable line_length
    // swiftlint:enable type_contents_order

}

// swiftlint:enable type_body_length
// swiftlint:enable file_length
