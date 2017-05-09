
module mem(
	input clk,
	input [ADDR-1:0] addr,
	input [WORD-1:0] data_in,
	input wr,
	output wire [WORD-1:0] data_out
);

parameter ADDR = 8;
parameter WORD = 32;

reg [WORD-1:0] data [ADDR-1:0];

assign data_out = data[addr];

always @(posedge clk) begin
	if (wr)
		data[addr] = data_in;	
end

endmodule