`ifndef VX_BITMANIP_REQ_IF
`define VX_BITMANIP_REQ_IF

`include "VX_define.vh"

interface VX_bitmanip_req_if ();

    wire                    valid;  
    wire [`UUID_BITS-1:0]   uuid; 
    wire [`NW_BITS-1:0]     wid;
    wire [`NUM_THREADS-1:0] tmask;
    wire [31:0]             PC;
    wire [`INST_BITMANIP_BITS-1:0] op_type;
    wire [`INST_MOD_BITS-1:0] op_mod;
    wire                    use_imm;
    wire [31:0]             imm;
    wire [`NUM_THREADS-1:0][31:0] rs1_data;
    wire [`NUM_THREADS-1:0][31:0] rs2_data;
    wire [`NR_BITS-1:0]     rd;
    wire                    wb;    
    wire                    ready;

    modport master (
        output valid,
        output uuid,
        output wid,
        output tmask,
        output PC,
        output op_type,
        output op_mod,
        output use_imm,
        output imm,
        output rs1_data,
        output rs2_data,
        output rd,
        output wb,    
        input  ready
    );

    modport slave (
        input  valid,
        input  uuid,
        input  wid,
        input  tmask,
        input  PC,
        input  op_type,
        input  op_mod,
        input  use_imm,
        input  imm,
        input  rs1_data,
        input  rs2_data,
        input  rd,
        input  wb,    
        output ready
    );

endinterface

`endif