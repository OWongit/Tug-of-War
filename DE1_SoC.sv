module DE1_SoC (CLOCK_50, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW);
	input logic 			CLOCK_50; // 50MHz clock.
	output logic [6:0]   HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output logic [9:0]   LEDR;
	input logic [3:0] 	KEY; // True when not pressed, False when pressed
	input logic [9:0] 	SW;
	
	logic keyStable0, keyStable3, keyInput0, keyInput3; //logic for updated inputs after going through stabilizer and input modules
	
	assign HEX1 = 7'b1111111;
	assign HEX2 = 7'b1111111;
	assign HEX3 = 7'b1111111;
	assign HEX4 = 7'b1111111;
	assign HEX5 = 7'b1111111;
	assign LEDR[0] = 1'b0;
	//deal with metastability
	stabilizer stable0 (.clk(CLOCK_50), .reset(SW[9]), .key(~KEY[0]), .out(keyStable0));
	stabilizer stable3 (.clk(CLOCK_50), .reset(SW[9]), .key(~KEY[3]), .out(keyStable3));
	
	//assign one true value/pulse for each press/hold of the key
	uInput input0 (.clk(CLOCK_50), .reset(SW[9]), .key(keyStable0), .out(keyInput0));
	uInput input3 (.clk(CLOCK_50), .reset(SW[9]), .key(keyStable3), .out(keyInput3));

	//assign light values
	normalLight one   (.clk(CLOCK_50), .reset(SW[9]), .L(keyInput3), .R(keyInput0), .NL(LEDR[2]), .NR(LEDR[0]), .lightOn(LEDR[1]));
	normalLight two   (.clk(CLOCK_50), .reset(SW[9]), .L(keyInput3), .R(keyInput0), .NL(LEDR[3]), .NR(LEDR[1]), .lightOn(LEDR[2]));
	normalLight three (.clk(CLOCK_50), .reset(SW[9]), .L(keyInput3), .R(keyInput0), .NL(LEDR[4]), .NR(LEDR[2]), .lightOn(LEDR[3]));
	normalLight four  (.clk(CLOCK_50), .reset(SW[9]), .L(keyInput3), .R(keyInput0), .NL(LEDR[5]), .NR(LEDR[3]), .lightOn(LEDR[4]));
	centerLight five  (.clk(CLOCK_50), .reset(SW[9]), .L(keyInput3), .R(keyInput0), .NL(LEDR[6]), .NR(LEDR[4]), .lightOn(LEDR[5]));
	normalLight six   (.clk(CLOCK_50), .reset(SW[9]), .L(keyInput3), .R(keyInput0), .NL(LEDR[7]), .NR(LEDR[5]), .lightOn(LEDR[6])); 
	normalLight seven (.clk(CLOCK_50), .reset(SW[9]), .L(keyInput3), .R(keyInput0), .NL(LEDR[8]), .NR(LEDR[6]), .lightOn(LEDR[7])); 
	normalLight eight (.clk(CLOCK_50), .reset(SW[9]), .L(keyInput3), .R(keyInput0), .NL(LEDR[9]), .NR(LEDR[7]), .lightOn(LEDR[8]));
	normalLight nine  (.clk(CLOCK_50), .reset(SW[9]), .L(keyInput3), .R(keyInput0), .NL(1'b0), .NR(LEDR[8]), .lightOn(LEDR[9])); 

	//determine winner
	victory winner 	(.clk(CLOCK_50), .reset(SW[9]), .L(keyInput3), .R(keyInput0), .LEDL(LEDR[9]), .LEDR(LEDR[1]), .hex(HEX0));
	
endmodule

module DE1_SoC_testbench();
	logic 		clk;
	logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	logic [9:0] LEDR;
	logic [3:0] KEY;
	logic [9:0] SW;

	DE1_SoC dut (clk, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW);

	// Set up a simulated clock.
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk; // Forever toggle the clock
	end
	
	// Test the design.
		initial begin
		KEY[0] <= 1; KEY[3] <= 1; LEDR[0] = 0;	@(posedge clk);
		SW[9] <= 1;										@(posedge clk);
		SW[9] <= 0;										@(posedge clk); //LED 5 should be on
		KEY[0] <= 0;									@(posedge clk);
		KEY[0] <= 1;									@(posedge clk); //LED 4 should be on
		KEY[0] <= 0;									@(posedge clk);
		KEY[0] <= 1;									@(posedge clk); //LED 3 should be on
		KEY[3] <= 0;									@(posedge clk);
		KEY[3] <= 1;									@(posedge clk); //LED 4 should be on
		KEY[3] <= 0;									@(posedge clk);
		KEY[3] <= 1;									@(posedge clk); //LED 5 should be on
		KEY[0] <= 0; KEY[3] <= 0;					@(posedge clk);
		KEY[0] <= 1; KEY[3] <= 1;					@(posedge clk); //LED 5 should stay on
		KEY[0] <= 0;									@(posedge clk);
		KEY[0] <= 1;									@(posedge clk); //LED 4 should be on
		KEY[0] <= 0; KEY[3] <= 0;					@(posedge clk);
		KEY[0] <= 1; KEY[3] <= 1;					@(posedge clk); //LED 4 should stay on
		KEY[0] <= 0;									@(posedge clk);
		KEY[0] <= 1;									@(posedge clk); //LED 3 should be on
		KEY[0] <= 0;									@(posedge clk);
		KEY[0] <= 1;									@(posedge clk); //LED 2 should be on
		KEY[0] <= 0;									@(posedge clk);
		KEY[0] <= 1;									@(posedge clk); //LED 1 should be on
		KEY[0] <= 0;									@(posedge clk); //LED 1 should be off, HEX 0 should display 1
		KEY[0] <= 1;									@(posedge clk); 
		KEY[0] <= 0;									@(posedge clk); //LED 1 should be off, HEX 0 should display 1
		SW[9] <= 1;										@(posedge clk); 
		SW[9] <= 0;										@(posedge clk); //reset
		KEY[3] <= 0;									@(posedge clk);
		KEY[3] <= 1;									@(posedge clk); //LED 6 should be on	
		KEY[3] <= 0;									@(posedge clk);
		KEY[3] <= 1;									@(posedge clk); //LED 7 should be on	
		KEY[3] <= 0;									@(posedge clk);
		KEY[3] <= 1;									@(posedge clk); //LED 8 should be on	
		KEY[3] <= 0;									@(posedge clk);
		KEY[3] <= 1;									@(posedge clk); //LED 9 should be on
		KEY[3] <= 0;									@(posedge clk);
		KEY[3] <= 1;									@(posedge clk); //LED 9 should be off, HEX 0 should display 2
		KEY[3] <= 0;									@(posedge clk);
		KEY[3] <= 1;									@(posedge clk); //LED 9 should be off, HEX 0 should display 2			
		$stop;
	end

endmodule