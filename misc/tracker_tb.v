
`include "misc/tracker.v"

module tracker_tb();
`include "test.v"


reg  note_tp note;
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
	speed = 4'b1;
	note.instrument = `INSTR_SIN;
	for (i=0; i < 256; i=i+1) tick;
	note.instrument = `INSTR_SQUARE;
	for (i=0; i < 256; i=i+1) tick;
	note.instrument = `INSTR_SAW;
	for (i=0; i < 256; i=i+1) tick;
	note.instrument = `INSTR_RAND;
	for (i=0; i < 256; i=i+1) tick;
end
endtask

initial begin
	$dumpfile("/tmp/tracker.vcd");
	$dumpvars(0, tracker_tb);
	test_square_wave;
	success;	
end

endmodule
