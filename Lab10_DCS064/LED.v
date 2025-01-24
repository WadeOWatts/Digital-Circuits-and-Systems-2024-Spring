`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: CYCU DCS
// Design Name: LED
//////////////////////////////////////////////////////////////////////////////////

module LED(
		input clk,
 	 	input btn_rst,
 	 	input [2:0] btn,
 	 	input switch,
 	 	output reg [3:0] led
);

	reg [24:0] count;
	wire d_clk;
	
	always @(posedge clk or posedge btn_rst)begin
		if(btn_rst)
			count <= 0;
		else
			count <= count + 1;
	end
	
    //finish the following code below

    //d_clk 
    //if switch is 0, d_clk freqency is (clk frequency)/(2^25), otherwise d_clk frequency is (clk frequency)/(2^23) 
    //hit : using count[?] to generate d_clk
    assign d_clk = (switch == 0) ? count[24] : count[22];
    //finish the above code above

	
	//finish the following code below
	// State encoding
    localparam DEFAULT        = 3'b000;
    localparam ALL_ON         = 3'b100;
    localparam ALL_OFF        = 3'b010;
    localparam RIGHT_TO_LEFT  = 3'b001;

    // LED sequence counter
    reg [3:0] led_seq;
    reg [3:0] state;

    //led
 	always @( posedge d_clk or posedge btn_rst ) begin
		if (btn_rst) begin
            led <= 4'b0000;
            led_seq <= 4'b1000;
            state <= DEFAULT;
        end else begin
            // Update state based on button input
            case (btn)
                3'b100: state <= ALL_ON;
                3'b010: state <= ALL_OFF;
                3'b001: state <= RIGHT_TO_LEFT;
                default: state <= DEFAULT;
            endcase

            // Update LEDs based on state
            case (state)
                DEFAULT: begin
                    if (led_seq == 4'b0001)
                        led_seq <= 4'b1000;
                    else
                        led_seq <= led_seq >> 1;
                    led <= led_seq;
                end
                ALL_ON: led <= 4'b1111;
                ALL_OFF: led <= 4'b0000;
                RIGHT_TO_LEFT: begin
                    if (led_seq == 4'b1000)
                        led_seq <= 4'b0001;
                    else
                        led_seq <= led_seq << 1;
                    led <= led_seq;
                end
                default: led <= 4'b0000;
            endcase
        end
	end
	//finish the above code above

endmodule
