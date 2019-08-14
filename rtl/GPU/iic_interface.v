`define     IIC_Cycle       700
`define     ClkCnt          10:0       

module iic_interface (
    input  wire         clk,
    input  wire         rstn,
    
    input  wire         iic_en,
    input  wire         iic_we,
    input  wire [15: 0] iic_addr,
    input  wire [ 5: 0] iic_len,
    output reg          iic_rdy,
    
    output reg          buf_we,
    output reg  [ 5: 0] buf_addr,
    output reg  [ 7: 0] buf_wdata,
    input  wire [ 7: 0] buf_rdata,
    
    output reg          scl,
    output reg          sda_o,
    input  wire         sda_i
);
    
    //iic_clock
    reg [`ClkCnt] clk_cnt;
    wire          sda_tck = clk_cnt == 0;
    
    //assign scl =  clk_cnt == `IIC_Cycle >> 1);
    
    always @(posedge clk, negedge rstn) begin
        if(!rstn) begin
            clk_cnt <= 0;
            scl     <= 1'b1;
        end
        else begin
            clk_cnt <= clk_cnt == `IIC_Cycle -  1 ? 0    : clk_cnt + 1; 
            if(iic_en) 
                scl <= clk_cnt == `IIC_Cycle >> 1 ? ~scl : scl;
            else
                scl <= 1'b1;
        end
    end
    
    (*mark_debug="true"*)reg  [31: 0] state;
    reg  [ 7: 0] temp;
    reg  [ 3: 0] bcnt;
    
    parameter INIT_STATE     = 0;
    parameter SEND_WCMD      = 1;
    parameter GET_WCMD_ACK   = 2;
    parameter SEND_HIADDR    = 3;
    parameter GET_HIADDR_ACK = 4;
    parameter SEND_LOADDR    = 5;
    parameter GET_LOADDR_ACK = 6;
    parameter SEND_RD_START  = 7;
    parameter SEND_RCMD      = 8;
    parameter GET_RCMD_ACK   = 9;
    parameter GET_RDATA      = 10;
    parameter SEND_RDATA_ACK = 11;
    parameter END_SEND_ACK   = 12;
    parameter SEND_WDATA     = 13;
    parameter GET_WDATA_ACK  = 14;
    parameter SEND_STOP_LO   = 15;
    parameter SEND_STOP_HI   = 16;
    parameter DELAY_STATE    = 17;
    
    always @(posedge clk, negedge rstn) begin
        if(!rstn) begin
            state     <= INIT_STATE;
            temp      <= 0;
            sda_o     <= 1;
            iic_rdy   <= 0;
            bcnt      <= 0;
            
            buf_we    <= 0;
            buf_addr  <= 0;
            buf_wdata <= 0;
        end
        else begin
            buf_we   <= 1'b0;
            iic_rdy  <= 1'b0;
            
            if(sda_tck) begin
                case (state)
                    INIT_STATE: if(iic_en && scl) begin
                        sda_o    <= 1'b0;
                        bcnt     <= 0;
                        temp     <= 8'h28;
                        buf_addr <= 6'd0;
                        state <= SEND_WCMD;
                    end
                    
                    SEND_WCMD: if(!scl) begin
                        if(bcnt < 8) begin
                            sda_o <= temp[7];
                            temp  <= {temp[6:0], temp[7]};
                            bcnt  <= bcnt + 1;
                        end
                        else begin
                            sda_o <= 1'b1;
                            bcnt  <= 0;
                            state <= GET_WCMD_ACK;
                        end
                    end
                    
                    GET_WCMD_ACK: if(scl) begin
                        if(sda_i == 1'b0) begin
                            temp  <= iic_addr[15:8];
                            state <= SEND_HIADDR;
                        end
                        else state <= INIT_STATE;
                    end
                    
                    SEND_HIADDR: if(!scl) begin
                        if(bcnt < 8) begin
                            sda_o <= temp[7];
                            temp  <= {temp[6:0], temp[7]};
                            bcnt  <= bcnt + 1;
                        end
                        else begin
                            sda_o <= 1'b1;
                            bcnt  <= 0;
                            state <= GET_HIADDR_ACK;
                        end
                    end
                    
                    GET_HIADDR_ACK: if(scl) begin
                        if(sda_i == 1'b0) begin
                            temp  <= iic_addr[7:0];
                            state <= SEND_LOADDR;
                        end
                        else state <= INIT_STATE;
                    end
                    
                    SEND_LOADDR: if(!scl) begin
                        if(bcnt < 8) begin
                            sda_o <= temp[7];
                            temp  <= {temp[6:0], temp[7]};
                            bcnt  <= bcnt + 1;
                        end
                        else begin
                            sda_o <= 1'b1;
                            bcnt  <= 0;
                            state <= GET_LOADDR_ACK;
                        end
                    end
                    
                    GET_LOADDR_ACK: if(scl) begin
                        if(sda_i == 1'b0) begin
                            if(iic_we) begin
                                temp  <= buf_rdata;
                                state <= SEND_WDATA;
                            end
                            else state <= SEND_RD_START;
                        end
                        else state <= INIT_STATE;
                    end
                    
                    
                    // Read operationn branch
                    SEND_RD_START: if(scl) begin
                        sda_o <= 1'b0;
                        temp  <= 8'h29;
                        state <= SEND_RCMD;
                    end
                    
                    SEND_RCMD: if(!scl) begin
                        if(bcnt < 8) begin
                            sda_o <= temp[7];
                            temp  <= {temp[6:0], temp[7]};
                            bcnt  <= bcnt + 1;
                        end
                        else begin
                            sda_o <= 1'b1;
                            bcnt  <= 0;
                            state <= GET_RCMD_ACK;
                        end
                    end
                    
                    GET_RCMD_ACK: if(scl) begin
                        if(sda_i == 1'b0) begin
                            state <= GET_RDATA;
                        end
                        else state <= INIT_STATE;
                    end
                    
                    GET_RDATA: if(scl) begin
                        temp <= {temp[6:0], sda_i};
                        if(bcnt < 7) bcnt <= bcnt + 1;
                        else begin
                            bcnt  <= 0;
                            state <= SEND_RDATA_ACK;
                        end
                    end
                    
                    SEND_RDATA_ACK: if(!scl) begin
                        buf_we    <= 1'b1;
                        buf_wdata <= temp;
                        if(buf_addr >= iic_len - 1) begin
                            sda_o    <= 1'b1;  //NACK
                            state    <= SEND_STOP_LO;
                        end
                        else begin
                            sda_o    <= 1'b0;  //ACK
                            state    <= END_SEND_ACK;
                        end
                    end
                    
                    END_SEND_ACK: if(!scl) begin
                        sda_o <= 1'b1;
                        buf_addr <= buf_addr + 1;
                        state    <= GET_RDATA;
                    end
                    
                    //Write operation branch
                    SEND_WDATA: if(!scl) begin
                        if(bcnt < 8) begin
                            sda_o    <= temp[7];
                            temp     <= {temp[6:0], temp[7]};
                            bcnt     <= bcnt + 1;
                        end
                        else begin
                            sda_o    <= 1'b1;
                            bcnt     <= 0;
                            buf_addr <= buf_addr + 1;
                            state    <= GET_WDATA_ACK;
                        end
                    end
                    
                    GET_WDATA_ACK: if(scl) begin
                        if(sda_i == 1'b0) begin
                            if(buf_addr >= iic_len) begin
                                state <= SEND_STOP_LO;
                            end
                            else begin
                                temp  <= buf_rdata;
                                state <= SEND_WDATA;
                            end
                        end
                        else state <= INIT_STATE;
                    end
                    
                    SEND_STOP_LO: if(!scl) begin
                        sda_o <= 1'b0;
                        state <= SEND_STOP_HI;
                    end
                    
                    SEND_STOP_HI: if(scl) begin
                        sda_o   <= 1'b1;
                        iic_rdy <= 1'b1;
                        state   <= DELAY_STATE;
                    end
                    
                    DELAY_STATE: state <= INIT_STATE;
                endcase
            end
        end
    end
endmodule