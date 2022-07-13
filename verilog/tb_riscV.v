`timescale 1ns/1ps

module tb_riscV();

reg clk, rst, inst_wen, enb;
reg [31:0] inst_data;
reg [6:0] inst_addr;
wire [31:0] WB_o;

initial begin
    rst = 1;
    clk = 1;
    enb = 0;
    inst_wen = 0;
    inst_addr = 0;
    inst_data = 0;
    #11
    rst = 0;
    #10
    enb = 1;
    $readmemh("../machine code/code2.txt", TEST.IMEM.inst_reg);
    #3569
    $display("%32h", {TEST.DATAMEM.MEM_Data[87], TEST.DATAMEM.MEM_Data[86], TEST.DATAMEM.MEM_Data[85], TEST.DATAMEM.MEM_Data[84]});
    // $display("%32h", TEST.DATAMEM.MEM_Data[88]);
    // $display("%32h", TEST.DATAMEM.MEM_Data[56]);
    // $display("%32h", TEST.DATAMEM.MEM_Data[57]);
end

riscV32I TEST(
    WB_o, inst_data, inst_addr, clk, rst, inst_wen, enb
);

always #5 clk <= ~clk;

endmodule