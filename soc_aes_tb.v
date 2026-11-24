
`timescale 1ns/1ps

module soc_aes_tb;

    reg clk;
    reg reset;

    wire [31:0] debug_pc;
    wire [31:0] debug_mem0;
    wire aes_busy_debug;
    wire aes_done_debug;

    // Instantiate complete RISC-V AES SoC
    soc_top dut (
        .clk(clk),
        .reset(reset),
        .debug_pc(debug_pc),
        .debug_mem0(debug_mem0),
        .aes_busy_debug(aes_busy_debug),
        .aes_done_debug(aes_done_debug)
    );

    // Clock generation: 10 ns period
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // Main test
    initial begin

        $display("======================================");
        $display(" RISC-V AES SoC Simulation Started");
        $display("======================================");

        // Apply reset
        reset = 1'b1;
        #20;
        reset = 1'b0;

        $display("RISC-V processor running...");
        $display("Loading plaintext and AES key...");

        // Wait until all four ciphertext words are stored
        wait (
            dut.dmem.memory[0] == 32'h69C4E0D8 &&
            dut.dmem.memory[1] == 32'h6A7B0430 &&
            dut.dmem.memory[2] == 32'hD8CDB780 &&
            dut.dmem.memory[3] == 32'h70B4C55A
        );

        #10;

        $display("--------------------------------------");
        $display("AES encryption completed");

        $display("Ciphertext = %08h%08h%08h%08h",
            dut.dmem.memory[0],
            dut.dmem.memory[1],
            dut.dmem.memory[2],
            dut.dmem.memory[3]);

        $display("--------------------------------------");

        // Verify complete ciphertext
        if (
            dut.dmem.memory[0] == 32'h69C4E0D8 &&
            dut.dmem.memory[1] == 32'h6A7B0430 &&
            dut.dmem.memory[2] == 32'hD8CDB780 &&
            dut.dmem.memory[3] == 32'h70B4C55A
        ) begin

            $display("RISC-V AES SOC TEST PASSED");

        end else begin

            $display("RISC-V AES SOC TEST FAILED");

        end

        $display("Program Counter = %h", debug_pc);
        $display("AES Busy = %b", aes_busy_debug);
        $display("AES Done = %b", aes_done_debug);

        $display("======================================");

        $finish;

    end

    // Timeout protection
    initial begin

        #3000;

        $display("ERROR: RISC-V AES SoC timeout");
        $display("Program Counter = %h", debug_pc);

        $finish;

    end

endmodule
