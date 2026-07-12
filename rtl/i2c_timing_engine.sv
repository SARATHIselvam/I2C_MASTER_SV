//==============================================================================
// Project : I2C Master Controller
// File    : i2c_timing_engine.sv
// Author  : Sarathi Selvam D
//
// Description:
// Generates internal I2C timing phases from the clock generator tick.
//==============================================================================

import i2c_pkg::*;

module i2c_timing_engine(
	input logic clk,
	input logic rst_n,
	input logic enable,
	input logic tick,
	
	output phase_t phase,
	
	output logic shift_en,
	output logic sample_en

);

	phase_t phase_reg;
	
	assign phase = phase_reg;
	
	always_ff @(posedge clk or negedge rst_n) begin
		
		if(!rst_n) begin
			phase_reg <= PHASE0;
		end
		else if(!enable) begin
			phase_reg <= PHASE0;
		end
		
		else if(tick) begin
			
			case(phase_reg)
				
				PHASE0: phase_reg <= PHASE1;
				PHASE1: phase_reg <= PHASE2;
				PHASE2: phase_reg <= PHASE3;
				PHASE3: phase_reg <= PHASE0;
				
				default: phase_reg <= PHASE0;
			endcase
			
		end
	
	end
	
	always_comb begin
		
		shift_en = 1'b0;
		sample_en = 1'b0;
		
		case(phase_reg)
			
			PHASE0:
				shift_en = 1'b1;
			PHASE2:
				sample_en = 1'b1;
			default: begin
				shift_en = 1'b0;
				sample_en = 1'b0;
			end
			
		endcase
		
	end
	

	
endmodule
