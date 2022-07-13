module riscV32I(
    output [31:0] WB_o,
    input  [31:0] inst_data, 
    input  [6:0]  inst_addr, 
    input  clk, rst, inst_wen, enb
);

reg [8:0] PC;
wire [31:0] Imm, instruction, WB, DataA, DataB, WB_cut;
wire [31:0] DMEM, WB_Half, WB_Byte;
wire PCsel, RegWEn, BrUn, ASel, BSel, MemRW, BrEq, BrLT;
wire [1:0]  WBSel;
wire [2:0]  ImmSel, WordSizeSel;
wire [3:0]  ALUSel;

wire [8:0] PC_Next;
wire [8:0] PCp4 = PC + 7'd4;

wire [31:0] ALU_o, ALU_A, ALU_B;

assign PC_Next = PCsel ? ALU_o : PCp4;
assign ALU_A = ASel ? PC : DataA;
assign ALU_B = BSel ? Imm : DataB;

assign WB = (WBSel == 2'd2) ? PCp4 : ((WBSel == 2'd1) ? ALU_o : DMEM);
assign WB_Half = WordSizeSel[2] ? {16'b0, WB[15:0]} : {{16{WB[15]}}, WB[15:0]};
assign WB_Byte = WordSizeSel[2] ? {24'b0, WB[7:0]}  : {{24{WB[7]}},  WB[7:0]};
assign WB_cut = (WordSizeSel[1:0] == 2'b0) ? WB_Byte : ((WordSizeSel[1:0] == 2'b1) ? WB_Half : WB);

inst_mem IMEM(.inst(instruction),
    .inst_data(inst_data),
    .PC(PC[8 -: 7]), .inst_addr(inst_addr),
    .clk(clk), .rst(rst), .inst_wen(inst_wen)
);

register_file REGFILE(
    .RD1(DataA), .RD2(DataB),   
    .RR1(instruction[19:15]), .RR2(instruction[24:20]), .WR(instruction[11:7]),
    .WD(WB_cut),         
    .RegWrite(RegWEn), .clk(clk), .rst(rst)
);

BranchComp BrCOMP(
    .BrEq(BrEq), .BrLT(BrLT),
    .RD1(DataA), .RD2(DataB), 
    .BrUn(BrUn)
);

ImmGen IMMGEN(
    .Imm(Imm),
    .inst_Imm(instruction[31:7]),
    .ImmSel(ImmSel)
);

data_mem DATAMEM(
    .ReadData(DMEM),
    .ADDR(ALU_o), .WriteData(DataB),
    .clk(clk), .rst(rst), .MemWrite(MemRW)
);

control CTRL(
    .PCsel(PCsel), .RegWEn(RegWEn), .BrUn(BrUn),
    .ImmSel(ImmSel), .WordSizeSel(WordSizeSel),
    .BSel(BSel), .ASel(ASel), .MemRW(MemRW), 
    .ALUSel(ALUSel),
    .WBSel(WBSel),
    .instruction(instruction), 
    .BrEq(BrEq), .BrLT(BrLT)
);

ALU ALU_riscV(
    .ALU_o(ALU_o),
    .A(ALU_A), .B(ALU_B), .ALUSel(ALUSel)
);

always @ (posedge clk) begin
    if (rst) begin
        PC <= 9'b0;
    end
    else if (enb) begin
        PC <= PC_Next;
    end
end

endmodule