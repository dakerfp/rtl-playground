
module clock(
	output reg clk
);

initial begin
	clk = 0;
end
 
always begin
	#1 clk = ~clk;
end
endmodule