`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    02:47:59 05/22/2026 
// Design Name: 
// Module Name:    uart 
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
module uart(
	 input wire clk,
    input wire rst,
    output wire uart_tx
);

reg tx_start = 0;
reg [7:0] tx_data = 8'h41; // ASCII 'A'

wire tx_busy;

reg [31:0] counter = 0;


uart_tx #(
    .CLK_FREQ(50000000),
    .BAUD_RATE(115200)
)
uart_tx_inst (
    .clk(clk),
    .rst(rst),

    .tx_start(tx_start),
    .data_in(tx_data),

    .tx(uart_tx),
    .tx_busy(tx_busy)
);

always @(posedge clk) begin

    if (rst) begin
        counter  <= 0;
        tx_start <= 0;
    end
    else begin

        tx_start <= 0;

        counter <= counter + 1;

        // environ 1 fois par seconde à 50 MHz
        if (counter == 50000000) begin

            counter <= 0;

            if (!tx_busy) begin
                tx_start <= 1;
            end
        end
    end
end

endmodule