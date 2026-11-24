
`timescale 1ns / 1ps

module soc_tb;

    reg clk;
    reg reset;

    wire [31:0] debug_pc;
    wire [31:0] debug_mem0;

    soc_top dut (
        .clk(clk),
        .reset(reset),
        .debug_pc(debug_pc),
        .debug_mem0(debug_mem0)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test sequence
    initial begin

        $display("================================");
        $display(" RISC-V SoC Simulation Started");
        $display("================================");

        reset = 1;
        #20;

        reset = 0;

        // Wait for processor instructions
        #100;

        $display("Program Counter = %h", debug_pc);
        $display("Memory[0] = %d", debug_mem0);

        if (debug_mem0 == 32'd12) begin
            $display("TEST PASSED");
            $display("RISC-V processor executed correctly.");
        end
        else begin
            $display("TEST FAILED");
        end

        $display("================================");

        $finish;
    end

endmodule
