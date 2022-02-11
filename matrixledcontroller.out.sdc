## Generated SDC file "matrixledcontroller.out.sdc"

## Copyright (C) 2021  Intel Corporation. All rights reserved.
## Your use of Intel Corporation's design tools, logic functions 
## and other software and tools, and any partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Intel Program License 
## Subscription Agreement, the Intel Quartus Prime License Agreement,
## the Intel FPGA IP License Agreement, or other applicable license
## agreement, including, without limitation, that your use is for
## the sole purpose of programming logic devices manufactured by
## Intel and sold by Intel or its authorized distributors.  Please
## refer to the applicable agreement for further details, at
## https://fpgasoftware.intel.com/eula.


## VENDOR  "Altera"
## PROGRAM "Quartus Prime"
## VERSION "Version 21.1.0 Build 842 10/21/2021 SJ Lite Edition"

## DATE    "Wed Feb  9 15:38:23 2022"

##
## DEVICE  "10M04SCE144C8G"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {altera_reserved_tck} -period 100.000 -waveform { 0.000 50.000 } [get_ports {altera_reserved_tck}]
create_clock -name {clk_25} -period 40.000 -waveform { 0.000 20.000 } [get_ports {clk_25}]
create_clock -name {mii_rx_clk} -period 40.000 -waveform { 0.000 20.000 } [get_ports {mii_rx_clk}]
create_clock -name {mii_tx_clk} -period 40.000 -waveform { 0.000 20.000 } [get_ports {mii_tx_clk}]


#**************************************************************
# Create Generated Clock
#**************************************************************

create_generated_clock -name {clk_50} -source [get_ports {clk_25}] -multiply_by 2 -master_clock {clk_25} [get_nets {pll_inst|altpll_component|auto_generated|wire_pll1_clk[0]}] 


#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

set_clock_uncertainty -rise_from [get_clocks {mii_tx_clk}] -rise_to [get_clocks {mii_tx_clk}]  0.070  
set_clock_uncertainty -rise_from [get_clocks {mii_tx_clk}] -fall_to [get_clocks {mii_tx_clk}]  0.070  
set_clock_uncertainty -fall_from [get_clocks {mii_tx_clk}] -rise_to [get_clocks {mii_tx_clk}]  0.070  
set_clock_uncertainty -fall_from [get_clocks {mii_tx_clk}] -fall_to [get_clocks {mii_tx_clk}]  0.070  
set_clock_uncertainty -rise_from [get_clocks {clk_50}] -rise_to [get_clocks {mii_tx_clk}] -setup 0.180  
set_clock_uncertainty -rise_from [get_clocks {clk_50}] -rise_to [get_clocks {mii_tx_clk}] -hold 0.160  
set_clock_uncertainty -rise_from [get_clocks {clk_50}] -fall_to [get_clocks {mii_tx_clk}] -setup 0.180  
set_clock_uncertainty -rise_from [get_clocks {clk_50}] -fall_to [get_clocks {mii_tx_clk}] -hold 0.160  
set_clock_uncertainty -rise_from [get_clocks {clk_50}] -rise_to [get_clocks {clk_50}]  0.070  
set_clock_uncertainty -rise_from [get_clocks {clk_50}] -fall_to [get_clocks {clk_50}]  0.070  
set_clock_uncertainty -rise_from [get_clocks {clk_50}] -rise_to [get_clocks {mii_rx_clk}] -setup 0.180  
set_clock_uncertainty -rise_from [get_clocks {clk_50}] -rise_to [get_clocks {mii_rx_clk}] -hold 0.160  
set_clock_uncertainty -rise_from [get_clocks {clk_50}] -fall_to [get_clocks {mii_rx_clk}] -setup 0.180  
set_clock_uncertainty -rise_from [get_clocks {clk_50}] -fall_to [get_clocks {mii_rx_clk}] -hold 0.160  
set_clock_uncertainty -fall_from [get_clocks {clk_50}] -rise_to [get_clocks {mii_tx_clk}] -setup 0.180  
set_clock_uncertainty -fall_from [get_clocks {clk_50}] -rise_to [get_clocks {mii_tx_clk}] -hold 0.160  
set_clock_uncertainty -fall_from [get_clocks {clk_50}] -fall_to [get_clocks {mii_tx_clk}] -setup 0.180  
set_clock_uncertainty -fall_from [get_clocks {clk_50}] -fall_to [get_clocks {mii_tx_clk}] -hold 0.160  
set_clock_uncertainty -fall_from [get_clocks {clk_50}] -rise_to [get_clocks {clk_50}]  0.070  
set_clock_uncertainty -fall_from [get_clocks {clk_50}] -fall_to [get_clocks {clk_50}]  0.070  
set_clock_uncertainty -fall_from [get_clocks {clk_50}] -rise_to [get_clocks {mii_rx_clk}] -setup 0.180  
set_clock_uncertainty -fall_from [get_clocks {clk_50}] -rise_to [get_clocks {mii_rx_clk}] -hold 0.160  
set_clock_uncertainty -fall_from [get_clocks {clk_50}] -fall_to [get_clocks {mii_rx_clk}] -setup 0.180  
set_clock_uncertainty -fall_from [get_clocks {clk_50}] -fall_to [get_clocks {mii_rx_clk}] -hold 0.160  
set_clock_uncertainty -rise_from [get_clocks {mii_rx_clk}] -rise_to [get_clocks {clk_50}] -setup 0.160  
set_clock_uncertainty -rise_from [get_clocks {mii_rx_clk}] -rise_to [get_clocks {clk_50}] -hold 0.180  
set_clock_uncertainty -rise_from [get_clocks {mii_rx_clk}] -fall_to [get_clocks {clk_50}] -setup 0.160  
set_clock_uncertainty -rise_from [get_clocks {mii_rx_clk}] -fall_to [get_clocks {clk_50}] -hold 0.180  
set_clock_uncertainty -rise_from [get_clocks {mii_rx_clk}] -rise_to [get_clocks {mii_rx_clk}]  0.070  
set_clock_uncertainty -rise_from [get_clocks {mii_rx_clk}] -fall_to [get_clocks {mii_rx_clk}]  0.070  
set_clock_uncertainty -fall_from [get_clocks {mii_rx_clk}] -rise_to [get_clocks {clk_50}] -setup 0.160  
set_clock_uncertainty -fall_from [get_clocks {mii_rx_clk}] -rise_to [get_clocks {clk_50}] -hold 0.180  
set_clock_uncertainty -fall_from [get_clocks {mii_rx_clk}] -fall_to [get_clocks {clk_50}] -setup 0.160  
set_clock_uncertainty -fall_from [get_clocks {mii_rx_clk}] -fall_to [get_clocks {clk_50}] -hold 0.180  
set_clock_uncertainty -fall_from [get_clocks {mii_rx_clk}] -rise_to [get_clocks {mii_rx_clk}]  0.070  
set_clock_uncertainty -fall_from [get_clocks {mii_rx_clk}] -fall_to [get_clocks {mii_rx_clk}]  0.070  
set_clock_uncertainty -rise_from [get_clocks {altera_reserved_tck}] -rise_to [get_clocks {altera_reserved_tck}]  0.070  
set_clock_uncertainty -rise_from [get_clocks {altera_reserved_tck}] -fall_to [get_clocks {altera_reserved_tck}]  0.070  
set_clock_uncertainty -fall_from [get_clocks {altera_reserved_tck}] -rise_to [get_clocks {altera_reserved_tck}]  0.070  
set_clock_uncertainty -fall_from [get_clocks {altera_reserved_tck}] -fall_to [get_clocks {altera_reserved_tck}]  0.070  


#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************

set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 
set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 


#**************************************************************
# Set False Path
#**************************************************************



#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

