module lcd_ctrl(clk, reset, datain, cmd, cmd_valid, dataout, output_valid, busy);
input           clk;
input           reset;
input   [7:0]   datain;
input   [2:0]   cmd;
input           cmd_valid;
output reg [7:0] dataout;
output reg       output_valid;
output reg       busy;
                                 
///// Reg /////
reg [1:0] cs, ns;
reg [2:0] x_cnt, y_cnt;
reg [7:0] image_buffer [0:4][0:4];
reg [2:0] x, y;
reg [3:0] OUT_cnt;
///////////////

///// Parameter /////
parameter IDLE = 2'd0;
parameter READ = 2'd1;
parameter EXE  = 2'd2;
parameter OUT  = 2'd3;
/////////////////////

///// FSM /////
always @(posedge clk or posedge reset) begin
    if (reset) begin
        cs <= IDLE;
    end else begin
        cs <= ns;
    end
end

always @(*) begin
    case (cs)
        IDLE: begin
            if (cmd_valid) begin
                if (cmd == 3'd0) begin
                    ns = READ;
                end else begin
                    ns = OUT;
                end
            end else begin
                ns = cs;
            end
        end 

        READ: begin
            if (x_cnt == 3'd4 && y_cnt == 3'd4) begin
                ns = OUT;
            end else begin
                ns = cs;
            end
        end

        EXE: begin
            ns = IDLE;
        end

        OUT: begin
            if (x_cnt == 3'd2 && y_cnt == 3'd2) begin
                ns = IDLE;
            end else begin
                ns = cs;
            end
        end
    endcase
end
///////////////

///// Busy Setting /////
always @(posedge clk or posedge reset) begin
    if (reset) begin
        busy <= 0;
    end else if (cs == IDLE) begin
        busy <= 0;
    end else begin
        busy <= 1;
    end
end

////////////////////////

///// Pointer /////
always @(posedge clk or posedge reset) begin
    if (reset) begin
        x_cnt <= 3'd0;
        y_cnt <= 3'd0;
    end else if (cs == READ) begin
        if (x_cnt == 3'd4) begin
            if (y_cnt == 3'd4) begin
                x_cnt <= 3'd0;
                y_cnt <= 3'd0;
            end else begin
                x_cnt <= 3'd0;
                y_cnt <= y_cnt + 3'd1;
            end
        end else begin
            x_cnt <= x_cnt + 3'd1;
            y_cnt <= y_cnt;
        end
    end else if (cs == OUT) begin
        if (x_cnt >= 3'd2) begin
            if (y_cnt >= 3'd2) begin
                x_cnt <= 3'd0;
                y_cnt <= 3'd0;
            end else begin
                x_cnt <= 3'd0;
                y_cnt <= y_cnt + 3'd1;
            end
        end else begin
            x_cnt <= x_cnt + 3'd1;
            y_cnt <= y_cnt;
        end
    end else begin

    end
end
///////////////////

///// Image Input /////
integer i, j;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        for (i = 0; i < 5; i = i + 1) begin
            for (j = 0; j < 5; j = j + 1) begin
                image_buffer[i][j] <= 8'd0;
            end
        end
    end else if (cs == READ) begin
        image_buffer[x_cnt][y_cnt] <= datain;
    end
end
///////////////////////

///// Execuate /////
always @(posedge clk or posedge reset) begin
    if (cmd_valid == 1 && busy == 0) begin
        if(cmd == 0) begin
            busy <= 1;
            x <= 1;
            y <= 1;
        end else if(cmd == 1) begin
            busy <= 1;
            if(x == 2) begin

            end else begin
                x <= x + 1;
            end
        end else if(cmd == 2) begin
            busy <= 1;
            if(x == 0) begin
            
            end else begin
                x <= x - 1;
            end
        end else if (cmd == 3) begin
            busy <= 1;
            if (y == 0) begin
                
            end else begin
                y <= y - 1;
            end
        end else if (cmd == 4) begin
            busy <= 1;
            if (y == 2) begin
                
            end else begin
                y <= y + 1;
            end
        end
    end else begin

    end
end

////////////////////

///// Output Setting /////
always @(posedge clk or posedge reset) begin
    if (reset) begin
        output_valid <= 0;
    end else if (cs == OUT) begin
        output_valid <= 1;
    end else begin
        output_valid <= 0;
    end
end

//////////////////////////

///// Image Output /////
always @(posedge clk or posedge reset) begin
    if (reset) begin
        dataout <= 0;
    end else if (cs == OUT) begin
        dataout <= image_buffer[x + x_cnt][y + y_cnt];
    end else begin
        dataout <= 0;
    end
end
////////////////////////

endmodule


