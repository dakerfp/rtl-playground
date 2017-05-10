`include "mem.v"

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


module mem_tb();
  
	wire clk;
	clock clk0(clk);

	reg [3:0] addr;
	reg [3:0] data_in;
	reg wr;
	wire [3:0] data_out;
  	mem #(.ADDR(4), .WORD(4)) mem0 (
    	clk,
    	addr,
    	data_in,
    	wr,
    	data_out
  	);

reg [0:3] i;

initial begin
	#0
	wr = 0;
	addr = 0;

	#2
   	addr = 2;
   	data_in = 7;
   	wr = 1;

	#2
   	addr = 3;
   	data_in = 5;
   	wr = 1;

   	#3
   	wr = 0;

   	#2
   	addr = 2;
   	#2
   	if (data_out != 7) begin
   		$display("data in memory is wrong");
   		$finish_and_return(1);
   	end

   	#2
   	addr = 3;
   	#2
   	if (data_out != 5) begin
   		$display("data in memory is wrong");
   		$finish_and_return(1);
   	end
   	#2
   	$finish;
end
   
endmodule