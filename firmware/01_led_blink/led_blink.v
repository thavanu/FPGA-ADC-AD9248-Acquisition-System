`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Universite cote d'azur
// Engineer: 
// 
// Create Date:    20:27:56 05/19/2026 
// Design Name: 
// Module Name:    led_blink 
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
`timescale 1ns / 1ps

module led_blink(
    input clk,
    output led
);

reg [24:0] counter = 25'd0;

always @(posedge clk)
begin
    counter <= counter + 1'b1;
end

assign led = counter[24];

endmodule
