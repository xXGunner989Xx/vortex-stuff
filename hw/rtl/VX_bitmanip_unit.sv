`include "VX_define.vh"

module VX_bitmanip_unit #(
    parameter CORE_ID = 0
) (
    input wire              clk,
    input wire              reset,
    
    // Inputs
    VX_bitmanip_req_if.slave     bitmanip_req_if,

    // Outputs
    VX_commit_if.master     bitmanip_commit_if    
);   

    `UNUSED_PARAM (CORE_ID)
    
    reg [`NUM_THREADS-1:0][31:0]  bitmanip_result;    
    wire [`NUM_THREADS-1:0][31:0] orcb_result;   
    wire [`NUM_THREADS-1:0][31:0] rev8_result;   
    wire [`NUM_THREADS-1:0][31:0] ror_result;  // also used for rori
    // wire [`NUM_THREADS-1:0][32:0] rori_result;
    wire [`NUM_THREADS-1:0][31:0] rol_result;

    wire ready_in;    

    `UNUSED_VAR (bitmanip_req_if.op_mod)
    wire [`INST_BITMANIP_BITS-1:0] bitmanip_op = `INST_BITMANIP_BITS'(bitmanip_req_if.op_type);
    // wire                      is_orcb = (bitmanip_op == `INST_BITMANIP_ORCB);
    // wire                      is_rev8 = (bitmanip_op == `INST_BITMANIP_REV8);
    // wire                      is_ror = (bitmanip_op == `INST_BITMANIP_ROR);
    // wire                      is_rori = (bitmanip_op == `INST_BITMANIP_RORI);
    // wire                      is_rol = (bitmanip_op == `INST_BITMANIP_ROL);

    wire [`NUM_THREADS-1:0][31:0] bitmanip_in1 = bitmanip_req_if.rs1_data;
    wire [`NUM_THREADS-1:0][31:0] bitmanip_in2 = bitmanip_req_if.rs2_data;

    wire [`NUM_THREADS-1:0][31:0] bitmanip_in2_imm  = bitmanip_req_if.use_imm ? {`NUM_THREADS{bitmanip_req_if.imm}} : bitmanip_in2;

    // ORCB
    for (genvar i = 0; i < `NUM_THREADS; i++) begin
        assign orcb_result[i] = ((bitmanip_in1[i] & 32'hFF) != 32'b0 ? 32'hff : 0) | (((bitmanip_in1[i] >> 8) & 32'hff) != 32'b0 ? (32'hff << 8) : 0)
        | (((bitmanip_in1[i] >> 16) & 32'hff) != 32'b0 ? (32'hff << 16) : 0) | (((bitmanip_in1[i] >> 24) & 32'hff) != 32'b0 ? (32'hff << 24) : 0);
    end

    // REV8
    wire [`NUM_THREADS-1:0][31:0] intermediate_rev8_result;
    for (genvar i = 0; i < `NUM_THREADS; i++) begin
        assign intermediate_rev8_result[i] = ((bitmanip_in1[i] & 32'h00FF00FF) <<  8) | ((bitmanip_in1[i] & 32'hFF00FF00) >>  8);
        assign rev8_result[i] = ((intermediate_rev8_result[i] & 32'h0000FFFF) << 16) | ((intermediate_rev8_result[i] & 32'hFFFF0000) >> 16);
    end

    // ROL
    for (genvar i = 0; i < `NUM_THREADS; i++) begin    
        assign rol_result[i] = (bitmanip_in1[i] << bitmanip_in2_imm[i][4:0] | bitmanip_in1[i] >> (`XLEN - bitmanip_in2_imm[i][4:0]));
    end      

    // ROR & RORI
    for (genvar i = 0; i < `NUM_THREADS; i++) begin    
        assign ror_result[i] = (bitmanip_in1[i] >> bitmanip_in2_imm[i][4:0] | bitmanip_in1[i] << (`XLEN - bitmanip_in2_imm[i][4:0]));
    end      


    for (genvar i = 0; i < `NUM_THREADS; i++) begin 
        always @(*) begin
            case (bitmanip_op)
                `INST_BITMANIP_ORCB: bitmanip_result[i] = orcb_result[i];
                `INST_BITMANIP_REV8: bitmanip_result[i] = rev8_result[i];
                `INST_BITMANIP_ROL: bitmanip_result[i] = rol_result[i];
                // `INST_BITMANIP_ROR: bitmanip_result[i] = ror_result[i];
                // `INST_BITMANIP_RORI: bitmanip_result[i] = ror_result[i];
                default: bitmanip_result[i] = ror_result[i];   // assume ROR or RORI if default        
            endcase
        end
    end

    // output

    wire                          bitmanip_valid_in;
    wire                          bitmanip_ready_in;
    wire                          bitmanip_valid_out;
    wire                          bitmanip_ready_out;
    wire [`UUID_BITS-1:0]         bitmanip_uuid;
    wire [`NW_BITS-1:0]           bitmanip_wid;
    wire [`NUM_THREADS-1:0]       bitmanip_tmask;
    wire [31:0]                   bitmanip_PC;
    wire [`NR_BITS-1:0]           bitmanip_rd;   
    wire                          bitmanip_wb; 
    wire [`NUM_THREADS-1:0][31:0] bitmanip_data;

    assign bitmanip_ready_in = bitmanip_ready_out || ~bitmanip_valid_out;

    VX_pipe_register #(
        .DATAW  (1 + `UUID_BITS + `NW_BITS + `NUM_THREADS + 32 + `NR_BITS + 1 + (32 * `NUM_THREADS)),
        .RESETW (1)
    ) pipe_reg (
        .clk      (clk),
        .reset    (reset),
        .enable   (bitmanip_ready_in),
        .data_in  ({bitmanip_valid_in,  bitmanip_req_if.uuid, bitmanip_req_if.wid, bitmanip_req_if.tmask, bitmanip_req_if.PC, bitmanip_req_if.rd, bitmanip_req_if.wb, bitmanip_result}),
        .data_out ({bitmanip_valid_out, bitmanip_uuid,        bitmanip_wid,        bitmanip_tmask,        bitmanip_PC,        bitmanip_rd,        bitmanip_wb,        bitmanip_data})
    );

    assign ready_in = bitmanip_ready_in;

    assign bitmanip_valid_in = bitmanip_req_if.valid;

    assign bitmanip_commit_if.valid = bitmanip_valid_out;
    assign bitmanip_commit_if.uuid  = bitmanip_uuid;
    assign bitmanip_commit_if.wid   = bitmanip_wid;
    assign bitmanip_commit_if.tmask = bitmanip_tmask;
    assign bitmanip_commit_if.PC    = bitmanip_PC; 
    assign bitmanip_commit_if.rd    = bitmanip_rd;    
    assign bitmanip_commit_if.wb    = bitmanip_wb;
    assign bitmanip_commit_if.data  = bitmanip_data;

    assign bitmanip_ready_out = bitmanip_commit_if.ready;

    assign bitmanip_commit_if.eop = 1'b1;

    // can accept new request?
    assign bitmanip_req_if.ready = ready_in;

// `ifdef DBG_TRACE_CORE_PIPELINE
//     always @(posedge clk) begin
//         if (branch_ctl_if.valid) begin
//             dpi_trace("%d: core%0d-branch: wid=%0d, PC=%0h, taken=%b, dest=%0h (#%0d)\n", 
//                 $time, CORE_ID, branch_ctl_if.wid, bitmanip_commit_if.PC, branch_ctl_if.taken, branch_ctl_if.dest, bitmanip_uuid);
//         end
//     end
// `endif

endmodule