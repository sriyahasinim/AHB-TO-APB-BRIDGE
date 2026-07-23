# AHB to APB Bridge using Verilog HDL

## Overview
This project implements an AHB (Advanced High-performance Bus) to APB (Advanced Peripheral Bus) Bridge using Verilog HDL. The bridge enables communication between a high-speed AHB bus and low-speed APB peripherals by converting AHB transactions into APB transactions.

## Features
- AHB Slave Interface
- APB Controller (Finite State Machine)
- APB Interface
- Address decoding
- Single Read operation
- Single Write operation
- Burst Write operation
- Modular Verilog design
- Testbench-based verification

## Project Structure
```
AHB-TO-APB-BRIDGE/
├── AHB_Master.v
├── AHP_slave.v
├── APB_controller.v
├── APB_interface.v
├── Bridge_top.v
├── tb_top.v
├── tb1_ahb_interface.v
├── tb2_apb_controller.v
├── tb3_single_write.v
├── tb4_single_read.v
├── tb5_burst_write.v
└── README.md
```

## Tools Used
- Verilog HDL
- Intel Quartus Prime
- ModelSim

## Verification
The design was verified using dedicated testbenches for:
- AHB Interface
- APB Controller
- Single Write
- Single Read
- Burst Write

## Applications
- SoC (System-on-Chip) Design
- AMBA-based Embedded Systems
- Digital IC Design
- VLSI Design Projects

## Future Improvements
- Burst Read support
- Error response handling
- Multiple APB peripherals
- Performance optimization

