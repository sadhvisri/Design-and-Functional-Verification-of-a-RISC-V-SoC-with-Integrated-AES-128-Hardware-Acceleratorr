
module soc_top (
    input wire clk,
    input wire reset,

    output wire [31:0] debug_pc,
    output wire [31:0] debug_mem0,

    output wire aes_busy_debug,
    output wire aes_done_debug
);

    wire [31:0] instruction;
    wire [31:0] mem_addr;
    wire [31:0] write_data;
    wire [31:0] read_data;
    wire mem_write;

    wire [31:0] ram_read_data;
    wire [31:0] aes_read_data;

    wire ram_write_enable;
    wire aes_write_enable;

    // Address decoding
    wire ram_select = (mem_addr < 32'h00000400);

    wire aes_select =
        (mem_addr >= 32'h00001000) &&
        (mem_addr <= 32'h00001034);

    assign ram_write_enable = mem_write && ram_select;
    assign aes_write_enable = mem_write && aes_select;

    // Read data multiplexer
    assign read_data =
        ram_select ? ram_read_data :
        aes_select ? aes_read_data :
        32'b0;

    // RISC-V CPU
    rv32i_cpu cpu (
        .clk(clk),
        .reset(reset),
        .instr(instruction),
        .read_data(read_data),
        .pc(debug_pc),
        .mem_addr(mem_addr),
        .write_data(write_data),
        .mem_write(mem_write)
    );

    // Instruction memory
    instruction_memory imem (
        .address(debug_pc),
        .instruction(instruction)
    );

    // Normal data memory
    data_memory dmem (
        .clk(clk),
        .write_enable(ram_write_enable),
        .address(mem_addr),
        .write_data(write_data),
        .read_data(ram_read_data)
    );

    // AES memory-mapped interface
    aes_mmio aes_interface (
        .clk(clk),
        .reset(reset),
        .write_enable(aes_write_enable),
        .address(mem_addr),
        .write_data(write_data),
        .read_data(aes_read_data)
    );

    assign debug_mem0 = dmem.memory[0];

    assign aes_busy_debug = aes_interface.aes_busy;
    assign aes_done_debug = aes_interface.aes_done;

endmodule
