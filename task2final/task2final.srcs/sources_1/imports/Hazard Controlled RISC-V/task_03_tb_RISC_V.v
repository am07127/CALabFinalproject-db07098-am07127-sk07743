module tb_RISC_V_3
();

reg clk, reset;
wire [63:0] index1,index2,index3,index4,index5,index6;
wire [63:0] r1,r2,r3,r4,r5;
RISC_V_Processor_3 asad
(
    .clk(clk),
    .reset(reset),
    .element1(index1),
    .element2(index2),
    .element3(index3),
    .element4(index4),
    .element5(index5),
    .element6(index6),
    .r1(r1),
    .r2(r2),
    .r3(r3),
    .r4(r4),
    .r5(r5)
    
);

initial 
 
 begin 
  
  clk = 1'b0; 
   
  reset = 1'b1; 
   
  #10 reset = 1'b0; 
 end 
  
  
always  
 
 #5 clk = ~clk; 

endmodule // tb_RISC_V