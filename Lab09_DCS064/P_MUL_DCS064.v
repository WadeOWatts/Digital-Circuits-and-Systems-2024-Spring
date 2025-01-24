module P_MUL(
    // input signals
	in_1,
	in_2,
	in_3,
	in_valid,
	rst_n,
	clk,
	
    // output signals
    out_valid,
	out
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input [46:0] in_1, in_2;
input [47:0] in_3;
input in_valid, rst_n, clk;
output reg out_valid;
output reg [95:0] out;

//==============================================//
//  			 reg declaration				//
//==============================================//

reg [47:0] A, B;
reg [47:0] P1, P2, P3, P4;
reg [15:0] count;

//==============================================//
//             	  Your Design          		 	//
//==============================================//

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		A <= 0;
		B <= 0;
	end else if(in_valid == 1) begin
		A <= in_1 + in_2;
		B <= in_3;
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		P1 <= 0;
		P2 <= 0;
		P3 <= 0;
		P4 <= 0;
	end else begin
		P1 <= A[23:0] * B[23:0];
		P2 <= A[23:0] * B[47:24];
		P3 <= A[47:24] * B[23:0];
		P4 <= A[47:24] * B[47:24];
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		out_valid <= 0;
		out <= 0;
	end else if(count >= 2) begin
		out_valid <= 1;
		out <= (P4 << 48) + (P3 << 24) + (P2 << 24) + P1;
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		count <= 0;
	end else if(in_valid == 1) begin
		count <= count + 1;
	end else if(count >= 1) begin
		count <= count + 1;
	end
end


endmodule