module OutPort (
	input wire clear,
	input wire clock,
	input wire enable,
	input wire [31:0] D,
	output wire [31:0] Q
	);
	
	always @ (posedge clock) begin
	
		if (clear)
			Q <= 0;		
		else if (enable != 0)
			Q <= 0;
		else 
			Q <= D;
	
	end
endmodule


module inPort (
	input wire clear,
	input wire clock,
	input wire [31:0] D,
	output wire [31:0] Q
	);
	
	always @ (posedge clock) begin
	
		if (clear)
			Q <= 0;	
		else 
			Q <= D;
	
	end
endmodule
