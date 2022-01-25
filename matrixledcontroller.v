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
    input rst,
    input clk,
    input [7:0] rx_axis_tdata,
    input rx_axis_tkeep,
    input rx_axis_tvalid,
    output rx_axis_tready,
    input rx_axis_tlast,
    input rx_axis_tuser
);

wire frame_valid;
wire [47:0] dst_mac;
wire [47:0] src_mac;
wire hdr_ready;
wire [15:0] eth_type;
wire [AXIS_DATA_WIDTH-1:0] payload_data;
wire payload_valid;
wire payload_last;
wire payload_keep;
wire payload_user;

assign hdr_ready = 1'b1;

eth_axis_rx #(
    .DATA_WIDTH(AXIS_DATA_WIDTH),
    .KEEP_ENABLE(AXIS_KEEP_ENABLE),
    .KEEP_WIDTH(AXIS_KEEP_WIDTH)
)
ethrx
(
    .clk(clk),
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
    .m_eth_dest_mac(dst_mac),
    .m_eth_src_mac(src_mac),
    .m_eth_type(eth_type),
    .m_eth_payload_axis_tdata(payload_data),
    .m_eth_payload_axis_tkeep(payload_keep),
    .m_eth_payload_axis_tvalid(payload_valid),
    .m_eth_payload_axis_tready(1'b1),
    .m_eth_payload_axis_tlast(payload_last),
    .m_eth_payload_axis_tuser(payload_user)

    /*
     * Status signals
     */
    //.busy,
    //.error_header_early_termination
);
endmodule
