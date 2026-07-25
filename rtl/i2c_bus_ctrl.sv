//==============================================================================
// Project : I2C Master Controller
// File    : i2c_bus_ctrl.sv
// Author  : Sarathi Selvam D
//
// Description:
// Handles the bidirectional physical I2C lines. 
// - Implements true open-drain behavior (never drives active high).
// - Protects internal logic by double-flopping asynchronous inputs.
//==============================================================================

module i2c_bus_ctrl(
    input  logic clk,
    input  logic rst_n,

    input  logic drive_sda_low,
    input  logic drive_scl_low,
    input  logic serial_out,

    inout  wire  sda,
    inout  wire  scl,

    output logic sda_in,
    output logic scl_in
);


    assign sda = drive_sda_low ? 1'b0 : 1'bz;
    assign scl = drive_scl_low ? 1'b0 : 1'bz;


    logic sda_r1, sda_r2;
    logic scl_r1, scl_r2;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sda_r1 <= 1'b1; 
            sda_r2 <= 1'b1;
            scl_r1 <= 1'b1;
            scl_r2 <= 1'b1;
        end else begin
            sda_r1 <= sda;     
            sda_r2 <= sda_r1; 
            
            scl_r1 <= scl;     
            scl_r2 <= scl_r1; 
        end
    end

    assign sda_in = sda_r2;
    assign scl_in = scl_r2;

endmodule
