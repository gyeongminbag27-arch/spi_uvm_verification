interface spi_if(input logic clk);

    logic       reset;

    logic       start;
    logic       cpol;
    logic       cpha;
    logic [7:0] clk_div;

    logic [7:0] master_tx_data;
    logic [7:0] slave_tx_data;

    logic       busy;
    logic       master_done;
    logic       slave_done;
    logic [7:0] master_rx_data;
    logic [7:0] slave_rx_data;

endinterface