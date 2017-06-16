
module file_readmemh; 
/* Declare a array 4 word deep 20 locations wide for 20/4 = 5 hexadecimal words */ 
reg [31:0] data [0:3];
// initialize the hexadecimal reads from the vectors.txt file
initial $readmemh("rom.txt", data);
/* declare an integer for the conditional
statement to read values from test file */
integer i;
/*read and display the values from the text file on screen*/ 
initial begin
     $display("rdata:");
     for (i=0; i < 4; i=i+1)
     $display("%d:%h",i,data[i]);
end     
endmodule 