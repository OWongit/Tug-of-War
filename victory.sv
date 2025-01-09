module victory(clk, reset, L, R, LEDL, LEDR, hex);
	input logic clk, reset;
	input logic L, R, LEDL, LEDR;
	output logic [6:0] hex;
	
	enum {off, p1, p2} ns, ps;
	
	always_comb begin
		case(ps)
				off: if(LEDL & L & ~R) ns = p2;
					  else if(LEDR & R & ~L) ns = p1;
					  else ns = off;
				p1: ns = p1;
				p2: ns = p2;
		endcase
		
		if(ns == p1) 		hex = 7'b1111001;
		else if(ns == p2)  hex = 7'b0100100;
		else					hex = 7'b1111111;
	
	end
	
	always_ff @(posedge clk) begin
		if(reset) ps <= off;
		else		 ps <= ns;
	end

endmodule

module victory_testbench();
	logic clk, reset;
	logic L, R, LEDL, LEDR;
	logic [6:0] hex;
	
	victory dut (.clk, .reset, .L, .R, .LEDL, .LEDR, .hex);
	
	// Set up a simulated clock.
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk; // Forever toggle the clock
	end
	
	initial begin
		L <= 0; R <= 0; LEDL <= 0; LEDR <= 0; 				@(posedge clk);
		reset <= 1;   												@(posedge clk);
		reset <= 0;								repeat(1)		@(posedge clk);
		LEDL <= 1;													@(posedge clk);
		L <= 1;														@(posedge clk);
		L <= 0; LEDL <= 0; reset <= 1; 						@(posedge clk);
		reset <= 0;								repeat(1)		@(posedge clk);
													repeat(1)		@(posedge clk);
		LEDR <= 1;													@(posedge clk);
		R <= 1;														@(posedge clk);
		R <= 0; LEDR <= 0; reset <= 1; 						@(posedge clk);
		reset <= 0;								repeat(1)		@(posedge clk);
		$stop;
	end
endmodule
		