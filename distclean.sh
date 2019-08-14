# =============================================================================
#  HITwh Hypothetic MIPS Team :: Hypothetic SoC IoT
#   _    _                   _____  ____   _____            _____   _______ 
#  | |  | |                 / ____|/ __ \ / ____|          |_   _| |__   __|
#  | |__| |_   _ _ __   ___| (___ | |  | | |       ______    | |  ___ | |   
#  |  __  | | | | '_ \ / _ \\___ \| |  | | |      |______|   | | / _ \| |   
#  | |  | | |_| | |_) | (_) |___) | |__| | |____            _| || (_) | |   
#  |_|  |_|\__, | .__/ \___/_____/ \____/ \_____|          |_____\___/|_|   
#           __/ | |                                                         
#          |___/|_|                                                         
 
#  Code And Concept By HITwh Hypothetic MIPS Team
#  https://github.com/hitwh-nscscc
 
# =============================================================================

#!/bin/bash
#set -o errexit

echo "_>  Running distclean..."
echo "_>  (0/3) Initialize..."
export WORKDIR=`pwd`

# Vivado temp file
echo "_>  (1/3) Cleaning Vivado temp files..."
rm -rf $WORKDIR/vivado_xpr/project-hyposoc_iot/project-hyposoc_iot.cache
rm -rf $WORKDIR/vivado_xpr/project-hyposoc_iot/project-hyposoc_iot.hw
rm -rf $WORKDIR/vivado_xpr/project-hyposoc_iot/project-hyposoc_iot.ip_user_files
rm -rf $WORKDIR/vivado_xpr/project-hyposoc_iot/project-hyposoc_iot.runs
rm -rf $WORKDIR/vivado_xpr/project-hyposoc_iot/project-hyposoc_iot.srcs
rm -rf $WORKDIR/vivado_xpr/project-hyposoc_iot/project-hyposoc_iot.sim
rm -rf $WORKDIR/vivado_xpr/project-hyposoc_iot/vivado.jou
rm -rf $WORKDIR/vivado_xpr/project-hyposoc_iot/vivado.log

# Xlnx IP Core
echo "_>  (2/3) Cleaning SoC Xlnx IP Core files..."
##  MIG
cd $WORKDIR/rtl/Xilinx_IP/mig_axi_32
rm -rf `ls -l | grep -v .xci | grep -v .prj | awk '{print $9}'`
##  GPU RAM
cd $WORKDIR/rtl/Xilinx_IP/gpu_ram
rm -rf `ls -l | grep -v .xci | awk '{print $9}'`
##  GPU AXI2BRAM
cd $WORKDIR/rtl/Xilinx_IP/gpu_axi_to_bram
rm -rf `ls -l | grep -v .xci | awk '{print $9}'`
##  DPRAM 512x32
cd $WORKDIR/rtl/Xilinx_IP/dpram_512x32
rm -rf `ls -l | grep -v .xci | awk '{print $9}'`
##  CLK WIZARD 0
cd $WORKDIR/rtl/Xilinx_IP/clk_wiz_0
rm -rf `ls -l | grep -v .xci | awk '{print $9}'`
##  CLK PLL 33
cd $WORKDIR/rtl/Xilinx_IP/clk_pll_33
rm -rf `ls -l | grep -v .xci | awk '{print $9}'`
##  AXI4 CROSSBAR
cd $WORKDIR/rtl/Xilinx_IP/axi4lite_crossbar_0
rm -rf `ls -l | grep -v .xci | awk '{print $9}'`
##  AXI4 LITE UART Lite
cd $WORKDIR/rtl/Xilinx_IP/axi_uartlite_0
rm -rf `ls -l | grep -v .xci | awk '{print $9}'`
##  AXI INTERCONNECT
cd $WORKDIR/rtl/Xilinx_IP/axi_interconnect_0
rm -rf `ls -l | grep -v .xci | awk '{print $9}'`
##  AXI INTC
cd $WORKDIR/rtl/Xilinx_IP/axi_intc_0
rm -rf `ls -l | grep -v .xci | awk '{print $9}'`
##  AXI GPIO
cd $WORKDIR/rtl/Xilinx_IP/axi_gpio_0
rm -rf `ls -l | grep -v .xci | awk '{print $9}'`
##  AXI3 CROSSBAR
cd $WORKDIR/rtl/Xilinx_IP/axi_crossbar_soc
rm -rf `ls -l | grep -v .xci | awk '{print $9}'`

## CPU XLNX IP
echo "_>  (3/3) Cleaning CPU XLNX IP Core files..."
##  BUS INTERFACE
cd $WORKDIR/rtl/CPU/Xilinx_IP/Bus_Interface
rm -rf `ls -l | grep -v .xci | awk '{print $9}'`
##  DCACHE RAM
cd $WORKDIR/rtl/CPU/Xilinx_IP/DCache_Ram_IP
rm -rf `ls -l | grep -v .xci | awk '{print $9}'`
##  ICACHE RAM
cd $WORKDIR/rtl/CPU/Xilinx_IP/ICache_Ram_IP
rm -rf `ls -l | grep -v .xci | awk '{print $9}'`

echo "_>  Done. "
echo "_>  Will exit in 1 sec. "
sleep 1s