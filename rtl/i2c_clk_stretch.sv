//==============================================================================
// Project : I2C Master Controller
// File    : i2c_clk_stretch.sv
// Author  : Sarathi Selvam D
//
// Description:
// Detects I2C clock stretching.
//
// When the master releases SCL but the line remains LOW,
// a slave is stretching the clock.
//==============================================================================

module i2c_clk_stretch (

    input  logic drive_scl_low,
    input  logic scl_in,

    output logic stretch_active

);

    assign stretch_active = drive_scl_low && !scl_in;

endmodule
