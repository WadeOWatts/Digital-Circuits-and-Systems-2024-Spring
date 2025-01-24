//############################################################################
//   2024 Digital Circuit and System Lab
//   Final Project: Pipeline CPU
//   Author       : Ceres Lab 2024 MS1
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   Date         : 2024/05/28
//   Version      : v1.0
//   File Name    : CPU.v
//   Module Name  : CPU
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
	output data_wen;
	output [31:0] data_addr;
	output [31:0] inst_addr;
	output [31:0] data_write;

    reg [31:0] reg_file [0:31];
    reg [31:0] inst_reg, read_data_1, read_data_2, ALU_result, write_data_reg, read_data_reg, bypass_reg;
    reg [4:0] pc_temp, read_reg_1, read_reg_2, reg_rt, reg_rd, ex_mem, mem_wb, pc;
    reg [31:0] reg_funct;
    reg id_ex_MemtoReg, id_ex_RegWrite, id_ex_MemWrite, id_ex_ALUSrc, id_ex_RegDst, id_ex_MemRead, id_ex_jump;
    reg [1:0] id_ex_ALUOp;
    reg ex_mem_MemtoReg, ex_mem_RegWrite, ex_mem_MemWrite, ex_mem_MemRead, ex_mem_jump;
    reg mem_wb_MemtoReg, mem_wb_RegWrite;
    reg flag;

    wire [5:0] opcode;
    wire [4:0] rs, rt, rd;
    wire [4:0] c;
    wire b, j;
    wire [15:0] addr;
    wire [25:0] jump_addr;
    wire [31:0] reg1, reg2, a, d, reg1_fw, reg2_fw;
    wire signed [31:0] alu1, alu2, alu2_0, main_alu;
    wire [1:0] fw_a, fw_b;
    wire alu_crtl, HC_mux, beq;
    wire ALUSrc, RegDst, MemtoReg, RegWrite, MemRead;
    wire [1:0] ALUOp;
    wire ex_MemRead, ex_MemtoReg, ex_MemWrite, ex_RegWrite;


    assign opcode = inst_reg[31:26];
    assign rs = inst_reg[25:21];
    assign rt = inst_reg[20:16];
    assign rd = inst_reg[15:11];
    assign addr = inst_reg[15:0];
    assign jump_addr = inst_reg[25:0];
    assign reg1 = reg_file[rs];
    assign reg2 = reg_file[rt];
    assign reg1_fw = read_data_1;
    assign reg2_fw = read_data_2;
    assign ALUSrc = id_ex_ALUSrc;
    assign ALUOp = id_ex_ALUOp;
    assign RegDst = id_ex_RegDst;
    assign data_wen = ex_mem_MemWrite;
    assign MemRead = ex_mem_MemRead;
    assign MemtoReg = mem_wb_MemtoReg;
    assign RegWrite = mem_wb_RegWrite;
    
    always @(posedge clk or negedge rst_n) begin    // inst_reg
        if(!rst_n) begin
            inst_reg <= 0;
        end else if (HC_mux == 1) begin
            inst_reg <= inst_reg;
        end else if (beq || j) begin
            inst_reg <= 0;
        end else begin
            inst_reg <= instruction;
        end
    end

    always @(posedge clk or negedge rst_n) begin    // reg out
        if(!rst_n) begin
            read_data_1 <= 0;
            read_data_2 <= 0;
        end else begin
            read_data_1 <= reg1;
            read_data_2 <= reg2;
        end
    end

    always @(posedge clk or negedge rst_n) begin // check for hazards
        if(!rst_n) begin
            read_reg_1 <= 0;
            read_reg_2 <= 0;
            reg_rt <= 0;
            reg_rd <= 0;
        end else begin
            read_reg_1 <= rs;
            read_reg_2 <= rt;
            reg_rt <= rt;
            reg_rd <= rd;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            reg_funct <= 0;
        end else begin
            reg_funct <= {{16{addr[15]}}, addr};
        end
    end

    assign alu1 = (fw_a == 2'b00) ? reg1_fw :               // Forward A
                  (fw_a == 2'b01) ? d :
                  (fw_a == 2'b10) ? a : 
                  reg1_fw; // default case


    assign alu2_0 = (fw_b == 2'b00) ? reg2_fw :             // Forward B
                    (fw_b == 2'b01) ? d :
                    (fw_b == 2'b10) ? a :
                    reg2_fw; // default case

    assign alu2 = (ALUSrc) ? reg_funct : alu2_0;    // ALUSrc

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            ex_mem <= 0;
        end else begin
            ex_mem <= (RegDst) ? reg_rd : reg_rt;
        end
    end

    assign alu_crtl = (ALUOp == 2'b00) ? 1'b0 :
                      (ALUOp == 2'b10 && reg_funct[5:0] == 6'b101010) ? 1'b1 :
                      1'b0; // default case

    assign main_alu = (alu_crtl == 1'b0) ? $signed(alu1) + $signed(alu2) :    // ALU add
                      ($signed(alu1) < $signed(alu2)) ? 1 : 0;                  // slt



    always @(posedge clk or negedge rst_n) begin        // ALU output
        if(!rst_n) begin
            ALU_result <= 0;
        end else begin
            ALU_result <= main_alu;
        end
    end

    always @(posedge clk or negedge rst_n) begin        // write_Data
        if(!rst_n) begin
            write_data_reg <= 0;
        end else begin
            write_data_reg <= alu2_0;
        end
    end

    assign data_addr = ALU_result;
    assign data_write = write_data_reg;
    assign a = ALU_result;
    
    always @(posedge clk or negedge rst_n) begin        // Mem output
        if(!rst_n) begin
            read_data_reg <= 0;
        end else begin
            read_data_reg <= data_read;
        end
    end

    always @(posedge clk or negedge rst_n) begin        // Bypass mem
        if(!rst_n) begin
            bypass_reg <= 0;
        end else begin
            bypass_reg <= a;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mem_wb <= 0;
        end else begin
            mem_wb <= (!rst_n) ? 0 : ex_mem;
        end
    end

    assign d = (MemtoReg) ? read_data_reg : bypass_reg;

    integer i;
    always @(negedge clk or negedge rst_n) begin                         // RegWrite
        if(!rst_n) begin
            for (i = 0; i < 32; i = i + 1) begin
                reg_file[i] <= 32'd0;
            end
        end else if (RegWrite == 1) begin
            reg_file[c] <= d;
        end
    end

    // Control unit
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            id_ex_MemtoReg <= 0;
            id_ex_RegWrite <= 0;
            id_ex_MemWrite <= 0;
            id_ex_ALUSrc <= 0;
            id_ex_ALUOp <= 0;
            id_ex_RegDst <= 0;
            id_ex_MemRead <= 0;
        end else if (HC_mux == 1) begin
            id_ex_MemtoReg <= 0;
            id_ex_RegWrite <= 0;
            id_ex_MemWrite <= 0;
            id_ex_ALUSrc <= 0;
            id_ex_ALUOp <= 0;
            id_ex_RegDst <= 0;
            id_ex_MemRead <= 0;
        end else begin
            case (opcode)
                6'd0: begin                     // add
                    id_ex_RegDst <= 1;
                    id_ex_ALUOp <= 2'b10;
                    id_ex_ALUSrc <= 0;
                    id_ex_MemWrite <= 0;
                    id_ex_RegWrite <= 1;
                    id_ex_MemtoReg <= 0;
                    id_ex_MemRead <= 0;
                    id_ex_jump <= 0;
                end

                6'd8: begin                     // addi
                    id_ex_RegDst <= 0;
                    id_ex_ALUOp <= 2'b00;
                    id_ex_ALUSrc <= 1;
                    id_ex_MemWrite <= 0;
                    id_ex_RegWrite <= 1;
                    id_ex_MemtoReg <= 0;
                    id_ex_MemRead <= 0;
                    id_ex_jump <= 0;
                end

                6'd0: begin                     // slt
                    id_ex_RegDst <= 1;
                    id_ex_ALUOp <= 2'b10;
                    id_ex_ALUSrc <= 0;
                    id_ex_MemWrite <= 0;
                    id_ex_RegWrite <= 1;
                    id_ex_MemtoReg <= 0;
                    id_ex_MemRead <= 0;
                    id_ex_jump <= 0;
                end

                6'd4: begin                     // beq
                    id_ex_RegDst <= 1'bx;
                    id_ex_ALUOp <= 2'b01;
                    id_ex_ALUSrc <= 0;
                    id_ex_MemWrite <= 0;
                    id_ex_RegWrite <= 0;
                    id_ex_MemtoReg <= 1'bx;
                    id_ex_MemRead <= 0;
                    id_ex_jump <= 0;
                end

                6'd35: begin                        // lw
                    id_ex_RegDst <= 0;
                    id_ex_ALUOp <= 2'b00;
                    id_ex_ALUSrc <= 1;
                    id_ex_MemWrite <= 0;
                    id_ex_RegWrite <= 1;
                    id_ex_MemtoReg <= 1;
                    id_ex_MemRead <= 1;
                    id_ex_jump <= 0;
                end

                6'd43: begin                        // sw
                    id_ex_RegDst <= 1'bx;
                    id_ex_ALUOp <= 2'b00;
                    id_ex_ALUSrc <= 1;
                    id_ex_MemWrite <= 1;
                    id_ex_RegWrite <= 0;
                    id_ex_MemtoReg <= 1'bx;
                    id_ex_MemRead <= 0;
                    id_ex_jump <= 0;
                end

                6'd2: begin                         // j
                    id_ex_RegDst <= 1'bx;
                    id_ex_ALUOp <= 2'bxx;
                    id_ex_ALUSrc <= 1'bx;
                    id_ex_MemWrite <= 0;
                    id_ex_RegWrite <= 0;
                    id_ex_MemtoReg <= 1'bx;
                    id_ex_MemRead <= 0;
                    id_ex_jump <= 1;
                end

                default: begin
                    id_ex_RegDst <= 0;
                    id_ex_ALUOp <= 0;
                    id_ex_ALUSrc <= 0;
                    id_ex_MemWrite <= 0;
                    id_ex_RegWrite <= 0;
                    id_ex_MemtoReg <= 0;
                    id_ex_MemRead <= 0;
                    id_ex_jump <= 0;
                end
            endcase
        end
    end

    always @(posedge clk or negedge rst_n) begin                                
        if (!rst_n) begin
            ex_mem_MemWrite <= 0;
        end else begin
            ex_mem_MemWrite <= id_ex_MemWrite;
        end
    end

    always @(posedge clk or negedge rst_n) begin                     
        if (!rst_n) begin
            ex_mem_MemtoReg <= 0;
        end else begin
            ex_mem_MemtoReg <= id_ex_MemtoReg;
        end
    end

    always @(posedge clk or negedge rst_n) begin                                
        if (!rst_n) begin
            ex_mem_RegWrite <= 0;
        end else begin
            ex_mem_RegWrite <= id_ex_RegWrite;
        end
    end

    always @(posedge clk or negedge rst_n) begin                                
        if (!rst_n) begin
            ex_mem_jump <= 0;
        end else begin
            ex_mem_jump <= id_ex_jump;
        end
    end

    always @(posedge clk or negedge rst_n) begin                                
        if (!rst_n) begin
            mem_wb_MemtoReg <= 0;
        end else begin
            mem_wb_MemtoReg <= ex_mem_MemtoReg;
        end
    end

    always @(posedge clk or negedge rst_n) begin                                
        if (!rst_n) begin
            mem_wb_RegWrite <= 0;
        end else begin
            mem_wb_RegWrite <= ex_mem_RegWrite;
        end
    end

    assign b = ex_mem_RegWrite;
    assign c = mem_wb;

    // forwarding unit A
    assign fw_a = (b && (ex_mem != 0) && (ex_mem == read_reg_1)) ? 2'b10 :
                  (mem_wb_RegWrite && (c != 0) && ~(b && (ex_mem != 0) && (ex_mem == read_reg_1)) && (c == read_reg_1)) ? 2'b01 :
                  2'b00;

    // forwarding unit B
    assign fw_b = (b && (ex_mem != 0) && (ex_mem == read_reg_2)) ? 2'b10 :
                  (mem_wb_RegWrite && (c != 0) && ~(b && (ex_mem != 0) && (ex_mem == read_reg_2)) && (c == read_reg_2)) ? 2'b01 :
                  2'b00;
    
    assign ex_MemRead = id_ex_MemRead;
    assign ex_MemtoReg = id_ex_MemtoReg;
    assign ex_MemWrite = id_ex_MemWrite;
    assign ex_RegWrite = id_ex_RegWrite;


    assign HC_mux = (id_ex_MemRead && (reg_rt == rs || reg_rt == rt)) ? 1 : 
                    (opcode == 6'd4 && id_ex_RegWrite) ? 1 :
                    (opcode == 6'd2 && (ex_MemRead || ex_MemtoReg || ex_MemWrite || ex_RegWrite || ALUOp[0]) == 1) ? 1 :                  // add a bubble for jump
                    0;    // hazard control

    always @(posedge clk or negedge rst_n) begin            // PC counter
        if (!rst_n) begin                                              
            pc <= 0;
        end else if (flag == 1) begin
            pc <= 0;
        end else begin
            if (HC_mux == 1) begin                                                       
                pc <= pc;
            end else if (beq == 1) begin                                                 
                pc <= $signed(pc) + $signed(addr);
            end else if (j == 1) begin                                                  
                pc <= $signed(jump_addr);
            end else begin
                pc <= $signed(pc_temp);
            end
        end
    end
    
    always @(posedge clk or negedge rst_n) begin    // flag
        if (~rst_n) begin
            flag <= 1;
        end else begin
            flag <= 0;
        end
    end

    assign inst_addr = pc;

    always @(*) begin
        pc_temp = $signed(pc) + 1;    
    end

    assign beq = ((HC_mux == 0) && (opcode == 6'd4) && ((ex_mem == rs && reg_file[rt] == ALU_result) || ex_mem == rt && reg_file[rs] == ALU_result)) ? 1 : 0;  // branch
    assign j = ((opcode == 6'd2) && (HC_mux == 0)) ? 1 : 0;     // modified jump

    








endmodule

