
module data_memory (
    input wire clk,
    input wire write_enable,
    input wire [31:0] address,
    input wire [31:0] write_data,
    output wire [31:0] read_data
);

    reg [31:0] memory [0:255];

    assign read_data = memory[address[9:2]];

    integer i;

    initial begin
        for (i = 0; i < 256; i = i + 1)
            memory[i] = 32'b0;
    end

    always @(posedge clk) begin
        if (write_enable)
            memory[address[9:2]] <= write_data;
    end

endmodule
