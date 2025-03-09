/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_addon (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    wire [7:0] A = ui_in;      // First operand
    wire [7:0] B = uio_in;     // Second operand
    wire Cin = 1'b0;           // Carry-in (set to 0)
    wire [7:0] Sum;
    wire Cout;

    // Generate and Propagate signals
    wire [7:0] G, P, C;
    assign G = A & B;  // Generate
    assign P = A ^ B;  // Propagate

    // Carry computation using prefix tree
    assign C[0] = Cin;
    assign C[1] = G[0] | (P[0] & C[0]);
    assign C[2] = G[1] | (P[1] & C[1]);
    assign C[3] = G[2] | (P[2] & C[2]);
    assign C[4] = G[3] | (P[3] & C[3]);
    assign C[5] = G[4] | (P[4] & C[4]);
    assign C[6] = G[5] | (P[5] & C[5]);
    assign C[7] = G[6] | (P[6] & C[6]);
    assign Cout = G[7] | (P[7] & C[7]); 

    // Sum computation
    assign Sum = P ^ C;
    // Assign outputs
    assign uo_out[6:0] = Sum[6:0]; // Sum bits
    assign uo_out[7] = Cout;  
    // Unused outputs
    assign uio_out = 8'b00000000;
    assign uio_oe  = 8'b00000000;

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, clk, rst_n, 1'b0};

endmodule
