
module riscv_if(
	input wire rst,
	input wire clk,
	input wire bubble,

	output reg [XLEN-1:0] pc
);

parameter XLEN = 32;

always @(posedge clk or posedge rst) begin
	if (rst) begin
		pc <= 0;
	end
	else if (clk) begin
		if (~bubble) pc <= pc + 4;
	end
end

endmodule