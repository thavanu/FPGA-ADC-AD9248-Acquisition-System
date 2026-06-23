`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    07:32:37 05/28/2026 
// Design Name: 
// Module Name:    uart_tx 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module uart_tx #(
    parameter CLK_FREQ  = 50000000,
    parameter BAUD_RATE = 115200
)(
    input  wire clk,
    input  wire rst,

    input  wire tx_start,
    input  wire [7:0] data_in,

    output reg  tx,
    output reg  tx_busy
);

localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;

reg [15:0] clk_cnt;
reg [3:0]  bit_idx;
reg [9:0]  tx_shift;

always @(posedge clk) begin
    if (rst) begin
        tx <= 1'b1;
        tx_busy <= 1'b0;
        clk_cnt <= 0;
        bit_idx <= 0;
    end
    else begin
	 
		 if (!tx_busy) begin

					if (tx_start) begin
						 tx_busy  <= 1'b1;

						 // stop + data + start
						 tx_shift <= {1'b1, data_in, 1'b0};

						 clk_cnt <= 0;
						 bit_idx <= 0;
					end

					tx <= 1'b1;
			  end
			 
			  else begin
				tx <= tx_shift[bit_idx];

            if (clk_cnt == CLKS_PER_BIT - 1) begin
                clk_cnt <= 0;

                if (bit_idx == 9) begin
                    tx_busy <= 1'b0;
                end
                else begin
                    bit_idx <= bit_idx + 1'b1;
                end
            end
            else begin
                clk_cnt <= clk_cnt + 1'b1;
            end
        end
    end
end

endmodule

