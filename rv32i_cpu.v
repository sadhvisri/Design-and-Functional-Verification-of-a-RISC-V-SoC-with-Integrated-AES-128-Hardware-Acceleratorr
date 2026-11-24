
module rv32i_cpu (
    input wire clk,
    input wire reset,

    input wire [31:0] instr,
    input wire [31:0] read_data,

    output reg [31:0] pc,
    output reg [31:0] mem_addr,
    output reg [31:0] write_data,
    output reg mem_write
);

    reg [31:0] registers [0:31];

    wire [6:0] opcode = instr[6:0];
    wire [4:0] rd = instr[11:7];
    wire [2:0] funct3 = instr[14:12];
    wire [4:0] rs1 = instr[19:15];
    wire [4:0] rs2 = instr[24:20];
    wire [6:0] funct7 = instr[31:25];

    wire [31:0] reg1 =
        (rs1 == 0) ? 32'b0 : registers[rs1];

    wire [31:0] reg2 =
        (rs2 == 0) ? 32'b0 : registers[rs2];

    wire [31:0] imm_i =
        {{20{instr[31]}}, instr[31:20]};

    wire [31:0] imm_s =
        {{20{instr[31]}}, instr[31:25], instr[11:7]};

    wire [31:0] imm_b =
        {{19{instr[31]}}, instr[31], instr[7],
         instr[30:25], instr[11:8], 1'b0};

    wire [31:0] imm_u =
        {instr[31:12], 12'b0};

    wire [31:0] imm_j =
        {{11{instr[31]}}, instr[31],
         instr[19:12], instr[20],
         instr[30:21], 1'b0};

    reg [31:0] next_pc;
    reg [31:0] result;
    reg reg_write;

    always @(*) begin

        next_pc = pc + 4;
        result = 32'b0;
        reg_write = 1'b0;
        mem_addr = 32'b0;
        write_data = reg2;
        mem_write = 1'b0;

        case (opcode)

            // R-type
            7'b0110011: begin
                reg_write = 1'b1;

                case (funct3)

                    3'b000:
                        result = (funct7 == 7'b0100000)
                               ? reg1 - reg2
                               : reg1 + reg2;

                    3'b111: result = reg1 & reg2;
                    3'b110: result = reg1 | reg2;
                    3'b100: result = reg1 ^ reg2;

                    default: result = 0;

                endcase
            end

            // ADDI and ANDI
            7'b0010011: begin
                reg_write = 1'b1;

                case (funct3)

                    3'b000:
                        result = reg1 + imm_i;

                    3'b111:
                        result = reg1 & imm_i;

                    default:
                        result = 0;

                endcase
            end

            // LUI
            7'b0110111: begin
                reg_write = 1'b1;
                result = imm_u;
            end

            // LW
            7'b0000011: begin
                mem_addr = reg1 + imm_i;
                reg_write = 1'b1;
                result = read_data;
            end

            // SW
            7'b0100011: begin
                mem_addr = reg1 + imm_s;
                mem_write = 1'b1;
            end

            // BEQ
            7'b1100011: begin
                if (funct3 == 3'b000 &&
                    reg1 == reg2)
                    next_pc = pc + imm_b;
            end

            // JAL
            7'b1101111: begin
                reg_write = 1'b1;
                result = pc + 4;
                next_pc = pc + imm_j;
            end

            default: begin
                result = 0;
            end

        endcase
    end

    integer i;

    always @(posedge clk) begin

        if (reset) begin

            pc <= 32'b0;

            for (i = 0; i < 32; i = i + 1)
                registers[i] <= 32'b0;

        end else begin

            if (reg_write && rd != 0)
                registers[rd] <= result;

            registers[0] <= 32'b0;

            pc <= next_pc;

        end
    end

endmodule
