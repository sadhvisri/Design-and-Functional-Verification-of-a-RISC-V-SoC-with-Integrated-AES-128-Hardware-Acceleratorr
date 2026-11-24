`timescale 1ns/1ps

module aes128_seq_tb;

    reg clk;
    reg reset;
    reg start;
    reg [127:0] plaintext;
    reg [127:0] key;

    wire [127:0] ciphertext;
    wire busy;
    wire done;

    aes128_seq dut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .plaintext(plaintext),
        .key(key),
        .ciphertext(ciphertext),
        .busy(busy),
        .done(done)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 1'b0;
        reset = 1'b1;
        start = 1'b0;
        plaintext = 128'h00112233445566778899AABBCCDDEEFF;
        key       = 128'h000102030405060708090A0B0C0D0E0F;

        $display("AES-128 sequential test started");
        #20;
        reset = 1'b0;
        #10;
        start = 1'b1;
        #10;
        start = 1'b0;

        wait(done == 1'b1);
        #1;
        $display("Ciphertext = %h", ciphertext);

        if (ciphertext == 128'h69C4E0D86A7B0430D8CDB78070B4C55A)
            $display("AES TEST PASSED");
        else
            $display("AES TEST FAILED");

        #20;
        $finish;
    end

    initial begin
        #500;
        if (!done) begin
            $display("TIMEOUT: AES did not finish");
            $finish;
        end
    end

endmodule
