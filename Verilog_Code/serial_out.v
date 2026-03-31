// ============================================================
//  Serial Output — 4-bit parallel to 1-bit serial
//
//  WHY THIS NEEDS A CLOCK:
//  We need to send 4 bits one at a time over 4 clock cycles.
//  That means "remembering" which bit we're on and shifting
//  the register — both require flip-flops → posedge clk.
//
//  How it works:
//    Cycle 0: load=1 → latch 4-bit word into shift register
//    Cycle 1: output bit 3 (MSB), shift left
//    Cycle 2: output bit 3 (was bit 2), shift left
//    Cycle 3: output bit 3 (was bit 1), shift left
//    Cycle 4: output bit 3 (was bit 0, LSB), tx_done=1
//
//  serial_out is always the MSB of the shift register.
// ============================================================

module serial_out (
    input        clk,
    input        reset_n,
    input  [3:0] data_in,     // 4-bit word from QAM demapper
    input        load,         // pulse high for 1 cycle to start sending
    output reg   serial_out,   // 1 bit per clock
    output reg   tx_done,      // high for 1 cycle when all 4 bits sent
    output reg   tx_busy       // high while transmitting
);

    reg [3:0] shift_reg;
    reg [2:0] bit_count;    // counts 0 to 3

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            shift_reg  <= 4'b0;
            bit_count  <= 0;
            serial_out <= 0;
            tx_done    <= 0;
            tx_busy    <= 0;
        end
        else if (load && !tx_busy) begin
            // Load new data and immediately output MSB
            shift_reg  <= data_in << 1;  // pre-shift so next cycle is bit 2
            serial_out <= data_in[3];    // MSB first
            bit_count  <= 1;
            tx_done    <= 0;
            tx_busy    <= 1;
        end
        else if (tx_busy) begin
            if (bit_count < 4) begin
                serial_out <= shift_reg[3];   // output current MSB
                shift_reg  <= shift_reg << 1; // shift left for next bit
                bit_count  <= bit_count + 1;
                tx_done    <= 0;
            end
            else begin
                // All 4 bits sent
                tx_done   <= 1;
                tx_busy   <= 0;
                bit_count <= 0;
            end
        end
        else begin
            tx_done <= 0;
        end
    end

endmodule
