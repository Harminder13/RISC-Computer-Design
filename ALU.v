module ALU (
	input wire[31:0] A,
	input wire[31:0] B,
	input wire[31:0] Op,
	output reg[31:0] alu_out,
	output reg[31:0] alu_out2
);

reg[63:0] big;
	
always @(Op) begin
	case (Op)
		4'b0000: alu_out = CLA (A, B);
		4'b0001: alu_out = subtract (A, B);
		4'b0010: begin
		big = Div(A,B);
			alu_out = big[31:0];
			alu_out2 = big[63:32];
		end
		
		4'b0011: begin
			big = Mul(A,B);
			alu_out = big[31:0];
			alu_out2 = big[63:32];
		end
		
		4'b0100: alu_out = And (A, B);
		4'b0101: alu_out = Or (A, B);
		4'b0110: alu_out = LogicalRightShift (A);
		4'b0111: alu_out = ArithmeticRightShift (A);
		4'b1000: alu_out = LeftShift (A);
		4'b1001: alu_out = RotateRight (A);
		4'b1010: alu_out = RotateLeft (A);

		default alu_out = 1'bz;
	endcase
end

function [31:0] And (input [31:0] A, B);
      integer i;
		reg[31:0] result;
	begin
		
		for (i = 0; i < 32; i = i + 1) begin
			 result [i] = A [i] & B [i];
		end
		And = result;
	end
endfunction


function [31:0] Or (input [31:0] A, B);
	
	integer i;
	reg[31:0] result;
	
	begin
		for (i = 0; i < 32; i = i + 1) begin
			result [i] = A [i] | B [i];
		end
		Or = result;
	end
endfunction

function [31:0] Neg (input [31:0] A);
	reg [31:0] newReg;
	
	begin
		newReg = ~A + 1;
		Neg = newReg;
	end
endfunction

function [31:0] Not (input [31:0] A);
	reg [31:0] newReg;
	integer i;
	
	begin
		for (i = 0; i < 32; i = i + 1) begin
			if (A[i] == 0)
				newReg[i] = 1;
			else
				newReg[i] = 0;
		end
		Not = newReg;
	end
endfunction

function [31:0] CLA (input [31:0] A, B);
	
	reg [32:0] C;
	reg [31:0] G, P, sum;
	integer i;
	
	begin
		
		 C[0] = 0;
		for (i = 0; i < 32; i = i + 1) begin
			G[i] = A[i] & B[i];
			P[i] = A[i] | B[i];
			C[i + 1] = G[i] | (P[i] & C[i]);
			sum[i] = A[i] ^ B[i] ^ C[i];
		end
		CLA = sum;
	end

endfunction

function [31:0] subtract (input [31:0] A, B);
	reg [31:0] newReg;
	reg [32:0] C;
	reg [31:0] G, P, diff;
	integer i;
	
	begin
		newReg = ~B + 1;
		
		C[0] = 0;
		for (i = 0; i < 32; i = i + 1) begin
			G[i] = A[i] & newReg[i];
			P[i] = A[i] | newReg[i];
			C[i + 1] = G[i] | (P[i] & C[i]);
			diff[i] = A[i] ^ newReg[i] ^ C[i];
		end
		
		if (C [32] == 0)
			diff = ~diff + 1;
			
		subtract = diff;
	end
endfunction

function [31:0] LogicalRightShift (input [31:0] unshifted);
	
	reg[31:0] shifted;
	integer i;
	begin
		for (i = 0; i < 31; i = i + 1) begin
			shifted [i] = unshifted [i + 1];
		end
		shifted [31] = 0;
		LogicalRightShift = shifted;
	end
endfunction


function [31:0] ArithmeticRightShift (input [31:0] unshifted);
	
	reg[31:0] shifted;
	integer i;
	
	begin
		for (i = 0; i < 31; i = i + 1) begin
			shifted [i] = unshifted [i + 1];
		end
		shifted [31] = unshifted [31];
		ArithmeticRightShift = shifted;
	end
endfunction


function [31:0] LeftShift (input [31:0] unshifted);

   reg[31:0] shifted;
	integer i;
	begin
		for (i = 1; i < 32; i = i + 1) begin
			shifted [i] = unshifted [i - 1];
		end
		shifted [0] = 0;
		LeftShift = shifted;
	end
endfunction


function [31:0] RotateRight (input [31:0] unrotated);
	integer i;
	reg[31:0] rotated;
	
	begin
		
		for (i = 0; i < 31; i = i + 1) begin
			rotated [i] = unrotated [i + 1];
		end
		rotated [31] = unrotated [0];
		RotateRight = rotated;
	end
endfunction


function [31:0] RotateLeft (input [31:0] unrotated);
	
	reg[31:0] rotated;
	integer i;
	
	begin
	
		for (i = 1; i < 32; i = i + 1) begin
			rotated [i] = unrotated [i - 1];
		end
		rotated [0] = unrotated [31];
		RotateLeft = rotated;
	end
endfunction

// Multiplicant= A , Multiplier= B
function [63:0] Mul (input [31:0] A, B);

	reg signed [63:0] product_reg;         
	reg signed [31:0] recoded_multiplier; 
	reg signed [63:0] extended_multiplicand;

	
	integer prdouct_reg;
	integer counter;
	begin
	
	prdouct_reg=0;
	counter= 0;
	
	extended_multiplicand = {{32{A[31]}}, A};
	
	while (counter<32) begin 
	
		case ({B[counter], (counter == 0) ? B[0] : B[counter-1]})
			2'b11: recoded_multiplier[counter] = 0;   // no adjustment
			2'b10: recoded_multiplier[counter] = 1;   // +1 adjustment
			2'b01: recoded_multiplier[counter] = -1;  // -1 adjustment
			2'b00: recoded_multiplier[counter] = 0;   // no adjustment
		endcase

		case (recoded_multiplier[counter])
			1: product_reg = product_reg + extended_multiplicand; // Addition
			-1: product_reg = product_reg - extended_multiplicand; // Subtraction
			default: ; // No adjustment
		endcase
	
		product_reg = product_reg >>> 1;
		counter = counter + 1;
	end
	counter = 0; 
	Mul = product_reg[63:0];  
	end
endfunction


// dividend= A , divisor= B
function [63:0] Div (input [31:0] A, B);
	reg [31:0] C;
	reg [31:0] M;
	reg [31:0] Q;
	reg [31:0] quotient;
	reg [31:0] remainder; 
	reg [31:0] n;
	
	integer counter;
	begin
	counter=32;
	
	M =B;
	Q =A;
	
	while (counter > 0) begin
		// Shift left {C, Q}, (This value will be updated immediately)
		{C, Q} = {C, Q} << 1; 
		// C = C - M, (This value will be updated immediately)
		C = C - M;             
            
		// Check sign bit of C
		if (C[31] == 0) begin    
			// Set least significant bit (LSB) of Q as 0
			Q[0] = 1'b0;
		end 
			
		else begin
			// Set LSB of Q as 1, and restore C
			Q[0] = 1'b1;
			// (This value will be updated immediately)
			C = C + M;
		end
			
		// Decrement count
		counter = counter - 1;
	end
	// Result is in Q, and remainder is in C
	quotient = Q;
	remainder = C; 
			
	C = 32'b0;
	Q = A;
	M = B;
	n = 5'b1;  
	quotient = 32'b0;
	remainder = 32'b0;
			
	Div= {quotient[31:0], remainder[31:0]};
	end
endfunction 
endmodule

