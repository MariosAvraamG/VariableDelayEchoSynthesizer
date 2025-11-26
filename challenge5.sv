
module challenge5(
	input  logic            MAX10_CLK1_50, 				// system clock at 50MHz
	input  logic            ADC_DOUT,					// ADC chip select - low active
	output logic            DAC_CS, DAC_SDI, DAC_SCK,	// DAC SPI signals
	output logic            ADC_CS, ADC_CLK,			// ADC chip-select & serial symmetical clock at 1MHz
	input logic [9:0] SW,
	output logic [6:0] HEX0, HEX1, HEX2, HEX3
);
	// internal signals
	logic       tick_10k;			//  1 tick per sampling period
	logic [9:0] data_in; 			// data from ADC
	logic [9:0] data_out; 			// data to DAC and PWM
	logic	    data_valid;			// high when converted data is available
 	
	// Generate sampling tick once every 100us (10kHz sampling rate)
	clktick  GEN_10K (.clk(MAX10_CLK1_50), .rst(1'b0), .en(1'b1), .N(16'd4999),  .tick(tick_10k));

	spi2adc SPI_ADC_INTERFACE (	
			.sysclk (MAX10_CLK1_50),
			.start (tick_10k),
			.data_from_adc (data_in),
			.data_valid (data_valid),
			.adc_cs (ADC_CS),
			.adc_sck (ADC_CLK),
			.sdata_from_adc (ADC_DOUT));
    
    spi2dac MCP4921 (
		   .sysclk(MAX10_CLK1_50), .data_in(data_out), .load(tick_10k),
		   .dac_cs(DAC_CS), .dac_sdi(DAC_SDI), .dac_sck(DAC_SCK) );
			
	processor	ALLPASS (.sysclk(MAX10_CLK1_50), 
						.data_in(data_in), .data_out(data_out), .data_valid(data_valid), .sw(SW), .hex0(HEX0), .hex1(HEX1), .hex2(HEX2), .hex3(HEX3));   // do some processing on the data
	
endmodule


