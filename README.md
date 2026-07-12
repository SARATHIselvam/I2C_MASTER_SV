# I2C Master Controller (SystemVerilog)

A synthesizable **I2C Master Controller** designed in **SystemVerilog** following the **NXP I²C Bus Specification**. The design adopts a modular RTL architecture with a dedicated control FSM, timing engine, datapath, and open-drain bus interface.

This project was developed as an RTL Design project to strengthen digital design, finite state machine implementation, timing control, and serial communication protocol knowledge.

---

## Features

- Synthesizable RTL
- Modular architecture
- Supports Standard Mode (100 kHz)
- 7-bit slave addressing
- Master Write operation
- Master Read framework
- Open-drain SDA/SCL interface
- Clock stretching detection
- ACK/NACK detection
- Parameterizable clock frequency
- Clean separation of Control Path and Data Path

---

## Specifications

| Parameter | Value |
|-----------|-------|
| Language | SystemVerilog |
| Protocol | I²C |
| Mode | Standard Mode |
| Bus Speed | 100 kHz |
| System Clock | 100 MHz |
| Address Width | 7-bit |
| Data Width | 8-bit |
| Synthesizable | Yes |

---

# Project Architecture

```
                    +----------------------+
                    |     User Interface   |
                    | start, addr, data    |
                    +----------+-----------+
                               |
                               |
                    +----------v-----------+
                    |   I2C Master FSM     |
                    | (Control Path)       |
                    +----------+-----------+
                               |
             +-----------------+----------------+
             |                                  |
             |                                  |
     +-------v------+                  +--------v--------+
     | Timing Engine |                  | Shift Register |
     +-------+------+                  +--------+--------+
             |                                  |
             |                          +--------v--------+
             |                          | Bit Counter     |
             |                          +--------+--------+
             |                                   |
     +-------v-----------------------------------v------+
     |               Bus Controller                     |
     |      Open Drain SDA / SCL Interface              |
     +-------------------------+-------------------------+
                               |
                        I²C Bus (SDA / SCL)
```

---

# Module Description

## i2c_pkg.sv

Global package containing:

- Design parameters
- FSM state definitions
- Timing phase definitions
- Error codes
- Load selector types

---

## i2c_clk_gen.sv

Generates timing ticks from the system clock.

Converts:

```
100 MHz
      ↓
100 kHz timing tick
```

---

## i2c_timing_engine.sv

Generates the four timing phases for every I²C bit.

```
PHASE0
↓

PHASE1
↓

PHASE2
↓

PHASE3
↓

Repeat
```

Responsibilities

- Shift timing
- Sampling timing
- Bit synchronization

---

## i2c_shift_reg.sv

Implements separate transmit and receive shift registers.

Transmit

- Parallel load
- MSB-first shift

Receive

- Serial input
- Parallel output

---

## i2c_bit_counter.sv

Counts transmitted or received bits.

Features

- Byte completion detection
- Counter reset
- Parameterized width

---

## i2c_bus_ctrl.sv

Implements the physical I²C bus.

Responsibilities

- Open-drain SDA
- Open-drain SCL
- SDA sampling
- SCL sampling

---

## i2c_clk_stretch.sv

Detects slave clock stretching.

If SCL is released by the master but remains LOW, clock stretching is detected.

---

## i2c_master_ctrl.sv

Main finite state machine controlling the entire protocol.

Implemented states

- IDLE
- START
- LOAD_ADDR
- SEND_ADDR
- ADDR_ACK
- LOAD_DATA
- WRITE_DATA
- READ_DATA
- DATA_ACK
- STOP
- DONE
- ERROR

Responsibilities

- Protocol sequencing
- Shift register control
- Bit counter control
- SDA/SCL control
- ACK/NACK handling
- Error reporting

---

## i2c_master_top.sv

Top-level integration module.

Instantiates all RTL blocks and connects the datapath with the controller.

---

# FSM

```
             +------+
             | IDLE |
             +--+---+
                |
             START
                |
          LOAD_ADDR
                |
          SEND_ADDR
                |
          ADDR_ACK
          /      \
      ACK          NACK
      |              |
      |            ERROR
      |
  +---+---+
  |       |
 WRITE   READ
  |       |
 DATA_ACK
     |
    STOP
     |
    DONE
     |
    IDLE
```

---

# Repository Structure

```
I2C_Master/
│
├── rtl/
│   ├── i2c_pkg.sv
│   ├── i2c_clk_gen.sv
│   ├── i2c_timing_engine.sv
│   ├── i2c_shift_reg.sv
│   ├── i2c_bit_counter.sv
│   ├── i2c_bus_ctrl.sv
│   ├── i2c_clk_stretch.sv
│   ├── i2c_master_ctrl.sv
│   └── i2c_master_top.sv
│
├── tb/
│   └── tb_i2c_master.sv
│
├── waveforms/
│
├── docs/
│
└── README.md
```

---

# Simulation

Recommended tools

- ModelSim Intel FPGA Edition
- QuestaSim

Compile

```
vlog *.sv
```

Simulate

```
vsim tb_i2c_master
run -all
```

---

# Synthesis

Successfully synthesized using

- Intel Quartus Prime Lite Edition

No synthesis errors.

---

# Future Improvements

- Repeated START support
- Multi-byte read/write
- Multi-master arbitration
- Bus busy detection
- Programmable clock divider
- Timeout detection
- 10-bit addressing
- Fast Mode (400 kHz)
- Fast Mode Plus (1 MHz)

---

# Learning Outcomes

This project demonstrates understanding of:

- RTL Design
- SystemVerilog
- Finite State Machines
- Serial Communication Protocols
- Timing Generation
- Shift Registers
- Open-Drain Bus Interfaces
- Clock Domain Timing
- Protocol Controller Design
- Digital System Integration

---

# References

1. NXP Semiconductors, **UM10204 I²C-bus Specification and User Manual**.
2. Janick Bergeron, *Writing Testbenches using SystemVerilog*.
3. IEEE Std 1800™ SystemVerilog Language Reference Manual.
4. Intel Quartus Prime Documentation.

---

## Author

**Sarathi Selvam D**

Electronics and Communication Engineering  
Sri Venkateswara College of Engineering

Focused on RTL Design • Digital Design • VLSI • Verification
