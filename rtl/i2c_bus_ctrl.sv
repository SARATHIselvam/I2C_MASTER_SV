module i2c_bus_ctrl(

    input logic drive_sda_low,
    input logic drive_scl_low,

    input logic serial_out,

    inout wire sda,
    inout wire scl,

    output logic sda_in,
    output logic scl_in

);


    assign sda =drive_sda_low ?(serial_out ? 1'bz : 1'b0):1'bz;


    assign scl =drive_scl_low ?1'b0: 1'bz;


    assign sda_in = sda;

    assign scl_in = scl;

endmodule
