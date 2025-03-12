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

  // All output pins must be assigned. If not used, assign to 0.
//  assign uo_out  = ui_in + uio_in;  // Example: ou_out is the sum of ui_in and uio_in
   
    // Define input bits
    wire [2:0] A, B;
    wire Cin;
    assign A   = ui_in[2:0];  // A[2:0]
    assign B   = ui_in[5:3];  // B[2:0]
    assign Cin = ui_in[6];    // Carry-in

    // Generate (G) and Propagate (P) signals
    wire [2:0] G, P;
    assign G = A & B;     // Generate: G[i] = A[i] & B[i]
    assign P = A ^ B;     // Propagate: P[i] = A[i] ^ B[i]

    // Carry computation using Kogge-Stone structure
    wire [2:0] C;
    assign C[0] = Cin;
    assign C[1] = G[0] | (P[0] & C[0]);
    assign C[2] = G[1] | (P[1] & G[0]) | (P[1] & P[0] & C[0]);
    assign uo_out[3] = G[2] | (P[2] & G[1]) | (P[2] & P[1] & G[0]) | (P[2] & P[1] & P[0] & C[0]);

    // Sum computation
    wire [2:0] Sum;
    assign Sum = P ^ C;

    // Assign outputs (Sum[2:0] and Carry-out)
    assign uo_out[2:0] = Sum;   // Sum[2:0]
    assign uo_out[7:4] = 4'b0;  // Unused bits set to 0
  assign uio_out = 0;
  assign uio_oe  = 0;

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, clk, rst_n, 1'b0};

endmodule
