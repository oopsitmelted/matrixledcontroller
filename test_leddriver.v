/*

Copyright (c) 2019 Alex Forencich

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

*/

// Language: Verilog 2001

`timescale 1ns / 1ps

/*
 * Testbench for controller
 */
module test_leddriver;

// Parameters

// Inputs
reg rst = 0;
reg clk = 0;
reg [2:0] r0 = 0;
reg [2:0] r1 = 0;
reg [2:0] g0 = 0;
reg [2:0] g1 = 0;
reg [1:0] b0 = 0;
reg [1:0] b1 = 0;

// Outputs

wire [3:0] row;
wire [5:0] col;
wire frame_start;
wire panel_r0;
wire panel_r1;
wire panel_g0;
wire panel_g1;
wire panel_b0;
wire panel_b1;
wire panel_pa1;
wire panel_pa2;
wire panel_pa3;
wire panel_pa4;
wire panel_sclk;
wire panel_latch;
wire panel_blank;

initial begin
    // myhdl integration
    $from_myhdl(
        // Data Input
        rst,
        clk,
        r0,
        r1,
        g0,
        g1,
        b0,
        b1
    );
    $to_myhdl(
        // Control Output
        row,
        col,
        frame_start,
        // Panel Outputs
        panel_r0,
        panel_r1,
        panel_g0,
        panel_g1,
        panel_b0,
        panel_b1,
        panel_pa1,
        panel_pa2,
        panel_pa3,
        panel_pa4,
        panel_sclk,
        panel_latch,
        panel_blank
    );

    // dump file
    $dumpfile("test_leddriver.lxt");
    $dumpvars(0, test_leddriver);
end

leddriver UUT(
    .rst(rst),
    .clk(clk),
    .r0(r0),
    .r1(r1),
    .g0(g0),
    .g1(g1),
    .b0(b0),
    .b1(b1),
    .row(row),
    .col(col),
    .frame_start(frame_start),
    .panel_r0(panel_r0),
    .panel_r1(panel_r1),
    .panel_g0(panel_g0),
    .panel_g1(panel_g1),
    .panel_b0(panel_b0),
    .panel_b1(panel_b1),
    .panel_pa1(panel_pa1),
    .panel_pa2(panel_pa2),
    .panel_pa3(panel_pa3),
    .panel_pa4(panel_pa4),
    .panel_sclk(panel_sclk),
    .panel_latch(panel_latch),
    .panel_blank(panel_blank)
);

endmodule
