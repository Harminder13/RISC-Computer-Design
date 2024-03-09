module CON_FF (
	input wire [20:19] C2, 
	input wire [31:0] bus,
	input wire ConIn,
	output wire result);
	
	initial decode [3:0] = 4'b0;
	integer nor32;
	integer A1, A2, A3, A4, O1;
	
	always @ (posedge clk) begin
	
		Decoder2to4 Dec (
		.input_bits(C2),
		.output_bits(decode)
		);
		
		nor32 = Nor32Bit(bus);
		A1 = nor32 & decode[0];
		A2 = ~nor32 & decode[1];
		A3 = ~bus & decode[2];
		A4 = bus & decode[3];
		O1 = A1 | A2 | A3 | A4;
		
		DFlipDlip DFF (
		.D(O1),
		.clk(ConIn),
		.Q(result)
		);
		
	end
	
endmodule


module Decoder2to4(
    input [2:0] input_bits,
    output reg [4:0] output_bits
);

always @ (posedge clk)
begin
    case(input_bits)
        4'b00: output_bits <= 16'b0001;
        4'b01: output_bits <= 16'b0010;
        4'b10: output_bits <= 16'b0100;
        4'b11: output_bits <= 16'b1000;
        default: output_bits <= 16'b0000; // Just for safety
    endcase
end
endmodule



function Nor32Bit (input [31:0] input32);
	
	integer result;
	integer i;
	
	begin
	
		result = input32[0];
	
		for (i = 1; i < 32; i = i + 1) begin
		
			result = result | input[i];
		
		end
		Nor32Bit = ~result;

	end
	
endfunction


module DFlipFlop(input D,input clk, output Q);

	always @ (posedge clk) begin
		Q <= D; 
	end 

endmodule 
