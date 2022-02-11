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
module test_matrixledcontroller;

// Parameters
parameter TARGET = "SIM";
parameter AXIS_DATA_WIDTH = 8;
parameter AXIS_KEEP_ENABLE = (AXIS_DATA_WIDTH>8);
parameter AXIS_KEEP_WIDTH = (AXIS_DATA_WIDTH/8);
parameter ENABLE_PADDING = 1;
parameter MIN_FRAME_LENGTH = 64;
parameter TX_FIFO_DEPTH = 4096;
parameter TX_FRAME_FIFO = 1;
parameter TX_DROP_BAD_FRAME = TX_FRAME_FIFO;
parameter TX_DROP_WHEN_FULL = 0;
parameter RX_FIFO_DEPTH = 4096;
parameter RX_FRAME_FIFO = 1;
parameter RX_DROP_BAD_FRAME = RX_FRAME_FIFO;
parameter RX_DROP_WHEN_FULL = RX_FRAME_FIFO;

// Inputs
reg rst = 0;
reg clk = 0;
reg mii_rx_clk = 0;
reg [3:0] mii_rxd = 0;
reg mii_rx_dv = 0;
reg mii_rx_er = 0;
reg mii_tx_clk = 0;

// Outputs
wire [3:0] mii_txd;
wire mii_tx_en;

initial begin
    // myhdl integration
    $from_myhdl(
        rst,
        clk,
        mii_rx_clk,
        mii_rxd,
        mii_rx_dv,
        mii_rx_er,
        mii_tx_clk
    );
    $to_myhdl(
        mii_txd,
        mii_tx_en
    );

    // dump file
    $dumpfile("test_controller.lxt");
    $dumpvars(0, test_matrixledcontroller);
end

matrixledcontroller #(
	.TARGET(TARGET),
	.AXIS_DATA_WIDTH(AXIS_DATA_WIDTH),
	.AXIS_KEEP_ENABLE(AXIS_KEEP_ENABLE),
	.AXIS_KEEP_WIDTH(AXIS_KEEP_WIDTH),
	.ENABLE_PADDING(ENABLE_PADDING),
	.MIN_FRAME_LENGTH(MIN_FRAME_LENGTH),
	.TX_FIFO_DEPTH(TX_FIFO_DEPTH),
	.TX_FRAME_FIFO(TX_FRAME_FIFO),	
	.TX_DROP_BAD_FRAME(TX_DROP_BAD_FRAME),
	.TX_DROP_WHEN_FULL(TX_DROP_WHEN_FULL),
	.RX_FIFO_DEPTH(RX_FIFO_DEPTH),
	.RX_FRAME_FIFO(RX_FRAME_FIFO),
	.RX_DROP_BAD_FRAME(RX_DROP_BAD_FRAME),
	.RX_DROP_WHEN_FULL(RX_DROP_WHEN_FULL)
) 
UUT(
    .rst(rst),
    .clk(clk),
    .mii_rx_clk(mii_rx_clk),
    .mii_rxd(mii_rxd),
    .mii_rx_dv(mii_rx_dv),
    .mii_rx_er(mii_rx_er),
    .mii_tx_clk(mii_tx_clk),
    .mii_txd(mii_txd),
    .mii_tx_en(mii_tx_en)
);

endmodule
