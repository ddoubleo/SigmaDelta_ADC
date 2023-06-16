//Copyright (C)2014-2022 GOWIN Semiconductor Corporation.
//All rights reserved.
//File Title: Timing Constraints file
//GOWIN Version: 1.9.8.03 
//Created Time: 2022-05-07 16:25:54
create_clock -name clk -period 16 -waveform {0 8} [get_nets {clk}]
create_clock -name clk_in -period 20 -waveform {0 10} [get_nets {clk_in_d}]