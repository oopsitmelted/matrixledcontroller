module leddriver
(
    // Data Input
    input rst,
    input clk,
    input [2:0] r0,
    input [2:0] r1,
    input [2:0] g0,
    input [2:0] g1,
    input [1:0] b0,
    input [1:0] b1,
    // Control Output
    output reg [3:0] row,
    output reg [5:0] col,
    output reg frame_start,
    // Panel Outputs
    output reg panel_r0,
    output reg panel_r1,
    output reg panel_g0,
    output reg panel_g1,
    output reg panel_b0,
    output reg panel_b1,
    output panel_pa1,
    output panel_pa2,
    output panel_pa3,
    output panel_pa4,
    output reg panel_sclk,
    output reg panel_latch,
    output panel_blank
);

localparam state_waitline = 0;
localparam state_latchline = 1;
localparam state_readline0 = 2;
localparam state_readline1 = 3;

reg [15:0] timer;
reg [1:0] bitpos;
reg [1:0] state;
reg [3:0] pa;

assign panel_pa1 = pa[0];
assign panel_pa2 = pa[1];
assign panel_pa3 = pa[2];
assign panel_pa4 = pa[3];
assign panel_blank = 0;

always @(posedge clk)
begin
    if (rst)
    begin
        state <= state_readline0;
        timer <= 0;
        bitpos <= 0;
        row <= 0;
        col <= 0;
        panel_r0 <= 0;
        panel_r1 <= 0;
        panel_g0 <= 0;
        panel_g1 <= 0;
        panel_b0 <= 0;
        panel_b1 <= 0;
        panel_latch <= 0;
        pa <= 0;
        panel_sclk <= 0;
        frame_start <= 0;
    end
    else
    begin
        if (timer != 0)
            timer <= timer - 1;

        case (state)
        
            state_waitline:
            begin
                if (timer == 0)
                begin
                    case (bitpos) // Based on 50MHz clock
                        0: timer <= 7428;
                        1: timer <= 14856;
                        2: timer <= 29712;
                        default: timer <= 0;
                    endcase
                    state <= state_latchline;
                end
            end

            state_latchline:
            begin
                panel_latch <= 1;
                pa <= row;
                if (bitpos == 2)
                begin
                    bitpos <= 0;
                    row <= row + 1;
                end
                else
                    bitpos <= bitpos + 1;
                state <= state_readline0;
            end

            state_readline0:
            begin
                panel_latch <= 0;     
                panel_sclk <= 0;   
                state <= state_readline1;     

                if (row == 0 && col == 0 && bitpos == 0)
                    frame_start <= 1;
                else
                    frame_start <= 0;  
            end

            state_readline1:
            begin
                panel_sclk <= 1;

                if (col == 63)
                begin
                    state <= state_waitline;
                    col <= 0;
                end
                else
                begin
                    panel_r0 <= r0[bitpos];
                    panel_r1 <= r1[bitpos];
                    panel_g0 <= g0[bitpos];
                    panel_g1 <= g1[bitpos];
                    panel_b0 <= b0[bitpos[1]];
                    panel_b1 <= b1[bitpos[1]];
                    col <= col + 1;
                    state <= state_readline0;
                end
            end
        endcase
    end
end
endmodule