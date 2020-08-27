// ------------------------ Disclaimer -----------------------
// No warranty of correctness, synthesizability or 
// functionality of this code is given.
// Use this code under your own risk.
// When using this code, copy this disclaimer at the top of 
// Your file
//
// (c) Luca Hanel 2020
//
// ------------------------------------------------------------
//
// Module name: apb_bar
// 
// Functionality: Interconnect for APB bus
//                Each slave as 2**APB_ACT_ADDR_W words of memory
//                assigned.
//
//                !!! IMPORTANT !!!
//                The slaves are selected by the $clog2(N_SLAVES)
//                bits right above the APB_ACT_ADDR_W bits in
//                PADDR. Those bits aren't sent to the slaves.
//
// Tests: 
//
// ------------------------------------------------------------

`ifndef APB_BUS_SV
`include "apb_intf.sv"
`endif

module apb_bar#(
  parameter                             APB_DATA_WIDTH  = 32,
  parameter                             APB_ADDR_WIDTH  = 32,
  parameter                             APB_ACT_ADDR_W  = 12,
  parameter                             N_SLAVES
)(
  apb_bus_t.slave           slave_port,
  apb_bus_t.master          master_port[N_SLAVES]
);

logic [APB_ADDR_WIDTH-1:0]  PADDR;
logic [APB_DATA_WIDTH-1:0]  PRDATA;
logic                       PREADY;
logic                       PSLVERR;
logic [N_SLAVES-1:0]        PSEL;

logic [APB_DATA_WIDTH-1:0]  PRDATA_i[N_SLAVES];
logic                       PREADY_i[N_SLAVES];
logic                       PSLVERR_i[N_SLAVES];
logic [$clog2(N_SLAVES)-1:0] slave_sel;

// Assign the signals to the slaves
for(genvar ii = 0; ii < N_SLAVES; ii = ii + 1) begin
  assign master_port[ii].PCLK     = slave_port.PCLK;
  assign master_port[ii].PRESETn  = slave_port.PRESETn;
  assign master_port[ii].PSEL     = PSEL[ii];
  assign master_port[ii].PADDR    = PADDR;
  assign master_port[ii].PWRITE   = slave_port.PWRITE;
  assign master_port[ii].PWDATA   = slave_port.PWDATA;
  assign master_port[ii].PENABLE  = slave_port.PENABLE;
  assign PRDATA_i[ii] = master_port[ii].PRDATA;
  assign PREADY_i[ii] = master_port[ii].PREADY;
  assign PSLVERR_i[ii] = master_port[ii].PSLVERR;
end

// Assign the signals to the master
assign slave_port.PRDATA  = PRDATA;
assign slave_port.PREADY  = PREADY;
assign slave_port.PSLVERR = PSLVERR;

// slave select
assign slave_sel = slave_port.PADDR[APB_ACT_ADDR_W+$clog2(N_SLAVES)-1:APB_ACT_ADDR_W];

// slave arbiter
always_comb
begin
  PSEL    = 'b0;
  PADDR   = 'b0;
  PRDATA  = 'b0;
  PREADY  = 'b0;
  PSLVERR = 'b0;

  if(slave_port.PSEL) begin
    PSEL[slave_sel]           = 1'b1;
    PRDATA                    = PRDATA_i[slave_sel];
    PREADY                    = PREADY_i[slave_sel];
    PSLVERR                   = PSLVERR_i[slave_sel];
    PADDR[APB_ACT_ADDR_W-1:0] = slave_port.PADDR[APB_ACT_ADDR_W-1:0];
  end
end

endmodule