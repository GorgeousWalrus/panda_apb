/* verilator lint_off DECLFILENAME */
/* verilator lint_off MODDUP */
`ifndef APB_BUS_SV
`define APB_BUS_SV

interface apb_bus_t #(
  parameter DATA_WIDTH = 32,
  parameter ADDR_WIDTH = 32
  );

  logic                   PCLK;       // Clock
  logic                   PRESETn;    // Active low reset
  logic [ADDR_WIDTH-1:0]  PADDR;      // Address
  logic                   PSELx;      // Slave select
  logic                   PENABLE;    // Enable signal
  logic                   PWRITE;     // Write enable (low=read)
  logic [DATA_WIDTH-1:0]  PWDATA;     // Data to be written (master->slave)
  logic                   PREADY;     // Slave is ready
  logic                   PRDATA;     // Data read (slave->master)
  logic                   PSLVERR;    // Slave encountered error. If not used, tie to low

  modport master (
      input PREADY, PRDATA, PSLVERR,
      output PCLK, PRESETn, PADDR, PSELx, PENABLE, PWRITE, PWDATA
  );

  modport slave (
      input PCLK, PRESETn, PADDR, PSELx, PENABLE, PWRITE, PWDATA,
      output PREADY, PRDATA, PSLVERR
  );
endinterface //apb_bus_t

`endif
/* verilator lint_on DECLFILENAME */