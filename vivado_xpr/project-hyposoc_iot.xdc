#set_property SEVERITY {Warning} [get_drc_checks RTSTAT-2]

# Clocking
#create_clock -period 10.000 [get_ports clk]
set_property PACKAGE_PIN AC19 [get_ports clk]
set_property CLOCK_DEDICATED_ROUTE BACKBONE [get_nets clk]
create_clock -period 10.000 -name clk -waveform {0.000 5.000} [get_ports clk]

# Reset
set_property PACKAGE_PIN Y3 [get_ports resetn]

# ---- GPIO Pins FPGA_EXT_IO0-15
set_property PACKAGE_PIN M25 [get_ports {GPIO16_pins[0]}]
set_property PACKAGE_PIN P25 [get_ports {GPIO16_pins[1]}]
set_property PACKAGE_PIN R26 [get_ports {GPIO16_pins[2]}]
set_property PACKAGE_PIN K26 [get_ports {GPIO16_pins[3]}]
set_property PACKAGE_PIN N26 [get_ports {GPIO16_pins[4]}]
set_property PACKAGE_PIN R25 [get_ports {GPIO16_pins[5]}]
set_property PACKAGE_PIN K25 [get_ports {GPIO16_pins[6]}]
set_property PACKAGE_PIN M26 [get_ports {GPIO16_pins[7]}]
set_property PACKAGE_PIN P26 [get_ports {GPIO16_pins[8]}]
set_property PACKAGE_PIN T25 [get_ports {GPIO16_pins[9]}]
set_property PACKAGE_PIN L24 [get_ports {GPIO16_pins[10]}]
set_property PACKAGE_PIN L25 [get_ports {GPIO16_pins[11]}]
set_property PACKAGE_PIN L23 [get_ports {GPIO16_pins[12]}]
set_property PACKAGE_PIN L22 [get_ports {GPIO16_pins[13]}]
set_property PACKAGE_PIN M24 [get_ports {GPIO16_pins[14]}]
set_property PACKAGE_PIN L20 [get_ports {GPIO16_pins[15]}]

# ---- GPIO Pins FPGA_EXT_IO16-31
set_property PACKAGE_PIN M22 [get_ports rx]
set_property PACKAGE_PIN N24 [get_ports tx]
set_property PACKAGE_PIN N23 [get_ports pwm_0]
set_property PACKAGE_PIN N22 [get_ports pwm_1]
set_property PACKAGE_PIN M21 [get_ports pwm_2]
set_property PACKAGE_PIN N21 [get_ports pwm_3]
#set_property PACKAGE_PIN M20
#set_property PACKAGE_PIN N19
#set_property PACKAGE_PIN P24
#set_property PACKAGE_PIN P23
#set_property PACKAGE_PIN P21
#set_property PACKAGE_PIN R23
#set_property PACKAGE_PIN R22
#set_property PACKAGE_PIN T24
#set_property PACKAGE_PIN T23
#set_property PACKAGE_PIN T22

set_property IOSTANDARD LVCMOS33 [get_ports {GPIO16_pins[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports rx]
set_property IOSTANDARD LVCMOS33 [get_ports tx]
set_property IOSTANDARD LVCMOS33 [get_ports pwm_0]
set_property IOSTANDARD LVCMOS33 [get_ports pwm_1]
set_property IOSTANDARD LVCMOS33 [get_ports pwm_2]
set_property IOSTANDARD LVCMOS33 [get_ports pwm_3]

#LCD & TS
set_property PACKAGE_PIN J25 [get_ports lcd_rst]
set_property PACKAGE_PIN H18 [get_ports lcd_cs]
set_property PACKAGE_PIN K16 [get_ports lcd_rs]
set_property PACKAGE_PIN L8 [get_ports lcd_wr]
set_property PACKAGE_PIN K8 [get_ports lcd_rd]
set_property PACKAGE_PIN J15 [get_ports lcd_bl_ctr]
set_property PACKAGE_PIN H9 [get_ports {lcd_data_io[0]}]
set_property PACKAGE_PIN K17 [get_ports {lcd_data_io[1]}]
set_property PACKAGE_PIN J20 [get_ports {lcd_data_io[2]}]
set_property PACKAGE_PIN M17 [get_ports {lcd_data_io[3]}]
set_property PACKAGE_PIN L17 [get_ports {lcd_data_io[4]}]
set_property PACKAGE_PIN L18 [get_ports {lcd_data_io[5]}]
set_property PACKAGE_PIN L15 [get_ports {lcd_data_io[6]}]
set_property PACKAGE_PIN M15 [get_ports {lcd_data_io[7]}]
set_property PACKAGE_PIN M16 [get_ports {lcd_data_io[8]}]
set_property PACKAGE_PIN L14 [get_ports {lcd_data_io[9]}]
set_property PACKAGE_PIN M14 [get_ports {lcd_data_io[10]}]
set_property PACKAGE_PIN F22 [get_ports {lcd_data_io[11]}]
set_property PACKAGE_PIN G22 [get_ports {lcd_data_io[12]}]
set_property PACKAGE_PIN G21 [get_ports {lcd_data_io[13]}]
set_property PACKAGE_PIN H24 [get_ports {lcd_data_io[14]}]
set_property PACKAGE_PIN J16 [get_ports {lcd_data_io[15]}]
set_property PACKAGE_PIN L19 [get_ports ct_int]
set_property PACKAGE_PIN J24 [get_ports ct_sda]
set_property PACKAGE_PIN H21 [get_ports ct_scl]
set_property PACKAGE_PIN G24 [get_ports ct_rstn]

#LED
set_property PACKAGE_PIN K23 [get_ports {led[0]}]
set_property PACKAGE_PIN J21 [get_ports {led[1]}]
set_property PACKAGE_PIN H23 [get_ports {led[2]}]
set_property PACKAGE_PIN J19 [get_ports {led[3]}]
set_property PACKAGE_PIN G9 [get_ports {led[4]}]
set_property PACKAGE_PIN J26 [get_ports {led[5]}]
set_property PACKAGE_PIN J23 [get_ports {led[6]}]
set_property PACKAGE_PIN J8 [get_ports {led[7]}]
set_property PACKAGE_PIN H8 [get_ports {led[8]}]
set_property PACKAGE_PIN G8 [get_ports {led[9]}]
set_property PACKAGE_PIN F7 [get_ports {led[10]}]
set_property PACKAGE_PIN A4 [get_ports {led[11]}]
set_property PACKAGE_PIN A5 [get_ports {led[12]}]
set_property PACKAGE_PIN A3 [get_ports {led[13]}]
set_property PACKAGE_PIN D5 [get_ports {led[14]}]
set_property PACKAGE_PIN H7 [get_ports {led[15]}]

#led_rg 0/1
set_property PACKAGE_PIN G7 [get_ports {led_rg0[0]}]
set_property PACKAGE_PIN F8 [get_ports {led_rg0[1]}]
set_property PACKAGE_PIN B5 [get_ports {led_rg1[0]}]
set_property PACKAGE_PIN D6 [get_ports {led_rg1[1]}]

#DOT
set_property PACKAGE_PIN F3 [get_ports {dot_r[0]}]
set_property PACKAGE_PIN F4 [get_ports {dot_r[1]}]
set_property PACKAGE_PIN C2 [get_ports {dot_r[2]}]
set_property PACKAGE_PIN F5 [get_ports {dot_r[3]}]
set_property PACKAGE_PIN H3 [get_ports {dot_r[4]}]
set_property PACKAGE_PIN B1 [get_ports {dot_r[5]}]
set_property PACKAGE_PIN G4 [get_ports {dot_r[6]}]
set_property PACKAGE_PIN J5 [get_ports {dot_r[7]}]

set_property PACKAGE_PIN G6 [get_ports {dot_c[0]}]
set_property PACKAGE_PIN G5 [get_ports {dot_c[1]}]
set_property PACKAGE_PIN H6 [get_ports {dot_c[2]}]
set_property PACKAGE_PIN J4 [get_ports {dot_c[3]}]
set_property PACKAGE_PIN J6 [get_ports {dot_c[4]}]
set_property PACKAGE_PIN E3 [get_ports {dot_c[5]}]
set_property PACKAGE_PIN C1 [get_ports {dot_c[6]}]
set_property PACKAGE_PIN H4 [get_ports {dot_c[7]}]

#NUM
set_property PACKAGE_PIN D3 [get_ports {num_csn[7]}]
set_property PACKAGE_PIN D25 [get_ports {num_csn[6]}]
set_property PACKAGE_PIN D26 [get_ports {num_csn[5]}]
set_property PACKAGE_PIN E25 [get_ports {num_csn[4]}]
set_property PACKAGE_PIN E26 [get_ports {num_csn[3]}]
set_property PACKAGE_PIN G25 [get_ports {num_csn[2]}]
set_property PACKAGE_PIN G26 [get_ports {num_csn[1]}]
set_property PACKAGE_PIN H26 [get_ports {num_csn[0]}]

set_property PACKAGE_PIN C3 [get_ports {num_a_g[0]}]
set_property PACKAGE_PIN E6 [get_ports {num_a_g[1]}]
set_property PACKAGE_PIN B2 [get_ports {num_a_g[2]}]
set_property PACKAGE_PIN B4 [get_ports {num_a_g[3]}]
set_property PACKAGE_PIN E5 [get_ports {num_a_g[4]}]
set_property PACKAGE_PIN D4 [get_ports {num_a_g[5]}]
set_property PACKAGE_PIN A2 [get_ports {num_a_g[6]}]
#set_property PACKAGE_PIN C4 :DP

#switch
set_property PACKAGE_PIN AC21 [get_ports {switch[7]}]
set_property PACKAGE_PIN AD24 [get_ports {switch[6]}]
set_property PACKAGE_PIN AC22 [get_ports {switch[5]}]
set_property PACKAGE_PIN AC23 [get_ports {switch[4]}]
set_property PACKAGE_PIN AB6 [get_ports {switch[3]}]
set_property PACKAGE_PIN W6 [get_ports {switch[2]}]
set_property PACKAGE_PIN AA7 [get_ports {switch[1]}]
set_property PACKAGE_PIN Y6 [get_ports {switch[0]}]

#btn_key
set_property PACKAGE_PIN V8 [get_ports {btn_key_col[0]}]
set_property PACKAGE_PIN V9 [get_ports {btn_key_col[1]}]
set_property PACKAGE_PIN Y8 [get_ports {btn_key_col[2]}]
set_property PACKAGE_PIN V7 [get_ports {btn_key_col[3]}]
set_property PACKAGE_PIN U7 [get_ports {btn_key_row[0]}]
set_property PACKAGE_PIN W8 [get_ports {btn_key_row[1]}]
set_property PACKAGE_PIN Y7 [get_ports {btn_key_row[2]}]
set_property PACKAGE_PIN AA8 [get_ports {btn_key_row[3]}]

#btn_step
set_property PACKAGE_PIN Y5 [get_ports {btn_step[0]}]
set_property PACKAGE_PIN V6 [get_ports {btn_step[1]}]

#SPI flash
set_property PACKAGE_PIN P20 [get_ports SPI_CLK]
set_property PACKAGE_PIN R20 [get_ports SPI_CS]
set_property PACKAGE_PIN P19 [get_ports SPI_MISO]
set_property PACKAGE_PIN N18 [get_ports SPI_MOSI]

#mac phy connect
set_property PACKAGE_PIN AB21 [get_ports mtxclk_0]
set_property PACKAGE_PIN AA19 [get_ports mrxclk_0]
set_property PACKAGE_PIN AA15 [get_ports mtxen_0]
set_property PACKAGE_PIN AF18 [get_ports {mtxd_0[0]}]
set_property PACKAGE_PIN AE18 [get_ports {mtxd_0[1]}]
set_property PACKAGE_PIN W15 [get_ports {mtxd_0[2]}]
set_property PACKAGE_PIN W14 [get_ports {mtxd_0[3]}]
set_property PACKAGE_PIN AB20 [get_ports mtxerr_0]
set_property PACKAGE_PIN AE22 [get_ports mrxdv_0]
set_property PACKAGE_PIN V1 [get_ports {mrxd_0[0]}]
set_property PACKAGE_PIN V4 [get_ports {mrxd_0[1]}]
set_property PACKAGE_PIN V2 [get_ports {mrxd_0[2]}]
set_property PACKAGE_PIN V3 [get_ports {mrxd_0[3]}]
set_property PACKAGE_PIN W16 [get_ports mrxerr_0]
set_property PACKAGE_PIN Y15 [get_ports mcoll_0]
set_property PACKAGE_PIN AF20 [get_ports mcrs_0]
set_property PACKAGE_PIN W3 [get_ports mdc_0]
set_property PACKAGE_PIN W1 [get_ports mdio_0]
set_property PACKAGE_PIN AE26 [get_ports phy_rstn]

#uart
set_property PACKAGE_PIN F23 [get_ports UART_RX]
set_property IOSTANDARD LVCMOS33 [get_ports UART_RX]
set_property PACKAGE_PIN H19 [get_ports UART_TX]
set_property IOSTANDARD LVCMOS33 [get_ports UART_TX]

#nand flash
set_property PACKAGE_PIN V19 [get_ports NAND_CLE]
set_property PACKAGE_PIN W20 [get_ports NAND_ALE]
set_property PACKAGE_PIN AA25 [get_ports NAND_RDY]
set_property PACKAGE_PIN AA24 [get_ports NAND_RD]
set_property PACKAGE_PIN AB24 [get_ports NAND_CE]
set_property PACKAGE_PIN AA22 [get_ports NAND_WR]
set_property PACKAGE_PIN W19 [get_ports {NAND_DATA[7]}]
set_property PACKAGE_PIN Y20 [get_ports {NAND_DATA[6]}]
set_property PACKAGE_PIN Y21 [get_ports {NAND_DATA[5]}]
set_property PACKAGE_PIN V18 [get_ports {NAND_DATA[4]}]
set_property PACKAGE_PIN U19 [get_ports {NAND_DATA[3]}]
set_property PACKAGE_PIN U20 [get_ports {NAND_DATA[2]}]
set_property PACKAGE_PIN W21 [get_ports {NAND_DATA[1]}]
set_property PACKAGE_PIN AC24 [get_ports {NAND_DATA[0]}]

#ejtag
set_property PACKAGE_PIN J18 [get_ports EJTAG_TRST]
set_property PACKAGE_PIN K18 [get_ports EJTAG_TCK]
set_property PACKAGE_PIN K20 [get_ports EJTAG_TDI]
set_property PACKAGE_PIN K22 [get_ports EJTAG_TMS]
set_property PACKAGE_PIN K21 [get_ports EJTAG_TDO]


set_property IOSTANDARD LVCMOS33 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports resetn]
set_property IOSTANDARD LVCMOS33 [get_ports {led[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_rg0[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_rg1[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dot_c[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dot_r[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports {num_a_g[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports {num_csn[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports {switch[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports {btn_key_col[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports {btn_key_row[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports {btn_step[*]}]

set_property IOSTANDARD LVCMOS33 [get_ports lcd_rst]
set_property IOSTANDARD LVCMOS33 [get_ports lcd_cs]
set_property IOSTANDARD LVCMOS33 [get_ports lcd_rs]
set_property IOSTANDARD LVCMOS33 [get_ports lcd_wr]
set_property IOSTANDARD LVCMOS33 [get_ports lcd_rd]
set_property IOSTANDARD LVCMOS33 [get_ports lcd_bl_ctr]
set_property IOSTANDARD LVCMOS33 [get_ports {lcd_data_io[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports ct_int]
set_property IOSTANDARD LVCMOS33 [get_ports ct_sda]
set_property IOSTANDARD LVCMOS33 [get_ports ct_scl]
set_property IOSTANDARD LVCMOS33 [get_ports ct_rstn]

set_property IOSTANDARD LVCMOS33 [get_ports SPI_MOSI]
set_property IOSTANDARD LVCMOS33 [get_ports SPI_MISO]
set_property IOSTANDARD LVCMOS33 [get_ports SPI_CS]
set_property IOSTANDARD LVCMOS33 [get_ports SPI_CLK]

set_property IOSTANDARD LVCMOS33 [get_ports {mrxd_0[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mtxd_0[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports phy_rstn]
set_property IOSTANDARD LVCMOS33 [get_ports mtxerr_0]
set_property IOSTANDARD LVCMOS33 [get_ports mtxen_0]
set_property IOSTANDARD LVCMOS33 [get_ports mtxclk_0]
set_property IOSTANDARD LVCMOS33 [get_ports mrxerr_0]
set_property IOSTANDARD LVCMOS33 [get_ports mcoll_0]
set_property IOSTANDARD LVCMOS33 [get_ports mcrs_0]
set_property IOSTANDARD LVCMOS33 [get_ports mdc_0]
set_property IOSTANDARD LVCMOS33 [get_ports mdio_0]
set_property IOSTANDARD LVCMOS33 [get_ports mrxclk_0]
set_property IOSTANDARD LVCMOS33 [get_ports mrxdv_0]

set_property IOSTANDARD LVCMOS33 [get_ports NAND_CLE]
set_property IOSTANDARD LVCMOS33 [get_ports NAND_ALE]
set_property IOSTANDARD LVCMOS33 [get_ports NAND_RDY]
set_property IOSTANDARD LVCMOS33 [get_ports NAND_RD]
set_property IOSTANDARD LVCMOS33 [get_ports NAND_CE]
set_property IOSTANDARD LVCMOS33 [get_ports NAND_WR]
set_property IOSTANDARD LVCMOS33 [get_ports {NAND_DATA[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {NAND_DATA[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {NAND_DATA[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {NAND_DATA[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {NAND_DATA[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {NAND_DATA[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {NAND_DATA[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {NAND_DATA[0]}]

set_property IOSTANDARD LVCMOS33 [get_ports EJTAG_TRST]
set_property IOSTANDARD LVCMOS33 [get_ports EJTAG_TCK]
set_property IOSTANDARD LVCMOS33 [get_ports EJTAG_TDI]
set_property IOSTANDARD LVCMOS33 [get_ports EJTAG_TMS]
set_property IOSTANDARD LVCMOS33 [get_ports EJTAG_TDO]
# set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets EJTAG_TCK_IBUF]

create_clock -period 40.000 -name mrxclk_0 -waveform {0.000 20.000} [get_ports mrxclk_0]
create_clock -period 40.000 -name mtxclk_0 -waveform {0.000 20.000} [get_ports mtxclk_0]

set_false_path -from [get_clocks clk_pll_i] -to [get_clocks clk_out1_clk_pll_33]
set_false_path -from [get_clocks mrxclk_0] -to [get_clocks clk_out1_clk_pll_33]
set_false_path -from [get_clocks mtxclk_0] -to [get_clocks clk_out1_clk_pll_33]
set_false_path -from [get_clocks clk_out1_clk_pll_33] -to [get_clocks mrxclk_0]
set_false_path -from [get_clocks clk_out1_clk_pll_33] -to [get_clocks mrxclk_0]
set_false_path -from [get_clocks clk_out1_clk_pll_33] -to [get_clocks mtxclk_0]
set_false_path -from [get_clocks clk_out1_clk_pll_33] -to [get_clocks mtxclk_0]








