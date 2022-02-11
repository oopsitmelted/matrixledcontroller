module matrixledcontroller #(

	parameter TARGET = "ALTERA",
    parameter AXIS_DATA_WIDTH = 8,
    parameter AXIS_KEEP_ENABLE = (AXIS_DATA_WIDTH>8),
    parameter AXIS_KEEP_WIDTH = (AXIS_DATA_WIDTH/8),
    parameter ENABLE_PADDING = 1,
    parameter MIN_FRAME_LENGTH = 64,
    parameter TX_FIFO_DEPTH = 512,
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
    input mii_rx_clk,
    input [3:0] mii_rxd,
    input mii_rx_dv,
    input mii_rx_er,
    input mii_tx_clk,
    input [2:0] r0,
    input [2:0] r1,   
    input [2:0] g0, 
    input [2:0] g1, 
    input [1:0] b0, 
    input [1:0] b1, 
    output [3:0] mii_txd,
    output mii_tx_en,
    output led_r0,
	output led_r1,
	output led_g0,
	output led_g1,
	output led_b0,
	output led_b1,
	output led_pa1,
	output led_pa2,
	output led_pa3,
	output led_pa4,
	output led_sclk,
	output led_blank,
	output led_latch,
    output [3:0] row,
    output [5:0] col
);

wire frame_valid;
wire [47:0] dst_mac;
wire [47:0] src_mac;
wire [15:0] eth_type;
wire [AXIS_DATA_WIDTH-1:0] payload_data;
wire payload_valid;
wire payload_last;
wire payload_keep;
wire payload_user;
reg read_state;
reg payload_read;

wire [7:0] mac_tx_data;
wire mac_tx_ready;
wire [7:0] mac_rx_data;
wire mac_rx_ready;
wire mac_rx_last;
wire mac_rx_valid;
wire mac_rx_keep;
wire mac_rx_user;
wire mac_tx_last;
wire mac_tx_valid;
wire hdr_ready;

wire frame_start;

assign mac_tx_last = 1'b0;
assign mac_tx_valid = 1'b0;
assign mac_tx_data = 8'b0;
assign hdr_ready = 1'b1;

localparam wait_header = 0, process_payload = 1;

leddriver panel (
    // Inputs
    .rst(rst),
    .clk(clk),
    .r0(r0),
    .r1(r1),
    .g0(g0),
    .g1(g1),
    .b0(b0),
    .b1(b1),

    // Outputs
    .row(row),
    .col(col),
    .frame_start(frame_start),
    .panel_r0(led_r0),
    .panel_r1(led_r1),
    .panel_g0(led_g0),
    .panel_g1(led_g1),
    .panel_b0(led_b0),
    .panel_b1(led_b1),
    .panel_pa1(led_pa1),
    .panel_pa2(led_pa2),
    .panel_pa3(led_pa3),
    .panel_pa4(led_pa4),
    .panel_sclk(led_sclk),
    .panel_latch(led_latch),
    .panel_blank(led_blank)
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
    .logic_clk(clk),
    .logic_rst(rst),

    /*
     * AXI input
     */
    .tx_axis_tdata(mac_tx_data),
    .tx_axis_tkeep(1'b0),
    .tx_axis_tvalid(mac_tx_valid),
    .tx_axis_tready(mac_tx_ready),
    .tx_axis_tlast(mac_tx_last),
    .tx_axis_tuser(1'b0),

    /*
     * AXI output
     */
    .rx_axis_tdata(mac_rx_data),
    .rx_axis_tkeep(mac_rx_keep),
    .rx_axis_tvalid(mac_rx_valid),
    .rx_axis_tready(mac_rx_ready),
    .rx_axis_tlast(mac_rx_last),
    .rx_axis_tuser(mac_rx_user),

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
    .s_axis_tdata(mac_rx_data),
    .s_axis_tkeep(mac_rx_keep),
    .s_axis_tvalid(mac_rx_valid),
    .s_axis_tready(mac_rx_ready),
    .s_axis_tlast(mac_rx_last),
    .s_axis_tuser(mac_rx_user),
	 
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
    .m_eth_payload_axis_tready(payload_read),
    .m_eth_payload_axis_tlast(payload_last),
    .m_eth_payload_axis_tuser(payload_user)

    /*
     * Status signals
     */
    //.busy,
    //.error_header_early_termination
);

always @(posedge clk, posedge rst)
begin
    if (rst)
    begin
        read_state <= wait_header;
        payload_read <= 0;
    end
    else
    begin
        case (read_state)
            wait_header:
                begin
                    if (frame_valid && dst_mac == 48'hDAD1D2D3D4D5)
                    begin
                        read_state <= process_payload;
                        payload_read <= 1;
                    end
                end

            process_payload:
                begin
                    if (payload_last) 
                    begin
                        read_state <= wait_header;
                        payload_read <= 0;
                    end
                    
                end

            default: read_state <= read_state;
        endcase
    end
end

endmodule
