`include "misc/pwm.v"

module pwm_tb();
`include "test.v"

reg [2:0] ampl;
reg [3:0] duty;
wire signal;

pwm #(.XLEN(3)) p(
	rst,
	clk,

	ampl,
	duty,

	signal
);

task test0;
begin
	reset;
	ampl = 0;
	duty = 7;
	tick; assert(signal == 0, "0 1");
	tick; assert(signal == 0, "2");
	tick; assert(signal == 0, "3");
	tick; assert(signal == 0, "4");
	tick; assert(signal == 0, "5");
	tick; assert(signal == 0, "6");
	tick; assert(signal == 0, "7");
	tick; assert(signal == 0, "8");
	tick; assert(signal == 0, "9");
end
endtask

task test1;
begin
	reset;
	duty = 7;
	ampl = 7; // this takes 1 all th time
	tick; assert(signal == 1, "1");
	tick; assert(signal == 1, "2");
	tick; assert(signal == 1, "3");
	tick; assert(signal == 1, "4");
	tick; assert(signal == 1, "5");
	tick; assert(signal == 1, "6");
	tick; assert(signal == 1, "7");
	tick; assert(signal == 1, "8");
	tick; assert(signal == 1, "9");

end
endtask

task test4;
begin
	reset;
	duty = 7;
	ampl = 4;
	tick; assert(signal == 1, "1");
	tick; assert(signal == 1, "2");
	tick; assert(signal == 1, "3");
	tick; assert(signal == 1, "4");
	tick; assert(signal == 0, "5");
	tick; assert(signal == 0, "6");
	tick; assert(signal == 0, "7");
	// wrap duty cycle
	tick; assert(signal == 1, "8");
	tick; assert(signal == 1, "9");
	tick; assert(signal == 1, "10");
	tick; assert(signal == 1, "11");
	tick; assert(signal == 0, "12");
	tick; assert(signal == 0, "13");
	tick; assert(signal == 0, "14");
	// wrap
	tick; assert(signal == 1, "15");
end
endtask

initial begin
	test0;
	test1;
	test4;
	success;
end

endmodule
