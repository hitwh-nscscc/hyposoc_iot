`define     Delay_5ms           340000
`define     Delay_ClrBuf        700000

`define     TS_Control_Reg      16'h8040
`define     TS_Status_Reg       16'h814E
`define     TS_Point_Reg        16'h8150

module ts_controller (
    input  wire         clk,
    input  wire         rstn,
    
    input  wire         bus_en,
    input  wire [ 3: 0] bus_wen,
    input  wire [19: 0] bus_addr,
    output reg  [31: 0] bus_rdata,
    input  wire [31: 0] bus_wdata,
    
    (*mark_debug="true"*)inout  wire         ct_int,
    (*mark_debug="true"*)inout  wire         ct_sda,
    (*mark_debug="true"*)output wire         ct_scl,
    (*mark_debug="true"*)output wire         ct_rstn
);

`ifdef Software_Control_IIC

    reg    scl;
    reg    sda_o;
    reg    int_oe;
    wire   sda_i  = ct_sda;
    wire   int_i  = ct_int;
    
    assign ct_int  = int_oe ? 1'b1 : 1'bz;
    assign ct_rstn = rstn;
    assign ct_scl  = scl    ? 1'bz : 1'b0;
    assign ct_sda  = sda_o  ? 1'bz : 1'b0;
    // assign ct_scl = scl;
    // assign ct_sda = int_oe ? sda_o : 1'bz;
    
    always @(posedge clk, negedge rstn) begin
        if(!rstn) begin
            scl       <= 1'b1;
            sda_o     <= 1'b1;
            int_oe    <= 1'b1;
            bus_rdata <= 0;
        end
        else if(bus_en) begin
            scl    <= bus_wen[0] ? bus_wdata[ 0] : scl;
            sda_o  <= bus_wen[1] ? bus_wdata[ 8] : sda_o;
            int_oe <= bus_wen[2] ? bus_wdata[16] : int_oe;
            bus_rdata[ 0] <= scl;
            bus_rdata[ 8] <= sda_i;
            bus_rdata[16] <= int_i;
        end
    end
    
`else
    
    // IIC tri-state signal processing
    reg    int_o;
    wire   scl;
    wire   sda_o;    
    wire   sda_i  = ct_sda;
    
    assign ct_rstn = rstn;
    assign ct_int  = int_o ? 1'b1 : 1'bz;
    assign ct_scl  = scl   ? 1'bz : 1'b0;
    assign ct_sda  = sda_o ? 1'bz : 1'b0;
    
    // IIC data buffer
    wire         buf_iic;
    
    wire         buf_we,   buf_wea;
    wire [ 5: 0] buf_addr, buf_addra;
    wire [ 7: 0] buf_din,  buf_dina; 
    reg          buf_web;
    reg  [ 5: 0] buf_addrb;
    reg  [ 7: 0] buf_dinb;
    
    wire [ 7: 0] buf_dout;
    
    reg  [ 7: 0] buffer [63: 0];
    
    assign buf_we   = buf_iic ? buf_wea   : buf_web;
    assign buf_addr = buf_iic ? buf_addra : buf_addrb;
    assign buf_din  = buf_iic ? buf_dina  : buf_dinb;
    assign buf_dout = buffer[buf_addr];
    
    always @(posedge clk) 
        if(buf_we) buffer[buf_addr] = buf_din;
    
    // IIC interface
    reg          iic_en;
    reg          iic_we;
    reg  [15: 0] iic_addr;
    reg  [ 5: 0] iic_len;
    wire         iic_rdy;
    
    iic_interface iic (
        .clk        ( clk       ),
        .rstn       ( rstn      ),
        
        .iic_en     ( iic_en    ),
        .iic_we     ( iic_we    ),
        .iic_addr   ( iic_addr  ),
        .iic_len    ( iic_len   ),
        .iic_rdy    ( iic_rdy   ),
        
        .buf_we     ( buf_wea   ),
        .buf_addr   ( buf_addra ),
        .buf_wdata  ( buf_dina  ),
        .buf_rdata  ( buf_dout  ),
        
        .scl        ( scl       ),
        .sda_o      ( sda_o     ),
        .sda_i      ( sda_i     )
    );
    
    assign buf_iic = iic_en;
    
    
    // BRAM interface (Read Only)
    reg [15:0] bram [15:0];
    
    always @(posedge clk, negedge rstn) begin
        if(!rstn)       bus_rdata <= 0;
        else if(bus_en) bus_rdata <= {16'b0, bram[bus_addr[5:2]]};
    end
    
    // Controller
    reg  [31: 0] dl_cnt;
    
    (*mark_debug="true"*)reg  [ 3: 0] state;
    
    (*mark_debug="true"*)reg  [ 7: 0] status;
    
    parameter RESET_STATE  = 0;
    parameter RELEASE_INT  = 1;
    parameter SOFT_RESET_1 = 2;
    parameter SOFT_RESET_2 = 3;
    parameter GET_STATUS   = 4;
    parameter CHECK_STATUS = 5;
    parameter GET_POINTS   = 6;
    parameter STORE_POINTS = 7;
    parameter CLEAR_STATUS = 8;
    
    integer i;
    
    always @(posedge clk, negedge rstn) begin
        if(!rstn) begin
            state     <= RESET_STATE;
            int_o     <= 1'b1;
            status    <= 0;
            dl_cnt    <= 0;
            
            iic_en    <= 0;
            iic_we    <= 0;
            iic_addr  <= 0;
            iic_len   <= 0;
            
            buf_web   <= 0;
            buf_addrb <= 0;
            buf_dinb  <= 0;
            
            for(i = 0; i < 16; i = i + 1) bram[i] <= 0;
        end
        else begin
            iic_en    <= 0;
            iic_we    <= 0;
            iic_addr  <= 0;
            iic_len   <= 0;
            
            buf_web   <= 0;
            buf_addrb <= 0;
            buf_dinb  <= 0;
            
            case (state)
                RESET_STATE: begin
                    if(dl_cnt < `Delay_5ms)
                        dl_cnt <= dl_cnt + 1;
                    else begin
                        dl_cnt <= 0;
                        state <= RELEASE_INT;
                    end
                end
                
                RELEASE_INT: begin
                    int_o     <= 1'b0;
                    buf_web   <= 1'b1;
                    buf_dinb  <= 8'h02;
                    state <= SOFT_RESET_1;
                end
                
                SOFT_RESET_1: 
                if(!iic_rdy) begin
                    iic_en    <= 1'b1;
                    iic_we    <= 1'b1;
                    iic_addr  <= `TS_Control_Reg;
                    iic_len   <= 6'd1;
                end
                else begin
                    buf_web   <= 1'b1;
                    buf_dinb  <= 8'h00;
                    state <= SOFT_RESET_2;
                end
                
                SOFT_RESET_2: 
                if(!iic_rdy) begin
                    iic_en   <= 1'b1;
                    iic_we   <= 1'b1;
                    iic_addr <= `TS_Control_Reg;
                    iic_len  <= 6'd1;
                end
                else state   <= GET_STATUS;
                
                GET_STATUS: 
                if(!iic_rdy) begin
                    iic_en    <= 1'b1;
                    iic_addr  <= `TS_Status_Reg;
                    iic_len   <= 6'd1;
                end
                else begin
                    state <= CHECK_STATUS;
                end
                
                CHECK_STATUS:
                if(buf_dout[7] != 0) begin
                    status <= buf_dout;
                    state  <= GET_POINTS;
                end
                else begin
                    if(dl_cnt >= `Delay_ClrBuf)
                        bram[0] <= 0;
                    else
                        dl_cnt <= dl_cnt + 1;
                    state   <= GET_STATUS;
                end

                GET_POINTS: 
                if(!iic_rdy) begin
                    iic_en   <= 1'b1;
                    iic_addr <= `TS_Point_Reg;
                    iic_len  <= 6'd40;
                end
                else begin
                    state = STORE_POINTS;
                end
                
                STORE_POINTS: begin
                    bram[ 0] <= {12'b0, status[3:0]};
                    
                    bram[ 1] <= {buffer[ 1], buffer[ 0]};
                    bram[ 2] <= {buffer[ 3], buffer[ 2]};
                    bram[ 3] <= {buffer[ 5], buffer[ 4]};
                    
                    bram[ 4] <= {buffer[ 9], buffer[ 8]};
                    bram[ 5] <= {buffer[11], buffer[10]};
                    bram[ 6] <= {buffer[13], buffer[12]};
                    
                    bram[ 7] <= {buffer[17], buffer[16]};
                    bram[ 8] <= {buffer[19], buffer[18]};
                    bram[ 9] <= {buffer[21], buffer[20]};
                    
                    bram[10] <= {buffer[25], buffer[24]};
                    bram[11] <= {buffer[27], buffer[26]};
                    bram[12] <= {buffer[29], buffer[28]};
                    
                    bram[13] <= {buffer[33], buffer[32]};
                    bram[14] <= {buffer[35], buffer[34]};
                    bram[15] <= {buffer[37], buffer[36]};
                    
                    buf_web  <= 1'b1;
                    buf_dinb <= 8'h00;
                    dl_cnt   <= 0;
                    state    <= CLEAR_STATUS;
                end
                
                CLEAR_STATUS:
                if(!iic_rdy) begin
                    iic_en    <= 1'b1;
                    iic_we    <= 1'b1;
                    iic_addr  <= 16'h814E;
                    iic_len   <= 6'd1;
                end
                else state = GET_STATUS;
                
            endcase
            
        end
    end
    
`endif
endmodule
