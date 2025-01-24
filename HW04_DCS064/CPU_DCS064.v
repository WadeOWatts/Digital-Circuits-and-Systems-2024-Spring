//############################################################################
//   2024 Digital Circuit and System Lab
//   HW04        : Single Cycle CPU
//   Author      : Ceres Lab 2024 MS1
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   Date        : 2024/05/28
//   Version     : v1.0
//   File Name   : CPU.v
//   Module Name : CPU
//############################################################################

//==============================================//
//           Top CPU Module Declaration         //
//==============================================//
module CPU(
	// Input Ports
    clk,
    rst_n,
    data_read,
    instruction,
    // Output Ports
    data_wen,
    data_addr,
    inst_addr,
    data_write
    );
					
	input clk;
	input rst_n;
	input [31:0] instruction;
	input [31:0] data_read;
	output  reg data_wen;
	output  reg [31:0] data_addr;
	output  reg [31:0] inst_addr;
	output  reg [31:0] data_write;

    wire [5:0] opcode;
    wire [4:0] rs;
    wire [4:0] rt;
    wire [4:0] rd;
    wire [4:0] shamt;
    wire [5:0] funct;
    wire [15:0] addr;
    wire [25:0] jump_addr;
    wire branch;
    wire jump;
    integer i;
    reg [31:0] reg_file [0:31];
    reg flag;

    assign opcode = instruction[31:26];
    assign rs = instruction[25:21];
    assign rt = instruction[20:16];
    assign rd = instruction[15:11];
    assign shamt = instruction[10:6];
    assign funct = instruction[5:0];
    assign addr = instruction[15:0];
    assign jump_addr = instruction[25:0];

    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            inst_addr <= 0;
            flag <= 1;
        end else if (branch == 1) begin
            inst_addr <= $signed(inst_addr) + $signed(addr) + 1;
        end else if (jump == 1)  begin
            inst_addr <= $signed(jump_addr);
        end else if (flag == 1) begin
            flag <= 0;
            inst_addr <= $signed(inst_addr);
        end else begin
            inst_addr <= $signed(inst_addr) + 1;
        end
    end

    assign branch = (opcode == 6'd4 && ($signed(reg_file[rs]) == $signed(reg_file[rt]))) ? 1'b1 : 1'b0;
    assign jump = (opcode == 6'd2) ? 1'b1 : 1'b0;
    assign data_wen = (opcode == 6'd43) ? 1'b1 : 1'b0;
    assign data_addr = (opcode == 6'd35 || opcode == 6'd43) ? ($signed(reg_file[rs]) + $signed(addr)) : 0;
    assign data_write = (opcode == 6'd43) ? $signed(reg_file[rt]) : 0;
    

    always @(posedge clk or negedge rst_n) begin                           // control
        if (~rst_n) begin
            for (i = 0; i < 32; i = i + 1) begin
                reg_file[i] <= 32'd0;
            end
        end else if (opcode == 6'd0) begin               // r-type
            if (funct == 6'd32) begin           // add 
                reg_file[rd] <= $signed(reg_file[rs]) + $signed(reg_file[rt]);
            end else if (funct == 6'd42) begin     // slt
                reg_file[rd] <= ($signed(reg_file[rs]) < $signed(reg_file[rt])) ? 1 : 0;
            end
        end else if (opcode == 6'd8) begin      // addi
            reg_file[rt] <= $signed(reg_file[rs]) + $signed(addr);
        end else if (opcode == 6'd35) begin     // lw
            reg_file[rt] <= data_read;
        end
    end

endmodule