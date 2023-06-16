
`define HIGH 1'b1
`define LOW  1'b0

module spi_transmitter
#( parameter
	N = 8,
	CLK_FREQ = 24000000,
	SPI_FREQ = 6000000
)
(
	input wire clk,
	input wire rst,
	input wire [N-1:0] data,
	input wire tx_start,
	
	output reg spi_csn,
	output reg spi_clk,
	output reg spi_mosi
);

reg [N-1:0] shiftreg;

localparam TIME_REGISTER_TRIGGER_VALUE = CLK_FREQ / (SPI_FREQ * 2); // N clocks per one SPI_CLK trigger
localparam LEN_TIME_REGISTER = $clog2( TIME_REGISTER_TRIGGER_VALUE ); // N digits for this counter
localparam CNT_LEN = $clog2(N+1);

reg [CNT_LEN-1:0] cnt; // SPI clocks counter
reg [LEN_TIME_REGISTER-1:0] t; // Time register
reg work, cs_delay;

always @(posedge clk, posedge rst) begin
	if (rst) begin
		spi_csn  <= 'b1;
		spi_clk  <= 'b0;
		spi_mosi <= 'b0;
		cnt      <= 'b0;
		t        <= 'b0;
		work     <= 'b0;
        cs_delay <= 'b0;
		shiftreg <= 'b0;
	end
	else if (cs_delay) begin // Half spi_clk cycle delay after CSn goes low and before it goes high
        t <= t + 1'b1;
        if (t == TIME_REGISTER_TRIGGER_VALUE-1) begin
            if(work) begin
                spi_csn <= `HIGH;
                work <= `LOW;
            end
            else
                work <= `HIGH;
            cs_delay <= `LOW;
            t <= 'b0;
        end
    end
    else if (work) begin // Transmitting data
        t <= t + 1'b1;
        if (t == TIME_REGISTER_TRIGGER_VALUE-1) begin
            t <= 'b0;
            spi_clk <= ~spi_clk;
            if (spi_clk) begin // If spi_clk goes low
                spi_mosi <= shiftreg[N-1];
                if (cnt == N) begin
                    cs_delay <= `HIGH;
                    spi_clk <= `LOW;
                    spi_mosi <= `LOW;
                end
            end
            else begin // If spi_clk goes high
                cnt <= cnt + 1'b1;
                shiftreg <= (shiftreg << 1);
            end
        end
    end   
    else if (tx_start) begin
        cs_delay <= `HIGH;
        spi_csn <= `LOW;
        spi_clk <= `LOW;
        spi_mosi <= data[N-1];
        shiftreg <= data;
        cnt      <= 'b0;
    end
end

endmodule
