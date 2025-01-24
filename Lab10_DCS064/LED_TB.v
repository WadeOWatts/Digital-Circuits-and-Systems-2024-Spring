`timescale 1ps / 1ps

module LED_TB;
 	
	reg clk,btn_rst;
	reg [2:0]btn;
	reg switch;
 	wire [3:0] led;
 	  	
	initial begin
		clk = 1'b0;
		btn_rst = 1'b0;
		btn = 3'b0;
		switch = 1'b0;
		#10 btn_rst = 1'b1;
		#10 btn_rst = 1'b0;
		#1000000000				 

		btn = 1'b001;
        #1000000000				 

		btn = 3'b010;
		#1000000000				 

		btn = 3'b100;
		#1000000000				 

		switch = 1'b1;
        btn = 3'b000;
        #1000000000	

		btn = 3'b001;
        #1000000000				 

		btn = 3'b010;
		#1000000000				 

		btn = 3'b100;
		#1000000000	
		$finish;
	end
	
	always #5 clk <= ~clk;
	
	LED LED(
		.clk( clk ),
		.btn_rst( btn_rst ),
		.btn( btn ),
		.switch( switch ),
		.led( led )
	);
endmodule
