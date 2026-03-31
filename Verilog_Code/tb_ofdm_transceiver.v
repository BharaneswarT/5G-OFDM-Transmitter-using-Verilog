// ============================================================
//  Testbench — ofdm_transceiver (full loopback)
//
//  Tests every 16-QAM symbol (all 16 patterns).
//  For each symbol:
//    - Send data_in
//    - Wait for data_recovered to stabilize (2 cycles: 1 TX + 1 RX)
//    - Check data_recovered == data_in  (parallel check)
//    - Wait for all 4 serial bits and reassemble them
//    - Check serial reassembled == data_in
//
//  Expected timing:
//    Cycle 0: data_valid=1, data_in presented
//    Cycle 1: TX symbol_valid=1, RX sees samples, data_recovered valid
//    Cycle 1: serial_out starts (bit 3 = MSB)
//    Cycle 2: serial_out bit 2
//    Cycle 3: serial_out bit 1
//    Cycle 4: serial_out bit 0, tx_done=1 next cycle
// ============================================================

`timescale 1ns/1ps

module tb_ofdm_transceiver;

    reg        clk, reset_n, data_valid;
    reg  [3:0] data_in;

    wire        serial_out, tx_done, tx_busy;
    wire [3:0]  data_recovered;

    ofdm_transceiver dut (
        .clk           (clk),
        .reset_n       (reset_n),
        .data_in       (data_in),
        .data_valid    (data_valid),
        .serial_out    (serial_out),
        .tx_done       (tx_done),
        .tx_busy       (tx_busy),
        .data_recovered(data_recovered)
    );

    always #5 clk = ~clk;

    // Collect serial bits into a shift register for checking
    reg [3:0] serial_collected;
    reg [2:0] serial_count;
    reg       collecting;

    always @(posedge clk) begin
        if (tx_busy && collecting) begin
            serial_collected <= {serial_collected[2:0], serial_out};
            serial_count     <= serial_count + 1;
        end
    end

    integer i;
    integer pass_parallel, pass_serial, fail_count;

    initial begin
        $display("======================================");
        $display("  OFDM Transceiver — Full Loopback TB");
        $display("======================================");
        clk=0; reset_n=0; data_valid=0; data_in=0;
        collecting=0; serial_count=0; serial_collected=0;
        pass_parallel=0; pass_serial=0; fail_count=0;

        repeat(3) @(posedge clk); #1;
        reset_n = 1;
        repeat(2) @(posedge clk); #1;

        // Test all 16 QAM symbols
        for (i = 0; i < 16; i = i+1) begin
            // Send symbol
            data_in    = i[3:0];
            data_valid = 1;
            @(posedge clk); #1;
            data_valid = 0;

            // Cycle 1: TX latches, parallel output valid
            @(posedge clk); #1;

            // Check parallel recovery
            if (data_recovered === data_in) begin
                $display("Symbol %04b | parallel PASS | recovered=%04b", i[3:0], data_recovered);
                pass_parallel = pass_parallel + 1;
            end else begin
                $display("Symbol %04b | parallel FAIL | got=%04b expected=%04b",
                          i[3:0], data_recovered, i[3:0]);
                fail_count = fail_count + 1;
            end

            // Collect 4 serial bits
            collecting       = 1;
            serial_count     = 0;
            serial_collected = 0;
            repeat(4) @(posedge clk); #1;
            collecting = 0;

            // Check serial recovery
            if (serial_collected === data_in) begin
                $display("         | serial  PASS | bits=%04b", serial_collected);
                pass_serial = pass_serial + 1;
            end else begin
                $display("         | serial  FAIL | got=%04b expected=%04b",
                          serial_collected, i[3:0]);
                fail_count = fail_count + 1;
            end

            // Gap between symbols
            repeat(2) @(posedge clk); #1;
        end

        $display("======================================");
        $display("  Parallel: %0d/16 passed", pass_parallel);
        $display("  Serial:   %0d/16 passed", pass_serial);
        $display("  Failures: %0d",           fail_count);
        if (fail_count == 0)
            $display("  ALL TESTS PASSED — transceiver works!");
        else
            $display("  SOME TESTS FAILED — check waveform");
        $display("======================================");
        $finish;
    end

endmodule
