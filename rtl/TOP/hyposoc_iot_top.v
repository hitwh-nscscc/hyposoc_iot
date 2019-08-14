// =============================================================================
//  HITwh Hypothetic MIPS Team :: Hypothetic SoC IoT
//   _    _                   _____  ____   _____            _____   _______ 
//  | |  | |                 / ____|/ __ \ / ____|          |_   _| |__   __|
//  | |__| |_   _ _ __   ___| (___ | |  | | |       ______    | |  ___ | |   
//  |  __  | | | | '_ \ / _ \\___ \| |  | | |      |______|   | | / _ \| |   
//  | |  | | |_| | |_) | (_) |___) | |__| | |____            _| || (_) | |   
//  |_|  |_|\__, | .__/ \___/_____/ \____/ \_____|          |_____\___/|_|   
//           __/ | |                                                         
//          |___/|_|                                                         
 
//  Code And Concept By HITwh Hypothetic MIPS Team
//  https://github.com/hitwh-nscscc
 
// =============================================================================

/*------------------------------------------------------------------------------
--------------------------------------------------------------------------------
Copyright (c) 2016, Loongson Technology Corporation Limited.

All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this 
list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, 
this list of conditions and the following disclaimer in the documentation and/or
other materials provided with the distribution.

3. Neither the name of Loongson Technology Corporation Limited nor the names of 
its contributors may be used to endorse or promote products derived from this 
software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
DISCLAIMED. IN NO EVENT SHALL LOONGSON TECHNOLOGY CORPORATION LIMITED BE LIABLE
TO ANY PARTY FOR DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE 
GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) 
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT 
LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--------------------------------------------------------------------------------
------------------------------------------------------------------------------*/

`include "config.h"

module hyposoc_iot_top(
    input           resetn, 
    input           clk,

    // -- Left-Side IOEXT 40 Pins Interface
    inout   [15:0]  GPIO16_pins,            // AXI4 GPIO

    input           rx,                     // AXI4 UART Lite
    output          tx,                     // ..

    // -- Loongson Confreg Interface
    output  [15:0]  led,
    output  [1 :0]  led_rg0,
    output  [1 :0]  led_rg1,
    output  [7 :0]  dot_r,
    output  [7 :0]  dot_c,
    output  [7 :0]  num_csn,
    output  [6 :0]  num_a_g,
    input   [7 :0]  switch, 
    output  [3 :0]  btn_key_col,
    input   [3 :0]  btn_key_row,
    input   [1 :0]  btn_step,

    output          pwm_0,                  // Confreg PWM
    output          pwm_1,                  // ..
    output          pwm_2,
    output          pwm_3,
    
    // -- LCD & TouchScreen
    output          lcd_rst,
    output          lcd_cs,
    output          lcd_rs,
    output          lcd_wr,
    output          lcd_rd,
    inout   [15:0]  lcd_data_io,
    output          lcd_bl_ctr,
    inout           ct_int,
    inout           ct_sda,
    output          ct_scl,
    output          ct_rstn,
    
    // -- Loongson DDR3 Interface
    inout   [15:0]  ddr3_dq,
    output  [12:0]  ddr3_addr,
    output  [2 :0]  ddr3_ba,
    output          ddr3_ras_n,
    output          ddr3_cas_n,
    output          ddr3_we_n,
    output          ddr3_odt,
    output          ddr3_reset_n,
    output          ddr3_cke,
    output  [1:0]   ddr3_dm,
    inout   [1:0]   ddr3_dqs_p,
    inout   [1:0]   ddr3_dqs_n,
    output          ddr3_ck_p,
    output          ddr3_ck_n,

    // -- Loongson MAC Controller Interface
    // TX
    input           mtxclk_0,     
    output          mtxen_0,      
    output  [3:0]   mtxd_0,       
    output          mtxerr_0,
    // RX
    input           mrxclk_0,      
    input           mrxdv_0,     
    input   [3:0]   mrxd_0,        
    input           mrxerr_0,
    input           mcoll_0,
    input           mcrs_0,
    // MIIM
    output          mdc_0,
    inout           mdio_0,
    
    output          phy_rstn,
 
    // -- Loongson EJTAG
    input           EJTAG_TRST,
    input           EJTAG_TCK,
    input           EJTAG_TDI,
    input           EJTAG_TMS,
    output          EJTAG_TDO,

    // -- Loongson UART 8250/16550 Series
    inout           UART_RX,
    inout           UART_TX,

    //-- Loongson Nand Interface
    output          NAND_CLE ,
    output          NAND_ALE ,
    input           NAND_RDY ,
    inout   [7:0]   NAND_DATA,
    output          NAND_RD  ,
    output          NAND_CE  ,  //low active
    output          NAND_WR  ,  
       
    // -- Loongson Spi Flash Interface
    output          SPI_CLK,
    output          SPI_CS,
    inout           SPI_MISO,
    inout           SPI_MOSI
);
    // ------------------------------------- SoC Clocking -------------------------------------
    /*
        Here is description.
    **/
    // -- WIRE NET TYPE
    wire            aclk;
    wire            aresetn;
    wire            cpu_clk;
    wire   c1_clk_ref_i;

    assign aclk =   cpu_clk;

    // -- PLL Modules
    clk_pll_33  clk_pll_33
    (
        .clk_out1   (cpu_clk),      // 66MHz
                                    // Please change corresponding UART16550/8250 baudrate to 115200
        .clk_in1    (clk)           // 100MHz, FPGA
    );
    clk_wiz_0  clk_pll_1
    (
        .clk_out1   (c1_clk_ref_i), // 200MHz, ref for MIG DDR3 Interface
        .clk_in1    (clk)           // 100MHz, FPGA
    );

    // ------------------------------------- SoC AXI Interface -------------------------------------
    /*
        Here is description.
    **/
    // ---- WIRE NET TYPE
    // -- CPU AXI Interface
    wire [`LID         -1 :0] m0_awid;
    wire [`Lawaddr     -1 :0] m0_awaddr;
    wire [`Lawlen      -1 :0] m0_awlen;
    wire [`Lawsize     -1 :0] m0_awsize;
    wire [`Lawburst    -1 :0] m0_awburst;
    wire [`Lawlock     -1 :0] m0_awlock;
    wire [`Lawcache    -1 :0] m0_awcache;
    wire [`Lawprot     -1 :0] m0_awprot;
    wire                      m0_awvalid;
    wire                      m0_awready;
    wire [`LID         -1 :0] m0_wid;
    wire [`Lwdata      -1 :0] m0_wdata;
    wire [`Lwstrb      -1 :0] m0_wstrb;
    wire                      m0_wlast;
    wire                      m0_wvalid;
    wire                      m0_wready;
    wire [`LID         -1 :0] m0_bid;
    wire [`Lbresp      -1 :0] m0_bresp;
    wire                      m0_bvalid;
    wire                      m0_bready;
    wire [`LID         -1 :0] m0_arid;
    wire [`Laraddr     -1 :0] m0_araddr;
    wire [`Larlen      -1 :0] m0_arlen;
    wire [`Larsize     -1 :0] m0_arsize;
    wire [`Larburst    -1 :0] m0_arburst;
    wire [`Larlock     -1 :0] m0_arlock;
    wire [`Larcache    -1 :0] m0_arcache;
    wire [`Larprot     -1 :0] m0_arprot;
    wire                      m0_arvalid;
    wire                      m0_arready;
    wire [`LID         -1 :0] m0_rid;
    wire [`Lrdata      -1 :0] m0_rdata;
    wire [`Lrresp      -1 :0] m0_rresp;
    wire                      m0_rlast;
    wire                      m0_rvalid;
    wire                      m0_rready;

    // -- Loongson SPI AXI Interface
    wire [`LID         -1 :0] spi_s_awid;
    wire [`Lawaddr     -1 :0] spi_s_awaddr;
    wire [`Lawlen      -1 :0] spi_s_awlen;
    wire [`Lawsize     -1 :0] spi_s_awsize;
    wire [`Lawburst    -1 :0] spi_s_awburst;
    wire [`Lawlock     -1 :0] spi_s_awlock;
    wire [`Lawcache    -1 :0] spi_s_awcache;
    wire [`Lawprot     -1 :0] spi_s_awprot;
    wire                      spi_s_awvalid;
    wire                      spi_s_awready;
    wire [`LID         -1 :0] spi_s_wid;
    wire [`Lwdata      -1 :0] spi_s_wdata;
    wire [`Lwstrb      -1 :0] spi_s_wstrb;
    wire                      spi_s_wlast;
    wire                      spi_s_wvalid;
    wire                      spi_s_wready;
    wire [`LID         -1 :0] spi_s_bid;
    wire [`Lbresp      -1 :0] spi_s_bresp;
    wire                      spi_s_bvalid;
    wire                      spi_s_bready;
    wire [`LID         -1 :0] spi_s_arid;
    wire [`Laraddr     -1 :0] spi_s_araddr;
    wire [`Larlen      -1 :0] spi_s_arlen;
    wire [`Larsize     -1 :0] spi_s_arsize;
    wire [`Larburst    -1 :0] spi_s_arburst;
    wire [`Larlock     -1 :0] spi_s_arlock;
    wire [`Larcache    -1 :0] spi_s_arcache;
    wire [`Larprot     -1 :0] spi_s_arprot;
    wire                      spi_s_arvalid;
    wire                      spi_s_arready;
    wire [`LID         -1 :0] spi_s_rid;
    wire [`Lrdata      -1 :0] spi_s_rdata;
    wire [`Lrresp      -1 :0] spi_s_rresp;
    wire                      spi_s_rlast;
    wire                      spi_s_rvalid;
    wire                      spi_s_rready;

    // -- Loogson Confreg AXI Interface - No customization
    wire [`LID         -1 :0] conf_s_awid;
    wire [`Lawaddr     -1 :0] conf_s_awaddr;
    wire [`Lawlen      -1 :0] conf_s_awlen;
    wire [`Lawsize     -1 :0] conf_s_awsize;
    wire [`Lawburst    -1 :0] conf_s_awburst;
    wire [`Lawlock     -1 :0] conf_s_awlock;
    wire [`Lawcache    -1 :0] conf_s_awcache;
    wire [`Lawprot     -1 :0] conf_s_awprot;
    wire                      conf_s_awvalid;
    wire                      conf_s_awready;
    wire [`LID         -1 :0] conf_s_wid;
    wire [`Lwdata      -1 :0] conf_s_wdata;
    wire [`Lwstrb      -1 :0] conf_s_wstrb;
    wire                      conf_s_wlast;
    wire                      conf_s_wvalid;
    wire                      conf_s_wready;
    wire [`LID         -1 :0] conf_s_bid;
    wire [`Lbresp      -1 :0] conf_s_bresp;
    wire                      conf_s_bvalid;
    wire                      conf_s_bready;
    wire [`LID         -1 :0] conf_s_arid;
    wire [`Laraddr     -1 :0] conf_s_araddr;
    wire [`Larlen      -1 :0] conf_s_arlen;
    wire [`Larsize     -1 :0] conf_s_arsize;
    wire [`Larburst    -1 :0] conf_s_arburst;
    wire [`Larlock     -1 :0] conf_s_arlock;
    wire [`Larcache    -1 :0] conf_s_arcache;
    wire [`Larprot     -1 :0] conf_s_arprot;
    wire                      conf_s_arvalid;
    wire                      conf_s_arready;
    wire [`LID         -1 :0] conf_s_rid;
    wire [`Lrdata      -1 :0] conf_s_rdata;
    wire [`Lrresp      -1 :0] conf_s_rresp;
    wire                      conf_s_rlast;
    wire                      conf_s_rvalid;
    wire                      conf_s_rready;

    // -- Loogson MAC AXI Interface
    // - Slave
    wire [`LID         -1 :0] mac_s_awid;
    wire [`Lawaddr     -1 :0] mac_s_awaddr;
    wire [`Lawlen      -1 :0] mac_s_awlen;
    wire [`Lawsize     -1 :0] mac_s_awsize;
    wire [`Lawburst    -1 :0] mac_s_awburst;
    wire [`Lawlock     -1 :0] mac_s_awlock;
    wire [`Lawcache    -1 :0] mac_s_awcache;
    wire [`Lawprot     -1 :0] mac_s_awprot;
    wire                      mac_s_awvalid;
    wire                      mac_s_awready;
    wire [`LID         -1 :0] mac_s_wid;
    wire [`Lwdata      -1 :0] mac_s_wdata;
    wire [`Lwstrb      -1 :0] mac_s_wstrb;
    wire                      mac_s_wlast;
    wire                      mac_s_wvalid;
    wire                      mac_s_wready;
    wire [`LID         -1 :0] mac_s_bid;
    wire [`Lbresp      -1 :0] mac_s_bresp;
    wire                      mac_s_bvalid;
    wire                      mac_s_bready;
    wire [`LID         -1 :0] mac_s_arid;
    wire [`Laraddr     -1 :0] mac_s_araddr;
    wire [`Larlen      -1 :0] mac_s_arlen;
    wire [`Larsize     -1 :0] mac_s_arsize;
    wire [`Larburst    -1 :0] mac_s_arburst;
    wire [`Larlock     -1 :0] mac_s_arlock;
    wire [`Larcache    -1 :0] mac_s_arcache;
    wire [`Larprot     -1 :0] mac_s_arprot;
    wire                      mac_s_arvalid;
    wire                      mac_s_arready;
    wire [`LID         -1 :0] mac_s_rid;
    wire [`Lrdata      -1 :0] mac_s_rdata;
    wire [`Lrresp      -1 :0] mac_s_rresp;
    wire                      mac_s_rlast;
    wire                      mac_s_rvalid;
    wire                      mac_s_rready;
    // - Master
    wire [`LID         -1 :0] mac_m_awid;
    wire [`Lawaddr     -1 :0] mac_m_awaddr;
    wire [`Lawlen      -1 :0] mac_m_awlen;
    wire [`Lawsize     -1 :0] mac_m_awsize;
    wire [`Lawburst    -1 :0] mac_m_awburst;
    wire [`Lawlock     -1 :0] mac_m_awlock;
    wire [`Lawcache    -1 :0] mac_m_awcache;
    wire [`Lawprot     -1 :0] mac_m_awprot;
    wire                      mac_m_awvalid;
    wire                      mac_m_awready;
    wire [`LID         -1 :0] mac_m_wid;
    wire [`Lwdata      -1 :0] mac_m_wdata;
    wire [`Lwstrb      -1 :0] mac_m_wstrb;
    wire                      mac_m_wlast;
    wire                      mac_m_wvalid;
    wire                      mac_m_wready;
    wire [`LID         -1 :0] mac_m_bid;
    wire [`Lbresp      -1 :0] mac_m_bresp;
    wire                      mac_m_bvalid;
    wire                      mac_m_bready;
    wire [`LID         -1 :0] mac_m_arid;
    wire [`Laraddr     -1 :0] mac_m_araddr;
    wire [`Larlen      -1 :0] mac_m_arlen;
    wire [`Larsize     -1 :0] mac_m_arsize;
    wire [`Larburst    -1 :0] mac_m_arburst;
    wire [`Larlock     -1 :0] mac_m_arlock;
    wire [`Larcache    -1 :0] mac_m_arcache;
    wire [`Larprot     -1 :0] mac_m_arprot;
    wire                      mac_m_arvalid;
    wire                      mac_m_arready;
    wire [`LID         -1 :0] mac_m_rid;
    wire [`Lrdata      -1 :0] mac_m_rdata;
    wire [`Lrresp      -1 :0] mac_m_rresp;
    wire                      mac_m_rlast;
    wire                      mac_m_rvalid;
    wire                      mac_m_rready;

    // -- MIG_AXI-Interconnect AXI Interface
    wire [`LID         -1 :0] s0_awid;
    wire [`Lawaddr     -1 :0] s0_awaddr;
    wire [`Lawlen      -1 :0] s0_awlen;
    wire [`Lawsize     -1 :0] s0_awsize;
    wire [`Lawburst    -1 :0] s0_awburst;
    wire [`Lawlock     -1 :0] s0_awlock;
    wire [`Lawcache    -1 :0] s0_awcache;
    wire [`Lawprot     -1 :0] s0_awprot;
    wire                      s0_awvalid;
    wire                      s0_awready;
    wire [`LID         -1 :0] s0_wid;
    wire [`Lwdata      -1 :0] s0_wdata;
    wire [`Lwstrb      -1 :0] s0_wstrb;
    wire                      s0_wlast;
    wire                      s0_wvalid;
    wire                      s0_wready;
    wire [`LID         -1 :0] s0_bid;
    wire [`Lbresp      -1 :0] s0_bresp;
    wire                      s0_bvalid;
    wire                      s0_bready;
    wire [`LID         -1 :0] s0_arid;
    wire [`Laraddr     -1 :0] s0_araddr;
    wire [`Larlen      -1 :0] s0_arlen;
    wire [`Larsize     -1 :0] s0_arsize;
    wire [`Larburst    -1 :0] s0_arburst;
    wire [`Larlock     -1 :0] s0_arlock;
    wire [`Larcache    -1 :0] s0_arcache;
    wire [`Larprot     -1 :0] s0_arprot;
    wire                      s0_arvalid;
    wire                      s0_arready;
    wire [`LID         -1 :0] s0_rid;
    wire [`Lrdata      -1 :0] s0_rdata;
    wire [`Lrresp      -1 :0] s0_rresp;
    wire                      s0_rlast;
    wire                      s0_rvalid;
    wire                      s0_rready;

    // -- MIG AXI Interface
    wire [8            -1 :0] mig_awid;
    wire [`Lawaddr     -1 :0] mig_awaddr;
    wire [8            -1 :0] mig_awlen;
    wire [`Lawsize     -1 :0] mig_awsize;
    wire [`Lawburst    -1 :0] mig_awburst;
    wire [`Lawlock     -1 :0] mig_awlock;
    wire [`Lawcache    -1 :0] mig_awcache;
    wire [`Lawprot     -1 :0] mig_awprot;
    wire                      mig_awvalid;
    wire                      mig_awready;
    wire [8            -1 :0] mig_wid;
    wire [`Lwdata      -1 :0] mig_wdata;
    wire [`Lwstrb      -1 :0] mig_wstrb;
    wire                      mig_wlast;
    wire                      mig_wvalid;
    wire                      mig_wready;
    wire [8            -1 :0] mig_bid;
    wire [`Lbresp      -1 :0] mig_bresp;
    wire                      mig_bvalid;
    wire                      mig_bready;
    wire [8            -1 :0] mig_arid;
    wire [`Laraddr     -1 :0] mig_araddr;
    wire [8            -1 :0] mig_arlen;
    wire [`Larsize     -1 :0] mig_arsize;
    wire [`Larburst    -1 :0] mig_arburst;
    wire [`Larlock     -1 :0] mig_arlock;
    wire [`Larcache    -1 :0] mig_arcache;
    wire [`Larprot     -1 :0] mig_arprot;
    wire                      mig_arvalid;
    wire                      mig_arready;
    wire [8            -1 :0] mig_rid;
    wire [`Lrdata      -1 :0] mig_rdata;
    wire [`Lrresp      -1 :0] mig_rresp;
    wire                      mig_rlast;
    wire                      mig_rvalid;
    wire                      mig_rready;

    // -- Loongson DMA AXI Interface
    wire [`LID         -1 :0] dma0_awid       ;
    wire [`Lawaddr     -1 :0] dma0_awaddr     ;
    wire [`Lawlen      -1 :0] dma0_awlen      ;
    wire [`Lawsize     -1 :0] dma0_awsize     ;
    wire [`Lawburst    -1 :0] dma0_awburst    ;
    wire [`Lawlock     -1 :0] dma0_awlock     ;
    wire [`Lawcache    -1 :0] dma0_awcache    ;
    wire [`Lawprot     -1 :0] dma0_awprot     ;
    wire                      dma0_awvalid    ;
    wire                      dma0_awready    ;
    wire [`LID         -1 :0] dma0_wid        ;
    wire [64           -1 :0] dma0_wdata      ;
    wire [8            -1 :0] dma0_wstrb      ;
    wire                      dma0_wlast      ;
    wire                      dma0_wvalid     ;
    wire                      dma0_wready     ;
    wire [`LID         -1 :0] dma0_bid        ;
    wire [`Lbresp      -1 :0] dma0_bresp      ;
    wire                      dma0_bvalid     ;
    wire                      dma0_bready     ;
    wire [`LID         -1 :0] dma0_arid       ;
    wire [`Laraddr     -1 :0] dma0_araddr     ;
    wire [`Larlen      -1 :0] dma0_arlen      ;
    wire [`Larsize     -1 :0] dma0_arsize     ;
    wire [`Larburst    -1 :0] dma0_arburst    ;
    wire [`Larlock     -1 :0] dma0_arlock     ;
    wire [`Larcache    -1 :0] dma0_arcache    ;
    wire [`Larprot     -1 :0] dma0_arprot     ;
    wire                      dma0_arvalid    ;
    wire                      dma0_arready    ;
    wire [`LID         -1 :0] dma0_rid        ;
    wire [64           -1 :0] dma0_rdata      ;
    wire [`Lrresp      -1 :0] dma0_rresp      ;
    wire                      dma0_rlast      ;
    wire                      dma0_rvalid     ;
    wire                      dma0_rready     ;

    // -- Loongson AXI2APB_Bridge AXI Interface
    wire [`LID         -1 :0] apb_s_awid;
    wire [`Lawaddr     -1 :0] apb_s_awaddr;
    wire [`Lawlen      -1 :0] apb_s_awlen;
    wire [`Lawsize     -1 :0] apb_s_awsize;
    wire [`Lawburst    -1 :0] apb_s_awburst;
    wire [`Lawlock     -1 :0] apb_s_awlock;
    wire [`Lawcache    -1 :0] apb_s_awcache;
    wire [`Lawprot     -1 :0] apb_s_awprot;
    wire                      apb_s_awvalid;
    wire                      apb_s_awready;
    wire [`LID         -1 :0] apb_s_wid;
    wire [`Lwdata      -1 :0] apb_s_wdata;
    wire [`Lwstrb      -1 :0] apb_s_wstrb;
    wire                      apb_s_wlast;
    wire                      apb_s_wvalid;
    wire                      apb_s_wready;
    wire [`LID         -1 :0] apb_s_bid;
    wire [`Lbresp      -1 :0] apb_s_bresp;
    wire                      apb_s_bvalid;
    wire                      apb_s_bready;
    wire [`LID         -1 :0] apb_s_arid;
    wire [`Laraddr     -1 :0] apb_s_araddr;
    wire [`Larlen      -1 :0] apb_s_arlen;
    wire [`Larsize     -1 :0] apb_s_arsize;
    wire [`Larburst    -1 :0] apb_s_arburst;
    wire [`Larlock     -1 :0] apb_s_arlock;
    wire [`Larcache    -1 :0] apb_s_arcache;
    wire [`Larprot     -1 :0] apb_s_arprot;
    wire                      apb_s_arvalid;
    wire                      apb_s_arready;
    wire [`LID         -1 :0] apb_s_rid;
    wire [`Lrdata      -1 :0] apb_s_rdata;
    wire [`Lrresp      -1 :0] apb_s_rresp;
    wire                      apb_s_rlast;
    wire                      apb_s_rvalid;
    wire                      apb_s_rready;

    // -- RickTino NT35510 TFT-LCD Module AXI Interface
    wire [`LID         -1 :0] gpu_s_awid;
    wire [`Lawaddr     -1 :0] gpu_s_awaddr;
    wire [`Lawlen      -1 :0] gpu_s_awlen;
    wire [`Lawsize     -1 :0] gpu_s_awsize;
    wire [`Lawburst    -1 :0] gpu_s_awburst;
    wire [`Lawlock     -1 :0] gpu_s_awlock;
    wire [`Lawcache    -1 :0] gpu_s_awcache;
    wire [`Lawprot     -1 :0] gpu_s_awprot;
    wire                      gpu_s_awvalid;
    wire                      gpu_s_awready;
    wire [`LID         -1 :0] gpu_s_wid;
    wire [`Lwdata      -1 :0] gpu_s_wdata;
    wire [`Lwstrb      -1 :0] gpu_s_wstrb;
    wire                      gpu_s_wlast;
    wire                      gpu_s_wvalid;
    wire                      gpu_s_wready;
    wire [`LID         -1 :0] gpu_s_bid;
    wire [`Lbresp      -1 :0] gpu_s_bresp;
    wire                      gpu_s_bvalid;
    wire                      gpu_s_bready;
    wire [`LID         -1 :0] gpu_s_arid;
    wire [`Laraddr     -1 :0] gpu_s_araddr;
    wire [`Larlen      -1 :0] gpu_s_arlen;
    wire [`Larsize     -1 :0] gpu_s_arsize;
    wire [`Larburst    -1 :0] gpu_s_arburst;
    wire [`Larlock     -1 :0] gpu_s_arlock;
    wire [`Larcache    -1 :0] gpu_s_arcache;
    wire [`Larprot     -1 :0] gpu_s_arprot;
    wire                      gpu_s_arvalid;
    wire                      gpu_s_arready;
    wire [`LID         -1 :0] gpu_s_rid;
    wire [`Lrdata      -1 :0] gpu_s_rdata;
    wire [`Lrresp      -1 :0] gpu_s_rresp;
    wire                      gpu_s_rlast;
    wire                      gpu_s_rvalid;
    wire                      gpu_s_rready;
    
    wire inner_lcd_bl_ctl;

    // ------------------------------------- Loongson SoC Interface -------------------------------------
    /*
        Here is description.
    **/
    wire          apb_ready_dma0;
    wire          apb_start_dma0;
    wire          apb_rw_dma0;
    wire          apb_psel_dma0;
    wire          apb_penable_dma0;
    wire[31:0]    apb_addr_dma0;
    wire[31:0]    apb_wdata_dma0;
    wire[31:0]    apb_rdata_dma0;

    wire         dma_int;
    wire         dma_ack;
    wire         dma_req;

    wire                      dma0_gnt;
    wire[31:0]                order_addr_in;
    wire                      write_dma_end;
    wire                      finish_read_order;

    //spi
    wire [3:0]spi_csn_o ;
    wire [3:0]spi_csn_en;
    wire spi_sck_o ;
    wire spi_sdo_i ;
    wire spi_sdo_o ;
    wire spi_sdo_en;
    wire spi_sdi_i ;
    wire spi_sdi_o ;
    wire spi_sdi_en;
    wire spi_inta_o;
    assign     SPI_CLK = spi_sck_o;
    assign     SPI_CS  = ~spi_csn_en[0] & spi_csn_o[0];
    assign     SPI_MOSI = spi_sdo_en ? 1'bz : spi_sdo_o ;
    assign     SPI_MISO = spi_sdi_en ? 1'bz : spi_sdi_o ;
    assign     spi_sdo_i = SPI_MOSI;
    assign     spi_sdi_i = SPI_MISO;

    // confreg 
    wire   [31:0] cr00,cr01,cr02,cr03,cr04,cr05,cr06,cr07;

    //mac
    wire md_i_0;      // MII data input (from I/O cell)
    wire md_o_0;      // MII data output (to I/O cell)
    wire md_oe_0;     // MII data output enable (to I/O cell)
    IOBUF mac_mdio(.IO(mdio_0),.I(md_o_0),.T(~md_oe_0),.O(md_i_0));
    assign phy_rstn = aresetn;

    //nand
    wire       nand_cle   ;
    wire       nand_ale   ;
    wire [3:0] nand_rdy   ;
    wire [3:0] nand_ce    ;
    wire       nand_rd    ;
    wire       nand_wr    ;
    wire       nand_dat_oe;
    wire [7:0] nand_dat_i ;
    wire [7:0] nand_dat_o ;
    wire       nand_int   ;
    assign     NAND_CLE = nand_cle;
    assign     NAND_ALE = nand_ale;
    assign     nand_rdy = {3'd0,NAND_RDY};
    assign     NAND_RD  = nand_rd;
    assign     NAND_CE  = nand_ce[0];  //low active
    assign     NAND_WR  = nand_wr;  
    generate
        genvar i;
        for(i=0;i<8;i=i+1)
        begin: nand_data_loop
            IOBUF nand_data(.IO(NAND_DATA[i]),.I(nand_dat_o[i]),.T(nand_dat_oe),.O(nand_dat_i[i]));
        end
    endgenerate

    //uart
    wire UART_CTS,   UART_RTS;
    wire UART_DTR,   UART_DSR;
    wire UART_RI,    UART_DCD;
    assign UART_CTS = 1'b0;
    assign UART_DSR = 1'b0;
    assign UART_DCD = 1'b0;
    wire uart0_int   ;
    wire uart0_txd_o ;
    wire uart0_txd_i ;
    wire uart0_txd_oe;
    wire uart0_rxd_o ;
    wire uart0_rxd_i ;
    wire uart0_rxd_oe;
    wire uart0_rts_o ;
    wire uart0_cts_i ;
    wire uart0_dsr_i ;
    wire uart0_dcd_i ;
    wire uart0_dtr_o ;
    wire uart0_ri_i  ;
    assign     UART_RX     = uart0_rxd_oe ? 1'bz : uart0_rxd_o ;
    assign     UART_TX     = uart0_txd_oe ? 1'bz : uart0_txd_o ;
    assign     UART_RTS    = uart0_rts_o ;
    assign     UART_DTR    = uart0_dtr_o ;
    assign     uart0_txd_i = UART_TX;
    assign     uart0_rxd_i = UART_RX;
    assign     uart0_cts_i = UART_CTS;
    assign     uart0_dcd_i = UART_DCD;
    assign     uart0_dsr_i = UART_DSR;
    assign     uart0_ri_i  = UART_RI ;

    // ------------------------------------- SoC Interrupt -------------------------------------
    /*
        Here is description.
    **/
    // ---- Xlnx AXI INTC
    // -- WIRE NET TYPE
    wire [8:0]  soc_intc_awaddr;
    wire        soc_intc_awvalid;
    wire        soc_intc_awready;
    wire [31:0] soc_intc_wdata;
    wire [3:0]  soc_intc_wstrb;
    wire        soc_intc_wvalid;
    wire        soc_intc_wready;
    wire [1:0]  soc_intc_bresp;
    wire        soc_intc_bvalid;
    wire        soc_intc_bready;
    wire [8:0]  soc_intc_araddr;
    wire        soc_intc_arvalid;
    wire        soc_intc_arready;
    wire [31:0] soc_intc_rdata;
    wire [1:0]  soc_intc_rresp;
    wire        soc_intc_rvalid;
    wire        soc_intc_rready;
    wire [1:0]  soc_intc_intr;
    wire        soc_intc_irq;

    wire        uart_lite_int;  // Connected to XUart_Lite .irq
    wire        mac_int;
    wire [31:0] hyposoc_intr;

    wire [5:0]  int_out;
    
    assign      soc_intc_intr   = {uart_lite_int, uart0_int};   // INTC interrupt input, LSB is the highest priority
    assign      hyposoc_intr    = {31'b0, uart_lite_int};       // INTC interrupt input, LSB is the highest priority

`ifdef CONFIG_USE_XLNX_AXI_INTC
    // Hypothetic MIPS CauseIP     7     6        5         4           3             2
    assign      int_out         = {1'b0, dma_int, nand_int, spi_inta_o, soc_intc_irq, mac_int};
`else
`define CONFIG_USE_CONFREG_INTC
    // Hypothetic MIPS CauseIP     7     6        5         4           3          2
    assign      int_out         = {1'b0, dma_int, nand_int, spi_inta_o, uart0_int, mac_int};
`endif

    // -- AXI INTC Module
    axi_intc_0 axi_soc_intc (
    .s_axi_aclk       (aclk), 
    .s_axi_aresetn    (aresetn), 

    .s_axi_awaddr     (soc_intc_awaddr), 
    .s_axi_awvalid    (soc_intc_awvalid), 
    .s_axi_awready    (soc_intc_awready),  

    .s_axi_wdata      (soc_intc_wdata), 
    .s_axi_wstrb      (soc_intc_wstrb),  
    .s_axi_wvalid     (soc_intc_wvalid), 
    .s_axi_wready     (soc_intc_wready),   

    .s_axi_bresp      (soc_intc_bresp),  
    .s_axi_bvalid     (soc_intc_bvalid),   
    .s_axi_bready     (soc_intc_bready),   

    .s_axi_araddr     (soc_intc_araddr),  
    .s_axi_arvalid    (soc_intc_arvalid),  
    .s_axi_arready    (soc_intc_arready),  

    .s_axi_rdata      (soc_intc_rdata),   
    .s_axi_rresp      (soc_intc_rresp),     
    .s_axi_rvalid     (soc_intc_rvalid),    
    .s_axi_rready     (soc_intc_rready),    
    
    .intr             (soc_intc_intr),             
    .irq              (soc_intc_irq)          
    );

    assign EJTAG_TDO = 0; // Why on the earth is this variable written here ???

    // ------------------------------------- Hypothetic CPU Core -------------------------------------
    /*
        Here is description.
    **/
    MangoMIPS_Top cpu_mid(
    .intr           (int_out      ),
    .aclk           (aclk         ),
    .aresetn        (aresetn      ),
    .m_arid         (m0_arid[3:0] ),
    .m_araddr       (m0_araddr    ),
    .m_arlen        (m0_arlen     ),
    .m_arsize       (m0_arsize    ),
    .m_arburst      (m0_arburst   ),
    .m_arlock       (m0_arlock    ),
    .m_arcache      (m0_arcache   ),
    .m_arprot       (m0_arprot    ),
    .m_arvalid      (m0_arvalid   ),
    .m_arready      (m0_arready   ),
    .m_rid          (m0_rid[3:0]  ),
    .m_rdata        (m0_rdata     ),
    .m_rresp        (m0_rresp     ),
    .m_rlast        (m0_rlast     ),
    .m_rvalid       (m0_rvalid    ),
    .m_rready       (m0_rready    ),
    .m_awid         (m0_awid[3:0] ),
    .m_awaddr       (m0_awaddr    ),
    .m_awlen        (m0_awlen     ),
    .m_awsize       (m0_awsize    ),
    .m_awburst      (m0_awburst   ),
    .m_awlock       (m0_awlock    ),
    .m_awcache      (m0_awcache   ),
    .m_awprot       (m0_awprot    ),
    .m_awvalid      (m0_awvalid   ),
    .m_awready      (m0_awready   ),
    .m_wid          (m0_wid[3:0]  ),
    .m_wdata        (m0_wdata     ),
    .m_wstrb        (m0_wstrb     ),
    .m_wlast        (m0_wlast     ),
    .m_wvalid       (m0_wvalid    ),
    .m_wready       (m0_wready    ),
    .m_bid          (m0_bid[3:0]  ),
    .m_bresp        (m0_bresp     ),
    .m_bvalid       (m0_bvalid    ),
    .m_bready       (m0_bready    )
    );

    // ------------------------------------- Hypothetic SoC eXtended AXI Interface -----------------
    /*
        HXAI.
        Please be notified: AXI4-Lite Interface is like the pattern 'aw-w-b-ar-r 3-4-3-3-4'.
    **/
    // ---- AXI3 to AXI4-Lite CROSSBAR
    // -- WIRE NET TYPE
    wire [3:0]  s_axi3t4l_awid;
    wire [31:0] s_axi3t4l_awaddr;
    wire [7:0]  s_axi3t4l_awlen;
    wire [2:0]  s_axi3t4l_awsize;
    wire [1:0]  s_axi3t4l_awburst;
    wire [0:0]  s_axi3t4l_awlock;
    wire [3:0]  s_axi3t4l_awcache;
    wire [2:0]  s_axi3t4l_awprot;
    wire [0:0]  s_axi3t4l_awvalid;
    wire [0:0]  s_axi3t4l_awready;
    wire [31:0] s_axi3t4l_wdata;
    wire [3:0]  s_axi3t4l_wstrb;
    wire [0:0]  s_axi3t4l_wlast;
    wire [0:0]  s_axi3t4l_wvalid;
    wire [0:0]  s_axi3t4l_wready;
    wire [3:0]  s_axi3t4l_bid;
    wire [1:0]  s_axi3t4l_bresp;
    wire [0:0]  s_axi3t4l_bvalid;
    wire [0:0]  s_axi3t4l_bready;
    wire [3:0]  s_axi3t4l_arid;
    wire [31:0] s_axi3t4l_araddr;
    wire [7:0]  s_axi3t4l_arlen;
    wire [2:0]  s_axi3t4l_arsize;
    wire [1:0]  s_axi3t4l_arburst;
    wire [0:0]  s_axi3t4l_arlock;
    wire [3:0]  s_axi3t4l_arcache;
    wire [2:0]  s_axi3t4l_arprot;
    wire [0:0]  s_axi3t4l_arvalid;
    wire [0:0]  s_axi3t4l_arready;
    wire [3:0]  s_axi3t4l_rid;
    wire [31:0] s_axi3t4l_rdata;
    wire [1:0]  s_axi3t4l_rresp;
    wire [0:0]  s_axi3t4l_rlast;
    wire [0:0]  s_axi3t4l_rvalid;
    wire [0:0]  s_axi3t4l_rready;

    // ---- AXI4 Lite GPIO
    // -- WIRE NET TYPE
    wire [8:0]  single_gpio_awaddr;
    wire        single_gpio_awvalid;
    wire        single_gpio_awready;
    wire [31:0] single_gpio_wdata;
    wire [3:0]  single_gpio_wstrb;
    wire        single_gpio_wvalid;
    wire        single_gpio_wready;
    wire [1:0]  single_gpio_bresp;
    wire        single_gpio_bvalid;
    wire        single_gpio_bready;
    wire [8:0]  single_gpio_araddr;
    wire        single_gpio_arvalid;
    wire        single_gpio_arready;
    wire [31:0] single_gpio_rdata;
    wire [1:0]  single_gpio_rresp;
    wire        single_gpio_rvalid;
    wire        single_gpio_rready;

    // -- Tri-state re-use of the pins
    wire [15:0] single_gpio_io_o;
    wire [15:0] single_gpio_io_i;
    wire [15:0] single_gpio_io_t;
    generate
        genvar gpio_itr;
        for(gpio_itr = 0; gpio_itr < 16; gpio_itr = gpio_itr + 1)
        begin: gpio_inout_assign
            // io_t will be High-Level when the pin is set to input dirction.
            // 1. Set the pin to Z if the pin is used for input purpose.
            assign GPIO16_pins[gpio_itr] = single_gpio_io_t[gpio_itr] ? 1'bz : single_gpio_io_o[gpio_itr];
            // 2. Assign the input value to io_i
            assign single_gpio_io_i[gpio_itr] = GPIO16_pins[gpio_itr];
        end
    endgenerate

    // ---- AXI4 Lite UART LITE
    // -- WIRE NET TYPE
    wire [3:0]  uart_lite_awaddr;
    wire        uart_lite_awvalid;
    wire        uart_lite_awready;
    wire [31:0] uart_lite_wdata;
    wire [3:0]  uart_lite_wstrb;
    wire        uart_lite_wvalid;
    wire        uart_lite_wready;
    wire [1:0]  uart_lite_bresp;
    wire        uart_lite_bvalid;
    wire        uart_lite_bready;
    wire [3:0]  uart_lite_araddr;
    wire        uart_lite_arvalid;
    wire        uart_lite_arready;
    wire [31:0] uart_lite_rdata;
    wire [1:0]  uart_lite_rresp;
    wire        uart_lite_rvalid;
    wire        uart_lite_rready;

    // -- AXI3 to AXI4-Lite CROSSBAR
    axi4lite_crossbar_0 gpio_axi3t4l_crossbar (
    .aclk             (aclk               ),  
    .aresetn          (aresetn            ),   
    
    // Slave interface, connected to the father crossbar Master Interface.
    // Write Address Channel
    .s_axi_awid       (s_axi3t4l_awid     ),
    .s_axi_awaddr     (s_axi3t4l_awaddr   ),
    .s_axi_awlen      (s_axi3t4l_awlen    ),
    .s_axi_awsize     (s_axi3t4l_awsize   ),
    .s_axi_awburst    (s_axi3t4l_awburst  ),
    .s_axi_awlock     (s_axi3t4l_awlock   ),
    .s_axi_awcache    (s_axi3t4l_awcache  ),
    .s_axi_awprot     (s_axi3t4l_awprot   ),
    .s_axi_awqos      (4'b0               ),
    .s_axi_awvalid    (s_axi3t4l_awvalid  ),
    .s_axi_awready    (s_axi3t4l_awready  ),
    // Write Data Channel
    .s_axi_wdata      (s_axi3t4l_wdata    ),
    .s_axi_wstrb      (s_axi3t4l_wstrb    ),
    .s_axi_wlast      (s_axi3t4l_wlast    ),
    .s_axi_wvalid     (s_axi3t4l_wvalid   ),
    .s_axi_wready     (s_axi3t4l_wready   ),
    // Write Response Channel
    .s_axi_bid        (s_axi3t4l_bid      ),
    .s_axi_bresp      (s_axi3t4l_bresp    ),
    .s_axi_bvalid     (s_axi3t4l_bvalid   ),
    .s_axi_bready     (s_axi3t4l_bready   ),
    // Read Address Channel
    .s_axi_arid       (s_axi3t4l_arid     ),
    .s_axi_araddr     (s_axi3t4l_araddr   ),
    .s_axi_arlen      (s_axi3t4l_arlen    ),
    .s_axi_arsize     (s_axi3t4l_arsize   ),
    .s_axi_arburst    (s_axi3t4l_arburst  ),
    .s_axi_arlock     (s_axi3t4l_arlock   ),
    .s_axi_arcache    (s_axi3t4l_arcache  ),
    .s_axi_arprot     (s_axi3t4l_arprot   ),
    .s_axi_arqos      (4'b0               ),
    .s_axi_arvalid    (s_axi3t4l_arvalid  ),
    .s_axi_arready    (s_axi3t4l_arready  ),
    // Read Data Channel
    .s_axi_rid        (s_axi3t4l_rid      ),
    .s_axi_rdata      (s_axi3t4l_rdata    ),
    .s_axi_rresp      (s_axi3t4l_rresp    ),
    .s_axi_rlast      (s_axi3t4l_rlast    ),
    .s_axi_rvalid     (s_axi3t4l_rvalid   ),
    .s_axi_rready     (s_axi3t4l_rready   ),

    // Master Interface, connected to the each AXI4LITE GPIO IP core.
    // Write Address Channel
    .m_axi_awaddr     ({{23'b0,soc_intc_awaddr},  {28'b0,uart_lite_awaddr},   {23'b0,single_gpio_awaddr}}),
    .m_axi_awlen      (),
    .m_axi_awsize     (),
    .m_axi_awburst    (),
    .m_axi_awlock     (),
    .m_axi_awcache    (),
    .m_axi_awprot     (),
    .m_axi_awregion   (),
    .m_axi_awqos      (),
    .m_axi_awvalid    ({soc_intc_awvalid,         uart_lite_awvalid,         single_gpio_awvalid    }),
    .m_axi_awready    ({soc_intc_awready,         uart_lite_awready,         single_gpio_awready    }),
    // Write Date Channel
    .m_axi_wdata      ({soc_intc_wdata,           uart_lite_wdata,           single_gpio_wdata      }),
    .m_axi_wstrb      ({soc_intc_wstrb,           uart_lite_wstrb,           single_gpio_wstrb      }),
    .m_axi_wlast      (),
    .m_axi_wvalid     ({soc_intc_wvalid,          uart_lite_wvalid,          single_gpio_wvalid     }),
    .m_axi_wready     ({soc_intc_wready,          uart_lite_wready,          single_gpio_wready     }),
    // Write Response Channel
    .m_axi_bresp      ({soc_intc_bresp,           uart_lite_bresp,           single_gpio_bresp      }),
    .m_axi_bvalid     ({soc_intc_bvalid,          uart_lite_bvalid,          single_gpio_bvalid     }),
    .m_axi_bready     ({soc_intc_bready,          uart_lite_bready,          single_gpio_bready     }),
    // Read Address Channel
    .m_axi_araddr     ({{23'b0,soc_intc_araddr},  {28'b0,uart_lite_araddr},  {23'b0,single_gpio_araddr}}),
    .m_axi_arlen      (),
    .m_axi_arsize     (),
    .m_axi_arburst    (),
    .m_axi_arlock     (),
    .m_axi_arcache    (),
    .m_axi_arprot     (),
    .m_axi_arregion   (),
    .m_axi_arqos      (),
    .m_axi_arvalid    ({soc_intc_arvalid,         uart_lite_arvalid,         single_gpio_arvalid    }),
    .m_axi_arready    ({soc_intc_arready,         uart_lite_arready,         single_gpio_arready    }),
    // Read Date Channel
    .m_axi_rdata      ({soc_intc_rdata,           uart_lite_rdata,           single_gpio_rdata      }),
    .m_axi_rresp      ({soc_intc_rresp,           uart_lite_rresp,           single_gpio_rresp      }),
    .m_axi_rlast      ({soc_intc_rvalid,          uart_lite_rvalid,          single_gpio_rvalid     }),
    .m_axi_rvalid     ({soc_intc_rvalid,          uart_lite_rvalid,          single_gpio_rvalid     }),
    .m_axi_rready     ({soc_intc_rready,          uart_lite_rready,          single_gpio_rready     })
    );

    // -- AXI4 LITE UART LITE IP CORE
    axi_uartlite_0 axi_uartlite (
    .s_axi_aclk               (aclk               ), 
    .s_axi_aresetn            (aresetn            ), 

    .interrupt                (uart_lite_int      ),  

    .s_axi_awaddr             (uart_lite_awaddr   ),    
    .s_axi_awvalid            (uart_lite_awvalid  ),  
    .s_axi_awready            (uart_lite_awready  ),  

    .s_axi_wdata              (uart_lite_wdata    ),      
    .s_axi_wstrb              (uart_lite_wstrb    ),   
    .s_axi_wvalid             (uart_lite_wvalid   ),    
    .s_axi_wready             (uart_lite_wready   ),   

    .s_axi_bresp              (uart_lite_bresp    ),      
    .s_axi_bvalid             (uart_lite_bvalid   ),     
    .s_axi_bready             (uart_lite_bready   ),     

    .s_axi_araddr             (uart_lite_araddr   ),   
    .s_axi_arvalid            (uart_lite_arvalid  ),   
    .s_axi_arready            (uart_lite_arready  ),   

    .s_axi_rdata              (uart_lite_rdata    ),     
    .s_axi_rresp              (uart_lite_rresp    ),       
    .s_axi_rvalid             (uart_lite_rvalid   ),    
    .s_axi_rready             (uart_lite_rready   ),     

    .rx                       (rx                 ),             
    .tx                       (tx                 )              
    );

    // -- AXI4 LITE GPIO IP Core
    axi_gpio_0 single_gpio_0 (
    .s_axi_aclk               (aclk                ),
    .s_axi_aresetn            (aresetn             ),

    .s_axi_awaddr             (single_gpio_awaddr  ),
    .s_axi_awvalid            (single_gpio_awvalid ),
    .s_axi_awready            (single_gpio_awready ),

    .s_axi_wdata              (single_gpio_wdata   ),
    .s_axi_wstrb              (single_gpio_wstrb   ),
    .s_axi_wvalid             (single_gpio_wvalid  ),
    .s_axi_wready             (single_gpio_wready  ),

    .s_axi_bresp              (single_gpio_bresp   ),
    .s_axi_bvalid             (single_gpio_bvalid  ),
    .s_axi_bready             (single_gpio_bready  ),

    .s_axi_araddr             (single_gpio_araddr  ),
    .s_axi_arvalid            (single_gpio_arvalid ),
    .s_axi_arready            (single_gpio_arready ),

    .s_axi_rdata              (single_gpio_rdata   ),
    .s_axi_rresp              (single_gpio_rresp   ),
    .s_axi_rvalid             (single_gpio_rvalid  ),
    .s_axi_rready             (single_gpio_rready  ),

    .gpio_io_i                (single_gpio_io_i    ),
    .gpio_io_o                (single_gpio_io_o    ),
    .gpio_io_t                (single_gpio_io_t    )
    );

    // ------------------------------------- SoC Master AXI Crossbar & DEV -------------------------------------
    /*
        Here is description.
    **/
    // -- AXI3 Crossbar
    axi_crossbar_soc AXI_Crossbar_SoC (
        .aclk           (aclk       ),
        .aresetn        (aresetn    ),
        .s_axi_awid     (m0_awid    ),
        .s_axi_awaddr   (m0_awaddr  ),
        .s_axi_awlen    (m0_awlen   ),
        .s_axi_awsize   (m0_awsize  ),
        .s_axi_awburst  (m0_awburst ),
        .s_axi_awlock   (m0_awlock  ),
        .s_axi_awcache  (m0_awcache ),
        .s_axi_awprot   (m0_awprot  ),
        .s_axi_awqos    (4'b0       ),
        .s_axi_awvalid  (m0_awvalid ),
        .s_axi_awready  (m0_awready ),
        .s_axi_wid      (m0_wid     ),
        .s_axi_wdata    (m0_wdata   ),
        .s_axi_wstrb    (m0_wstrb   ),
        .s_axi_wlast    (m0_wlast   ),
        .s_axi_wvalid   (m0_wvalid  ),
        .s_axi_wready   (m0_wready  ),
        .s_axi_bid      (m0_bid     ),
        .s_axi_bresp    (m0_bresp   ),
        .s_axi_bvalid   (m0_bvalid  ),
        .s_axi_bready   (m0_bready  ),
        .s_axi_arid     (m0_arid    ),
        .s_axi_araddr   (m0_araddr  ),
        .s_axi_arlen    (m0_arlen   ),
        .s_axi_arsize   (m0_arsize  ),
        .s_axi_arburst  (m0_arburst ),
        .s_axi_arlock   (m0_arlock  ),
        .s_axi_arcache  (m0_arcache ),
        .s_axi_arprot   (m0_arprot  ),
        .s_axi_arqos    (4'b0       ),
        .s_axi_arvalid  (m0_arvalid ),
        .s_axi_arready  (m0_arready ),
        .s_axi_rid      (m0_rid     ),
        .s_axi_rdata    (m0_rdata   ),
        .s_axi_rresp    (m0_rresp   ),
        .s_axi_rlast    (m0_rlast   ),
        .s_axi_rvalid   (m0_rvalid  ),
        .s_axi_rready   (m0_rready  ),
        
        .m_axi_awid     ({s_axi3t4l_awid,       gpu_s_awid,     mac_s_awid,     conf_s_awid,     apb_s_awid,     spi_s_awid,     s0_awid     }),
        .m_axi_awaddr   ({s_axi3t4l_awaddr,     gpu_s_awaddr,   mac_s_awaddr,   conf_s_awaddr,   apb_s_awaddr,   spi_s_awaddr,   s0_awaddr   }),
        .m_axi_awlen    ({s_axi3t4l_awlen,      gpu_s_awlen,    mac_s_awlen,    conf_s_awlen,    apb_s_awlen,    spi_s_awlen,    s0_awlen    }),
        .m_axi_awsize   ({s_axi3t4l_awsize,     gpu_s_awsize,   mac_s_awsize,   conf_s_awsize,   apb_s_awsize,   spi_s_awsize,   s0_awsize   }),
        .m_axi_awburst  ({s_axi3t4l_awburst,    gpu_s_awburst,  mac_s_awburst,  conf_s_awburst,  apb_s_awburst,  spi_s_awburst,  s0_awburst  }),
        .m_axi_awlock   ({s_axi3t4l_awlock,     gpu_s_awlock,   mac_s_awlock,   conf_s_awlock,   apb_s_awlock,   spi_s_awlock,   s0_awlock   }),
        .m_axi_awcache  ({s_axi3t4l_awcache,    gpu_s_awcache,  mac_s_awcache,  conf_s_awcache,  apb_s_awcache,  spi_s_awcache,  s0_awcache  }),
        .m_axi_awprot   ({s_axi3t4l_awprot,     gpu_s_awprot,   mac_s_awprot,   conf_s_awprot,   apb_s_awprot,   spi_s_awprot,   s0_awprot   }),
        .m_axi_awqos    (),
        .m_axi_awvalid  ({s_axi3t4l_awvalid,    gpu_s_awvalid,  mac_s_awvalid,  conf_s_awvalid,  apb_s_awvalid,  spi_s_awvalid,  s0_awvalid  }),
        .m_axi_awready  ({s_axi3t4l_awready,    gpu_s_awready,  mac_s_awready,  conf_s_awready,  apb_s_awready,  spi_s_awready,  s0_awready  }),
        
        .m_axi_wid      ({                      gpu_s_wid,      mac_s_wid,      conf_s_wid,      apb_s_wid,      spi_s_wid,      s0_wid      }),
        .m_axi_wdata    ({s_axi3t4l_wdata,      gpu_s_wdata,    mac_s_wdata,    conf_s_wdata,    apb_s_wdata,    spi_s_wdata,    s0_wdata    }),
        .m_axi_wstrb    ({s_axi3t4l_wstrb,      gpu_s_wstrb,    mac_s_wstrb,    conf_s_wstrb,    apb_s_wstrb,    spi_s_wstrb,    s0_wstrb    }),
        .m_axi_wlast    ({s_axi3t4l_wlast,      gpu_s_wlast,    mac_s_wlast,    conf_s_wlast,    apb_s_wlast,    spi_s_wlast,    s0_wlast    }),
        .m_axi_wvalid   ({s_axi3t4l_wvalid,     gpu_s_wvalid,   mac_s_wvalid,   conf_s_wvalid,   apb_s_wvalid,   spi_s_wvalid,   s0_wvalid   }),
        .m_axi_wready   ({s_axi3t4l_wready,     gpu_s_wready,   mac_s_wready,   conf_s_wready,   apb_s_wready,   spi_s_wready,   s0_wready   }),
        
        .m_axi_bid      ({s_axi3t4l_bid,        gpu_s_bid,      mac_s_bid,      conf_s_bid,      apb_s_bid,      spi_s_bid,      s0_bid      }),
        .m_axi_bresp    ({s_axi3t4l_bresp,      gpu_s_bresp,    mac_s_bresp,    conf_s_bresp,    apb_s_bresp,    spi_s_bresp,    s0_bresp    }),
        .m_axi_bvalid   ({s_axi3t4l_bvalid,     gpu_s_bvalid,   mac_s_bvalid,   conf_s_bvalid,   apb_s_bvalid,   spi_s_bvalid,   s0_bvalid   }),
        .m_axi_bready   ({s_axi3t4l_bready,     gpu_s_bready,   mac_s_bready,   conf_s_bready,   apb_s_bready,   spi_s_bready,   s0_bready   }),
        
        .m_axi_arid     ({s_axi3t4l_arid,       gpu_s_arid,     mac_s_arid,     conf_s_arid,     apb_s_arid,     spi_s_arid,     s0_arid     }),
        .m_axi_araddr   ({s_axi3t4l_araddr,     gpu_s_araddr,   mac_s_araddr,   conf_s_araddr,   apb_s_araddr,   spi_s_araddr,   s0_araddr   }),
        .m_axi_arlen    ({s_axi3t4l_arlen,      gpu_s_arlen,    mac_s_arlen,    conf_s_arlen,    apb_s_arlen,    spi_s_arlen,    s0_arlen    }),
        .m_axi_arsize   ({s_axi3t4l_arsize,     gpu_s_arsize,   mac_s_arsize,   conf_s_arsize,   apb_s_arsize,   spi_s_arsize,   s0_arsize   }),
        .m_axi_arburst  ({s_axi3t4l_arburst,    gpu_s_arburst,  mac_s_arburst,  conf_s_arburst,  apb_s_arburst,  spi_s_arburst,  s0_arburst  }),
        .m_axi_arlock   ({s_axi3t4l_arlock,     gpu_s_arlock,   mac_s_arlock,   conf_s_arlock,   apb_s_arlock,   spi_s_arlock,   s0_arlock   }),
        .m_axi_arcache  ({s_axi3t4l_arcache,    gpu_s_arcache,  mac_s_arcache,  conf_s_arcache,  apb_s_arcache,  spi_s_arcache,  s0_arcache  }),
        .m_axi_arprot   ({s_axi3t4l_arprot,     gpu_s_arprot,   mac_s_arprot,   conf_s_arprot,   apb_s_arprot,   spi_s_arprot,   s0_arprot   }),
        .m_axi_arqos    (),
        .m_axi_arvalid  ({s_axi3t4l_arvalid,    gpu_s_arvalid,  mac_s_arvalid,  conf_s_arvalid,  apb_s_arvalid,  spi_s_arvalid,  s0_arvalid  }),
        .m_axi_arready  ({s_axi3t4l_arready,    gpu_s_arready,  mac_s_arready,  conf_s_arready,  apb_s_arready,  spi_s_arready,  s0_arready  }),
        
        .m_axi_rid      ({s_axi3t4l_rid,        gpu_s_rid,      mac_s_rid,      conf_s_rid,      apb_s_rid,      spi_s_rid,      s0_rid      }),
        .m_axi_rdata    ({s_axi3t4l_rdata,      gpu_s_rdata,    mac_s_rdata,    conf_s_rdata,    apb_s_rdata,    spi_s_rdata,    s0_rdata    }),
        .m_axi_rresp    ({s_axi3t4l_rresp,      gpu_s_rresp,    mac_s_rresp,    conf_s_rresp,    apb_s_rresp,    spi_s_rresp,    s0_rresp    }),
        .m_axi_rlast    ({s_axi3t4l_rlast,      gpu_s_rlast,    mac_s_rlast,    conf_s_rlast,    apb_s_rlast,    spi_s_rlast,    s0_rlast    }),
        .m_axi_rvalid   ({s_axi3t4l_rvalid,     gpu_s_rvalid,   mac_s_rvalid,   conf_s_rvalid,   apb_s_rvalid,   spi_s_rvalid,   s0_rvalid   }),
        .m_axi_rready   ({s_axi3t4l_rready,     gpu_s_rready,   mac_s_rready,   conf_s_rready,   apb_s_rready,   spi_s_rready,   s0_rready   })
    );

    // -- Loongson AXI SPI CTL
    spi_flash_ctrl SPI                    
    (                                         
    .aclk           (aclk              ),       
    .aresetn        (aresetn           ),       
    .spi_addr       (16'h1fe8          ),
    .fast_startup   (1'b0              ),
    .s_awid         (spi_s_awid        ),
    .s_awaddr       (spi_s_awaddr      ),
    .s_awlen        (spi_s_awlen       ),
    .s_awsize       (spi_s_awsize      ),
    .s_awburst      (spi_s_awburst     ),
    .s_awlock       (spi_s_awlock      ),
    .s_awcache      (spi_s_awcache     ),
    .s_awprot       (spi_s_awprot      ),
    .s_awvalid      (spi_s_awvalid     ),
    .s_awready      (spi_s_awready     ),
    .s_wready       (spi_s_wready      ),
    .s_wid          (spi_s_wid         ),
    .s_wdata        (spi_s_wdata       ),
    .s_wstrb        (spi_s_wstrb       ),
    .s_wlast        (spi_s_wlast       ),
    .s_wvalid       (spi_s_wvalid      ),
    .s_bid          (spi_s_bid         ),
    .s_bresp        (spi_s_bresp       ),
    .s_bvalid       (spi_s_bvalid      ),
    .s_bready       (spi_s_bready      ),
    .s_arid         (spi_s_arid        ),
    .s_araddr       (spi_s_araddr      ),
    .s_arlen        (spi_s_arlen       ),
    .s_arsize       (spi_s_arsize      ),
    .s_arburst      (spi_s_arburst     ),
    .s_arlock       (spi_s_arlock      ),
    .s_arcache      (spi_s_arcache     ),
    .s_arprot       (spi_s_arprot      ),
    .s_arvalid      (spi_s_arvalid     ),
    .s_arready      (spi_s_arready     ),
    .s_rready       (spi_s_rready      ),
    .s_rid          (spi_s_rid         ),
    .s_rdata        (spi_s_rdata       ),
    .s_rresp        (spi_s_rresp       ),
    .s_rlast        (spi_s_rlast       ),
    .s_rvalid       (spi_s_rvalid      ),

    .power_down_req (1'b0              ),
    .power_down_ack (                  ),
    .csn_o          (spi_csn_o         ),
    .csn_en         (spi_csn_en        ), 
    .sck_o          (spi_sck_o         ),
    .sdo_i          (spi_sdo_i         ),
    .sdo_o          (spi_sdo_o         ),
    .sdo_en         (spi_sdo_en        ), // active low
    .sdi_i          (spi_sdi_i         ),
    .sdi_o          (spi_sdi_o         ),
    .sdi_en         (spi_sdi_en        ),
    .inta_o         (spi_inta_o        )
    );

    // -- Loongson Confreg
    confreg CONFREG(
    .aclk              (aclk               ),       
    .aresetn           (aresetn            ),       
    .s_awid            (conf_s_awid        ),
    .s_awaddr          (conf_s_awaddr      ),
    .s_awlen           (conf_s_awlen       ),
    .s_awsize          (conf_s_awsize      ),
    .s_awburst         (conf_s_awburst     ),
    .s_awlock          (conf_s_awlock      ),
    .s_awcache         (conf_s_awcache     ),
    .s_awprot          (conf_s_awprot      ),
    .s_awvalid         (conf_s_awvalid     ),
    .s_awready         (conf_s_awready     ),
    .s_wready          (conf_s_wready      ),
    .s_wid             (conf_s_wid         ),
    .s_wdata           (conf_s_wdata       ),
    .s_wstrb           (conf_s_wstrb       ),
    .s_wlast           (conf_s_wlast       ),
    .s_wvalid          (conf_s_wvalid      ),
    .s_bid             (conf_s_bid         ),
    .s_bresp           (conf_s_bresp       ),
    .s_bvalid          (conf_s_bvalid      ),
    .s_bready          (conf_s_bready      ),
    .s_arid            (conf_s_arid        ),
    .s_araddr          (conf_s_araddr      ),
    .s_arlen           (conf_s_arlen       ),
    .s_arsize          (conf_s_arsize      ),
    .s_arburst         (conf_s_arburst     ),
    .s_arlock          (conf_s_arlock      ),
    .s_arcache         (conf_s_arcache     ),
    .s_arprot          (conf_s_arprot      ),
    .s_arvalid         (conf_s_arvalid     ),
    .s_arready         (conf_s_arready     ),
    .s_rready          (conf_s_rready      ),
    .s_rid             (conf_s_rid         ),
    .s_rdata           (conf_s_rdata       ),
    .s_rresp           (conf_s_rresp       ),
    .s_rlast           (conf_s_rlast       ),
    .s_rvalid          (conf_s_rvalid      ),

    //dma
    .order_addr_reg    (order_addr_in      ),
    .write_dma_end     (write_dma_end      ),
    .finish_read_order (finish_read_order  ),

    //cr00~cr07
    .cr00              (cr00        ),
    .cr01              (cr01        ),
    .cr02              (cr02        ),
    .cr03              (cr03        ),
    .cr04              (cr04        ),
    .cr05              (cr05        ),
    .cr06              (cr06        ),
    .cr07              (cr07        ),

    .led               (led         ),
    .led_rg0           (led_rg0     ),
    .led_rg1           (led_rg1     ),
    .dot_r             (dot_r       ),
    .dot_c             (dot_c       ),
    .num_csn           (num_csn     ),
    .num_a_g           (num_a_g     ),
    .switch            (switch      ),
    .btn_key_col       (btn_key_col ),
    .btn_key_row       (btn_key_row ),
    .btn_step          (btn_step    ),

    // -- PWMs
    .pwm0_out          (pwm_0       ),
    .pwm1_out          (pwm_1       ),
    .pwm2_out          (pwm_2       ),
    .pwm3_out          (pwm_3       ),
    .lcd_bl_general_ctl(inner_lcd_bl_ctl),
    .lcd_bl_ctl_o      (lcd_bl_ctr  ),

    // -- INR
    .hypo_intr         (hyposoc_intr)
    );

    // -- Loongson MAC
    ethernet_top ETHERNET_TOP(

        .hclk       (aclk   ),
        .hrst_      (aresetn),      
        //axi master
        .mawid_o    (mac_m_awid    ),
        .mawaddr_o  (mac_m_awaddr  ),
        .mawlen_o   (mac_m_awlen   ),
        .mawsize_o  (mac_m_awsize  ),
        .mawburst_o (mac_m_awburst ),
        .mawlock_o  (mac_m_awlock  ),
        .mawcache_o (mac_m_awcache ),
        .mawprot_o  (mac_m_awprot  ),
        .mawvalid_o (mac_m_awvalid ),
        .mawready_i (mac_m_awready ),
        .mwid_o     (mac_m_wid     ),
        .mwdata_o   (mac_m_wdata   ),
        .mwstrb_o   (mac_m_wstrb   ),
        .mwlast_o   (mac_m_wlast   ),
        .mwvalid_o  (mac_m_wvalid  ),
        .mwready_i  (mac_m_wready  ),
        .mbid_i     (mac_m_bid     ),
        .mbresp_i   (mac_m_bresp   ),
        .mbvalid_i  (mac_m_bvalid  ),
        .mbready_o  (mac_m_bready  ),
        .marid_o    (mac_m_arid    ),
        .maraddr_o  (mac_m_araddr  ),
        .marlen_o   (mac_m_arlen   ),
        .marsize_o  (mac_m_arsize  ),
        .marburst_o (mac_m_arburst ),
        .marlock_o  (mac_m_arlock  ),
        .marcache_o (mac_m_arcache ),
        .marprot_o  (mac_m_arprot  ),
        .marvalid_o (mac_m_arvalid ),
        .marready_i (mac_m_arready ),
        .mrid_i     (mac_m_rid     ),
        .mrdata_i   (mac_m_rdata   ),
        .mrresp_i   (mac_m_rresp   ),
        .mrlast_i   (mac_m_rlast   ),
        .mrvalid_i  (mac_m_rvalid  ),
        .mrready_o  (mac_m_rready  ),
        //axi slaver
        .sawid_i    (mac_s_awid    ),
        .sawaddr_i  (mac_s_awaddr  ),
        .sawlen_i   (mac_s_awlen   ),
        .sawsize_i  (mac_s_awsize  ),
        .sawburst_i (mac_s_awburst ),
        .sawlock_i  (mac_s_awlock  ),
        .sawcache_i (mac_s_awcache ),
        .sawprot_i  (mac_s_awprot  ),
        .sawvalid_i (mac_s_awvalid ),
        .sawready_o (mac_s_awready ),   
        .swid_i     (mac_s_wid     ),
        .swdata_i   (mac_s_wdata   ),
        .swstrb_i   (mac_s_wstrb   ),
        .swlast_i   (mac_s_wlast   ),
        .swvalid_i  (mac_s_wvalid  ),
        .swready_o  (mac_s_wready  ),
        .sbid_o     (mac_s_bid     ),
        .sbresp_o   (mac_s_bresp   ),
        .sbvalid_o  (mac_s_bvalid  ),
        .sbready_i  (mac_s_bready  ),
        .sarid_i    (mac_s_arid    ),
        .saraddr_i  (mac_s_araddr  ),
        .sarlen_i   (mac_s_arlen   ),
        .sarsize_i  (mac_s_arsize  ),
        .sarburst_i (mac_s_arburst ),
        .sarlock_i  (mac_s_arlock  ),
        .sarcache_i (mac_s_arcache ),
        .sarprot_i  (mac_s_arprot  ),
        .sarvalid_i (mac_s_arvalid ),
        .sarready_o (mac_s_arready ),
        .srid_o     (mac_s_rid     ),
        .srdata_o   (mac_s_rdata   ),
        .srresp_o   (mac_s_rresp   ),
        .srlast_o   (mac_s_rlast   ),
        .srvalid_o  (mac_s_rvalid  ),
        .srready_i  (mac_s_rready  ),                 

        .interrupt_0 (mac_int),
    
        // I/O pad interface signals
        //TX
        .mtxclk_0    (mtxclk_0 ),     
        .mtxen_0     (mtxen_0  ),      
        .mtxd_0      (mtxd_0   ),       
        .mtxerr_0    (mtxerr_0 ),
        //RX
        .mrxclk_0    (mrxclk_0 ),      
        .mrxdv_0     (mrxdv_0  ),     
        .mrxd_0      (mrxd_0   ),        
        .mrxerr_0    (mrxerr_0 ),
        .mcoll_0     (mcoll_0  ),
        .mcrs_0      (mcrs_0   ),
        // MIIM
        .mdc_0       (mdc_0    ),
        .md_i_0      (md_i_0   ),
        .md_o_0      (md_o_0   ),       
        .md_oe_0     (md_oe_0  )

    );

    // ------------------------------------- Loongson SoC MIG DDR3 Interface -------------------------------------
    /*
        Here is description.
    **/
    // -- WIRE NET TYPE
    wire   c1_sys_clk_i;
    // wire   c1_clk_ref_i;
    wire   c1_sys_rst_i;
    wire   c1_calib_done;
    wire   c1_clk0;
    wire   c1_rst0;
    wire        ddr_aresetn;
    reg         interconnect_aresetn;

    assign c1_sys_clk_i      = clk;
    assign c1_sys_rst_i      = resetn;

    reg c1_calib_done_0;
    reg c1_calib_done_1;
    reg c1_rst0_0;
    reg c1_rst0_1;
    reg interconnect_aresetn_0;

    always @(posedge c1_clk0)
    begin
        interconnect_aresetn <= ~c1_rst0 && c1_calib_done;
    end

    // -- AXI3 Interconnect 3x1
    axi_interconnect_0 mig_axi_interconnect (
        .INTERCONNECT_ACLK    (c1_clk0             ),
        .INTERCONNECT_ARESETN (interconnect_aresetn),
        .S00_AXI_ARESET_OUT_N (aresetn             ),
        .S00_AXI_ACLK         (aclk                ),
        .S00_AXI_AWID         (s0_awid[3:0]        ),
        .S00_AXI_AWADDR       (s0_awaddr           ),
        .S00_AXI_AWLEN        ({4'b0,s0_awlen}     ),
        .S00_AXI_AWSIZE       (s0_awsize           ),
        .S00_AXI_AWBURST      (s0_awburst          ),
        .S00_AXI_AWLOCK       (s0_awlock[0:0]      ),
        .S00_AXI_AWCACHE      (s0_awcache          ),
        .S00_AXI_AWPROT       (s0_awprot           ),
        .S00_AXI_AWQOS        (4'b0                ),
        .S00_AXI_AWVALID      (s0_awvalid          ),
        .S00_AXI_AWREADY      (s0_awready          ),
        .S00_AXI_WDATA        (s0_wdata            ),
        .S00_AXI_WSTRB        (s0_wstrb            ),
        .S00_AXI_WLAST        (s0_wlast            ),
        .S00_AXI_WVALID       (s0_wvalid           ),
        .S00_AXI_WREADY       (s0_wready           ),
        .S00_AXI_BID          (s0_bid[3:0]         ),
        .S00_AXI_BRESP        (s0_bresp            ),
        .S00_AXI_BVALID       (s0_bvalid           ),
        .S00_AXI_BREADY       (s0_bready           ),
        .S00_AXI_ARID         (s0_arid[3:0]        ),
        .S00_AXI_ARADDR       (s0_araddr           ),
        .S00_AXI_ARLEN        ({4'b0,s0_arlen}     ),
        .S00_AXI_ARSIZE       (s0_arsize           ),
        .S00_AXI_ARBURST      (s0_arburst          ),
        .S00_AXI_ARLOCK       (s0_arlock[0:0]      ),
        .S00_AXI_ARCACHE      (s0_arcache          ),
        .S00_AXI_ARPROT       (s0_arprot           ),
        .S00_AXI_ARQOS        (4'b0                ),
        .S00_AXI_ARVALID      (s0_arvalid          ),
        .S00_AXI_ARREADY      (s0_arready          ),
        .S00_AXI_RID          (s0_rid[3:0]         ),
        .S00_AXI_RDATA        (s0_rdata            ),
        .S00_AXI_RRESP        (s0_rresp            ),
        .S00_AXI_RLAST        (s0_rlast            ),
        .S00_AXI_RVALID       (s0_rvalid           ),
        .S00_AXI_RREADY       (s0_rready           ),

        .S01_AXI_ARESET_OUT_N (                    ),
        .S01_AXI_ACLK         (aclk                ),
        .S01_AXI_AWID         (mac_m_awid[3:0]     ),
        .S01_AXI_AWADDR       (mac_m_awaddr        ),
        .S01_AXI_AWLEN        ({4'b0,mac_m_awlen}  ),
        .S01_AXI_AWSIZE       (mac_m_awsize        ),
        .S01_AXI_AWBURST      (mac_m_awburst       ),
        .S01_AXI_AWLOCK       (mac_m_awlock[0:0]   ),
        .S01_AXI_AWCACHE      (mac_m_awcache       ),
        .S01_AXI_AWPROT       (mac_m_awprot        ),
        .S01_AXI_AWQOS        (4'b0                ),
        .S01_AXI_AWVALID      (mac_m_awvalid       ),
        .S01_AXI_AWREADY      (mac_m_awready       ),
        .S01_AXI_WDATA        (mac_m_wdata         ),
        .S01_AXI_WSTRB        (mac_m_wstrb         ),
        .S01_AXI_WLAST        (mac_m_wlast         ),
        .S01_AXI_WVALID       (mac_m_wvalid        ),
        .S01_AXI_WREADY       (mac_m_wready        ),
        .S01_AXI_BID          (mac_m_bid[3:0]      ),
        .S01_AXI_BRESP        (mac_m_bresp         ),
        .S01_AXI_BVALID       (mac_m_bvalid        ),
        .S01_AXI_BREADY       (mac_m_bready        ),
        .S01_AXI_ARID         (mac_m_arid[3:0]     ),
        .S01_AXI_ARADDR       (mac_m_araddr        ),
        .S01_AXI_ARLEN        ({4'b0,mac_m_arlen}  ),
        .S01_AXI_ARSIZE       (mac_m_arsize        ),
        .S01_AXI_ARBURST      (mac_m_arburst       ),
        .S01_AXI_ARLOCK       (mac_m_arlock[0:0]   ),
        .S01_AXI_ARCACHE      (mac_m_arcache       ),
        .S01_AXI_ARPROT       (mac_m_arprot        ),
        .S01_AXI_ARQOS        (4'b0                ),
        .S01_AXI_ARVALID      (mac_m_arvalid       ),
        .S01_AXI_ARREADY      (mac_m_arready       ),
        .S01_AXI_RID          (mac_m_rid[3:0]      ),
        .S01_AXI_RDATA        (mac_m_rdata         ),
        .S01_AXI_RRESP        (mac_m_rresp         ),
        .S01_AXI_RLAST        (mac_m_rlast         ),
        .S01_AXI_RVALID       (mac_m_rvalid        ),
        .S01_AXI_RREADY       (mac_m_rready        ),

        .S02_AXI_ARESET_OUT_N (                    ),
        .S02_AXI_ACLK         (aclk                ),
        .S02_AXI_AWID         (dma0_awid           ),
        .S02_AXI_AWADDR       (dma0_awaddr         ),
        .S02_AXI_AWLEN        ({4'd0,dma0_awlen}   ),
        .S02_AXI_AWSIZE       (dma0_awsize         ),
        .S02_AXI_AWBURST      (dma0_awburst        ),
        .S02_AXI_AWLOCK       (dma0_awlock[0:0]    ),
        .S02_AXI_AWCACHE      (dma0_awcache        ),
        .S02_AXI_AWPROT       (dma0_awprot         ),
        .S02_AXI_AWQOS        (4'b0                ),
        .S02_AXI_AWVALID      (dma0_awvalid        ),
        .S02_AXI_AWREADY      (dma0_awready        ),
        .S02_AXI_WDATA        (dma0_wdata          ),
        .S02_AXI_WSTRB        (dma0_wstrb          ),
        .S02_AXI_WLAST        (dma0_wlast          ),
        .S02_AXI_WVALID       (dma0_wvalid         ),
        .S02_AXI_WREADY       (dma0_wready         ),
        .S02_AXI_BID          (dma0_bid            ),
        .S02_AXI_BRESP        (dma0_bresp          ),
        .S02_AXI_BVALID       (dma0_bvalid         ),
        .S02_AXI_BREADY       (dma0_bready         ),
        .S02_AXI_ARID         (dma0_arid           ),
        .S02_AXI_ARADDR       (dma0_araddr         ),
        .S02_AXI_ARLEN        ({4'd0,dma0_arlen}   ),
        .S02_AXI_ARSIZE       (dma0_arsize         ),
        .S02_AXI_ARBURST      (dma0_arburst        ),
        .S02_AXI_ARLOCK       (dma0_arlock[0:0]    ),
        .S02_AXI_ARCACHE      (dma0_arcache        ),
        .S02_AXI_ARPROT       (dma0_arprot         ),
        .S02_AXI_ARQOS        (4'b0                ),
        .S02_AXI_ARVALID      (dma0_arvalid        ),
        .S02_AXI_ARREADY      (dma0_arready        ),
        .S02_AXI_RID          (dma0_rid            ),
        .S02_AXI_RDATA        (dma0_rdata          ),
        .S02_AXI_RRESP        (dma0_rresp          ),
        .S02_AXI_RLAST        (dma0_rlast          ),
        .S02_AXI_RVALID       (dma0_rvalid         ),
        .S02_AXI_RREADY       (dma0_rready         ),

        .M00_AXI_ARESET_OUT_N (ddr_aresetn         ),
        .M00_AXI_ACLK         (c1_clk0             ),
        .M00_AXI_AWID         (mig_awid            ),
        .M00_AXI_AWADDR       (mig_awaddr          ),
        .M00_AXI_AWLEN        ({mig_awlen}         ),
        .M00_AXI_AWSIZE       (mig_awsize          ),
        .M00_AXI_AWBURST      (mig_awburst         ),
        .M00_AXI_AWLOCK       (mig_awlock[0:0]     ),
        .M00_AXI_AWCACHE      (mig_awcache         ),
        .M00_AXI_AWPROT       (mig_awprot          ),
        .M00_AXI_AWQOS        (                    ),
        .M00_AXI_AWVALID      (mig_awvalid         ),
        .M00_AXI_AWREADY      (mig_awready         ),
        .M00_AXI_WDATA        (mig_wdata           ),
        .M00_AXI_WSTRB        (mig_wstrb           ),
        .M00_AXI_WLAST        (mig_wlast           ),
        .M00_AXI_WVALID       (mig_wvalid          ),
        .M00_AXI_WREADY       (mig_wready          ),
        .M00_AXI_BID          (mig_bid             ),
        .M00_AXI_BRESP        (mig_bresp           ),
        .M00_AXI_BVALID       (mig_bvalid          ),
        .M00_AXI_BREADY       (mig_bready          ),
        .M00_AXI_ARID         (mig_arid            ),
        .M00_AXI_ARADDR       (mig_araddr          ),
        .M00_AXI_ARLEN        ({mig_arlen}         ),
        .M00_AXI_ARSIZE       (mig_arsize          ),
        .M00_AXI_ARBURST      (mig_arburst         ),
        .M00_AXI_ARLOCK       (mig_arlock[0:0]     ),
        .M00_AXI_ARCACHE      (mig_arcache         ),
        .M00_AXI_ARPROT       (mig_arprot          ),
        .M00_AXI_ARQOS        (                    ),
        .M00_AXI_ARVALID      (mig_arvalid         ),
        .M00_AXI_ARREADY      (mig_arready         ),
        .M00_AXI_RID          (mig_rid             ),
        .M00_AXI_RDATA        (mig_rdata           ),
        .M00_AXI_RRESP        (mig_rresp           ),
        .M00_AXI_RLAST        (mig_rlast           ),
        .M00_AXI_RVALID       (mig_rvalid          ),
        .M00_AXI_RREADY       (mig_rready          )
    );
    // -- MIG DDR3 Controller
    mig_axi_32 mig_axi (
        // Inouts
        .ddr3_dq             (ddr3_dq         ),  
        .ddr3_dqs_p          (ddr3_dqs_p      ),    // for X16 parts 
        .ddr3_dqs_n          (ddr3_dqs_n      ),  // for X16 parts
        // Outputs
        .ddr3_addr           (ddr3_addr       ),  
        .ddr3_ba             (ddr3_ba         ),
        .ddr3_ras_n          (ddr3_ras_n      ),                        
        .ddr3_cas_n          (ddr3_cas_n      ),                        
        .ddr3_we_n           (ddr3_we_n       ),                          
        .ddr3_reset_n        (ddr3_reset_n    ),
        .ddr3_ck_p           (ddr3_ck_p       ),                          
        .ddr3_ck_n           (ddr3_ck_n       ),       
        .ddr3_cke            (ddr3_cke        ),                          
        .ddr3_dm             (ddr3_dm         ),
        .ddr3_odt            (ddr3_odt        ),
        
        .ui_clk              (c1_clk0         ),
        .ui_clk_sync_rst     (c1_rst0         ),
    
        .sys_clk_i           (c1_sys_clk_i    ),
        .sys_rst             (c1_sys_rst_i    ),                        
        .init_calib_complete (c1_calib_done   ),
        .clk_ref_i           (c1_clk_ref_i    ),
        .mmcm_locked         (                ),
        
        .app_sr_active       (                ),
        .app_ref_ack         (                ),
        .app_zq_ack          (                ),
        .app_sr_req          (1'b0            ),
        .app_ref_req         (1'b0            ),
        .app_zq_req          (1'b0            ),
        
        .aresetn             (ddr_aresetn     ),
        .s_axi_awid          (mig_awid        ),
        .s_axi_awaddr        (mig_awaddr[26:0]),
        .s_axi_awlen         ({mig_awlen}     ),
        .s_axi_awsize        (mig_awsize      ),
        .s_axi_awburst       (mig_awburst     ),
        .s_axi_awlock        (mig_awlock[0:0] ),
        .s_axi_awcache       (mig_awcache     ),
        .s_axi_awprot        (mig_awprot      ),
        .s_axi_awqos         (4'b0            ),
        .s_axi_awvalid       (mig_awvalid     ),
        .s_axi_awready       (mig_awready     ),
        .s_axi_wdata         (mig_wdata       ),
        .s_axi_wstrb         (mig_wstrb       ),
        .s_axi_wlast         (mig_wlast       ),
        .s_axi_wvalid        (mig_wvalid      ),
        .s_axi_wready        (mig_wready      ),
        .s_axi_bid           (mig_bid         ),
        .s_axi_bresp         (mig_bresp       ),
        .s_axi_bvalid        (mig_bvalid      ),
        .s_axi_bready        (mig_bready      ),
        .s_axi_arid          (mig_arid        ),
        .s_axi_araddr        (mig_araddr[26:0]),
        .s_axi_arlen         ({mig_arlen}     ),
        .s_axi_arsize        (mig_arsize      ),
        .s_axi_arburst       (mig_arburst     ),
        .s_axi_arlock        (mig_arlock[0:0] ),
        .s_axi_arcache       (mig_arcache     ),
        .s_axi_arprot        (mig_arprot      ),
        .s_axi_arqos         (4'b0            ),
        .s_axi_arvalid       (mig_arvalid     ),
        .s_axi_arready       (mig_arready     ),
        .s_axi_rid           (mig_rid         ),
        .s_axi_rdata         (mig_rdata       ),
        .s_axi_rresp         (mig_rresp       ),
        .s_axi_rlast         (mig_rlast       ),
        .s_axi_rvalid        (mig_rvalid      ),
        .s_axi_rready        (mig_rready      )
    );

    // -- Loongson DMA
    dma_master DMA_MASTER0
    (
    .clk                (aclk                   ),
    .rst_n		        (aresetn                ),
    .awid               (dma0_awid              ), 
    .awaddr             (dma0_awaddr            ), 
    .awlen              (dma0_awlen             ), 
    .awsize             (dma0_awsize            ), 
    .awburst            (dma0_awburst           ),
    .awlock             (dma0_awlock            ), 
    .awcache            (dma0_awcache           ), 
    .awprot             (dma0_awprot            ), 
    .awvalid            (dma0_awvalid           ), 
    .awready            (dma0_awready           ), 
    .wid                (dma0_wid               ), 
    .wdata              (dma0_wdata             ), 
    .wstrb              (dma0_wstrb             ), 
    .wlast              (dma0_wlast             ), 
    .wvalid             (dma0_wvalid            ), 
    .wready             (dma0_wready            ),
    .bid                (dma0_bid               ), 
    .bresp              (dma0_bresp             ), 
    .bvalid             (dma0_bvalid            ), 
    .bready             (dma0_bready            ),
    .arid               (dma0_arid              ), 
    .araddr             (dma0_araddr            ), 
    .arlen              (dma0_arlen             ), 
    .arsize             (dma0_arsize            ), 
    .arburst            (dma0_arburst           ), 
    .arlock             (dma0_arlock            ), 
    .arcache            (dma0_arcache           ),
    .arprot             (dma0_arprot            ),
    .arvalid            (dma0_arvalid           ), 
    .arready            (dma0_arready           ),
    .rid                (dma0_rid               ), 
    .rdata              (dma0_rdata             ), 
    .rresp              (dma0_rresp             ),
    .rlast              (dma0_rlast             ), 
    .rvalid             (dma0_rvalid            ), 
    .rready             (dma0_rready            ),

    .dma_int            (dma_int                ), 
    .dma_req_in         (dma_req                ), 
    .dma_ack_out        (dma_ack                ), 

    .dma_gnt            (dma0_gnt               ),
    .apb_rw             (apb_rw_dma0            ),
    .apb_psel           (apb_psel_dma0          ),
    .apb_valid_req      (apb_start_dma0	        ),
    .apb_penable        (apb_penable_dma0       ),
    .apb_addr           (apb_addr_dma0          ),
    .apb_wdata          (apb_wdata_dma0         ),
    .apb_rdata          (apb_rdata_dma0         ),

    .order_addr_in      (order_addr_in          ),
    .write_dma_end      (write_dma_end          ),
    .finish_read_order  (finish_read_order      ) 
    );

    // -- Loongson AXI2APB Bridge
    axi2apb_misc APB_DEV 
    (
    .clk                (aclk               ),
    .rst_n              (aresetn            ),

    .axi_s_awid         (apb_s_awid         ),
    .axi_s_awaddr       (apb_s_awaddr       ),
    .axi_s_awlen        (apb_s_awlen        ),
    .axi_s_awsize       (apb_s_awsize       ),
    .axi_s_awburst      (apb_s_awburst      ),
    .axi_s_awlock       (apb_s_awlock       ),
    .axi_s_awcache      (apb_s_awcache      ),
    .axi_s_awprot       (apb_s_awprot       ),
    .axi_s_awvalid      (apb_s_awvalid      ),
    .axi_s_awready      (apb_s_awready      ),
    .axi_s_wid          (apb_s_wid          ),
    .axi_s_wdata        (apb_s_wdata        ),
    .axi_s_wstrb        (apb_s_wstrb        ),
    .axi_s_wlast        (apb_s_wlast        ),
    .axi_s_wvalid       (apb_s_wvalid       ),
    .axi_s_wready       (apb_s_wready       ),
    .axi_s_bid          (apb_s_bid          ),
    .axi_s_bresp        (apb_s_bresp        ),
    .axi_s_bvalid       (apb_s_bvalid       ),
    .axi_s_bready       (apb_s_bready       ),
    .axi_s_arid         (apb_s_arid         ),
    .axi_s_araddr       (apb_s_araddr       ),
    .axi_s_arlen        (apb_s_arlen        ),
    .axi_s_arsize       (apb_s_arsize       ),
    .axi_s_arburst      (apb_s_arburst      ),
    .axi_s_arlock       (apb_s_arlock       ),
    .axi_s_arcache      (apb_s_arcache      ),
    .axi_s_arprot       (apb_s_arprot       ),
    .axi_s_arvalid      (apb_s_arvalid      ),
    .axi_s_arready      (apb_s_arready      ),
    .axi_s_rid          (apb_s_rid          ),
    .axi_s_rdata        (apb_s_rdata        ),
    .axi_s_rresp        (apb_s_rresp        ),
    .axi_s_rlast        (apb_s_rlast        ),
    .axi_s_rvalid       (apb_s_rvalid       ),
    .axi_s_rready       (apb_s_rready       ),

    .apb_rw_dma         (apb_rw_dma0        ),
    .apb_psel_dma       (apb_psel_dma0      ),
    .apb_enab_dma       (apb_penable_dma0   ),
    .apb_addr_dma       (apb_addr_dma0[19:0]),
    .apb_valid_dma      (apb_start_dma0     ),
    .apb_wdata_dma      (apb_wdata_dma0     ),
    .apb_rdata_dma      (apb_rdata_dma0     ),
    .apb_ready_dma      (                   ), //output, no use
    .dma_grant          (dma0_gnt           ),

    .dma_req_o          (dma_req            ),
    .dma_ack_i          (dma_ack            ),

    // -- Loongson UART0
    .uart0_txd_i        (uart0_txd_i      ),
    .uart0_txd_o        (uart0_txd_o      ),
    .uart0_txd_oe       (uart0_txd_oe     ),
    .uart0_rxd_i        (uart0_rxd_i      ),
    .uart0_rxd_o        (uart0_rxd_o      ),
    .uart0_rxd_oe       (uart0_rxd_oe     ),
    .uart0_rts_o        (uart0_rts_o      ),
    .uart0_dtr_o        (uart0_dtr_o      ),
    .uart0_cts_i        (uart0_cts_i      ),
    .uart0_dsr_i        (uart0_dsr_i      ),
    .uart0_dcd_i        (uart0_dcd_i      ),
    .uart0_ri_i         (uart0_ri_i       ),
    .uart0_int          (uart0_int        ),

    .nand_type          (2'h2             ),  //1Gbit
    .nand_cle           (nand_cle         ),
    .nand_ale           (nand_ale         ),
    .nand_rdy           (nand_rdy         ),
    .nand_rd            (nand_rd          ),
    .nand_ce            (nand_ce          ),
    .nand_wr            (nand_wr          ),
    .nand_dat_i         (nand_dat_i       ),
    .nand_dat_o         (nand_dat_o       ),
    .nand_dat_oe        (nand_dat_oe      ),

    .nand_int           (nand_int         )
    );

    // ------------------------------------- RickTino NT35510 TFT-LCD Module -------------------------------------
    /*
        Here is description.
    **/
    gpu_top GPU
    (
    .aclk           (aclk               ),
    .aresetn        (aresetn            ),

    .s_awid         (gpu_s_awid         ),
    .s_awaddr       (gpu_s_awaddr       ),
    .s_awlen        (gpu_s_awlen        ),
    .s_awsize       (gpu_s_awsize       ),
    .s_awburst      (gpu_s_awburst      ),
    .s_awlock       (gpu_s_awlock       ),
    .s_awcache      (gpu_s_awcache      ),
    .s_awprot       (gpu_s_awprot       ),
    .s_awvalid      (gpu_s_awvalid      ),
    .s_awready      (gpu_s_awready      ),
    .s_wid          (gpu_s_wid          ),
    .s_wdata        (gpu_s_wdata        ),
    .s_wstrb        (gpu_s_wstrb        ),
    .s_wlast        (gpu_s_wlast        ),
    .s_wvalid       (gpu_s_wvalid       ),
    .s_wready       (gpu_s_wready       ),
    .s_bid          (gpu_s_bid          ),
    .s_bresp        (gpu_s_bresp        ),
    .s_bvalid       (gpu_s_bvalid       ),
    .s_bready       (gpu_s_bready       ),
    .s_arid         (gpu_s_arid         ),
    .s_araddr       (gpu_s_araddr       ),
    .s_arlen        (gpu_s_arlen        ),
    .s_arsize       (gpu_s_arsize       ),
    .s_arburst      (gpu_s_arburst      ),
    .s_arlock       (gpu_s_arlock       ),
    .s_arcache      (gpu_s_arcache      ),
    .s_arprot       (gpu_s_arprot       ),
    .s_arvalid      (gpu_s_arvalid      ),
    .s_arready      (gpu_s_arready      ),
    .s_rid          (gpu_s_rid          ),
    .s_rdata        (gpu_s_rdata        ),
    .s_rresp        (gpu_s_rresp        ),
    .s_rlast        (gpu_s_rlast        ),
    .s_rvalid       (gpu_s_rvalid       ),
    .s_rready       (gpu_s_rready       ),

    .lcd_rst        (lcd_rst            ),
    .lcd_cs         (lcd_cs             ),
    .lcd_rs         (lcd_rs             ),
    .lcd_wr         (lcd_wr             ),
    .lcd_rd         (lcd_rd             ),
    .lcd_data_io    (lcd_data_io        ),
    .lcd_bl_ctr     (inner_lcd_bl_ctl   ),
        
    .ct_int         (ct_int             ),
    .ct_sda         (ct_sda             ),
    .ct_scl         (ct_scl             ),
    .ct_rstn        (ct_rstn            )
    );
endmodule

