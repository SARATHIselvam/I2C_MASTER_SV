`timescale 1ns/1ps

import i2c_pkg::*;

module tb_i2c_master;



    logic clk;
    logic rst_n;

    logic start;
    logic rw;

    logic [ADDR_WIDTH-1:0] slave_addr;
    logic [DATA_WIDTH-1:0] tx_data;
    logic [DATA_WIDTH-1:0] rx_data;

    logic busy;
    logic done;
    error_t error;

    tri1 sda;
    tri1 scl;

    logic slave_ack;


    assign sda = (slave_ack) ? 1'b0 : 1'bz;


    i2c_master_top dut(
        .clk(clk),
        .rst_n(rst_n),

        .start(start),
        .rw(rw),

        .slave_addr(slave_addr),
        .tx_data(tx_data),
        .rx_data(rx_data),

        .busy(busy),
        .done(done),
        .error(error),

        .sda(sda),
        .scl(scl)
    );


    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end


    initial begin

        rst_n      = 0;
        start      = 0;
        rw         = 0;

        slave_addr = 7'h50;
        tx_data    = 8'hA5;

        slave_ack  = 0;


        repeat(5) @(posedge clk);
        rst_n = 1;

        repeat(5) @(posedge clk);


        $display("Starting I2C Write");

        start = 1;

        repeat(3) @(posedge clk);

        start = 0;


        repeat(200) @(posedge clk);

        slave_ack = 1;

        repeat(20) @(posedge clk);

        slave_ack = 0;



        repeat(2000) @(posedge clk);

        $display("--------------------------------");
        $display("busy  = %0d", busy);
        $display("done  = %0d", done);
        $display("error = %0d", error);
        $display("--------------------------------");

        $stop;

    end

endmodule