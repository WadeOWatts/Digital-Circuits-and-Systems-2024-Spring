`timescale 1ns/10ps
module huffman( 
    clk, 
    reset, 
    gray_valid, 
    gray_data, 
    CNT_valid, 
    CNT,
    code_valid, 
    HC, 
    M, 
    in_Aid_all, 
    in_CNT_all, 
    out_Aid_all, 
    out_CNT_all
);

input               clk;
input               reset;
input               gray_valid;
input       [7:0]   gray_data;

output reg          CNT_valid;
output reg  [47:0]  CNT;
output reg          code_valid;
output reg  [47:0]  HC;
output reg  [47:0]  M;

// ===============================================================
//      SORT(6 input)
// ===============================================================
output reg [47:0]   in_Aid_all;
output reg [47:0]   in_CNT_all;

input      [47:0]   out_Aid_all;
input      [47:0]   out_CNT_all;

reg [7:0] in_Aid [5:0];
reg [7:0] in_CNT [5:0];

reg [7:0] out_Aid [5:0];
reg [7:0] out_CNT [5:0];

always @(*) begin
    in_Aid_all = {in_Aid[5], in_Aid[4], in_Aid[3], in_Aid[2], in_Aid[1], in_Aid[0]};
    in_CNT_all = {in_CNT[5], in_CNT[4], in_CNT[3], in_CNT[2], in_CNT[1], in_CNT[0]};
end

always @(*) begin
    {out_Aid[5], out_Aid[4], out_Aid[3], out_Aid[2], out_Aid[1], out_Aid[0]} = out_Aid_all;
    {out_CNT[5], out_CNT[4], out_CNT[3], out_CNT[2], out_CNT[1], out_CNT[0]} = out_CNT_all;
end

// ===============================================================
//      Reg & Wire Declaration
// ===============================================================
reg [7:0] cnt_100;
reg [1:0] current_state, next_state;
reg [2:0] work_cnt;
reg [7:0] in_CNT_temp [5:0];
reg [7:0] id [5:0];
reg [7:0] code [5:0];
reg [7:0] mask [5:0];
reg [7:0] ptr [5:0];
integer left, right;

// =======================================================
//      FSM state
// ===============================================================

//You can modify the FSM state
localparam IDLE = 2'd0;
localparam READ = 2'd1;
localparam WORK = 2'd2;
localparam OUT  = 2'd3;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        current_state <= IDLE;
    end else begin
        current_state <= next_state;
    end
end

//================================================================
//      FSM design
//================================================================
always @(*) begin
    case(current_state)
        IDLE: begin
            if(gray_valid) begin
                next_state = READ;
            end else begin
                next_state = current_state;
            end
        end
        READ: begin
            if(cnt_100 == 8'd100) begin
                next_state = WORK;
            end else begin
                next_state = current_state;
            end 
        end 
        WORK: begin
            if(out_Aid[0] == 11) begin
                next_state = OUT;
            end else begin
                next_state = current_state;
            end
        end 
        OUT: begin
            if(current_state == OUT) begin
                next_state = IDLE;
            end else begin
                next_state = current_state;
            end 
        end 
    endcase
end


// ===============================================================
//      Design
// ===============================================================

always @(posedge clk or posedge reset) begin
    if (reset) begin
        in_CNT_temp[0] <= 0; 
        in_CNT_temp[1] <= 0;
        in_CNT_temp[2] <= 0; 
        in_CNT_temp[3] <= 0;
        in_CNT_temp[4] <= 0; 
        in_CNT_temp[5] <= 0;
        cnt_100 <= 0;
    end else if (gray_valid) begin
        case(gray_data)
            1: begin
                in_CNT_temp[5] <= in_CNT_temp[5] + 1;
            end
            2: begin
                in_CNT_temp[4] <= in_CNT_temp[4] + 1;
            end
            3: begin
                in_CNT_temp[3] <= in_CNT_temp[3] + 1;
            end
            4: begin
                in_CNT_temp[2] <= in_CNT_temp[2] + 1;
            end
            5: begin
                in_CNT_temp[1] <= in_CNT_temp[1] + 1;
            end
            6: begin 
                in_CNT_temp[0] <= in_CNT_temp[0] + 1;
            end 
            default begin
                in_CNT_temp[0] <= in_CNT_temp[0];
            end 
        endcase 
        cnt_100 <= cnt_100 + 1;
    end else if (current_state == IDLE) begin
        in_CNT_temp[0] <= 0; 
        in_CNT_temp[1] <= 0;
        in_CNT_temp[2] <= 0; 
        in_CNT_temp[3] <= 0;
        in_CNT_temp[4] <= 0; 
        in_CNT_temp[5] <= 0;
        cnt_100 <= 0;
    end
end


always @(posedge clk or posedge reset) begin
    if(reset) begin 
        work_cnt <= 0;
        for(integer i = 5; i >= 0; i = i - 1) begin
            id[i] <= 6 - i;
            code[i] <= 0;
            mask[i] <= 0;
            ptr[i] <= 0;
        end
    end else if (current_state == IDLE) begin
        work_cnt <= 0;
        for(integer i = 5; i >= 0; i = i - 1) begin
            id[i] <= 6 - i;
            code[i] <= 0;
            mask[i] <= 0;
            ptr[i] <= 0;
        end
    end else if (next_state == WORK ) begin
        if (work_cnt == 0) begin
            in_Aid[5] <= 1;
            in_Aid[4] <= 2;
            in_Aid[3] <= 3;
            in_Aid[2] <= 4;
            in_Aid[1] <= 5;
            in_Aid[0] <= 6;
            in_CNT[5] <= in_CNT_temp[5];
            in_CNT[4] <= in_CNT_temp[4];
            in_CNT[3] <= in_CNT_temp[3];
            in_CNT[2] <= in_CNT_temp[2];
            in_CNT[1] <= in_CNT_temp[1];
            in_CNT[0] <= in_CNT_temp[0];
            work_cnt <= 1;
        end else if (work_cnt < 6) begin
            in_CNT[1] <= out_CNT[1] + out_CNT[0];
            in_CNT[0] <= 127;
            in_CNT[5] <= out_CNT[5]; in_CNT[4] <= out_CNT[4]; in_CNT[3] <= out_CNT[3]; in_CNT[2] <= out_CNT[2];
            in_Aid[1] <= 6 + work_cnt;
            in_Aid[0] <= 127;
            in_Aid[5] <= out_Aid[5]; in_Aid[4] <= out_Aid[4]; in_Aid[3] <= out_Aid[3]; in_Aid[2] <= out_Aid[2];
            for(integer i = 0; i < 6; i = i + 1) begin
                if (id[i] == out_Aid[1]) begin
                    id[i] <= 6 + work_cnt;
                    ptr[i] <= ptr[i] + 1;
                end else if (id[i] == out_Aid[0]) begin
                    id[i] <= 6 + work_cnt;
                    code[i] <= code[i] + 2 ** ptr[i];
                    ptr[i] <= ptr[i] + 1;
                end 
            end 
            work_cnt <= work_cnt + 1;
            if (work_cnt == 5) begin
                for(integer i = 0; i < 6; i = i + 1) begin
                    mask[i] <= 2 ** (ptr[i] + 1) - 1;
                end
            end
        end 
    end
end

always @(posedge clk or posedge reset) begin
    if(reset) begin
        CNT_valid <= 0;
        CNT <= 0;
        code_valid <= 0;
        HC <= 0;
        M <= 0;
    end else if (current_state == OUT) begin
        CNT_valid <= 1;
        CNT <= {in_CNT_temp[5], in_CNT_temp[4], in_CNT_temp[3], in_CNT_temp[2], in_CNT_temp[1], in_CNT_temp[0]};
        code_valid <= 1;
        HC <= {code[5], code[4], code[3], code[2], code[1], code[0]};
        M <= {mask[5], mask[4], mask[3], mask[2], mask[1], mask[0]};
    end else begin
        CNT_valid <= 0;
        CNT <= 0;
        code_valid <= 0;
        HC <= 0;
        M <= 0;
    end
end

endmodule