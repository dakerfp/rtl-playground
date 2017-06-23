
typedef enum {
	INSTR_SIN,
	INSTR_SQUARE,
	INSTR_SAW,
	INSTR_RAND
} instrument_t;

typedef enum {
	EFF_NONE,
	EFF_SLIDE,
	EFF_VIBRATO,
	EFF_DROP,
	EFF_FADE_IN,
	EFF_FADE_OUT,
	EFF_FAST_ARPEGGIO,
	EFF_SLOW_ARPEGGIO
} effect_t;

typedef struct packed {
	logic [2:0] tone;
	logic [2:0] octave;
	instrument_t instrument;
	logic [4:0] volume;
	effect_t [2:0] effect;
} note_tp;

module tracker

	#(parameter PERIOD = 256,
	  parameter MAXAMPLITUDE = 256,
	  parameter MAXSPEED = 16)

	(input logic rst, clk,

	 input note_tp note,
	 input logic [SPLEN-1:0] speed,

	 output logic [AMPLEN-1:0] amplitude);

	localparam TLEN = $clog2(PERIOD);
	localparam AMPLEN = $clog2(MAXAMPLITUDE);
	localparam SPLEN = $clog2(MAXSPEED);
 	localparam MAXVOLUME = 1 << 5;

	`include "misc/sinlut.v"
	`include "misc/randlut.v"

	function [AMPLEN-1:0] square;
	input [TLEN-1:0] t;
	begin
		square = (t < (PERIOD / 2)) ? 0 : MAXAMPLITUDE - 1;
	end
	endfunction

	function [AMPLEN-1:0] wave;
	input [TLEN-1:0] t;
	input instrument;
		case (instrument)
		INSTR_SIN: wave = sinlut(t);
		INSTR_SQUARE: wave = square(t);
		INSTR_SAW: wave = t;
		INSTR_RAND: wave = randlut(t);
		endcase
	endfunction

	logic [TLEN-1:0] t;
	always @(posedge rst or posedge clk)
		if (rst)
			t <= 0;
		else if (clk)
			t <= t + speed;

	always @(posedge clk)
		amplitude <= wave(t, note.instrument);

endmodule : tracker
