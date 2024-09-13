//
//  File.swift
//  
//
//  Created by Morgan McColl on 19/5/21.
//

import Foundation
import SwiftUtils
import TestUtils
@testable import VHDLMachines
import VHDLParsing
import XCTest

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
        Machine.testMachine(directory: testMachinePath)
    }

    /// The representation of the machine.
    var representation: MachineRepresentation {
        // swiftlint:disable:next force_unwrapping
        MachineRepresentation(machine: machine, name: .testMachine)!
    }

    /// Factory generating PingPong arrangements.
    let factory = PingPongArrangement()

    /// IO Helper.
    let manager = FileManager.default

    /// FileWrapper for the test machine.
    var testMachineFileWrapper: FileWrapper? {
        VHDLGenerator().generate(machine: machine, with: .testMachine)
    }

    // swiftlint:disable type_contents_order

    /// Default state creation.
    private func defaultState(name: String) -> VHDLMachines.State {
        VHDLMachines.State(
            // swiftlint:disable force_unwrapping
            name: VariableName(rawValue: name)!,
            actions: [
                VariableName.onEntry: SynchronousBlock(
                    rawValue: "x <= '1';\nxx <= \"00\"; -- \(name) onEntry"
                )!,
                VariableName.onExit: SynchronousBlock(rawValue: "x <= '0'; -- \(name) OnExit")!,
                VariableName.onResume: SynchronousBlock(rawValue: "x <= '0'; -- \(name) OnResume")!,
                VariableName.onSuspend: SynchronousBlock(rawValue: "xx <= \"11\"; -- \(name) onSuspend")!,
                VariableName.internal: SynchronousBlock(rawValue: "x <= '1'; -- \(name) Internal")!
            ],
            signals: [],
            externalVariables: []
            // swiftlint:enable force_unwrapping
        )
    }

    /// Test can compile initial machine.
    func testInitialMachine() {
        guard let wrapper = compiler.compile(machine: machine, name: .testMachine) else {
            XCTFail("Failed to create wrapper!")
            return
        }
        XCTAssertNil(wrapper.preferredFilename)
        XCTAssertNil(wrapper.filename)
        XCTAssertEqual(wrapper.fileWrappers?.count, 1)
        let file = wrapper.fileWrappers?.first
        XCTAssertEqual(file?.key, "TestMachine.vhd")
        XCTAssertEqual(file?.value.preferredFilename, "TestMachine.vhd")
        guard let data = file?.value.regularFileContents else {
            XCTFail("File is empty!")
            return
        }
        let rawValue = String(data: data, encoding: .utf8)
        XCTAssertEqual(rawValue, VHDLFile(representation: representation).rawValue)
        let f: (Machine, VariableName) -> MachineRepresentation? = { _, _ in nil }
        XCTAssertNil(compiler.compile(machine: machine, name: .testMachine, createRepresentation: f))
    }

    /// Test that an arrangement is generated correctly.
    func testArrangementGeneration() {
        let arrangement = Arrangement.testArrangement
        guard let wrapper = compiler.compile(arrangement: arrangement, name: .arrangement1) else {
            XCTFail("Failed to create arrangement wrapper!")
            return
        }
        XCTAssertNil(wrapper.preferredFilename)
        XCTAssertNil(wrapper.filename)
        XCTAssertEqual(wrapper.fileWrappers?.count, 1)
        let file = wrapper.fileWrappers?.first
        XCTAssertEqual(file?.key, "Arrangement1.vhd")
        XCTAssertEqual(file?.value.preferredFilename, "Arrangement1.vhd")
        let data = file?.value.regularFileContents
        guard
            let rawValue = data.flatMap({ String(data: $0, encoding: .utf8) }),
            let expected = ArrangementRepresentation(
                arrangement: arrangement, name: .arrangement1
            )?.file.rawValue
        else {
            XCTFail("File is empty!")
            return
        }
        XCTAssertEqual(rawValue, expected)
        let f: (Arrangement, VariableName) -> ArrangementRepresentation? = { _, _ in nil }
        XCTAssertNil(compiler.compile(arrangement: arrangement, name: .arrangement1, createRepresentation: f))
    }

    // swiftlint:disable line_length

    /// The vhdl code for the test machine.
    private let vhdl = """
        library IEEE;
        use IEEE.std_logic_1164.all;
        use IEEE.math_real.all;

        entity TestMachine is
            port(
                clk: in std_logic;
                clk2: in std_logic;
                EXTERNAL_x: in std_logic := '1'; -- A std_logic variable.
                EXTERNAL_xx: out std_logic_vector(1 downto 0) := "00"; -- A variable called xx.
                PARAMETER_parX: in std_logic := '1'; -- Parameter parX
                PARAMETER_parXs: in std_logic_vector(1 downto 0) := "01"; -- Parameter parXs
                OUTPUT_retX: out std_logic; -- Returnable retX
                OUTPUT_retXs: out std_logic_vector(1 downto 0); -- Returnable retXs
                suspended: out std_logic;
                command: in std_logic_vector(1 downto 0)
            );
        end TestMachine;

        architecture Behavioral of TestMachine is
            -- Internal State Representation Bits
            constant CheckTransition: std_logic_vector(3 downto 0) := "0000";
            constant Internal: std_logic_vector(3 downto 0) := "0001";
            constant NoOnEntry: std_logic_vector(3 downto 0) := "0010";
            constant OnEntry: std_logic_vector(3 downto 0) := "0011";
            constant OnExit: std_logic_vector(3 downto 0) := "0100";
            constant OnResume: std_logic_vector(3 downto 0) := "0101";
            constant OnSuspend: std_logic_vector(3 downto 0) := "0110";
            constant ReadSnapshot: std_logic_vector(3 downto 0) := "0111";
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
            constant clockPeriod: real := 20000.0; -- ps
            constant ringletLength: real := 5.0 * clockPeriod;
            constant RINGLETS_PER_PS: real := 1.0 / ringletLength;
            constant RINGLETS_PER_NS: real := 1000.0 * RINGLETS_PER_PS;
            constant RINGLETS_PER_US: real := 1000000.0 * RINGLETS_PER_PS;
            constant RINGLETS_PER_MS: real := 1000000000.0 * RINGLETS_PER_PS;
            constant RINGLETS_PER_S: real := 1000000000000.0 * RINGLETS_PER_PS;
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
            -- State Signals
            signal STATE_Initial_initialX: std_logic;
            signal STATE_Initial_z: std_logic;
        begin
            process(clk)
            begin
                if (rising_edge(clk)) then
                    case internalState is
                        when CheckTransition =>
                            case currentState is
                                when STATE_Initial =>
                                    if (STATE_Initial_z = '1') then
                                        targetState <= STATE_Suspended;
                                        internalState <= OnExit;
                                    elsif (false) then
                                        targetState <= STATE_Suspended;
                                        internalState <= OnExit;
                                    elsif ((ringlet_counter >= integer(ceil(real(50.0) * RINGLETS_PER_MS))) or (ringlet_counter >= integer(ceil(real(2.0) * RINGLETS_PER_S))) or (ringlet_counter >= integer(ceil(real(20000.0))))) then
                                        targetState <= STATE_Suspended;
                                        internalState <= OnExit;
                                    elsif (true) then
                                        targetState <= STATE_Suspended;
                                        internalState <= OnExit;
                                    else
                                        internalState <= Internal;
                                    end if;
                                when STATE_Suspended =>
                                    if (xx = "11") then
                                        targetState <= STATE_State0;
                                        internalState <= OnExit;
                                    elsif (x = '1') then
                                        targetState <= STATE_State0;
                                        internalState <= OnExit;
                                    elsif (true) then
                                        targetState <= STATE_Initial;
                                        internalState <= OnExit;
                                    else
                                        internalState <= Internal;
                                    end if;
                                when others =>
                                    internalState <= Internal;
                            end case;
                        when Internal =>
                            case currentState is
                                when STATE_Initial =>
                                    x <= '1';
                                    ringlet_counter <= ringlet_counter + 1;
                                when STATE_Suspended =>
                                    x <= '1';
                                when STATE_State0 =>
                                    x <= '1';
                                when others =>
                                    null;
                            end case;
                            internalState <= WriteSnapshot;
                        when NoOnEntry =>
                            internalState <= CheckTransition;
                        when OnEntry =>
                            case currentState is
                                when STATE_Initial =>
                                    STATE_Initial_z <= '0';
                                    ringlet_counter <= 0;
                                when STATE_Suspended =>
                                    x <= '1';
                                    xx <= "00";
                                when STATE_State0 =>
                                    x <= '1';
                                    xx <= "00";
                                when others =>
                                    null;
                            end case;
                            internalState <= CheckTransition;
                        when OnExit =>
                            case currentState is
                                when STATE_Initial =>
                                    x <= '0';
                                when STATE_Suspended =>
                                    x <= '0';
                                when STATE_State0 =>
                                    x <= '0';
                                when others =>
                                    null;
                            end case;
                            internalState <= WriteSnapshot;
                        when OnResume =>
                            case currentState is
                                when STATE_Initial =>
                                    x <= '0';
                                    STATE_Initial_z <= '0';
                                    ringlet_counter <= 0;
                                when STATE_Suspended =>
                                    x <= '0';
                                    x <= '1';
                                    xx <= "00";
                                when STATE_State0 =>
                                    x <= '0';
                                    x <= '1';
                                    xx <= "00";
                                when others =>
                                    null;
                            end case;
                            internalState <= CheckTransition;
                        when OnSuspend =>
                            case suspendedFrom is
                                when STATE_Initial =>
                                    xx <= "11";
                                when STATE_Suspended =>
                                    xx <= "11";
                                when STATE_State0 =>
                                    xx <= "11";
                                when others =>
                                    null;
                            end case;
                            x <= '1';
                            xx <= "00";
                            internalState <= CheckTransition;
                        when ReadSnapshot =>
                            case currentState is
                                when STATE_Initial =>
                                    x <= EXTERNAL_x;
                                when STATE_Suspended =>
                                    x <= EXTERNAL_x;
                                when STATE_State0 =>
                                    x <= EXTERNAL_x;
                                when others =>
                                    null;
                            end case;
                            if (command = COMMAND_RESTART) then
                                parX <= PARAMETER_parX;
                                parXs <= PARAMETER_parXs;
                            end if;
                            if ((command = COMMAND_RESTART) and (currentState /= STATE_Initial)) then
                                currentState <= STATE_Initial;
                                suspended <= '0';
                                suspendedFrom <= STATE_Initial;
                                targetState <= STATE_Initial;
                                if (previousRinglet = STATE_Suspended) then
                                    internalState <= OnResume;
                                elsif (previousRinglet = STATE_Initial) then
                                    internalState <= NoOnEntry;
                                else
                                    internalState <= OnEntry;
                                end if;
                            elsif ((command = COMMAND_RESUME) and ((currentState = STATE_Suspended) and (suspendedFrom /= STATE_Suspended))) then
                                suspended <= '0';
                                currentState <= suspendedFrom;
                                targetState <= suspendedFrom;
                                if (previousRinglet = suspendedFrom) then
                                    internalState <= NoOnEntry;
                                else
                                    internalState <= OnResume;
                                end if;
                            elsif ((command = COMMAND_SUSPEND) and (currentState /= STATE_Suspended)) then
                                suspendedFrom <= currentState;
                                suspended <= '1';
                                currentState <= STATE_Suspended;
                                targetState <= STATE_Suspended;
                                if (previousRinglet = STATE_Suspended) then
                                    internalState <= NoOnEntry;
                                else
                                    internalState <= OnSuspend;
                                end if;
                            elsif (currentState = STATE_Suspended) then
                                suspended <= '1';
                                if (previousRinglet /= STATE_Suspended) then
                                    internalState <= OnSuspend;
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
                                    internalState <= OnEntry;
                                else
                                    internalState <= NoOnEntry;
                                end if;
                            end if;
                        when WriteSnapshot =>
                            case currentState is
                                when STATE_Initial =>
                                    EXTERNAL_xx <= xx;
                                when STATE_Suspended =>
                                    EXTERNAL_xx <= xx;
                                when STATE_State0 =>
                                    EXTERNAL_xx <= xx;
                                when others =>
                                    null;
                            end case;
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
