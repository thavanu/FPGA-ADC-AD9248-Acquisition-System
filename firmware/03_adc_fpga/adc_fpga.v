`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:31:51 05/20/2026 
// Design Name: 
// Module Name:    adc_clk 
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
module adc_clk(
    input        clk_50m,
    input [13:0] ADC_D,
    output       ACL,
    output       BCL_OUT,
    output       uart_tx
);

// ACL à 3800 Hz - envoie TOUS les samples
localparam DIV      = 6_579;   // 50MHz / (2×6579) ≈ 3800 Hz
localparam SEND_DIV = 1;       // envoie chaque sample


// ── Génération ACL 1 MHz ──────────────────────────────────────────────
reg [4:0] acl_cnt = 0;
reg       acl_r   = 0;

always @(posedge clk_50m) begin
    if (acl_cnt == 24) begin
        acl_cnt <= 0;
        acl_r   <= ~acl_r;
    end else
        acl_cnt <= acl_cnt + 1;
end

assign ACL     = acl_r;
assign BCL_OUT = acl_r;
/*// ── Génération ACL 50MHz ───────────────────────────────────
reg acl_r = 0;
always @(posedge clk_50m) begin
    acl_r <= ~acl_r;
end
assign ACL     = acl_r;
assign BCL_OUT = acl_r;*/
reg acl_r1 = 0, acl_r2 = 0;

always @(posedge clk_50m) begin
    acl_r1 <= acl_r;
    acl_r2 <= acl_r1;
end

wire acl_rising = acl_r1 & ~acl_r2;  // pulse 1 cycle sur front montant

// ── Capture ADC sur front montant détecté ────────────────────────────
reg [13:0] sample = 0;

always @(posedge clk_50m) begin
    if (acl_rising)
        sample <= ADC_D;
end

/*// TEST TEMPORAIRE - injectez une valeur fixe
// Attendu en sortie Python : raw=0x1555 = 5461, tension ≈ +0.667 V
reg [13:0] sample = 0;
always @(posedge clk_50m) begin
    if (acl_rising)
        sample <= 14'h2AAA;   // valeur de test fixe
end*/
// ── Envoi UART toutes les secondes ────────────────────────────────────
// On envoie 3 octets : 0xAB | bits[13:6] | bits[5:0]
reg [19:0] counter = 0;
reg        tx_start = 0;
reg [7:0]  tx_data  = 0;
wire       tx_busy;
reg [1:0]  state    = 0;
reg [13:0] snap     = 0;  // snapshot stable pour l'envoi

uart_tx uart_inst (
    .clk     (clk_50m),
    .rst     (1'b0),
    .tx_start(tx_start),
    .data_in (tx_data),
    .tx_busy (tx_busy),
    .tx      (uart_tx)
);

always @(posedge clk_50m) begin
    tx_start <= 0;
    counter  <= counter + 1;
	
	 case (state)
        0: if (counter == 26'd499_999) begin // // snapshot toutes les 100 µs
               counter  <= 0;
               snap     <= sample;   // capture snapshot
               tx_data  <= 8'hAB;
               tx_start <= 1;
               state    <= 1;
           end
			  
		  1: if (tx_busy) state <= 2;          // tx_busy monté → on attend la fin

        2: if (!tx_busy) begin               // tx_busy retombé → b0 terminé
               tx_data  <= snap[13:6];
               tx_start <= 1;
               state    <= 3;
           end

        3: if (tx_busy) state <= 4;

        4: if (!tx_busy) begin
               tx_data  <= {2'b00, snap[5:0]};
               tx_start <= 1;
               state    <= 5;
           end
		  5: if (tx_busy) state <= 6;

        6: if (!tx_busy) state <= 0;

    endcase
 
end

endmodule
