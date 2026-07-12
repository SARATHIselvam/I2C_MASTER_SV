//==============================================================================
// Project : I2C Master Controller
// File    : i2c_bit_counter.sv
// Author  : Sarathi Selvam D
//
// Description:
// Counts the number of bits transmitted or received during an I2C byte
// transfer. Generates a 'bit_done' level signal after DATA_WIDTH bits.
//==============================================================================

import i2c_pkg :: *;

module i2c_bit_counter(
	input logic clk,
	input logic rst_n,
	
	input logic enable,
	input logic clear,
	
	output logic [$clog2(DATA_WIDTH)-1:0] bit_count,
	output logic byte_done
);

	logic [$clog2(DATA_WIDTH)-1:0] bit_counter;
	
	always_ff @(posedge clk or negedge rst_n) begin
		if(!rst_n)
			bit_counter <= '0;
		else if (clear)
			bit_counter <= '0;
		else if (enable)begin
			if(bit_counter!= DATA_WIDTH -1)
				bit_counter <= bit_counter + 1'b1;
		end
	end
	
	assign bit_count = bit_counter;

	assign byte_done = (bit_counter == DATA_WIDTH-1);
	
endmodule
