module gpu_top (
    input  wire         aclk,
    input  wire         aresetn,

    input  wire [ 3: 0] s_awid,
    input  wire [31: 0] s_awaddr,
    input  wire [ 7: 0] s_awlen,
    input  wire [ 2: 0] s_awsize,
    input  wire [ 1: 0] s_awburst,
    input  wire         s_awlock,
    input  wire [ 3: 0] s_awcache,
    input  wire [ 2: 0] s_awprot,
    input  wire         s_awvalid,
    output wire         s_awready,
    input  wire [ 3: 0] s_wid,
    input  wire [31: 0] s_wdata,
    input  wire [ 3: 0] s_wstrb,
    input  wire         s_wlast,
    input  wire         s_wvalid,
    output wire         s_wready,
    output wire [ 3: 0] s_bid,
    output wire [ 1: 0] s_bresp,
    output wire         s_bvalid,
    input  wire         s_bready,
    input  wire [ 3: 0] s_arid,
    input  wire [31: 0] s_araddr,
    input  wire [ 7: 0] s_arlen,
    input  wire [ 2: 0] s_arsize,
    input  wire [ 1: 0] s_arburst,
    input  wire         s_arlock,
    input  wire [ 3: 0] s_arcache,
    input  wire [ 2: 0] s_arprot,
    input  wire         s_arvalid,
    output wire         s_arready,
    output wire [ 3: 0] s_rid,
    output wire [31: 0] s_rdata,
    output wire [ 1: 0] s_rresp,
    output wire         s_rlast,
    output wire         s_rvalid,
    input  wire         s_rready,
    
    input  wire         lcd_clk,
    output wire         lcd_rst,    // low active
    output wire         lcd_cs,     // low active
    output wire         lcd_rs,
    output wire         lcd_wr,     // low active
    output wire         lcd_rd,     // low active
    inout  wire [15: 0] lcd_data_io,
    output wire         lcd_bl_ctr,
    
    inout  wire         ct_int,
    inout  wire         ct_sda,
    output wire         ct_scl,
    output wire         ct_rstn
);
    
    //Interface
    wire        bus_en;
    wire [ 3:0] bus_wen;
    wire [19:0] bus_addr;
    wire [31:0] bus_rdata;
    wire [31:0] bus_wdata;
    
    gpu_axi_to_bram axi_interface ( 
        .s_axi_aclk       ( aclk          ),      // input  wire s_axi_aclk
        .s_axi_aresetn    ( aresetn       ),      // input  wire s_axi_aresetn
        .s_axi_awid       ( s_awid        ),      // input  wire [3 : 0] s_axi_awid
        .s_axi_awaddr     ( s_awaddr[19:0]),      // input  wire [19 : 0] s_axi_awaddr
        .s_axi_awlen      ( s_awlen       ),      // input  wire [7 : 0] s_axi_awlen
        .s_axi_awsize     ( s_awsize      ),      // input  wire [2 : 0] s_axi_awsize
        .s_axi_awburst    ( s_awburst     ),      // input  wire [1 : 0] s_axi_awburst
        .s_axi_awlock     ( s_awlock      ),      // input  wire s_axi_awlock
        .s_axi_awcache    ( s_awcache     ),      // input  wire [3 : 0] s_axi_awcache
        .s_axi_awprot     ( s_awprot      ),      // input  wire [2 : 0] s_axi_awprot
        .s_axi_awvalid    ( s_awvalid     ),      // input  wire s_axi_awvalid
        .s_axi_awready    ( s_awready     ),      // output wire s_axi_awready
        .s_axi_wdata      ( s_wdata       ),      // input  wire [31 : 0] s_axi_wdata
        .s_axi_wstrb      ( s_wstrb       ),      // input  wire [3 : 0] s_axi_wstrb
        .s_axi_wlast      ( s_wlast       ),      // input  wire s_axi_wlast
        .s_axi_wvalid     ( s_wvalid      ),      // input  wire s_axi_wvalid
        .s_axi_wready     ( s_wready      ),      // output wire s_axi_wready
        .s_axi_bid        ( s_bid         ),      // output wire [3 : 0] s_axi_bid
        .s_axi_bresp      ( s_bresp       ),      // output wire [1 : 0] s_axi_bresp
        .s_axi_bvalid     ( s_bvalid      ),      // output wire s_axi_bvalid
        .s_axi_bready     ( s_bready      ),      // input  wire s_axi_bready
        .s_axi_arid       ( s_arid        ),      // input  wire [3 : 0] s_axi_arid
        .s_axi_araddr     ( s_araddr[19:0]),      // input  wire [19 : 0] s_axi_araddr
        .s_axi_arlen      ( s_arlen       ),      // input  wire [7 : 0] s_axi_arlen
        .s_axi_arsize     ( s_arsize      ),      // input  wire [2 : 0] s_axi_arsize
        .s_axi_arburst    ( s_arburst     ),      // input  wire [1 : 0] s_axi_arburst
        .s_axi_arlock     ( s_arlock      ),      // input  wire s_axi_arlock
        .s_axi_arcache    ( s_arcache     ),      // input  wire [3 : 0] s_axi_arcache
        .s_axi_arprot     ( s_arprot      ),      // input  wire [2 : 0] s_axi_arprot
        .s_axi_arvalid    ( s_arvalid     ),      // input  wire s_axi_arvalid
        .s_axi_arready    ( s_arready     ),      // output wire s_axi_arready
        .s_axi_rid        ( s_rid         ),      // output wire [3 : 0] s_axi_rid
        .s_axi_rdata      ( s_rdata       ),      // output wire [31 : 0] s_axi_rdata
        .s_axi_rresp      ( s_rresp       ),      // output wire [1 : 0] s_axi_rresp
        .s_axi_rlast      ( s_rlast       ),      // output wire s_axi_rlast
        .s_axi_rvalid     ( s_rvalid      ),      // output wire s_axi_rvalid
        .s_axi_rready     ( s_rready      ),      // input  wire s_axi_rready
        
        .bram_en_a        ( bus_en        ),      // output wire bram_en_a
        .bram_we_a        ( bus_wen       ),      // output wire [3 : 0] bram_we_a
        .bram_addr_a      ( bus_addr      ),      // output wire [19 : 0] bram_addr_a
        .bram_wrdata_a    ( bus_wdata     ),      // output wire [31 : 0] bram_wrdata_a
        .bram_rddata_a    ( bus_rdata     )       // input  wire [31 : 0] bram_rddata_a
    );
    
    wire scr_en = bus_en && (bus_addr[19:18] != 2'b11);
    wire cts_en = bus_en && (bus_addr[19:18] == 2'b11);
    
    wire [31:0] scr_rdata;
    wire [31:0] cts_rdata;
    
    reg  cts_rden;
    always @(posedge aclk) cts_rden <= cts_en;
    assign bus_rdata = cts_rden ? cts_rdata : scr_rdata;
    
    // LCD screen module
    lcd_controller lcd_ctrl (
        .clk            ( aclk          ),
        .rstn           ( aresetn       ),
        
        .bus_en         ( scr_en        ),
        .bus_wen        ( bus_wen       ),
        .bus_addr       ( bus_addr      ),
        .bus_rdata      ( scr_rdata     ),
        .bus_wdata      ( bus_wdata     ),
        
        .lcd_rst        ( lcd_rst       ),
        .lcd_cs         ( lcd_cs        ),
        .lcd_rs         ( lcd_rs        ),
        .lcd_wr         ( lcd_wr        ),
        .lcd_rd         ( lcd_rd        ),
        .lcd_data_io    ( lcd_data_io   ),
        .lcd_bl_ctr     ( lcd_bl_ctr    )
    );
    
    //Touchscreen module
    ts_controller ts_ctrl (
        .clk            ( aclk          ),
        .rstn           ( aresetn       ),
        
        .bus_en         ( cts_en        ),
        .bus_wen        ( bus_wen       ),
        .bus_addr       ( bus_addr      ),
        .bus_rdata      ( cts_rdata     ),
        .bus_wdata      ( bus_wdata     ),
        
        .ct_int         ( ct_int        ),
        .ct_sda         ( ct_sda        ),
        .ct_scl         ( ct_scl        ),
        .ct_rstn        ( ct_rstn       )
    );
    
endmodule