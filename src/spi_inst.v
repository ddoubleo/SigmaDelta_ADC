spi_transmitter 
  #(
    .N(spi_debug_data_w),
    .CLK_FREQ(20480000),
    .SPI_FREQ(5120000)
  ) 
  debug_spi               
  (
    .clk(sysclk),
        .rst(rst_l1),
        .data(eq_out),
    .tx_start(rx_sample_en),
    .spi_csn(),     // IO5
    .spi_clk(),     // IO4
    .spi_mosi()     // IO3
  );