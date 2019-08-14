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

`define ORDER_REG_ADDR  16'h1160   //32'hbfd0_1160
`define LED_ADDR        16'hf000   //32'hbfd0_f000 
`define LED_RG0_ADDR    16'hf004   //32'hbfd0_f004 
`define LED_RG1_ADDR    16'hf008   //32'hbfd0_f008 
`define NUM_ADDR        16'hf010   //32'hbfd0_f010 
`define SWITCH_ADDR     16'hf020   //32'hbfd0_f020 
`define BTN_KEY_ADDR    16'hf024   //32'hbfd0_f024
`define BTN_STEP_ADDR   16'hf028   //32'hbfd0_f028
`define TIMER_ADDR      16'he000   //32'hbfd0_e000
`define DOT_ADDR        16'hf040   //32'hbfd0_f040 - f05C

`define PWM_CONFR_ADDR  16'hff00   // Main PWM Control of the whole ConfReg LED
`define CONFR_ISEL_ADDR 16'hff04   // Confreg Control Signal Select: 0(default) for PWM, 1 for General.
`define PWM_LCD_BL_ADDR 16'hff08   // LCD Backlight PWM Control
`define LCD_BLSEL_ADDR  16'hff0c   // LCD Backlight Select: 0(default) for PWM, 1 for General.
`define UNDEFINED_ADDR  16'hff10
`define PWM0_ADDR       16'hff14
`define PWM1_ADDR       16'hff18
`define PWM2_ADDR       16'hff1c
`define PWM3_ADDR       16'hff20

`define INTR_ADDR       16'hff00

module confreg(
    aclk,
    aresetn,

    s_awid,
    s_awaddr,
    s_awlen,
    s_awsize,
    s_awburst,
    s_awlock,
    s_awcache,
    s_awprot,
    s_awvalid,
    s_awready,
    s_wid,
    s_wdata,
    s_wstrb,
    s_wlast,
    s_wvalid,
    s_wready,
    s_bid,
    s_bresp,
    s_bvalid,
    s_bready,
    s_arid,
    s_araddr,
    s_arlen,
    s_arsize,
    s_arburst,
    s_arlock,
    s_arcache,
    s_arprot,
    s_arvalid,
    s_arready,
    s_rid,
    s_rdata,
    s_rresp,
    s_rlast,
    s_rvalid,
    s_rready,
    
    order_addr_reg,
    finish_read_order,
    write_dma_end, 

    cr00,
    cr01,
    cr02,
    cr03,
    cr04,
    cr05,
    cr06,
    cr07,

    led,
    led_rg0,
    led_rg1,
    dot_r,
    dot_c,
    num_csn,
    num_a_g,
    switch,
    btn_key_col,
    btn_key_row,
    btn_step,

    // -- PWM
    pwm0_out,
    pwm1_out,
    pwm2_out,
    pwm3_out,
    lcd_bl_general_ctl,     // -- LCD BL control general signal from TFT-LCD Module.
    lcd_bl_ctl_o,           // -- LCD BL SEL output




    // -- Hypo Interrupt Register
    hypo_intr
);
    input           aclk;
    input           aresetn;

    input  [3 :0] s_awid;
    input  [31:0] s_awaddr;
    input  [7 :0] s_awlen;
    input  [2 :0] s_awsize;
    input  [1 :0] s_awburst;
    input         s_awlock;
    input  [3 :0] s_awcache;
    input  [2 :0] s_awprot;
    input         s_awvalid;
    output        s_awready;
    input  [3 :0] s_wid;
    input  [31:0] s_wdata;
    input  [3 :0] s_wstrb;
    input         s_wlast;
    input         s_wvalid;
    output        s_wready;
    output [3 :0] s_bid;
    output [1 :0] s_bresp;
    output        s_bvalid;
    input         s_bready;
    input  [3 :0] s_arid;
    input  [31:0] s_araddr;
    input  [7 :0] s_arlen;
    input  [2 :0] s_arsize;
    input  [1 :0] s_arburst;
    input         s_arlock;
    input  [3 :0] s_arcache;
    input  [2 :0] s_arprot;
    input         s_arvalid;
    output        s_arready;
    output [3 :0] s_rid;
    output [31:0] s_rdata;
    output [1 :0] s_rresp;
    output        s_rlast;
    output        s_rvalid;
    input         s_rready;
    
    output reg [31:0] order_addr_reg;
    input         finish_read_order;
    input         write_dma_end;

    output [31:0]    cr00;
    output [31:0]    cr01;
    output [31:0]    cr02;
    output [31:0]    cr03;
    output [31:0]    cr04;
    output [31:0]    cr05;
    output [31:0]    cr06;
    output [31:0]    cr07;

    output     [15:0] led;
    output     [1 :0] led_rg0;
    output     [1 :0] led_rg1;
    output reg [7 :0] dot_r;
    output reg [7 :0] dot_c;
    output reg [7 :0] num_csn;
    output reg [6 :0] num_a_g;
    input      [7 :0] switch;
    output     [3 :0] btn_key_col;
    input      [3 :0] btn_key_row;
    input      [1 :0] btn_step;

// -- PWM Modules
    output pwm0_out;
    output pwm1_out;
    output pwm2_out;
    output pwm3_out;

    input  lcd_bl_general_ctl;  // -- LCD BL control general signal from TFT-LCD Module.
    output reg lcd_bl_ctl_o;    // -- LCD BL SEL output

wire pwm_lcd_bl_ctr;
wire pwm_confreg_ctl;

reg [31:0]  pwm0_compare;
reg [31:0]  pwm1_compare;
reg [31:0]  pwm2_compare;
reg [31:0]  pwm3_compare;
reg [31:0]  pwm_lcd_bl_compare;
reg [31:0]  pwm_confreg_compare;
reg         reg_confr_isel;
reg         reg_lcd_blsel;
reg [15:0]  confreg_ctl_o;

// -- HypoINT Register
    input [31:0] hypo_intr;
reg [31:0] reg_intr;

//
reg  [31:0] led_data;
reg  [31:0] led_rg0_data;
reg  [31:0] led_rg1_data;
reg  [31:0] num_data;
wire [31:0] switch_data;
wire [31:0] btn_key_data;
wire [31:0] btn_step_data;
reg  [31:0] timer;
reg  [ 7:0] dot_data [7:0];
reg  [31:0] pwm_ct;

reg [31:0] cr00,cr01,cr02,cr03,cr04,cr05,cr06,cr07;
reg busy,write,R_or_W;
reg s_wready;

wire ar_enter = s_arvalid & s_arready;
wire r_retire = s_rvalid & s_rready & s_rlast;
wire aw_enter = s_awvalid & s_awready;
wire w_enter  = s_wvalid & s_wready & s_wlast;
wire b_retire = s_bvalid & s_bready;

wire s_arready = ~busy & (!R_or_W| !s_awvalid);
wire s_awready = ~busy & ( R_or_W| !s_arvalid);

always@(posedge aclk)
    if(~aresetn) busy <= 1'b0;
    else if(ar_enter|aw_enter) busy <= 1'b1;
    else if(r_retire|b_retire) busy <= 1'b0;

reg [3 :0] buf_id;
reg [31:0] buf_addr;
reg [7 :0] buf_len;
reg [2 :0] buf_size;
reg [1 :0] buf_burst;
reg        buf_lock;
reg [3 :0] buf_cache;
reg [2 :0] buf_prot;

always@(posedge aclk)
    if(~aresetn) begin
        R_or_W      <= 1'b0;
        buf_id      <= 'b0;
        buf_addr    <= 'b0;
        buf_len     <= 'b0;
        buf_size    <= 'b0;
        buf_burst   <= 'b0;
        buf_lock    <= 'b0;
        buf_cache   <= 'b0;
        buf_prot    <= 'b0;
    end
    else
    if(ar_enter | aw_enter) begin
        R_or_W      <= ar_enter;
        buf_id      <= ar_enter ? s_arid   : s_awid   ;
        buf_addr    <= ar_enter ? s_araddr : s_awaddr ;
        buf_len     <= ar_enter ? s_arlen  : s_awlen  ;
        buf_size    <= ar_enter ? s_arsize : s_awsize ;
        buf_burst   <= ar_enter ? s_arburst: s_awburst;
        buf_lock    <= ar_enter ? s_arlock : s_awlock ;
        buf_cache   <= ar_enter ? s_arcache: s_awcache;
        buf_prot    <= ar_enter ? s_arprot : s_awprot ;
    end

always@(posedge aclk)
    if(~aresetn) write <= 1'b0;
    else if(aw_enter) write <= 1'b1;
    else if(ar_enter)  write <= 1'b0;

always@(posedge aclk)
    if(~aresetn) s_wready <= 1'b0;
    else if(aw_enter) s_wready <= 1'b1;
    else if(w_enter & s_wlast) s_wready <= 1'b0;

always@(posedge aclk)
    if(~aresetn) begin
        cr00 <= 32'd0;  
        cr01 <= 32'd0;  
        cr02 <= 32'd0;  
        cr03 <= 32'd0;
        cr04 <= 32'd0;
        cr05 <= 32'd0;
        cr06 <= 32'd0;
        cr07 <= 32'd0;
    end
    else if(w_enter) begin
        case (buf_addr[15:2])
            14'd0: cr00 <= s_wdata;
            14'd1: cr01 <= s_wdata;
            14'd2: cr02 <= s_wdata;
            14'd3: cr03 <= s_wdata;
            14'd4: cr04 <= s_wdata;
            14'd5: cr05 <= s_wdata;
            14'd6: cr06 <= s_wdata;
            14'd7: cr07 <= s_wdata;
        endcase
    end

reg [31:0] s_rdata;
reg s_rvalid,s_rlast;
wire [31:0] rdata_d = buf_addr[15:2]         == 14'd0 ? cr00 :
                       buf_addr[15:2]         == 14'd1 ? cr01 :
                       buf_addr[15:2]         == 14'd2 ? cr02 :
                       buf_addr[15:2]         == 14'd3 ? cr03 :
                       buf_addr[15:2]         == 14'd4 ? cr04 :
                       buf_addr[15:2]         == 14'd5 ? cr05 :
                       buf_addr[15:2]         == 14'd6 ? cr06 :
                       buf_addr[15:2]         == 14'd7 ? cr07 :
                       buf_addr[15:0]         == `PWM_CONFR_ADDR ? pwm_confreg_compare  :
                       buf_addr[15:0]         == `CONFR_ISEL_ADDR? reg_confr_isel :
                       buf_addr[15:0]         == `PWM_LCD_BL_ADDR? pwm_lcd_bl_compare   :
                       buf_addr[15:0]         == `LCD_BLSEL_ADDR ? reg_lcd_blsel  :
                       buf_addr[15:0]         == `PWM0_ADDR      ? pwm0_compare   : // Read for our compare value.
                       buf_addr[15:0]         == `PWM1_ADDR      ? pwm1_compare   : // Read for our compare value.
                       buf_addr[15:0]         == `PWM2_ADDR      ? pwm2_compare   : // Read for our compare value.
                       buf_addr[15:0]         == `PWM3_ADDR      ? pwm3_compare   : // Read for our compare value.
                       buf_addr[15:0]         == `INTR_ADDR      ? reg_intr       : // Read for int status
                       buf_addr[15:0]         == `ORDER_REG_ADDR ? order_addr_reg : 
                       buf_addr[15:0]         == `LED_ADDR       ? led_data       :
                       buf_addr[15:0]         == `LED_RG0_ADDR   ? led_rg0_data   :
                       buf_addr[15:0]         == `LED_RG1_ADDR   ? led_rg1_data   :
                       buf_addr[15:0]         == `NUM_ADDR       ? num_data       :
                       buf_addr[15:0]         == `SWITCH_ADDR    ? switch_data    :
                       buf_addr[15:0]         == `BTN_KEY_ADDR   ? btn_key_data   :
                       buf_addr[15:0]         == `BTN_STEP_ADDR  ? btn_step_data  :
                       buf_addr[15:0]         == `TIMER_ADDR     ? timer          :
                       {buf_addr[15:5], 5'b0} == `DOT_ADDR ? {24'b0, dot_data[buf_addr[4:2]]} :
                       32'd0;
//reg [31:0] rdata_d;
//always @(*) begin
//    casez (buf_addr[15:0])
//        {14'd0, 2'b??}:  rdata_d <= cr00;
//        {14'd1, 2'b??}:  rdata_d <= cr01;
//        {14'd2, 2'b??}:  rdata_d <= cr02;
//        {14'd3, 2'b??}:  rdata_d <= cr03;
//        {14'd4, 2'b??}:  rdata_d <= cr04;
//        {14'd5, 2'b??}:  rdata_d <= cr05;
//        {14'd6, 2'b??}:  rdata_d <= cr06;
//        {14'd7, 2'b??}:  rdata_d <= cr07;
//        `ORDER_REG_ADDR: rdata_d <= order_addr_reg;
//        `LED_ADDR      : rdata_d <= led_data;
//        `LED_RG0_ADDR  : rdata_d <= led_rg0_data;
//        `LED_RG1_ADDR  : rdata_d <= led_rg1_data;
//        `NUM_ADDR      : rdata_d <= num_data;
//        `SWITCH_ADDR   : rdata_d <= switch_data;
//        `BTN_KEY_ADDR  : rdata_d <= btn_key_data;
//        `BTN_STEP_ADDR : rdata_d <= btn_step_data;
//        `TIMER_ADDR    : rdata_d <= timer;
//        {11'b1111_0000_010, 5'b?????}: rdata_d <= {24'b0, dot_data[buf_addr[4:2]]};
//        default:         rdata_d <= 32'b0;
//    endcase
//end


always@(posedge aclk)
    if(~aresetn) begin
        s_rdata  <= 'b0;
        s_rvalid <= 1'b0;
        s_rlast  <= 1'b0;
    end
    else if(busy & !write & !r_retire)
    begin
        s_rdata <= rdata_d;
        s_rvalid <= 1'b1;
        s_rlast <= 1'b1; 
    end
    else if(r_retire)
    begin
        s_rvalid <= 1'b0;
    end

reg s_bvalid;
always@(posedge aclk)   
    if(~aresetn) s_bvalid <= 1'b0;
    else if(w_enter) s_bvalid <= 1'b1;
    else if(b_retire) s_bvalid <= 1'b0;

assign s_rid   = buf_id;
assign s_bid   = buf_id;
assign s_bresp = 2'b0;
assign s_rresp = 2'b0;

wire write_order_reg = w_enter & (buf_addr[15:0]==`ORDER_REG_ADDR);
always @(posedge aclk)
begin
    if(!aresetn)
    begin
        order_addr_reg <= 32'h0;
    end
    else if(write_order_reg)
    begin
        order_addr_reg <= s_wdata[31:0];
    end
    else if(write_dma_end | finish_read_order)
    begin
        order_addr_reg[2] <= write_dma_end ? 1'b0 : order_addr_reg[2];
        order_addr_reg[3] <= finish_read_order ? 1'b0 : order_addr_reg[3];
    end
end     
//-------------------------------{timer}begin----------------------------//
wire write_timer = w_enter & (buf_addr[15:0]==`TIMER_ADDR);
always @(posedge aclk)
begin
    if(!aresetn)
    begin
        timer <= 32'd0;
    end
    else if (write_timer)
    begin
        timer <= s_wdata[31:0];
    end
    else
    begin
        timer <= timer + 1'b1;
    end
end
//--------------------------------{timer}end-----------------------------//

//--------------------------------{led}begin-----------------------------//
//led display
//led_data[31:0]
wire write_led = w_enter & (buf_addr[15:0]==`LED_ADDR);
assign led = confreg_ctl_o; // led_data[15:0];
always @(posedge aclk)
begin
    if(!aresetn)
    begin
        led_data <= ~32'h0;
    end
    else if(write_led)
    begin
        led_data <= s_wdata[31:0];
    end
end
//---------------------------------{led}end------------------------------//

//-------------------------------{switch}begin---------------------------//
//switch data
//switch_data[7:0]
assign switch_data = {24'd0,switch};
//--------------------------------{switch}end----------------------------//

//------------------------------{btn key}begin---------------------------//
//btn key data
reg [15:0] btn_key_r;
assign btn_key_data = {16'd0,btn_key_r};

//state machine
reg  [2:0] state;
wire [2:0] next_state;

//eliminate jitter
reg        key_flag;
reg [19:0] key_count;
reg [3:0] state_count;
wire key_start = (state==3'b000) && !(&btn_key_row);
wire key_end   = (state==3'b111) &&  (&btn_key_row);
wire key_sample= key_count[19];
always @(posedge aclk)
begin
    if(!aresetn)
    begin
        key_flag <= 1'd0;
    end
    else if (key_sample && state_count[3]) 
    begin
        key_flag <= 1'b0;
    end
    else if( key_start || key_end )
    begin
        key_flag <= 1'b1;
    end

    if(!aresetn || !key_flag)
    begin
        key_count <= 20'd0;
    end
    else
    begin
        key_count <= key_count + 1'b1;
    end
end

always @(posedge aclk)
begin
    if(!aresetn || state_count[3])
    begin
        state_count <= 4'd0;
    end
    else
    begin
        state_count <= state_count + 1'b1;
    end
end

always @(posedge aclk)
begin
    if(!aresetn)
    begin
        state <= 3'b000;
    end
    else if (state_count[3])
    begin
        state <= next_state;
    end
end

assign next_state = (state == 3'b000) ? ( (key_sample && !(&btn_key_row)) ? 3'b001 : 3'b000 ) :
                    (state == 3'b001) ? (                !(&btn_key_row)  ? 3'b111 : 3'b010 ) :
                    (state == 3'b010) ? (                !(&btn_key_row)  ? 3'b111 : 3'b011 ) :
                    (state == 3'b011) ? (                !(&btn_key_row)  ? 3'b111 : 3'b100 ) :
                    (state == 3'b100) ? (                !(&btn_key_row)  ? 3'b111 : 3'b000 ) :
                    (state == 3'b111) ? ( (key_sample &&  (&btn_key_row)) ? 3'b000 : 3'b111 ) :
                                                                                        3'b000;
assign btn_key_col = (state == 3'b000) ? 4'b0000:
                     (state == 3'b001) ? 4'b1110:
                     (state == 3'b010) ? 4'b1101:
                     (state == 3'b011) ? 4'b1011:
                     (state == 3'b100) ? 4'b0111:
                                         4'b0000;
wire [15:0] btn_key_tmp;
always @(posedge aclk) begin
    if(!aresetn) begin
        btn_key_r   <= 16'd0;
    end
    else if(next_state==3'b000)
    begin
        btn_key_r   <=16'd0;
    end
    else if(next_state == 3'b111 && state != 3'b111) begin
        btn_key_r   <= btn_key_tmp;
    end
end

assign btn_key_tmp = (state == 3'b001)&(btn_key_row == 4'b1110) ? 16'h0001:
                     (state == 3'b001)&(btn_key_row == 4'b1101) ? 16'h0010:
                     (state == 3'b001)&(btn_key_row == 4'b1011) ? 16'h0100:
                     (state == 3'b001)&(btn_key_row == 4'b0111) ? 16'h1000:
                     (state == 3'b010)&(btn_key_row == 4'b1110) ? 16'h0002:
                     (state == 3'b010)&(btn_key_row == 4'b1101) ? 16'h0020:
                     (state == 3'b010)&(btn_key_row == 4'b1011) ? 16'h0200:
                     (state == 3'b010)&(btn_key_row == 4'b0111) ? 16'h2000:
                     (state == 3'b011)&(btn_key_row == 4'b1110) ? 16'h0004:
                     (state == 3'b011)&(btn_key_row == 4'b1101) ? 16'h0040:
                     (state == 3'b011)&(btn_key_row == 4'b1011) ? 16'h0400:
                     (state == 3'b011)&(btn_key_row == 4'b0111) ? 16'h4000:
                     (state == 3'b100)&(btn_key_row == 4'b1110) ? 16'h0008:
                     (state == 3'b100)&(btn_key_row == 4'b1101) ? 16'h0080:
                     (state == 3'b100)&(btn_key_row == 4'b1011) ? 16'h0800:
                     (state == 3'b100)&(btn_key_row == 4'b0111) ? 16'h8000:16'h0000;
//-------------------------------{btn key}end----------------------------//

//-----------------------------{btn step}begin---------------------------//
//btn step data
reg btn_step0_r; //0:press
reg btn_step1_r; //0:press
assign btn_step_data = {30'd0,~btn_step0_r,~btn_step1_r}; //1:press

//-----step0
//eliminate jitter
reg        step0_flag;
reg [19:0] step0_count;
wire step0_start = btn_step0_r && !btn_step[0];
wire step0_end   = !btn_step0_r && btn_step[0];
wire step0_sample= step0_count[19];
always @(posedge aclk)
begin
    if(!aresetn)
    begin
        step0_flag <= 1'd0;
    end
    else if (step0_sample) 
    begin
        step0_flag <= 1'b0;
    end
    else if( step0_start || step0_end )
    begin
        step0_flag <= 1'b1;
    end

    if(!aresetn || !step0_flag)
    begin
        step0_count <= 20'd0;
    end
    else
    begin
        step0_count <= step0_count + 1'b1;
    end

    if(!aresetn)
    begin
        btn_step0_r <= 1'b1;
    end
    else if(step0_sample)
    begin
        btn_step0_r <= btn_step[0];
    end
end

//-----step1
//eliminate jitter
reg        step1_flag;
reg [19:0] step1_count;
wire step1_start = btn_step1_r && !btn_step[1];
wire step1_end   = !btn_step1_r && btn_step[1];
wire step1_sample= step1_count[19];
always @(posedge aclk)
begin
    if(!aresetn)
    begin
        step1_flag <= 1'd0;
    end
    else if (step1_sample) 
    begin
        step1_flag <= 1'b0;
    end
    else if( step1_start || step1_end )
    begin
        step1_flag <= 1'b1;
    end

    if(!aresetn || !step1_flag)
    begin
        step1_count <= 20'd0;
    end
    else
    begin
        step1_count <= step1_count + 1'b1;
    end

    if(!aresetn)
    begin
        btn_step1_r <= 1'b1;
    end
    else if(step1_sample)
    begin
        btn_step1_r <= btn_step[1];
    end
end
//------------------------------{btn step}end----------------------------//

//-------------------------------{led rg}begin---------------------------//
//led_rg0_data[31:0]  led_rg0_data[31:0]
//bfd0_f010           bfd0_f014
wire write_led_rg0 = w_enter & (buf_addr[15:0]==`LED_RG0_ADDR);
wire write_led_rg1 = w_enter & (buf_addr[15:0]==`LED_RG1_ADDR);
assign led_rg0 = led_rg0_data[1:0];
assign led_rg1 = led_rg1_data[1:0];
always @(posedge aclk)
begin
    if(!aresetn)
    begin
        led_rg0_data <= 32'h0;
    end
    else if(write_led_rg0)
    begin
        led_rg0_data <= s_wdata[31:0];
    end

    if(!aresetn)
    begin
        led_rg1_data <= 32'h0;
    end
    else if(write_led_rg1)
    begin
        led_rg1_data <= s_wdata[31:0];
    end
end
//--------------------------------{led rg}end----------------------------//

//---------------------------{digital number}begin-----------------------//
//digital number display
//num_data[31:0]
wire write_num = w_enter & (buf_addr[15:0]==`NUM_ADDR);
always @(posedge aclk)
begin
    if(!aresetn)
    begin
        num_data <= 32'h0;
    end
    else if(write_num)
    begin
        num_data <= s_wdata[31:0];
    end
end


reg [19:0] count;
always @(posedge aclk)
begin
    if(!aresetn)
    begin
        count <= 20'd0;
    end
    else
    begin
        count <= count + 1'b1;
    end
end
//scan data
reg [3:0] scan_data;
always @ ( posedge aclk )  
begin
    if ( !aresetn )
    begin
        scan_data <= 32'd0;  
        num_csn   <= 8'b1111_1111;
    end
    else
    begin
        case(count[18:16])
            3'b000 : scan_data <= num_data[31:28];
            3'b001 : scan_data <= num_data[27:24];
            3'b010 : scan_data <= num_data[23:20];
            3'b011 : scan_data <= num_data[19:16];
            3'b100 : scan_data <= num_data[15:12];
            3'b101 : scan_data <= num_data[11: 8];
            3'b110 : scan_data <= num_data[7 : 4];
            3'b111 : scan_data <= num_data[3 : 0];
        endcase

        case(count[18:16])
            3'b000 : num_csn <= 8'b0111_1111;
            3'b001 : num_csn <= 8'b1011_1111;
            3'b010 : num_csn <= 8'b1101_1111;
            3'b011 : num_csn <= 8'b1110_1111;
            3'b100 : num_csn <= 8'b1111_0111;
            3'b101 : num_csn <= 8'b1111_1011;
            3'b110 : num_csn <= 8'b1111_1101;
            3'b111 : num_csn <= 8'b1111_1110;
        endcase
    end
end

always @(posedge aclk)
begin
    if ( !aresetn )
    begin
        num_a_g <= 7'b0000000;
    end
    else
    begin
        case ( scan_data )
            4'd0 : num_a_g <= 7'b1111110;   //0
            4'd1 : num_a_g <= 7'b0110000;   //1
            4'd2 : num_a_g <= 7'b1101101;   //2
            4'd3 : num_a_g <= 7'b1111001;   //3
            4'd4 : num_a_g <= 7'b0110011;   //4
            4'd5 : num_a_g <= 7'b1011011;   //5
            4'd6 : num_a_g <= 7'b1011111;   //6
            4'd7 : num_a_g <= 7'b1110000;   //7
            4'd8 : num_a_g <= 7'b1111111;   //8
            4'd9 : num_a_g <= 7'b1111011;   //9
            4'd10: num_a_g <= 7'b1110111;   //a
            4'd11: num_a_g <= 7'b0011111;   //b
            4'd12: num_a_g <= 7'b1001110;   //c
            4'd13: num_a_g <= 7'b0111101;   //d
            4'd14: num_a_g <= 7'b1001111;   //e
            4'd15: num_a_g <= 7'b1000111;   //f
        endcase
    end
end
//----------------------------{digital number}end------------------------//

//-------------------------------------{dot}begin-----------------------//
wire write_dot = w_enter & ({buf_addr[15:5], 5'b0} == `DOT_ADDR);
always @(posedge aclk)
begin
    if(!aresetn)
    begin
        dot_data[0] <= 8'h0;
        dot_data[1] <= 8'h0;
        dot_data[2] <= 8'h0;
        dot_data[3] <= 8'h0;
        dot_data[4] <= 8'h0;
        dot_data[5] <= 8'h0;
        dot_data[6] <= 8'h0;
        dot_data[7] <= 8'h0;
    end
    else if(write_dot)
    begin
        dot_data[buf_addr[4:2]] <= s_wdata[7:0];
    end
end

always @(posedge aclk)
begin
    if(!aresetn) begin
        dot_r <= 8'b0;
        dot_c <= 8'h0;
    end
    else begin
        case(count[18:16])
            3'b000 : dot_c <= 8'b1111_1110;
            3'b001 : dot_c <= 8'b1111_1101;
            3'b010 : dot_c <= 8'b1111_1011;
            3'b011 : dot_c <= 8'b1111_0111;
            3'b100 : dot_c <= 8'b1110_1111;
            3'b101 : dot_c <= 8'b1101_1111;
            3'b110 : dot_c <= 8'b1011_1111;
            3'b111 : dot_c <= 8'b0111_1111;
        endcase
        dot_r <= dot_data[count[18:16]];
    end
end

//--------------------------------------{dot}end------------------------//
// ------------------------------------- PWM -------------------------------------
// -- PWM 0
wire write_pwm0 = w_enter & (buf_addr[15:0]==`PWM0_ADDR);
PWM pwm0(
    .clk(aclk),
    .rst_n(aresetn),
    .compare(pwm0_compare),
    .pwm_out(pwm0_out)
);
always @(posedge aclk)
begin
    if(!aresetn)
    begin
        pwm0_compare <= 32'h0;
    end
    else if(write_pwm0)
    begin
        pwm0_compare <= s_wdata[31:0];
    end
end
// -- PWM 1
wire write_pwm1 = w_enter & (buf_addr[15:0]==`PWM1_ADDR);
PWM pwm1(
    .clk(aclk),
    .rst_n(aresetn),
    .compare(pwm1_compare),
    .pwm_out(pwm1_out)
);
always @(posedge aclk)
begin
    if(!aresetn)
    begin
        pwm1_compare <= 32'h0;
    end
    else if(write_pwm1)
    begin
        pwm1_compare <= s_wdata[31:0];
    end
end
// -- PWM 2
wire write_pwm2 = w_enter & (buf_addr[15:0]==`PWM2_ADDR);
PWM pwm2(
    .clk(aclk),
    .rst_n(aresetn),
    .compare(pwm2_compare),
    .pwm_out(pwm2_out)
);
always @(posedge aclk)
begin
    if(!aresetn)
    begin
        pwm2_compare <= 32'h0;
    end
    else if(write_pwm2)
    begin
        pwm2_compare <= s_wdata[31:0];
    end
end
// -- PWM 3
wire write_pwm3 = w_enter & (buf_addr[15:0]==`PWM3_ADDR);
PWM pwm3(
    .clk(aclk),
    .rst_n(aresetn),
    .compare(pwm3_compare),
    .pwm_out(pwm3_out)
);
always @(posedge aclk)
begin
    if(!aresetn)
    begin
        pwm3_compare <= 32'h0;
    end
    else if(write_pwm3)
    begin
        pwm3_compare <= s_wdata[31:0];
    end
end
// -- PWM LCD BACKLIGHT
wire write_pwm_lcd = w_enter & (buf_addr[15:0]==`PWM_LCD_BL_ADDR);
PWM pwm_lcd(
    .clk(aclk),
    .rst_n(aresetn),
    .compare(pwm_lcd_bl_compare),
    .pwm_out(pwm_lcd_bl_ctr)
);
always @(posedge aclk)
begin
    if(!aresetn)
    begin
        pwm_lcd_bl_compare <= 32'h0;
    end
    else if(write_pwm_lcd)
    begin
        pwm_lcd_bl_compare <= s_wdata[31:0];
    end
end
// -- PWM CONFREG MAIN CONTROL
wire write_pwm_confreg = w_enter & (buf_addr[15:0]==`PWM_CONFR_ADDR);
PWM pwm_confreg(
    .clk(aclk),
    .rst_n(aresetn),
    .compare(pwm_confreg_compare),
    .pwm_out(pwm_confreg_ctl)
);
always @(posedge aclk)
begin
    if(!aresetn)
    begin
        pwm_confreg_compare <= 32'h0;
    end
    else if(write_pwm_confreg)
    begin
        pwm_confreg_compare <= s_wdata[31:0];
    end
end

// ------------------------------------- Hypo INT Register -------------------------------------
wire write_intr = w_enter & (buf_addr[15:0]==`INTR_ADDR);

always @(posedge aclk) begin
    if(!aresetn) begin
        reg_intr <= 32'b0;
    end
    else if(write_intr) begin
        reg_intr <= s_wdata[31:0];
    end
    else begin
        reg_intr <= hypo_intr;
    end
end

// ------------------------------------- LCD BackLight Sel -------------------------------------
wire write_lcd_blsel = w_enter & (buf_addr[15:0]==`LCD_BLSEL_ADDR);
// Operate reg_lcd_blsel
always @(posedge aclk) begin
    if(!aresetn) begin
        reg_lcd_blsel <= 1'b0;
    end
    else if(write_intr) begin
        reg_lcd_blsel <= s_wdata[0];
    end
end
// MUX
always @(posedge aclk) begin
    if(!aresetn) begin
        lcd_bl_ctl_o <= 1'b0;
    end
    else if(reg_lcd_blsel == 1'b1) begin
        lcd_bl_ctl_o <= lcd_bl_general_ctl;
    end
    else if(reg_lcd_blsel == 1'b0) begin
        lcd_bl_ctl_o <= pwm_lcd_bl_ctr;
    end
end

// ------------------------------------- ConfReg Control Signal Sel -------------------------------------
wire write_confr_isel = w_enter & (buf_addr[15:0]==`CONFR_ISEL_ADDR);
// Operate reg_lcd_blsel
always @(posedge aclk) begin
    if(!aresetn) begin
        reg_confr_isel <= 1'b0;
    end
    else if(write_intr) begin
        reg_confr_isel <= s_wdata[0];
    end
end
// MUX
always @(posedge aclk) begin
    if(!aresetn) begin
        confreg_ctl_o <= 16'b0;
    end
    else if(reg_lcd_blsel == 1'b1) begin
        confreg_ctl_o <= led_data[15:0];
    end
    else if(reg_lcd_blsel == 1'b0) begin
        confreg_ctl_o <= {16{pwm_confreg_ctl}};
    end
end

endmodule