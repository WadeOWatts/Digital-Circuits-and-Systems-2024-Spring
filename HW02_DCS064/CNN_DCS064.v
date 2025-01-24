module CNN(
    //input
    input                           clk,
    input                           rst_n,
    input                           in_valid,
    input      signed   [15:0]      in_data,
    input                           opt,
    //output
    output reg                      out_valid, 
    output reg signed   [15:0]      out_data	
);

///////////////////////////////////////////////////////
//                   Parameter                       //
///////////////////////////////////////////////////////

//You can modify the states.
parameter IDLE = 2'd0;
parameter READ = 2'd1;
parameter CALC = 2'd2;
parameter OUT  = 2'd3;

//parameter IDLE = 2'd0;
parameter CONV = 2'd1;
parameter ACTF = 2'd2;
parameter MAXP = 2'd3;

///////////////////////////////////////////////////////
//                       FSM                         //
///////////////////////////////////////////////////////

//You can modify the reg name for your convenience.
reg [1:0] current_state, next_state;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        current_state <= IDLE;
    end else begin
        current_state <= next_state;
    end
end


///////////////////////////////////////////////////////
//                   wire & reg                      //
///////////////////////////////////////////////////////

//write down the wire and reg you need here.
reg [1:0] x, y;
reg [2:0] x_cnt, y_cnt;
reg act_func;
reg signed [15:0] input_buffer [44:0];
reg signed [15:0] feature_buffer [0:3][0:3];
reg signed [15:0] output_buffer [0:1][0:1];
reg [1:0] cal_state;
reg [5:0] count;

///////////////////////////////////////////////////////
//                   FSM design                      //
///////////////////////////////////////////////////////

//If you don't know how to design FSM, you can refer to lab04. 
always @(*) begin
    case (current_state)
        IDLE: begin
            if (in_valid) begin
                next_state = READ;
            end else begin
                next_state = current_state;
            end
        end 

        READ: begin
            if (in_valid == 0) begin
                next_state = CALC;
            end else begin
                next_state = current_state;
            end
        end

        CALC: begin
            if(cal_state == MAXP && x_cnt == 2'd1 && y_cnt == 2'd1) begin
                next_state = OUT;
            end else begin
                next_state = current_state;
            end            
        end

        OUT: begin
            if (x_cnt == 2'd1 && y_cnt == 2'd1) begin
                next_state = IDLE;
            end else begin
                next_state = current_state;
            end
        end
    endcase
end

integer i, j;
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        cal_state <= IDLE;
    end else if (in_valid == 0 && current_state == READ && cal_state == IDLE) begin
        cal_state <= CONV;
    end else if (cal_state == CONV && x == 2'd3 && y == 2'd3) begin
        cal_state <= ACTF;
    end else if (cal_state == ACTF) begin
        cal_state <= MAXP;
    end else if (cal_state == MAXP && out_valid == 1) begin
        cal_state <= IDLE;
    end else begin
        cal_state <= cal_state;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        act_func <= 1'b0;
    end else if (in_valid == 1'b1 && count == 6'd0) begin
        if (opt === 1'b1) begin
            act_func <= 1'b1;
        end else begin
            act_func <= 1'b0;
        end 
    end else begin
        act_func <= act_func;
    end
end
///////////////////////////////////////////////////////
//                     design                        //
///////////////////////////////////////////////////////

//write down your design here.

///// Pointer /////

always @(posedge clk or negedge rst_n) begin                             
    if (~rst_n) begin
        x_cnt <= 3'd0;
        y_cnt <= 3'd0;
    end else if (current_state == CALC) begin                       
        if (cal_state == MAXP) begin
            if (x_cnt == 3'd1) begin
                if (y_cnt == 3'd1) begin
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
        end
    end else if (current_state == OUT) begin
        if (x_cnt == 3'd1) begin
            if (y_cnt == 3'd1) begin
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
        x_cnt <= x_cnt;
        y_cnt <= y_cnt;
    end
end
///////////////////

///// Image Input /////


always @(posedge clk or negedge rst_n) begin      
    if (~rst_n) begin
        for (i = 0; i < 45; i = i + 1) begin
           input_buffer[i] <= 16'd0;
        end
    end else if (next_state == READ) begin         // need to be fixed
        input_buffer[count] <= in_data;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        count <= 6'd0;
    end else if (in_valid == 1) begin
        count <= count + 1;
    end else begin
        count <= 0;
    end
end


///////////////////////



reg signed [15:0] feature_counter;
///// Inner product /////    
always @(posedge clk or negedge rst_n) begin                        
    if (~rst_n) begin
        x <= 3'd0;
        y <= 3'd0;
    end else if (current_state == CALC && cal_state == CONV) begin
        if (x == 3'd3) begin
            if (y == 3'd3) begin
                x <= 3'd0;
                y <= 3'd0;
            end else begin
                x <= 3'd0;
                y <= y + 3'd1;
            end
        end else begin
            x <= x + 3'd1;
            y <= y;
        end             
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        for (i = 0; i < 4; i = i + 1) begin
            for (j = 0; j < 4; j = j + 1) begin
                feature_buffer[i][j] <= 16'd0;
            end
        end
    end else if (cal_state == CONV) begin
        feature_buffer[y][x] <= feature_counter;
    end else if (cal_state == ACTF && act_func == 1'b0) begin
        for (i = 0; i < 4; i = i + 1) begin
            for (j = 0; j < 4; j = j + 1) begin
                if (feature_buffer[i][j] < 0) begin
                    feature_buffer[i][j] <= 0;
                end else begin
                    feature_buffer[i][j] <= feature_buffer[i][j];
                end
            end
        end
    end
end


always @(*) begin                                        
    if (current_state == CALC && cal_state == CONV) begin
        feature_counter = 0;
        for (i = 0; i < 3; i = i + 1) begin
            for (j = 0; j < 3; j = j + 1) begin
                feature_counter = feature_counter + input_buffer[6*y + x + 6*i + j] * input_buffer[36 + 3*i + j];
            end
        end
    end else begin
        feature_counter = 0;
    end
end

integer max;
always @(posedge clk or negedge rst_n) begin     
    if (~rst_n) begin
        for (i = 0; i < 2; i = i + 1) begin
            for (j = 0; j < 2; j = j + 1) begin
                output_buffer[i][j] <= 16'd0;
            end
        end
    end else if (current_state == CALC && cal_state == MAXP) begin      
        output_buffer[y_cnt][x_cnt] <= max;
    end
end

always @(*) begin
    if (current_state == CALC && cal_state == MAXP) begin
        max = -32768;
        for (i = 0; i < 2; i = i + 1) begin
            for (j = 0; j < 2; j = j + 1) begin
                if (feature_buffer[y_cnt*2 + i][x_cnt*2 + j] > max) begin
                    max = feature_buffer[y_cnt*2 + i][x_cnt*2 + j];
                end
            end
        end  
    end else begin
        max = -32768;
    end
end

/////////////////////////

///// Output Setting /////
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        out_valid <= 0;
    end else if (current_state == OUT) begin
        out_valid <= 1;
    end else begin
        out_valid <= 0;
    end
end

//////////////////////////

///// Image Output /////
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        out_data <= 0;
    end else if (current_state == OUT) begin
        out_data <= output_buffer[y_cnt][x_cnt];
    end else begin
        out_data <= 0;
    end
end
////////////////////////

//////////////////////

endmodule
