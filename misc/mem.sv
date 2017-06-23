
module mem
	#(parameter XLEN = 32,
	  parameter SIZE = 256)

	(input clk,
	 input logic [ADDR-1:0] write_addr,
	 input logic [XLEN-1:0] write_data,
	 input logic [ADDR-1:0] read_addr,
	 output logic [XLEN-1:0] read_data);

	localparam ADDR = $clog2(SIZE);

	logic [XLEN-1:0] ram [SIZE-1:0];

	always @(posedge clk)
		ram[write_addr] <= write_data;

	always @(posedge clk)
		read_data <= ram[read_addr];

endmodule : mem
