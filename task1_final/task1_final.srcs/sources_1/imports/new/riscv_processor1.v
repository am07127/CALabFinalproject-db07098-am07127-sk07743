


module riscv_processor1(clk, reset, ele1,ele2,ele3,ele4,ele5);
  input clk;
  input reset;
  output wire [63:0] ele1;
  output wire [63:0] ele2;
  output wire [63:0] ele3;
  output wire [63:0] ele4;
  output wire [63:0] ele5;
 
  //t1
  wire [63:0] PC_Out; 
  
  //t2
  wire [63:0] adder1out;
  
  //t3
  wire [31:0]Instruction; 
  
  // t4
  wire [6:0]opcode;
  wire [4:0]rd;
  wire [2:0]func3;
  wire [4:0]rs1;
  wire [4:0]rs2;
  wire [6:0]func7;
  
  // t5
  wire  [1:0] ALUop;
  wire Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite;
  
  //t6
  wire [63:0] write_data; 
  wire [63:0]ReadData1;
  wire [63:0]ReadData2;
  
  //t7
  wire [63:0] imm_data;
  
   
  //t8
  wire [63:0] ALUinputb;
  
  //t9
  wire [3:0]  Operation;
  
  //t10
  wire [63:0] Result;
  wire Zero;
  
   //t11
  wire [63:0] adder2out;
  
  //t12
  wire [63:0] muxp12;
  
  //t13
  wire [63:0] readdata;
  wire [63:0] ele1;
  wire [63:0] ele2;
  wire [63:0] ele3;
  wire [63:0] ele4;
  wire [63:0] ele5;
 
  
  Program_Counter    pc (.clk(clk),.reset(reset),.PC_In(muxp12), .PC_Out(PC_Out));
  Adder              adder (.a(PC_Out),.b(64'd4),.out(adder1out));
  InstructionMemory  im (.Inst_Address(PC_Out),.Instruction(Instruction));
  instruction_parser ip (.inst(Instruction),.opcode(opcode),.rd(rd),.func3(func3),.rs1(rs1), .rs2(rs2), .func7(func7));
  control_Unit       cu (.OpCode(opcode), .ALUOp(ALUop), .Branch(Branch), .MemRead(MemRead), .MemtoReg(MemtoReg), .MemWrite(MemWrite), .ALUSrc(ALUSrc), .RegWrite(RegWrite));
  regFile            rf (.clk(clk),.reset(reset),.rs1(rs1),.rs2(rs2),.rd(rd), .write_data(write_data),.RegWrite(RegWrite), .readdata1(ReadData1),.readdata2(ReadData2));
  imm_data_extractor ide (.inst(Instruction),.imm_data(imm_data));                        
  mux                alumx (.a(ReadData2),.b(imm_data), .sel(ALUSrc), .data_out(ALUinputb));
  ALU_Control        aluc (.ALUOp(ALUop), .Funct({Instruction[30],Instruction[14:12]}), .Operation(Operation));                   
  ALU                alu (.a(ReadData1), .b(ALUinputb),.ALUop(Operation),.Result(Result),.Zero(Zero));                     
  Adder              adder2 (.a(PC_Out),.b(imm_data << 1),.out(adder2out));                       
  mux                pcmux (.a(adder1out),.b(adder2out), .sel(Branch & Zero), .data_out(muxp12));                       
  Data_Memory        dm(.clk(clk), .Mem_Address(Result), .Write_Data(ReadData2),.Read_Data(readdata), .MemWrite(MemWrite), .MemRead(MemRead), .element1(ele1), .element2(ele2),.element3(ele3),.element4(ele4),.element5(ele5));
  mux                mux (.a(Result),.b(readdata), .sel(MemtoReg), .data_out(write_data));

  endmodule                    
