
module pwm(
	input rst,
	input clk,

	input [XLEN-1:0] ampl,
	input [XLEN:0] duty_cycle,

	output reg signal
);

parameter XLEN = 8;
parameter FREQ = 4000000; // clocks / second

reg [XLEN:0] i;
always @(posedge clk or posedge rst) begin
	if (rst) begin
		i <= 1;
	end
	else if (clk) begin
		if (i == duty_cycle)
			i <= 1;
		else
			i <= i + 1;
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		signal <= 0;
	end
	else if (clk) begin
		if (i <= ampl)
			signal <= 1;
		else
			signal <= 0;

	end
end

endmodule

