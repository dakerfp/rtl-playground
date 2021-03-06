`include "misc/pwm.v"

module pwm_tb;
	`include "test.v"

	logic [2:0] ampl;
	logic [3:0] duty;
	logic signal;

	pwm #(.XLEN(3)) p(
		rst, clk,

		ampl, duty,

		signal
	);

	task test0;
	begin
		reset;
		ampl = 0;
		duty = 7;
		tick; assert_if(signal == 0, "0 1");
		tick; assert_if(signal == 0, "2");
		tick; assert_if(signal == 0, "3");
		tick; assert_if(signal == 0, "4");
		tick; assert_if(signal == 0, "5");
		tick; assert_if(signal == 0, "6");
		tick; assert_if(signal == 0, "7");
		tick; assert_if(signal == 0, "8");
		tick; assert_if(signal == 0, "9");
	end
	endtask

	task test1;
	begin
		reset;
		duty = 7;
		ampl = 7; // this takes 1 all th time
		tick; assert_if(signal == 1, "1");
		tick; assert_if(signal == 1, "2");
		tick; assert_if(signal == 1, "3");
		tick; assert_if(signal == 1, "4");
		tick; assert_if(signal == 1, "5");
		tick; assert_if(signal == 1, "6");
		tick; assert_if(signal == 1, "7");
		tick; assert_if(signal == 1, "8");
		tick; assert_if(signal == 1, "9");

	end
	endtask

	task test4;
	begin
		reset;
		duty = 7;
		ampl = 4;
		tick; assert_if(signal == 1, "1");
		tick; assert_if(signal == 1, "2");
		tick; assert_if(signal == 1, "3");
		tick; assert_if(signal == 1, "4");
		tick; assert_if(signal == 0, "5");
		tick; assert_if(signal == 0, "6");
		tick; assert_if(signal == 0, "7");
		// wrap duty cycle
		tick; assert_if(signal == 1, "8");
		tick; assert_if(signal == 1, "9");
		tick; assert_if(signal == 1, "10");
		tick; assert_if(signal == 1, "11");
		tick; assert_if(signal == 0, "12");
		tick; assert_if(signal == 0, "13");
		tick; assert_if(signal == 0, "14");
		// wrap
		tick; assert_if(signal == 1, "15");
		tick; assert_if(signal == 1, "16");
		tick; assert_if(signal == 1, "17");
		tick; assert_if(signal == 1, "18");
		tick; assert_if(signal == 0, "19");
		tick; assert_if(signal == 0, "20");
		tick; assert_if(signal == 0, "21");
	end
	endtask

	initial begin
		test0;
		test1;
		test4;
		success;
	end

endmodule : pwm_tb
