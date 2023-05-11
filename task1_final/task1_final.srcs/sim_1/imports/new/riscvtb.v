`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/23/2023 04:09:22 PM
// Design Name: 
// Module Name: riscvtb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module riscvtb();
  reg clk,reset;
  wire [63:0] index1,index2,index3,index4,index5;
  
  riscv_processor1 t1 (.clk(clk), .reset(reset), .ele1(index1), .ele2(index2), .ele3(index3), .ele4(index4), .ele5(index5));
                  
    initial
    begin
   clk = 1'b0;
   reset = 1'b1;
      #10
   reset = 1'b0;
    end
  
  always
    begin
      #5
      clk = ~clk;
    end
  
  initial begin
   $dumpfile("dump.vcd");
   //$dumpvars(1,tb);
    $dumpvars();


    $monitor("Time = %d --> clk = %b,reset = %b", $time,clk,reset);
  #1800 $finish;
  end
endmodule



