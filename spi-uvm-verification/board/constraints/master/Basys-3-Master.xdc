## Basys3 SPI Master constraints

## Clock
set_property -dict { PACKAGE_PIN W5 IOSTANDARD LVCMOS33 } [get_ports clk]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]

## SW[7:0] -> tx_data[7:0]
set_property -dict { PACKAGE_PIN V17 IOSTANDARD LVCMOS33 } [get_ports {tx_data[0]}]
set_property -dict { PACKAGE_PIN V16 IOSTANDARD LVCMOS33 } [get_ports {tx_data[1]}]
set_property -dict { PACKAGE_PIN W16 IOSTANDARD LVCMOS33 } [get_ports {tx_data[2]}]
set_property -dict { PACKAGE_PIN W17 IOSTANDARD LVCMOS33 } [get_ports {tx_data[3]}]
set_property -dict { PACKAGE_PIN W15 IOSTANDARD LVCMOS33 } [get_ports {tx_data[4]}]
set_property -dict { PACKAGE_PIN V15 IOSTANDARD LVCMOS33 } [get_ports {tx_data[5]}]
set_property -dict { PACKAGE_PIN W14 IOSTANDARD LVCMOS33 } [get_ports {tx_data[6]}]
set_property -dict { PACKAGE_PIN W13 IOSTANDARD LVCMOS33 } [get_ports {tx_data[7]}]

## Buttons
set_property -dict { PACKAGE_PIN U18 IOSTANDARD LVCMOS33 } [get_ports reset]
set_property -dict { PACKAGE_PIN T18 IOSTANDARD LVCMOS33 } [get_ports insert_start]

## Debug LEDs
set_property -dict { PACKAGE_PIN U16 IOSTANDARD LVCMOS33 } [get_ports led_done]
set_property -dict { PACKAGE_PIN E19 IOSTANDARD LVCMOS33 } [get_ports led_busy]
set_property -dict { PACKAGE_PIN U19 IOSTANDARD LVCMOS33 } [get_ports led_ss_n]
set_property -dict { PACKAGE_PIN V19 IOSTANDARD LVCMOS33 } [get_ports led_clean_start]

## PMOD JA: SPI
set_property -dict { PACKAGE_PIN J1 IOSTANDARD LVCMOS33 } [get_ports sclk] ;# JA1
set_property -dict { PACKAGE_PIN L2 IOSTANDARD LVCMOS33 } [get_ports mosi] ;# JA2
set_property -dict { PACKAGE_PIN J2 IOSTANDARD LVCMOS33 } [get_ports miso] ;# JA3
set_property -dict { PACKAGE_PIN G2 IOSTANDARD LVCMOS33 } [get_ports ss_n] ;# JA4

## Configuration
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]
