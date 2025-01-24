//--------------------------------------------------------------
//Module "half Adder" provided by TA
//--------------------------------------------------------------
module HA(
		a, 
		b, 
		sum, 
		c_out
);
  input wire a, b;
  output wire sum, c_out;
  xor (sum, a, b);
  and (c_out, a, b);
endmodule

//--------------------------------------------------------------
//Finish module "full Adder" & "core" by yourself
//--------------------------------------------------------------
module FA(
		a, 
		b, 
		c_in, 
		sum, 
		c_out
);
  input   a, b, c_in;
  output  sum, c_out;
  wire t1, t2, t3;

//-----write your code here-----V V V

  HA H1(.a(a), .b(b), .sum(t1), .c_out(t2));
  HA H2(.a(t1), .b(c_in), .sum(sum), .c_out(t3));
  or (c_out, t2, t3);

//-----write your code here-----Λ Λ Λ
endmodule


module CORE (
    in_n0,
    in_n1,
    opt,
    out_n
);
//--------------------------------------------------------------
//Input, Output Declaration
//--------------------------------------------------------------
input [3:0] in_n0, in_n1;
input opt;
output [3:0] out_n;

//-----write your code here-----V V V

wire b0, b1, b2, b3, c0, c1, c2, c3;
xor x1(b0, opt, in_n1[0]);
FA FA1(.a(in_n0[0]), .b(b0), .c_in(opt), .sum(out_n[0]), .c_out(c0));

xor x2(b1, opt, in_n1[1]);
FA FA2(.a(in_n0[1]), .b(b1), .c_in(c0), .sum(out_n[1]), .c_out(c1));

xor x3(b2, opt, in_n1[2]);
FA FA3(.a(in_n0[2]), .b(b2), .c_in(c1), .sum(out_n[2]), .c_out(c2));

xor x4(b3, opt, in_n1[3]);
FA FA4(.a(in_n0[3]), .b(b3), .c_in(c2), .sum(out_n[3]), .c_out(c3));

//-----write your code here-----Λ Λ Λ

endmodule 