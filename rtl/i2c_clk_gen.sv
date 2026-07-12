//==============================================================================
// Project : I2C Master Controller
// File    : i2c_clk_gen.sv
// Author  : Sarathi Selvam D
// 
// Description:
// Generate a one-clock-cycle tick every CLK_PER_PHASE system clock cycles.
// The tick is used by the Timing engine to advance the I2C protocol phases
//==============================================================================
 import i2c_pkg::*;
 
 module i2c_clk_gen (
 input logic clk,
 input logic rst_n,
 input logic enable,
 
 output logic tick);
 
	logic [$clog2(CLK_PER_PHASE)-1:0] counter;
	
	always_ff @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			counter <= '0;
			tick <= 1'b0;
		end
		else if (!enable) begin
			counter <= '0;
			tick <= 1'b0; 
		end
		
		else begin
			if(counter == CLK_PER_PHASE-1) begin
				counter <= '0;
				tick <= 1'b1;
			end
			else begin
				counter <= counter + 1'b1;
				tick <= 1'b0;
			end
			
		end
		
	end
 
 endmodule
 