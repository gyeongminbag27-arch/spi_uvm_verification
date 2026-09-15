class spi_seq_item extends uvm_sequence_item;
    `uvm_object_utils(spi_seq_item)

    rand logic [7:0] master_tx_data;
    rand logic [7:0] slave_tx_data;
    rand logic [7:0] clk_div;

    rand logic       cpol;
    rand logic       cpha;

    logic [7:0] master_rx_data;
    logic [7:0] slave_rx_data;

    constraint mode0_c {
        cpol == 1'b0;
        cpha == 1'b0;
    }

    constraint clk_div_c {
        clk_div inside {[2:20]};
    }

    function new(string name = "spi_seq_item");
        super.new(name);
    endfunction

    function string convert2string();
        return $sformatf(
            "M_TX=%02h S_TX=%02h M_RX=%02h S_RX=%02h CPOL=%0b CPHA=%0b CLK_DIV=%0d",
            master_tx_data,
            slave_tx_data,
            master_rx_data,
            slave_rx_data,
            cpol,
            cpha,
            clk_div
        );
    endfunction

endclass