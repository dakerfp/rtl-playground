`define INSTR_SIN 2'd0
`define INSTR_SQUARE 2'd1
`define INSTR_SAW 2'd2
`define INSTR_RAND 2'd3

`define EFF_NONE 3'd0
`define EFF_SLIDE 3'd1
`define EFF_VIBRATO 3'd2
`define EFF_DROP 3'd3
`define EFF_FADE_IN 3'd4
`define EFF_FADE_OUT 3'd5
`define EFF_FAST_ARPEGGIO 3'd6
`define EFF_SLOW_ARPEGGIO 3'd7

module tracker(
	input rst,
	input clk,

	input [15:0] note,
	input [SPLEN-1:0] speed,

	output reg [7:0] amplitude
);

parameter PERIOD = 256;
parameter TLEN = $clog2(PERIOD);
parameter MAXSPEED = 16;
parameter SPLEN = $clog2(MAXSPEED);

`include "sinlut.v"
`include "misc/randlut.v"

wire [2:0] tone = note[15:13];
wire [2:0] octave = note[12:10];
wire [1:0] instrument = note[10:8];
wire [2:0] volume = note[8:5];
wire [2:0] effect = note[2:0];

reg [TLEN-1:0] t;
always @(posedge rst or posedge clk) begin
	if (rst) t <= 0;
	else if (clk) t <= t + speed;
end


function square(
	input t
);
begin
	if (t < PERIOD / 2) square = 0;
	else square = 255;
end
endfunction

always @(posedge rst or posedge clk) begin
	if (rst) begin
		amplitude <= 0;
	end
	else if (clk) begin
		case (instrument)
		`INSTR_SIN: amplitude <= sinlut(t);
		`INSTR_SQUARE: amplitude <= square(t);
		`INSTR_SAW: amplitude <= t;
		`INSTR_RAND: amplitude <= randlut(t); // XXX
		endcase
	end
end

endmodule