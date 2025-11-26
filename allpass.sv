
module processor (
	input  logic		sysclk,			// system clock
	input  logic [9:0]	data_in,		// 10-bit input data
	input  logic		data_valid,		// asserted when sample data is ready for processing
	output logic [9:0] 	data_out,		// 10-bit output data
	input logic [9:0] sw,
	output logic [6:0] hex0, hex1, hex2, hex3
);

	logic [9:0] x, y;
	logic [8:0] ram_out;
	logic [12:0] rdaddr, wraddr;
	logic [19:0] read_out;
	logic	enable;

	parameter 		ADC_OFFSET = 10'd512;
	parameter 		DAC_OFFSET = 10'd512;

	assign x = data_in-ADC_OFFSET;
	
	pulse_gen  PULSE (.clk(sysclk), .rst(1'b0), .in(data_valid), .pulse(enable));
	
	ram RAM (.clock(sysclk), .wren(enable), .rden(enable), .rdaddress(rdaddr), .wraddress(wraddr), .data(y[9:1]), .q(ram_out));
	
	counter#(.WIDTH(13)) CTR(
		.clk(sysclk),
		.rst(1'b0),
		.en(~data_valid),
		.count(rdaddr)
	);
	
	
	always_ff @(posedge sysclk) begin
		wraddr <= rdaddr + {sw, 3'b000};
		y <= x - (ram_out >>> 1);
		data_out <= y+DAC_OFFSET;
	end
	
	assign read_out = sw*819;
	logic [3:0] BCD0, BCD1, BCD2, BCD3;
	
	bin2bcd_16(.x({6'b000000, read_out[19:10]}), .BCD0(BCD0), .BCD1(BCD1), .BCD2(BCD2), .BCD3(BCD3));
	hexto7seg SEG0(.out(hex0), .in(BCD0));
	hexto7seg SEG1(.out(hex1), .in(BCD1));
	hexto7seg SEG2(.out(hex2), .in(BCD2));
	hexto7seg SEG3(.out(hex3), .in(BCD3));
	
	
	
endmodule
	