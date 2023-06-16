//*********************************************************************
//
//	ADC Top Level Module
//
//*********************************************************************



module ADC_top (
	clk_in,
	rstn,
	digital_out,
	analog_cmp,	
	analog_out,
	sample_rdy,
    spi_csn,
    spi_clk,
    spi_mosi);

parameter 
ADC_WIDTH = 8,              // ADC Convertor Bit Precision
ACCUM_BITS = 10,            // 2^ACCUM_BITS is decimation rate of accumulator
LPF_DEPTH_BITS = 4,         // 2^LPF_DEPTH_BITS is decimation rate of averager
INPUT_TOPOLOGY = 1;         // 0: DIRECT: Analog input directly connected to + input of comparitor
                            // 1: NETWORK:Analog input connected through R divider to - input of comp.

//input ports
input	clk_in;				// 62.5Mhz on Control Demo board
input	rstn;	 
input	analog_cmp;			// from LVDS buffer or external comparitor

//output ports
output	analog_out;         // feedback to RC network
output  sample_rdy;
output [7:0] digital_out;   // connected to LED field on control demo bd.


output spi_csn;
output spi_clk;
output spi_mosi;
 

//**********************************************************************
//
//	Internal Wire & Reg Signals
//
//**********************************************************************
wire							clk;
wire							analog_out_i;
wire							sample_rdy_i;
wire [ADC_WIDTH-1:0]			digital_out_i;
wire [ADC_WIDTH-1:0]			digital_out_abs;


Gowin_rPLL PLL_inst(.clkout(clk), .clkin(clk_in));
//assign clk = clk_in;


//***********************************************************************
//
//  SSD ADC using onboard LVDS buffer or external comparitor
//
//***********************************************************************
sigmadelta_adc #(
	.ADC_WIDTH(ADC_WIDTH),
	.ACCUM_BITS(ACCUM_BITS),
	.LPF_DEPTH_BITS(LPF_DEPTH_BITS)
	)
SSD_ADC(
	.clk(clk),
	.rstn(rstn),
	.analog_cmp(analog_cmp),
	.digital_out(digital_out_i),
	.analog_out(analog_out_i),
	.sample_rdy(sample_rdy_i)
	);
assign digital_out_abs = INPUT_TOPOLOGY ? ~digital_out_i : digital_out_i;  

//***********************************************************************
//
//  output assignments
//
//***********************************************************************


assign digital_out   = ~digital_out_abs;	 // invert bits for LED display 
assign analog_out    =  analog_out_i;
assign sample_rdy    =  sample_rdy_i;

    spi_transmitter 
  #(
    .N(9),
    .CLK_FREQ(62500000),
    .SPI_FREQ(15625000)
  ) 
  debug_spi               
  (
    .clk(clk),
        .rst(~rstn),
        .data({1'b0,digital_out_abs}),
    .tx_start(sample_rdy),
    .spi_csn(spi_csn),     // IO5
    .spi_clk(spi_clk),     // IO4
    .spi_mosi(spi_mosi)     // IO3
  );


endmodule   
