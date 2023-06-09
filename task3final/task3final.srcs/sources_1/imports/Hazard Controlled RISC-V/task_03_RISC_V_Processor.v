module RISC_V_Processor_3
(
    clk, reset,
    element1,element2,element3,element4,element5,element6,
    r1,r2,r3,r4,r5
);
input clk,reset;
output wire [63:0] r1,r2,r3,r4,r5;
output wire [63:0] element1,element2,element3,element4,element5,element6;
wire [63:0] PC_to_IM;
wire [31:0] IM_to_IFID;
wire [6:0] opcode_out; 
wire[4:0] rd_out;
wire [2:0] funct3_out;
wire [6:0] funct7_out;
wire [4:0] rs1_out, rs2_out;
wire Branch_out, MemRead_out, MemtoReg_out, MemWrite_out, ALUSrc_out, RegWrite_out;
wire Is_Greater_out;
wire [1:0] ALUOp_out;
wire [63:0] mux_to_reg;
wire [63:0] mux_to_pc_in;
wire [3:0] ALU_C_Operation;
wire [63:0] ReadData1_out, ReadData2_out;
wire [63:0] imm_data_out;



wire [63:0] fixed_4 = 64'd4;
wire [63:0] PC_plus_4_to_mux;

wire [63:0] alu_mux_out;

wire [63:0] alu_result_out;
wire zero_out;

wire [63:0] imm_to_adder;
wire [63:0] imm_adder_to_mux;

wire [63:0] DM_Read_Data_out;

wire pc_mux_sel_wire;
wire PCWrite_out;


wire IDEX_Branch_out, IDEX_MemRead_out, IDEX_MemtoReg_out,
IDEX_MemWrite_out, IDEX_ALUSrc_out, IDEX_RegWrite_out;

//IDEX WIRES
wire [63:0] IDEX_PC_addr, IDEX_ReadData1_out, IDEX_ReadData2_out,
            IDEX_imm_data_out;
wire [3:0] IDEX_funct_in;
wire [4:0] IDEX_rd_out, IDEX_rs1_out, IDEX_rs2_out;
wire [1:0] IDEX_ALUOp_out;

assign imm_to_adder = IDEX_imm_data_out<< 1;


//EXMEM WIRES
wire EXMEM_Branch_out, EXMEM_MemRead_out, EXMEM_MemtoReg_out,
EXMEM_MemWrite_out, EXMEM_RegWrite_out; 
wire EXMEM_zero_out, EXMEM_Is_Greater_out;
wire [63:0] EXMEM_PC_plus_imm, EXMEM_alu_result_out,
    EXMEM_ReadData2_out;
wire [3:0] EXMEM_funct_in;
wire [4:0] EXMEM_rd_out;
wire Flush_out;

//MEMWB WIRES
wire MEMWB_MemtoReg_out, MEMWB_RegWrite_out;
wire [63:0] MEMWB_DM_Read_Data_out, MEMWB_alu_result_out;
wire [4:0] MEMWB_rd_out;


mux_3 pcsrcmux
(
    .a(EXMEM_PC_plus_imm),   //value when sel is 1
    .b(PC_plus_4_to_mux),
    .sel(pc_mux_sel_wire),
    .data_out(mux_to_pc_in)
);

Program_Counter_3 PC (
    .clk(clk),
    .reset(reset),
    .PCWrite(PCWrite_out),
    .PC_In(mux_to_pc_in),
    .PC_Out(PC_to_IM)
);

Adder_3 pcadder
(
    .A(PC_to_IM),
    .B(fixed_4),
    .out(PC_plus_4_to_mux)
);

Instruction_Memory_3 insmem
(
    .Inst_Address(PC_to_IM),
    .Instruction(IM_to_IFID)
);

wire [63:0] IFID_PC_addr;
wire [31:0] IFID_IM_to_parse;
wire IFID_Write_out;


IF_ID_3 IFIDreg
(
    .clk(clk),
    .Flush(Flush_out),
    .IFID_Write(IFID_Write_out),
    .PC_addr(PC_to_IM),
    .Instruc(IM_to_IFID),
    .PC_store(IFID_PC_addr),
    .Instr_store(IFID_IM_to_parse)
);
//IF_ID HERE

wire control_mux_sel;

Hazard_Detection_3 hazarddetectionunit
(
    .IDEX_rd(IDEX_rd_out),
    .IFID_rs1(rs1_out),
    .IFID_rs2(rs2_out),
    .IDEX_MemRead(IDEX_MemRead_out),
    .IDEX_mux_out(control_mux_sel),
    .IFID_Write(IFID_Write_out),
    .PCWrite(PCWrite_out)
);



instruc_parse_3 insparser
(
    .instruc(IFID_IM_to_parse),
    .opcode(opcode_out),
    .rd(rd_out),
    .funct3(funct3_out),
    .rs1(rs1_out),
    .rs2(rs2_out),
    .funct7(funct7_out)
);

wire [3:0] funct_in;
assign funct_in = {IFID_IM_to_parse[30],IFID_IM_to_parse[14:12]};
//assign [63:0] nop_to_mux = 64'd0;

Control_Unit_3 cunit
(
    .Opcode(opcode_out),
    .Branch(Branch_out), 
    .MemRead(MemRead_out), 
    .MemtoReg(MemtoReg_out),
    .MemWrite(MemWrite_out), 
    .ALUSrc(ALUSrc_out),
    .RegWrite(RegWrite_out),
    .ALUOp(ALUOp_out)
);

registerFile_3 registerfile
(
    .clk(clk),
    .reset(reset),
    .RegWrite(MEMWB_RegWrite_out), //change
    .WriteData(mux_to_reg),//??
    .RS1(rs1_out),
    .RS2(rs2_out),
    .RD(MEMWB_rd_out),    //??
    .ReadData1(ReadData1_out),
    .ReadData2(ReadData2_out),
    .r1(r1),
    .r2(r2),
    .r3(r3),
    .r4(r4),
    .r5(r5)
);


imm_data_ext_3 immgen
(
    .instruc(IFID_IM_to_parse),
    .imm_data(imm_data_out)
);

assign MemtoReg_IDEXin = control_mux_sel ? MemtoReg_out : 0;
assign RegWrite_IDEXin = control_mux_sel ? RegWrite_out : 0;
assign Branch_IDEXin = control_mux_sel ? Branch_out : 0;
assign MemWrite_IDEXin = control_mux_sel ? MemWrite_out : 0;
assign MemRead_IDEXin = control_mux_sel ? MemRead_out : 0;
assign ALUSrc_IDEXin = control_mux_sel ? ALUSrc_out : 0;
wire [1:0] ALUop_IDEXin;
assign ALUop_IDEXin = control_mux_sel ? ALUOp_out : 2'b00;


ID_EX_3 ID_EX1
(
    .clk(clk),
    .Flush(Flush_out),
    .PC_addr(IFID_PC_addr),
    .read_data1(ReadData1_out),
    .read_data2(ReadData2_out),
    .imm_val(imm_data_out),
    .funct_in(funct_in),
    .rd_in(rd_out),
    .rs1_in(rs1_out),
    .rs2_in(rs2_out),
    .RegWrite(RegWrite_IDEXin),
    .MemtoReg(MemtoReg_IDEXin),
    .Branch(Branch_IDEXin),
    .MemWrite(MemWrite_IDEXin),
    .MemRead(MemRead_IDEXin),
    .ALUSrc(ALUSrc_IDEXin),
    .ALU_op(ALUop_IDEXin),

    .PC_addr_store(IDEX_PC_addr),
    .read_data1_store(IDEX_ReadData1_out),
    .read_data2_store(IDEX_ReadData2_out),
    .imm_val_store(IDEX_imm_data_out),
    .funct_in_store(IDEX_funct_in),
    .rd_in_store(IDEX_rd_out),
    .rs1_in_store(IDEX_rs1_out),
    .rs2_in_store(IDEX_rs2_out),
    .RegWrite_store(IDEX_RegWrite_out),
    .MemtoReg_store(IDEX_MemtoReg_out),
    .Branch_store(IDEX_Branch_out),
    .MemWrite_store(IDEX_MemWrite_out),
    .MemRead_store(IDEX_MemRead_out),
    .ALUSrc_store(IDEX_ALUSrc_out),
    .ALU_op_store(IDEX_ALUOp_out)

);
// ID/EX HERE

ALU_Control_3 ALU_Control1
(
    .ALUOp(IDEX_ALUOp_out),
    .Funct(IDEX_funct_in),
    .Operation(ALU_C_Operation)
);

wire [1:0] fwd_A_out, fwd_B_out;

wire [63:0] triplemux_to_a, triplemux_to_b;

mux_3 ALU_mux
(
    .a(IDEX_imm_data_out), //value when sel is 1
    .b(triplemux_to_b),
    .sel(IDEX_ALUSrc_out),
    .data_out(alu_mux_out)
);



mux_triple_3 mux_for_a
(
    .a(IDEX_ReadData1_out), //00
    .b(mux_to_reg), //01
    .c(EXMEM_alu_result_out),   //10
    .sel(fwd_A_out),
    .data_out(triplemux_to_a)  
);

mux_triple_3 mux_for_b
(
    .a(IDEX_ReadData2_out), //00
    .b(mux_to_reg), //01
    .c(EXMEM_alu_result_out),   //10
    .sel(fwd_B_out),
    .data_out(triplemux_to_b)  
);

ALU_64_bit_3 ALU64
(
    .a(triplemux_to_a),
    .b(alu_mux_out), 
    .ALUOp(ALU_C_Operation),
    .Result(alu_result_out),
    .Zero(zero_out),
    .Is_Greater(Is_Greater_out)
);



Forwarding_Unit_3 Fwd_unit
(
    .EXMEM_rd(EXMEM_rd_out),
    .MEMWB_rd(MEMWB_rd_out),
    .IDEX_rs1(IDEX_rs1_out),
    .IDEX_rs2(IDEX_rs2_out),
    .EXMEM_RegWrite(EXMEM_RegWrite_out),
    .EXMEM_MemtoReg(EXMEM_MemtoReg_out),
    .MEMWB_RegWrite(MEMWB_RegWrite_out),
    .fwd_A(fwd_A_out),
    .fwd_B(fwd_B_out)
);


wire [63:0] pcplusimm_to_EXMEM;

Adder_3 PC_plus_imm
(
    .A(IDEX_PC_addr),
    .B(imm_to_adder),
    .out(pcplusimm_to_EXMEM) //
);

EX_MEM_3 EX_MEM1
(
    .clk(clk),
    .Flush(Flush_out),
    .RegWrite(IDEX_RegWrite_out),
    .MemtoReg(IDEX_MemtoReg_out),
    .Branch(IDEX_Branch_out),
    .Zero(zero_out),
    .Is_Greater(Is_Greater_out),
    .MemWrite(IDEX_MemWrite_out),
    .MemRead(IDEX_MemRead_out),
    .PCplusimm(pcplusimm_to_EXMEM),
    .ALU_result(alu_result_out),
    .WriteData(triplemux_to_b),
    .funct_in(IDEX_funct_in),
    .rd(IDEX_rd_out),

    .RegWrite_store(EXMEM_RegWrite_out),
    .MemtoReg_store(EXMEM_MemtoReg_out),
    .Branch_store(EXMEM_Branch_out),
    .Zero_store(EXMEM_zero_out),
    .Is_Greater_store(EXMEM_Is_Greater_out),
    .MemWrite_store(EXMEM_MemWrite_out),
    .MemRead_store(EXMEM_MemRead_out),
    .PCplusimm_store(EXMEM_PC_plus_imm),
    .ALU_result_store(EXMEM_alu_result_out),
    .WriteData_store(EXMEM_ReadData2_out),
    .funct_in_store(EXMEM_funct_in),
    .rd_store(EXMEM_rd_out)
);

// EX/MEM HERE

Branch_Control_3 Branch_Control
(
    .Branch(EXMEM_Branch_out),
    .Flush(Flush_out),
    .Zero(EXMEM_zero_out),
    .Is_Greater(EXMEM_Is_Greater_out),
    .funct(EXMEM_funct_in),
    .switch_branch(pc_mux_sel_wire)
);


Data_Memory dm
(
	EXMEM_alu_result_out,
	EXMEM_ReadData2_out,
	clk,EXMEM_MemWrite_out,EXMEM_MemRead_out,
	DM_Read_Data_out
, 
element1,
element2,
 element3,
element4,
element5,
element6
);



MEM_WB_3 MEM_WB1
(
    .clk(clk),
    .RegWrite(EXMEM_RegWrite_out),
    .MemtoReg(EXMEM_MemtoReg_out),
    .ReadData(DM_Read_Data_out),
    .ALU_result(EXMEM_alu_result_out),
    .rd(EXMEM_rd_out),

    .RegWrite_store(MEMWB_RegWrite_out),
    .MemtoReg_store(MEMWB_MemtoReg_out),
    .ReadData_store(MEMWB_DM_Read_Data_out),
    .ALU_result_store(MEMWB_alu_result_out),
    .rd_store(MEMWB_rd_out)
);

// MEM/WB HERE

mux_3 mux2
(
    .a(MEMWB_DM_Read_Data_out), //value when sel is 1
    .b(MEMWB_alu_result_out),
    .sel(MEMWB_MemtoReg_out),
    .data_out(mux_to_reg)
);




// always @(posedge clk) 
//     begin
//         $monitor("PC_In = ", mux_to_pc_in, ", PC_Out = ", PC_to_IM, 
//         ", Instruction = %b", IM_to_parse,", Opcode = %b", opcode_out, 
//         ", Funct3 = %b", funct3_out, ", rs1 = %d", rs1_out,
//         ", rs2 = %d", rs2_out, ", rd = %d", rd_out, ", funct7 = %b", funct7_out,
//         ", ALUOp = %b", ALUOp_out, ", imm_value = %d", imm_data_out,
//          ", Operation = %b", ALU_C_Operation);
//     end

endmodule // RISC_V_Processor