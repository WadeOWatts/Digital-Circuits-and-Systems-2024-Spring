`timescale 1ns/10ps
module pattern(
  // output signals
	clk,
	rst_n,
    in_number,
    mode,
    in_valid,
  // input signals
	out_valid,
	out_result
);

output logic  clk, rst_n, in_valid;
output logic signed [3:0] in_number ;
output logic [1:0] mode;
logic signed [3:0] in1, in2, in3, in4, tmp;
logic signed [3:0] innumber [3:0] ;
input out_valid;
input signed [5:0] out_result;
logic signed [5:0] golden;


//================================================================
// parameters & integer
//================================================================
integer PATNUM = 100;
integer CYCLE = 10;
integer total_latency;
integer patcount;
integer out_valid_count;
integer i, j;


//================================================================
// initial
//================================================================

always	#(CYCLE/2.0) clk = ~clk;
initial	clk = 0;


initial begin
	in_valid = 0;
	rst_n = 1;
	force clk = 0;
	reset_task;
	release clk;
	total_latency = 0; 
    @(negedge clk);

	for (patcount = 0; patcount < PATNUM; patcount = patcount + 1)begin
		$display("input_task;");
		input_task;
		$display("wait_outvalid;");
		wait_outvalid;

		$display("check_ans;");
		check_ans;
		$display("outvalid_rst;");
		outvalid_rst;
		@(negedge clk);
	end

	YOU_PASS_task;  
    $finish;
end

//================================================================
// task
//================================================================

// let rst_n = 0 for 3 cycles & check SPEC1(All output signals should be reset after the reset signal is asserted)
task reset_task ; begin
    //finish the task here vvv
	in_number = 'dx;
	mode = 'dx;

	// reset
	rst_n = 0;  #(CYCLE*4); // wait 4 cycles to check output signal
	// check reset
	if(out_result !== 0 || out_valid !== 0) begin
		$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
		$display ("                                                                    SPEC 1 FAIL                                                              ");
		$display ("                                                                       Reset                                                                ");
		$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
		repeat(3) #(CYCLE);
        $finish;
	end

	// release reset
	rst_n = 1; #(CYCLE*3);
	
	// release clock
	release clk; repeat(5) @ (negedge clk);
    
	//finish the task here vvv
end endtask

//generate random inputs & assign to in_number in the specific cycle & calculate the golden value
task input_task ; begin
    //finish the task here vvv
    mode = $urandom_range(3,0);
	in_valid = 1;
	// generate image from -9 to 9
	for(i = 0; i < 4; i = i + 1) begin
			innumber[i] = $urandom_range(-8,7);
	end

	for(i = 0; i < 4; i = i + 1) begin
			in_number = innumber[i];
			@ (negedge clk);
	end
	
	// release input
	in_valid = 0;
	in_number = 'dx;

	for (i = 0; i < 4; i = i + 1) begin
		for (j = 0; j < 3 - i; j = j + 1) begin
			if (innumber[j] > innumber[j+1]) begin
				// Swap elements
				tmp = innumber[j];
				innumber[j] = innumber[j+1];
				innumber[j+1] = tmp;
			end
		end
	end

	if (mode === 0) begin
		golden = innumber[0] + innumber[1];
	end else if (mode === 1) begin
		golden = innumber[1] - innumber[0];
	end else if (mode === 2) begin
		golden = innumber[3] - innumber[2];
	end else if (mode === 3) begin
		golden = innumber[0] - innumber[3];
	end


    
	//finish the task here vvv
end endtask

// check SPEC2 (The out_valid must be high for exact 1 cycles during output)
task outvalid_rst;begin
    //finish the task here vvv
    out_valid_count = 0;
	// wait out valid
	while(out_valid === 1) begin
		out_valid_count = out_valid_count + 1;
		// check latency is over MAX_LATENCY
		if(out_valid_count > 1) begin
			$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
			$display ("                                                                    SPEC 2 FAIL                                                              ");
			$display ("                                                         Output should be zero after check                                                  ");
			$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
			$finish;
		end
		@ (negedge clk);
	end
    
	//finish the task here vvv
end endtask

// check SPEC3 (Outvalid cannot overlap with in_valid)
always @(posedge clk) begin
    //finish the task here vvv
	if(in_valid === 1 && out_valid === 1) begin
		$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
		$display ("                                                                    SPEC 3 FAIL                                                               ");
		$display ("                                                Outvalid should be zero before give data finish                                            ");
		$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
		$finish;
		end
	//finish the task here vvv
end

//check SPEC4 (The execution latency should not over 100 cycles)
task wait_outvalid ; begin
    //finish the task here vvv
	total_latency = 0;
	while(out_valid === 0) begin
		@ (negedge clk);
		total_latency = total_latency + 1;
		// check latency is over MAX_LATENCY
		if(total_latency > 100) begin
			$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
			$display ("                                                                    SPEC 4 FAIL                                                               ");
			$display ("                                                  The execution latency are over 100  cycles                                            ");
			$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
			$finish;
		end
	end
    
    
	//finish the task here vvv
end endtask

// check SPEC5 (The output should be correct when out_valid is high)
task check_ans ; begin
    if(out_valid === 1) begin
        if (golden!== out_result)begin
            $display ("--------------------------------------------------------------------------------------------------------------------------------------------");
            $display ("                                                                    SPEC 5 FAIL                                                             ");
            $display ("                                                                    YOUR:  %d                                                 ",out_result);
            $display ("                                                                    GOLDEN: %d                                                    ",golden);
            $display ("--------------------------------------------------------------------------------------------------------------------------------------------");
	    $finish ;
        end
    end
end endtask



/*
$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
$display ("                                                                    SPEC 1 FAIL                                                              ");
$display ("                                                                       Reset                                                                ");
$display ("--------------------------------------------------------------------------------------------------------------------------------------------");

$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
$display ("                                                                    SPEC 2 FAIL                                                              ");
$display ("                                                         Output should be zero after check                                                  ");
$display ("--------------------------------------------------------------------------------------------------------------------------------------------");

$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
$display ("                                                                    SPEC 3 FAIL                                                               ");
$display ("                                                Outvalid should be zero before give data finish                                            ");
$display ("--------------------------------------------------------------------------------------------------------------------------------------------");

$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
$display ("                                                                    SPEC 4 FAIL                                                               ");
$display ("                                                  The execution latency are over 100  cycles                                            ");
$display ("--------------------------------------------------------------------------------------------------------------------------------------------");

$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
$display ("                                                                    SPEC 5 FAIL                                                             ");
$display ("                                                                    YOUR:  %d                                                 ",out_result);
$display ("                                                                    GOLDEN: %d                                                    ",golden);
$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
*/

task YOU_PASS_task;begin

$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
$display ("                                                               Congratulations!                						             ");
$display ("                                                        You have passed all patterns!          						             ");
$display ("                                                                time: %8t ns                                                        ",$time);
$display ("--------------------------------------------------------------------------------------------------------------------------------------------");

$finish;	
end endtask

endmodule


