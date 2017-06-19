
`include "misc/tracker.v"

module tracker_tb();
`include "test.v"


reg  [15:0] note;
reg  [3:0] speed;

wire [7:0] ampl;

tracker t(
	rst,
	clk,

	note,
	speed,

	ampl
);

integer i;
task test_square_wave;
begin
	reset;
	note = {3'd5, 3'd1, `INSTR_SQUARE, 3'd7, 3'd0, `EFF_NONE};
	for (i=0; i < 1024; i=i+1) tick;
end
endtask

initial begin
	$dumpfile("/tmp/tracker.vcd");
	$dumpvars(0, tracker_tb);
	test_square_wave;
	success;	
end

endmodule
