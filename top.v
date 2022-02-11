module top (
	input clk_25,
   	input mii_rx_clk,
   	input [3:0] mii_rxd,
   	input mii_rx_dv,
   	input mii_rx_er,
   	input mii_tx_clk,
   	output [3:0] mii_txd,
   	output mii_tx_en,
	output led_r0,
	output led_r1,
	output led_g0,
	output led_g1,
	output led_b0,
	output led_b1,
	output led_pa0,
	output led_pa1,
	output led_pa2,
	output led_pa3,
	output led_sclk,
	output led_blank,
	output led_latch,
	input [15:0] ram_d,
	output [17:0] ram_a,
	output ram_ce,
	output ram_we,
	output ram_ub,
	output ram_lb,
	output ram_oe
);

wire pll_locked;
wire clk_50;
wire rst;
reg [2:0] r0;
reg [2:0] r1;
reg [2:0] g0;
reg [2:0] g1;
reg [1:0] b0;
reg [1:0] b1;

parameter TARGET = "ALTERA";
parameter AXIS_DATA_WIDTH = 8;
parameter AXIS_KEEP_ENABLE = (AXIS_DATA_WIDTH>8);
parameter AXIS_KEEP_WIDTH = (AXIS_DATA_WIDTH/8);
parameter ENABLE_PADDING = 1;
parameter MIN_FRAME_LENGTH = 64;
parameter TX_FIFO_DEPTH = 512;
parameter TX_FRAME_FIFO = 1;
parameter TX_DROP_BAD_FRAME = TX_FRAME_FIFO;
parameter TX_DROP_WHEN_FULL = 0;
parameter RX_FIFO_DEPTH = 4096;
parameter RX_FRAME_FIFO = 1;
parameter RX_DROP_BAD_FRAME = RX_FRAME_FIFO;
parameter RX_DROP_WHEN_FULL = RX_FRAME_FIFO;

wire [3:0] row;
wire [5:0] col;

assign ram_a = (row * 64) + col;
assign ram_ce = 0;
assign ram_oe = 0;
assign ram_we = 1;
assign ram_ub = 0;
assign ram_lb = 0;

always @(negedge clk_50)
begin
	if (rst)
	begin
		r0 <= 0;
		g0 <= 0;
		b0 <= 0;
		r1 <= 0;
		g1 <= 0;
		b1 <= 0;
	end
	else
	begin
		r0 <= ram_d[15:13];
		g0 <= ram_d[12:10];
		b0 <= ram_d[9:8];
		r1 <= ram_d[7:5];
		g1 <= ram_d[4:2];
		b0 <= ram_d[1:0];
	end
end
pll pll_inst (
	.inclk0(clk_25),
	.c0(clk_50),
	.locked(pll_locked)
);

sync_reset #(
    .N(4)
)
sync_reset_inst (
    .clk(clk_50),
    .rst(~pll_locked),
    .out(rst)
);

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
controller(
    .rst(rst),
    .clk(clk_50),
    .mii_rx_clk(mii_rx_clk),
    .mii_rxd(mii_rxd),
    .mii_rx_dv(mii_rx_dv),
    .mii_rx_er(mii_rx_er),
    .mii_tx_clk(mii_tx_clk),
    .mii_txd(mii_txd),
    .mii_tx_en(mii_tx_en),
    .r0(r0),
    .r1(r1),   
    .g0(g0), 
    .g1(g1), 
    .b0(b0), 
    .b1(b1), 
	.led_r0(led_r0),
	.led_r1(led_r1),
	.led_g0(led_g0),
	.led_g1(led_g1),
	.led_b0(led_b0),
	.led_b1(led_b1),
	.led_pa1(led_pa0),
	.led_pa2(led_pa1),
	.led_pa3(led_pa2),
	.led_pa4(led_pa3),
	.led_sclk(led_sclk),
	.led_blank(led_blank),
	.led_latch(led_latch),
	.row(row),
	.col(col)
);

endmodule