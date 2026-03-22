`timescale 1ns/1ps
// ============================================================
//  Testbench — ofdm_transmitter (full chain)

//  Output appears 1 cycle after data_valid.
// ============================================================
module tb_ofdm_transmitter;

    reg        clk, reset_n, data_valid;
    reg  [3:0] data_in;

    wire signed [15:0] out0r,out0i,out1r,out1i,out2r,out2i,out3r,out3i,out4r,out4i;
    wire        symbol_valid;

    ofdm_transmitter dut (
        .clk(clk),.reset_n(reset_n),.data_in(data_in),.data_valid(data_valid),
        .out0r(out0r),.out0i(out0i),.out1r(out1r),.out1i(out1i),
        .out2r(out2r),.out2i(out2i),.out3r(out3r),.out3i(out3i),
        .out4r(out4r),.out4i(out4i),.symbol_valid(symbol_valid)
    );

    always #5 clk = ~clk;

    task check_symbol;
        input [7:0] label;
        input signed [15:0] ex0r,ex0i,ex1r,ex1i,ex2r,ex2i,ex3r,ex3i;
        reg cp_ok;
        begin
            cp_ok = (out0r==out4r) && (out0i==out4i);
            $display("TEST %0d: valid=%0d CP==x3:%s", label, symbol_valid, cp_ok?"OK":"BUG");
            $display("  CP=(%0d,%0d) x0=(%0d,%0d) x1=(%0d,%0d) x2=(%0d,%0d) x3=(%0d,%0d)",
                     out0r,out0i,out1r,out1i,out2r,out2i,out3r,out3i,out4r,out4i);
            if(out1r==ex0r&&out1i==ex0i&&out2r==ex1r&&out2i==ex1i&&
               out3r==ex2r&&out3i==ex2i&&out4r==ex3r&&out4i==ex3i&&cp_ok)
                $display("  PASSED");
            else
                $display("  FAILED (expected x0=(%0d,%0d) x1=(%0d,%0d) x2=(%0d,%0d) x3=(%0d,%0d))",
                         ex0r,ex0i,ex1r,ex1i,ex2r,ex2i,ex3r,ex3i);
        end
    endtask

    initial begin
        $display("=== OFDM Transmitter Testbench ===");
        clk=0; reset_n=0; data_valid=0; data_in=0;
        repeat(2) @(posedge clk); #1; reset_n=1;

        // 0000 → QAM(1,1)   → x0=(2,2) x1=(0,2) x2=(0,0) x3=(2,0)
        @(posedge clk); #1; data_in=4'b0000; data_valid=1;
        @(posedge clk); #1; data_valid=0;
        check_symbol(1, 2,2, 0,2, 0,0, 2,0);

        // 1100 → QAM(2,2)   → x0=(4,4) x1=(0,4) x2=(0,0) x3=(4,0)
        repeat(2) @(posedge clk); #1; data_in=4'b1100; data_valid=1;
        @(posedge clk); #1; data_valid=0;
        check_symbol(2, 4,4, 0,4, 0,0, 4,0);

        // 0011 → QAM(-1,-1) → x0=(-2,-2) x1=(0,-2) x2=(0,0) x3=(-2,0)
        repeat(2) @(posedge clk); #1; data_in=4'b0011; data_valid=1;
        @(posedge clk); #1; data_valid=0;
        check_symbol(3, -2,-2, 0,-2, 0,0, -2,0);

        // 0100 → QAM(2,1)   → x0=(4,2) x1=(1,3) x2=(0,0) x3=(3,-1)
        repeat(2) @(posedge clk); #1; data_in=4'b0100; data_valid=1;
        @(posedge clk); #1; data_valid=0;
        check_symbol(4, 4,2, 1,3, 0,0, 3,-1);

        // valid_out should be low with no data_valid
        repeat(2) @(posedge clk); #1;
        if(symbol_valid===0) $display("TEST 5 PASSED: symbol_valid low");
        else                 $display("TEST 5 FAILED: symbol_valid stuck high");

        // reset test
        data_in=4'b1111; data_valid=1;
        @(posedge clk); #1; reset_n=0;
        @(posedge clk); #1;
        if(symbol_valid===0) $display("TEST 6 PASSED: reset works");
        else                 $display("TEST 6 FAILED");
        reset_n=1; data_valid=0;

        $display("=== done ===");
        $finish;
    end
endmodule
