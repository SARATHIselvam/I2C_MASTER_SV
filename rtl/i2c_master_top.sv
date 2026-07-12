//==============================================================================
// Project : I2C Master Controller
// File    : i2c_master.sv
// Author  : Sarathi Selvam D
//
// Description:
// Top-level integration of the I2C Master Controller.
//
// Instantiates:
//   - Clock Generator
//   - Timing Engine
//   - Master Controller (FSM)
//   - Shift Register
//   - Bit Counter
//   - Bus Controller
//==============================================================================

import i2c_pkg::*;

module i2c_master_top(


    input  logic clk,
    input  logic rst_n,


    input  logic start,
    input  logic rw,

    input  logic [ADDR_WIDTH-1:0] slave_addr,
    input  logic [DATA_WIDTH-1:0] tx_data,

    output logic [DATA_WIDTH-1:0] rx_data,

    output logic busy,
    output logic done,
    output error_t error,


    inout wire sda,
    inout wire scl

);

    //======================================================================
    // Internal Signals
    //======================================================================

    logic tick;

    phase_t phase;

    logic shift_en;
    logic sample_en;

    logic clk_enable;

    load_sel_t load_sel;

    logic load_shift_reg;

    logic shift_tx;
    logic shift_rx;

    logic counter_enable;
    logic counter_clear;

    logic byte_done;

    logic drive_sda_low;
    logic drive_scl_low;

    logic serial_out;

    logic sda_in;
    logic scl_in;

    logic stretch_active;

    logic [DATA_WIDTH-1:0] shift_data;

    logic tx_shift_pulse;
    logic rx_shift_pulse;
    logic counter_pulse;

    //======================================================================
    // Address/Data Multiplexer
    //======================================================================

    always_comb begin

        unique case(load_sel)

            LOAD_SEL_ADDR :
                shift_data = {slave_addr, rw};

            LOAD_SEL_DATA :
                shift_data = tx_data;

            default :
                shift_data = '0;

        endcase

    end

    //======================================================================
    // Pulse Generation
    //======================================================================

    assign tx_shift_pulse = shift_tx & shift_en;

    assign rx_shift_pulse = shift_rx & sample_en;

    assign counter_pulse = counter_enable &
                           (shift_en | sample_en);



    //======================================================================
    // Clock Generator
    //======================================================================

    i2c_clk_gen u_clk_gen (

        .clk        (clk),
        .rst_n      (rst_n),
        .enable     (clk_enable),

        .tick       (tick)

    );

    //======================================================================
    // Timing Engine
    //======================================================================

    i2c_timing_engine u_timing_engine (

        .clk        (clk),
        .rst_n      (rst_n),

        .enable     (clk_enable),
        .tick        (tick),

        .phase      (phase),

        .shift_en   (shift_en),
        .sample_en  (sample_en)

    );

    //======================================================================
    // Shift Register
    //======================================================================

    i2c_shift_reg u_shift_reg (

        .clk        (clk),
        .rst_n      (rst_n),

        .tx_load    (load_shift_reg),
        .tx_shift   (tx_shift_pulse),
        .tx_data    (shift_data),

        .rx_shift   (rx_shift_pulse),
        .serial_in  (sda_in),

        .serial_out (serial_out),
        .rx_data    (rx_data)

    );

    //======================================================================
    // Bit Counter
    //======================================================================

    i2c_bit_counter u_bit_counter (

        .clk        (clk),
        .rst_n      (rst_n),

        .enable     (counter_pulse),
        .clear      (counter_clear),

        .bit_count  (),
        .byte_done  (byte_done)

    );

    //======================================================================
    // Bus Controller
    //======================================================================

    i2c_bus_ctrl u_bus_ctrl (

	 .drive_sda_low(drive_sda_low),
    .drive_scl_low(drive_scl_low),

    .serial_out(serial_out),

    .sda(sda),
    .scl(scl),

    .sda_in(sda_in),
    .scl_in(scl_in)
    );

    //======================================================================
    // Clock Stretch Detector
    //======================================================================

    i2c_clk_stretch u_clock_stretch (

        .scl_in          (scl_in),
        .drive_scl_low   (drive_scl_low),

        .stretch_active  (stretch_active)

    );

    //======================================================================
    // Master Controller
    //======================================================================

    i2c_master_ctrl u_master_ctrl (

        .clk            (clk),
        .rst_n          (rst_n),

        .start          (start),
        .rw             (rw),

        .phase          (phase),
        .byte_done      (byte_done),

        .sda_in         (sda_in),

        .stretch_active (stretch_active),

        .clk_enable     (clk_enable),

        .load_sel       (load_sel),
        .load_shift_reg (load_shift_reg),

        .shift_tx       (shift_tx),
        .shift_rx       (shift_rx),

        .counter_enable (counter_enable),
        .counter_clear  (counter_clear),

        .drive_sda_low  (drive_sda_low),
        .drive_scl_low  (drive_scl_low),

        .busy           (busy),
        .done           (done),

        .error          (error)

    );

endmodule
