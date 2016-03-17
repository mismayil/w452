module ieee754_sp(output [31:0] d, output reg done,
  input clk, input [31:0] a, b, input [1:0] op, input go, reset);
  
  parameter [1:0] op_mult = 0, op_div = 1, op_add = 2, op_sub = 3;

endmodule
