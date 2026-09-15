class spi_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(spi_scoreboard)

    uvm_analysis_imp #(spi_seq_item, spi_scoreboard) analysis_export;

    int pass_count;
    int fail_count;

    function new(string name = "spi_scoreboard", uvm_component parent);
        super.new(name, parent);
        analysis_export = new("analysis_export", this);
    endfunction

    function void write(spi_seq_item item);

        if ((item.master_rx_data === item.slave_tx_data) &&
            (item.slave_rx_data  === item.master_tx_data)) begin

            pass_count++;

            `uvm_info("SPI_SCB", $sformatf(
                "PASS | M_TX=%02h S_TX=%02h M_RX=%02h S_RX=%02h",
                item.master_tx_data,
                item.slave_tx_data,
                item.master_rx_data,
                item.slave_rx_data
            ), UVM_LOW)

        end else begin

            fail_count++;

            `uvm_error("SPI_SCB", $sformatf(
                "FAIL | M_TX=%02h S_TX=%02h M_RX=%02h S_RX=%02h | EXP_M_RX=%02h EXP_S_RX=%02h",
                item.master_tx_data,
                item.slave_tx_data,
                item.master_rx_data,
                item.slave_rx_data,
                item.slave_tx_data,
                item.master_tx_data
            ))

        end
    endfunction

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);

        `uvm_info("SPI_SCB", $sformatf(
            "SPI RESULT : PASS=%0d FAIL=%0d",
            pass_count,
            fail_count
        ), UVM_LOW)
    endfunction

endclass



