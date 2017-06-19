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

typedef struct packed {
	bit [2:0] tone;
	bit [2:0] octave;
	bit [1:0] instrument;
	bit [4:0] volume;
	bit [2:0] effect;
} note_tp;

module tracker(
	input rst,
	input clk,

	input note_tp note,

	input [SPLEN-1:0] speed,
	output reg [AMPLEN-1:0] amplitude
);

parameter PERIOD = 256;
parameter TLEN = $clog2(PERIOD);
parameter MAXAMPLITUDE = 256;
parameter AMPLEN = $clog2(MAXAMPLITUDE);
parameter MAXSPEED = 16;
parameter SPLEN = $clog2(MAXSPEED);

`include "misc/sinlut.v"
`include "misc/randlut.v"

function [AMPLEN-1:0] square;
input [TLEN-1:0] t;
begin
	if (t < (PERIOD / 2))
		square = 0;
	else
		square = MAXAMPLITUDE - 1;
end
endfunction

function [AMPLEN-1:0] wave;
input [TLEN-1:0] t;
input [1:0] instrument;
case (instrument)
	`INSTR_SIN: wave = sinlut(t);
	`INSTR_SQUARE: wave = square(t);
	`INSTR_SAW: wave = t;
	`INSTR_RAND: wave = randlut(t);
endcase
endfunction

reg [TLEN-1:0] t;
always @(posedge rst or posedge clk) begin
	if (rst) begin
		t <= 0;
	end
	else if (clk) begin
		t <= t + speed;
	end
end

always @(posedge clk) begin
	amplitude <= wave(t, note.instrument);
end

endmodule
