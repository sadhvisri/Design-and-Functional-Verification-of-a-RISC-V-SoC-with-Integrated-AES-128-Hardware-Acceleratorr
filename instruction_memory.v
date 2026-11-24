
module instruction_memory (
    input wire [31:0] address,
    output reg [31:0] instruction
);

    reg [31:0] memory [0:255];
    integer i;

    always @(*) begin
        instruction = memory[address[9:2]];
    end

    initial begin

        // Initialize instruction memory with NOPs
        for (i = 0; i < 256; i = i + 1)
            memory[i] = 32'h00000013;

        // AES base address = 0x1000
        memory[0] = 32'h000010B7; // LUI x1,0x1

        // --------------------------------
        // PLAINTEXT: 00112233445566778899AABBCCDDEEFF
        // --------------------------------

        memory[1]  = 32'h00112137;
        memory[2]  = 32'h23310113;
        memory[3]  = 32'h0020A023;

        memory[4]  = 32'h44556137;
        memory[5]  = 32'h67710113;
        memory[6]  = 32'h0020A223;

        memory[7]  = 32'h8899B137;
        memory[8]  = 32'hABB10113;
        memory[9]  = 32'h0020A423;

        memory[10] = 32'hCCDDF137;
        memory[11] = 32'hEFF10113;
        memory[12] = 32'h0020A623;

        // --------------------------------
        // AES KEY: 000102030405060708090A0B0C0D0E0F
        // --------------------------------

        memory[13] = 32'h00010137;
        memory[14] = 32'h20310113;
        memory[15] = 32'h0020A823;

        memory[16] = 32'h04050137;
        memory[17] = 32'h60710113;
        memory[18] = 32'h0020AA23;

        memory[19] = 32'h08091137;
        memory[20] = 32'hA0B10113;
        memory[21] = 32'h0020AC23;

        memory[22] = 32'h0C0D1137;
        memory[23] = 32'hE0F10113;
        memory[24] = 32'h0020AE23;

        // --------------------------------
        // START AES ENCRYPTION
        // --------------------------------

        memory[25] = 32'h00100193; // ADDI x3,x0,1
        memory[26] = 32'h0230A023; // SW x3,32(x1)

        // --------------------------------
        // CHECK AES BUSY STATUS
        // --------------------------------

        memory[27] = 32'h0240A203; // LW x4,36(x1)
        memory[28] = 32'h00127213; // ANDI x4,x4,1

        // If busy = 0, continue
        memory[29] = 32'h00020463; // BEQ x4,x0,+8

        // Otherwise repeat status check
        memory[30] = 32'hFF5FF06F; // JAL x0,-12

        // --------------------------------
        // READ CIPHERTEXT
        // --------------------------------

        memory[31] = 32'h0280A283; // LW x5,40(x1)
        memory[32] = 32'h02C0A303; // LW x6,44(x1)
        memory[33] = 32'h0300A383; // LW x7,48(x1)
        memory[34] = 32'h0340A403; // LW x8,52(x1)

        // --------------------------------
        // STORE CIPHERTEXT IN DATA RAM
        // --------------------------------

        memory[35] = 32'h00502023; // SW x5,0(x0)
        memory[36] = 32'h00602223; // SW x6,4(x0)
        memory[37] = 32'h00702423; // SW x7,8(x0)
        memory[38] = 32'h00802623; // SW x8,12(x0)

        // Infinite loop
        memory[39] = 32'h0000006F;

    end

endmodule
