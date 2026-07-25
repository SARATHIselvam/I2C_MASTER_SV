//==============================================================================
// Project : I2C Master Controller
// File    : i2c_master_ctrl.sv
// Author  : Sarathi Selvam D / Mentor
//
// Description:
// Main control FSM for the I2C Master.
// Responsible for protocol sequencing and datapath control generation.
//==============================================================================

import i2c_pkg :: *;

module i2c_master_ctrl(
    input  logic clk,
    input  logic rst_n,
    input  logic start,
    input  logic rw,

    input  phase_t phase,
    input  logic byte_done,
    input  logic sda_in,
    input  logic stretch_active,
    
    output logic clk_enable,
    output load_sel_t load_sel,
    output logic load_shift_reg,
    output logic shift_tx,
    output logic shift_rx,
    output logic counter_enable,
    output logic counter_clear,
    output logic drive_sda_low,
    output logic drive_scl_low,
    output logic busy,
    output logic done,
    output error_t error
);

    i2c_state_t state;
    i2c_state_t next_state;
    

    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end
    

    always_comb begin
        next_state = state;

        unique case(state)
            IDLE: begin
                if(start)
                    next_state = START;
            end

            START: begin
            
                if(!stretch_active && phase == PHASE3)
                    next_state = LOAD_ADDR;
            end

            LOAD_ADDR: begin
                next_state = SEND_ADDR;
            end

            SEND_ADDR: begin
                
                if(!stretch_active && byte_done && phase == PHASE3)
                    next_state = ADDR_ACK;
            end

            ADDR_ACK: begin
                if(!stretch_active && phase == PHASE3) begin
                    if(sda_in) 
                        next_state = ERROR;
                    else if(rw)
                        next_state = READ_DATA;
                    else
                        next_state = LOAD_DATA;
                end
            end

            LOAD_DATA: begin
                next_state = WRITE_DATA;
            end

            WRITE_DATA: begin
                if(!stretch_active && byte_done && phase == PHASE3)
                    next_state = DATA_ACK;
            end

            READ_DATA: begin
                if(!stretch_active && byte_done && phase == PHASE3)
                    next_state = DATA_ACK;
            end

            DATA_ACK: begin
                if(!stretch_active && phase == PHASE3)
                    next_state = STOP;
            end

            STOP: begin
                if(!stretch_active && phase == PHASE3)
                    next_state = DONE;
            end

            DONE: begin
                next_state = IDLE;
            end

            ERROR: begin
                next_state = IDLE;
            end

            default: next_state = IDLE;
        endcase
    end
    

    always_comb begin
       
        clk_enable      = 0;
        load_sel        = LOAD_SEL_DATA;
        load_shift_reg  = 0;
        shift_tx        = 0;
        shift_rx        = 0;
        counter_enable  = 0;
        counter_clear   = 0;
        drive_sda_low   = 0;
        drive_scl_low   = 0;
        busy            = 0;
        done            = 0;
        error           = NO_ERROR;

        case(state)
            IDLE: begin
                counter_clear = 1;
            end

            START: begin
                busy       = 1;
                clk_enable = 1;
                

                drive_scl_low = 0; 
                if (phase == PHASE2 || phase == PHASE3)
                    drive_sda_low = 1;
                else
                    drive_sda_low = 0;
            end

            LOAD_ADDR: begin
                busy           = 1;
                clk_enable     = 1;
                load_sel       = LOAD_SEL_ADDR;
                load_shift_reg = 1;
                counter_clear  = 1;
                

                drive_scl_low  = 1;
                drive_sda_low  = 1;
            end

            SEND_ADDR: begin
                busy       = 1;
                clk_enable = 1;
                load_sel   = LOAD_SEL_ADDR;


                drive_scl_low = (phase == PHASE0 || phase == PHASE3);
                

                if(phase == PHASE0) begin
                    shift_tx       = 1;
                    counter_enable = 1;
                end
                

                drive_sda_low = 1; 
            end

            ADDR_ACK: begin
                busy          = 1;
                clk_enable    = 1;
                

                drive_scl_low = (phase == PHASE0 || phase == PHASE3);
                
 
                drive_sda_low = 0; 
            end

            LOAD_DATA: begin
                busy           = 1;
                clk_enable     = 1;
                load_sel       = LOAD_SEL_DATA;
                load_shift_reg = 1;
                counter_clear  = 1;
                
                drive_scl_low  = 1;
            end

            WRITE_DATA: begin
                busy          = 1;
                clk_enable    = 1;
                drive_scl_low = (phase == PHASE0 || phase == PHASE3);

                if(phase == PHASE0) begin
                    shift_tx       = 1;
                    counter_enable = 1;
                end
                
                drive_sda_low = 1;
            end

            READ_DATA: begin
                busy          = 1;
                clk_enable    = 1;
                drive_scl_low = (phase == PHASE0 || phase == PHASE3);
                

                drive_sda_low = 0; 

                if(phase == PHASE2) begin
                    shift_rx       = 1;
                    counter_enable = 1;
                end
            end

            DATA_ACK: begin
                busy          = 1;
                clk_enable    = 1;
                drive_scl_low = (phase == PHASE0 || phase == PHASE3);
                

                drive_sda_low = rw ? 1'b1 : 1'b0; 
            end

            STOP: begin
                busy       = 1;
                clk_enable = 1;

                if (phase == PHASE0) begin
                    drive_scl_low = 1;
                    drive_sda_low = 1;
                end else if (phase == PHASE1) begin
                    drive_scl_low = 0;
                    drive_sda_low = 1;
                end else begin
                    drive_scl_low = 0;
                    drive_sda_low = 0; 
                end
            end

            DONE: begin
                done = 1;
            end

            ERROR: begin
                error = NACK_ERROR;
            end
        endcase
    end
    
endmodule
