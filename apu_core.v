
`define TRACKER_CLOCK_FREQ 440

`define EFFECT_NONE 0
`define EFFECT_SLIDE 1
`define EFFECT_VIBRATO 2
`define EFFECT_DROP 3 
`define EFFECT_FADE_IN 4
`define EFFECT_FADE_OUT 5
`define EFFECT_FAST_ARP 6
`define EFFECT_SLOW_ARP 7

`define INSTRUMENT_NONE 0
`define INSTRUMENT_SINE 1
`define INSTRUMENT_SQUARE 2

module tracker(
	input clk,
	input rst,

	input [RES-1:0] tone,
	input [RES-1:0] octave,
	input [RES-1:0] instrument,
	input [RES-1:0] volume,
	input [RES-1:0] effect,

	output reg [RES-1:0] outchan
);

parameter RES = 8;
parameter LEN = 8;

`include "sinlut.v"

function wave_ampl;
input instrument, t;
case (instrument)
	`INSTRUMENT_NONE: wave_ampl = 0;
	`INSTRUMENT_SINE: wave_ampl = sinlut(t);
	`INSTRUMENT_SQUARE: wave_ampl = 255;
	default: wave_ampl = 0;
endcase
endfunction

reg [LEN-1:0] t;

always @(posedge clk or posedge rst) begin
	if (rst) begin
		outchan <= 0;
		t <= 0;
	end
	else if (clk) begin
		outchan <= $signed(wave_ampl(instrument, t));
		t <= t + 1;
	end
end

endmodule