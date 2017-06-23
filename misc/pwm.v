
module pwm
	#(parameter XLEN=8,
	  FREQ=1024)

	(input logic rst, clk,

	 input logic [XLEN-1:0] ampl,
	 input logic [XLEN:0] duty_cycle,

	 output logic signal);

	logic [XLEN:0] i;
	always @(posedge clk or posedge rst)
		if (rst)
			i <= 1;
		else if (clk)
			i <= (i == duty_cycle) ? 1 : i + 1;

	always @(posedge clk or posedge rst)
		if (rst)
			signal <= 0;
		else if (clk)
			signal <= (i <= ampl) ? 1 : 0;

endmodule : pwm
