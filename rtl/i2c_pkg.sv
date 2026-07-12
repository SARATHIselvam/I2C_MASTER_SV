//==============================================================================
// Project : I2C Master Controller
// File    : i2c_pkg.sv
// Author  : Sarathi Selvam D
// 
// Description:
// Common package containing all global configuration parameters,
// typedefs, FSM states, timing phases, and error codes.
//==============================================================================

package i2c_pkg;

	parameter int CLK_FREQ_HZ = 100_000_000;
	parameter int I2C_FREQ_HZ = 100_000;
	parameter int DATA_WIDTH = 8;
	parameter int ADDR_WIDTH = 7;
	parameter int PHASES_PER_BIT = 4;

	localparam int CLK_PER_SCL = CLK_FREQ_HZ / I2C_FREQ_HZ;
	localparam int CLK_PER_PHASE = CLK_PER_SCL / PHASES_PER_BIT;
	
	typedef enum logic [3:0] {
    IDLE,
    START,
    LOAD_ADDR,
    SEND_ADDR,
    ADDR_ACK,
    LOAD_DATA,
    WRITE_DATA,
    READ_DATA,
    DATA_ACK,
    STOP,
    DONE,
    ERROR
	} i2c_state_t;
		
	typedef enum logic [1:0]{
		PHASE0,
		PHASE1,
		PHASE2,
		PHASE3
		} phase_t;
		
	
	
	typedef enum logic [2:0]{
		NO_ERROR,
		NACK_ERROR,
		TIMEOUT_ERROR,
		BUS_ERROR
		} error_t;
		
	typedef enum logic {
		LOAD_SEL_ADDR,
		LOAD_SEL_DATA
	} load_sel_t;
		
endpackage
