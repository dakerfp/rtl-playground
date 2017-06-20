
logic rst;
logic clk;

integer ticks;

initial ticks = 0;
initial rst = 1;
task reset;
begin
	#10 rst = 1;
	#10 rst = 0; clk = 0;
	ticks = 0;
end
endtask

initial clk = 0;
task tick;
begin
	#10 clk = 1;
	#10 clk = 0;
	ticks = ticks + 1;
end
endtask

task assert_if(
	input bit cond,
	input string msg
);
begin
	if (cond !== 1) begin
		$display("[ FAIL ] %s", msg);
		$finish;
	end
end
endtask

task success;
begin
	$finish;
end
endtask
