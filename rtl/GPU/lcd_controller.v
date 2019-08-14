//Size of LCD
`define     X_Start   0
`define     X_End     480
`define     Y_Start   0
`define     Y_End     800

`define     X_Size    (`X_End - `X_Start)
`define     Y_Size    (`Y_End - `Y_Start)
`define     LCD_Size  (`X_Size * `Y_Size)

module lcd_controller (
    input  wire         clk,        // 66MHz
    input  wire         rstn,
    
    input  wire         bus_en,
    input  wire [ 3: 0] bus_wen,
    input  wire [19: 0] bus_addr,
    output wire [31: 0] bus_rdata,
    input  wire [31: 0] bus_wdata,

    output wire         lcd_rst,    // low active
    output reg          lcd_cs,     // low active
    output reg          lcd_rs,
    output reg          lcd_wr,     // low active
    output wire         lcd_rd,     // low active
    inout  wire [15: 0] lcd_data_io,
    output wire         lcd_bl_ctr
);

    reg lcd_clk = 1'b0;
    always @(posedge clk) lcd_clk = ~lcd_clk;  //33MHz
    
    // Mux
    wire cr_sel = {bus_addr[19:14], 14'b0} == 20'hbc000;
    wire ram_en = bus_en && !cr_sel;
    wire cr_en  = bus_en && cr_sel;
    reg  cr_dvld;
    
    wire [31:0] ram_rdata;
    reg  [31:0] cr_rdata;
    assign bus_rdata = cr_dvld ? cr_rdata : ram_rdata;
    
    // Control register
    reg  [31:0] cr0;
    
    always @(posedge clk, negedge rstn) begin
        if(!rstn) begin
            cr0      <= 32'b1;
            cr_rdata <= 32'b0;
            cr_dvld  <= 1'b0;
        end
        else begin
            cr_dvld <= 0;
            if(cr_en) begin
                case (bus_addr[15:0])
                    16'hC000: begin
                        cr_rdata <= cr0;
                        cr_dvld  <= 1'b1;
                        cr0[ 7: 0] <= bus_wen[0] ? bus_wdata[ 7: 0] : cr0[ 7: 0];
                        cr0[15: 8] <= bus_wen[1] ? bus_wdata[15: 8] : cr0[15: 8];
                        cr0[23:16] <= bus_wen[2] ? bus_wdata[23:16] : cr0[23:16];
                        cr0[31:24] <= bus_wen[3] ? bus_wdata[31:24] : cr0[31:24];
                    end
                    default: cr_rdata <= 32'b0;
                endcase
            end
        end
    end
    
    //Frame buffer
    reg         pxl_rd;
    reg  [18:0] pxl_cnt;
    wire [31:0] pxl_data;
    
    gpu_ram frame_buffer (
        .clka   ( clk           ),    // input wire clka
        .ena    ( ram_en        ),    // input wire ena
        .wea    ( bus_wen       ),    // input wire [3 : 0] wea
        .addra  ( bus_addr[19:2]),    // input wire [17 : 0] addra
        .dina   ( bus_wdata     ),    // input wire [31 : 0] dina
        .douta  ( ram_rdata     ),    // output wire [31 : 0] douta
        .clkb   ( lcd_clk       ),    // input wire clkb
        .enb    ( pxl_rd        ),    // input wire enb
        .web    ( 4'b0          ),    // input wire [3 : 0] web
        .addrb  ( pxl_cnt[18:1] ),    // input wire [17 : 0] addrb
        .dinb   ( 32'b0         ),    // input wire [31 : 0] dinb
        .doutb  ( pxl_data      )     // output wire [31 : 0] doutb
    );
    
    // Fixed LCD signal connection
    reg  [15: 0] lcd_data_o;
    
    assign lcd_data_io = lcd_data_o;
    assign lcd_rd      = 1'b1;
    assign lcd_rst     = rstn;
    assign lcd_bl_ctr  = cr0[0];
    
    // LCD write state machine
    reg  [15: 0] buf_data;
    reg          buf_rs;
    reg          lcd_write;
    reg          lcd_state;

    always @(posedge lcd_clk, negedge rstn) begin
        if(!rstn) begin
            lcd_state  <= 1'b0;
            lcd_cs     <= 1'b1;
            lcd_rs     <= 1'b0;
            lcd_wr     <= 1'b1;
            lcd_data_o <= 16'b0;
        end
        else begin
            case (lcd_state)
                0: begin
                    if(lcd_write) begin
                        lcd_cs     <= 1'b0;
                        lcd_rs     <= buf_rs;
                        lcd_wr     <= 1'b0;
                        lcd_data_o <= buf_data;
                        lcd_state  <= 1'b1;
                    end
                    else lcd_cs     <= 1'b1;
                end
                1: begin
                    lcd_state  <= 1'b0;
                    lcd_wr     <= 1'b1;
                end
            endcase
        end
    end
    
    // LCD control state machine
    reg  [ 2: 0] state;
    
    parameter RESET_STATE     = 0;
    parameter SET_SLEEP_OUT   = 1;
    parameter SET_COLMOD_INST = 2;
    parameter SET_COLMOD_DATA = 3;
    parameter SET_DISPLAY_ON  = 4;
    parameter RAMWR_INST      = 5;
    parameter RAMWR_DATA      = 6;

    always @(posedge lcd_clk, negedge rstn) begin
        if(!rstn) begin
            state     <= RESET_STATE;
            lcd_write <= 0;
            buf_data  <= 0;
            buf_rs    <= 0;
            
            pxl_rd    <= 0;
            pxl_cnt   <= 0;
        end
        else begin
            case (state)
                RESET_STATE: begin
                    state <= SET_SLEEP_OUT;
                end
                SET_SLEEP_OUT: begin
                    lcd_write <= 1'b1;
                    buf_data  <= 16'h1100;
                    buf_rs    <= 1'b0;
                    state     <= SET_COLMOD_INST;
                end
                
                SET_COLMOD_INST: if(lcd_state) begin
                    buf_data <= 16'h3A00;
                    buf_rs   <= 1'b0;
                    state    <= SET_COLMOD_DATA;
                end 
                
                SET_COLMOD_DATA: if(lcd_state) begin
                    buf_data <= 16'h0055;
                    buf_rs   <= 1'b1;
                    state    <= SET_DISPLAY_ON;
                end 
                
                SET_DISPLAY_ON: if(lcd_state) begin
                    buf_data <= 16'h2900;
                    buf_rs   <= 1'b0;
                    state    <= RAMWR_INST;
                end
                
                RAMWR_INST: if(lcd_state) begin
                    buf_data <= 16'h2C00;
                    buf_rs   <= 1'b0;
                    state    <= RAMWR_DATA;
                    pxl_rd   <= 1'b1;
                end
                
                RAMWR_DATA: if(lcd_state) begin
                    buf_data <= pxl_cnt[0] ? pxl_data[31:16]: pxl_data[15:0];
                    buf_rs   <= 1'b1;
                    pxl_cnt  <= (pxl_cnt >= `LCD_Size - 1) ? 0 : pxl_cnt + 1;
                end
            endcase
        end
    end
    
endmodule