module matrixledcontroller #(

	parameter TARGET = "ALTERA",
    parameter AXIS_DATA_WIDTH = 8,
    parameter AXIS_KEEP_ENABLE = (AXIS_DATA_WIDTH>8),
    parameter AXIS_KEEP_WIDTH = (AXIS_DATA_WIDTH/8),
    parameter ENABLE_PADDING = 1,
    parameter MIN_FRAME_LENGTH = 64,
    parameter TX_FIFO_DEPTH = 4096,
    parameter TX_FRAME_FIFO = 1,
    parameter TX_DROP_BAD_FRAME = TX_FRAME_FIFO,
    parameter TX_DROP_WHEN_FULL = 0,
    parameter RX_FIFO_DEPTH = 4096,
    parameter RX_FRAME_FIFO = 1,
    parameter RX_DROP_BAD_FRAME = RX_FRAME_FIFO,
    parameter RX_DROP_WHEN_FULL = RX_FRAME_FIFO
)
(
	input clk_25,
    input mii_rx_clk,
    input [3:0] mii_rxd,
    input mii_rx_dv,
    input mii_rx_er,
    input mii_tx_clk,
    output [3:0] mii_txd,
    output mii_tx_en
);

wire clk_125;
wire pll_locked;
wire rst;

wire [7:0] rx_axis_tdata;
wire rx_axis_tkeep;
wire rx_axis_tvalid;
wire rx_axis_tready;
wire rx_axis_tlast;
wire [7:0] rx_axis_tuser;

wire frame_valid;
wire [47:0] dst_mac;
wire [47:0] src_mac;

assign hdr_ready = 1'b1;

//signaltap st(
//	.acq_clk(mii_rx_clk),
//	.acq_data_in({mii_rxd,mii_rx_dv,5'b0}),
//	.acq_trigger_in(1'b0)
//);

pll pll_inst (
	.inclk0(clk_25),
	.c0(clk_125),
	.locked(pll_locked)
);

sync_reset #(
    .N(4)
)
sync_reset_inst (
    .clk(clk_125),
    .rst(~pll_locked),
    .out(rst)
);

eth_mac_mii_fifo #(
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
ethmac_inst(
    .rst(rst),
    .logic_clk(clk_125),
    .logic_rst(rst),

    /*
     * AXI input
     */
    .tx_axis_tdata(8'b0),
    .tx_axis_tkeep(1'b0),
    .tx_axis_tvalid(1'b0),
    //.tx_axis_tready,
    .tx_axis_tlast(1'b0),
    .tx_axis_tuser(1'b0),

    /*
     * AXI output
     */
    .rx_axis_tdata(rx_axis_tdata),
    .rx_axis_tkeep(rx_axis_tkeep),
    .rx_axis_tvalid(rx_axis_tvalid),
    .rx_axis_tready(rx_axis_tready),
    .rx_axis_tlast(rx_axis_tlast),
    .rx_axis_tuser(rx_axis_tuser),

    /*
     * MII interface
     */
    .mii_rx_clk(mii_rx_clk),
    .mii_rxd(mii_rxd),
    .mii_rx_dv(mii_rx_dv),
    .mii_rx_er(mii_rx_er),
    .mii_tx_clk(mii_tx_clk),
    .mii_txd(mii_txd),
    .mii_tx_en(mii_tx_en),
    //.mii_tx_er,

    /*
     * Status
     */
    //.tx_error_underflow,
    //.tx_fifo_overflow,
    //.tx_fifo_bad_frame,
    //.tx_fifo_good_frame,
    //.rx_error_bad_frame,
    //.rx_error_bad_fcs,
    //.rx_fifo_overflow,
    //.rx_fifo_bad_frame,
    //.rx_fifo_good_frame,

    /*
     * Configuration
     */
    .ifg_delay(12)
);

eth_axis_rx #(
    .DATA_WIDTH(AXIS_DATA_WIDTH),
    .KEEP_ENABLE( (AXIS_DATA_WIDTH>8) ),
    .KEEP_WIDTH( (AXIS_DATA_WIDTH/8) )
)
ethrx
(
    .clk(clk_125),
    .rst(rst),
	 
	 /*
     * AXI input
     */
    .s_axis_tdata(rx_axis_tdata),
    .s_axis_tkeep(rx_axis_tkeep),
    .s_axis_tvalid(rx_axis_tvalid),
    .s_axis_tready(rx_axis_tready),
    .s_axis_tlast(rx_axis_tlast),
    .s_axis_tuser(rx_axis_tuser),
	 
    /*
     * Ethernet frame output
     */
    .m_eth_hdr_valid(frame_valid),
    .m_eth_hdr_ready(hdr_ready),
    .m_eth_dest_mac(dest_mac),
    .m_eth_src_mac(src_mac),
    //.m_eth_type,
    //.m_eth_payload_axis_tdata,
    //.m_eth_payload_axis_tkeep,
    //.m_eth_payload_axis_tvalid,
    //.m_eth_payload_axis_tready,
    //.m_eth_payload_axis_tlast,
    //.m_eth_payload_axis_tuser,

    /*
     * Status signals
     */
    //.busy,
    //.error_header_early_termination
);
endmodule
