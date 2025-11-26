
module processor (
	input  logic		sysclk,			// system clock
	input  logic [9:0]	data_in,		// 10-bit input data
	input  logic		data_valid,		// asserted when sample data is ready for processing
	output logic [9:0] 	data_out,		// 10-bit output data
	input logic [9:0] SW,
	output logic [6:0] HEX0, HEX1, HEX2, HEX3
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
		.out(rdaddr)
	);
	
	
	always_ff @(posedge sysclk) begin
		wraddr <= rdaddr + {SW, 3'b000};
		y <= x - {1'b0, ram_out}/2;
		data_out <= y+DAC_OFFSET;
	end
		
	assign read_out = SW*819;
	
	logic [3:0] BCD0, BCD1, BCD2, BCD3;
	
	bin2bcd_16(.x({6'b000000, read_out[19:10]}), .BCD0(BCD0), .BCD1(BCD1), .BCD2(BCD2), .BCD3(BCD3));
	hexto7seg SEG0(.out(HEX0), .in(BCD0));
	hexto7seg SEG1(.out(HEX1), .in(BCD1));
	hexto7seg SEG2(.out(HEX2), .in(BCD2));
	hexto7seg SEG3(.out(HEX3), .in(BCD3));
	
	
	
endmodule
	