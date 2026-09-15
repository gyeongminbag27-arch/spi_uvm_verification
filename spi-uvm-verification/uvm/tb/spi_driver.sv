class spi_driver extends uvm_driver #(spi_seq_item);
    `uvm_component_utils(spi_driver)

    virtual spi_if vif;

    function new(string name = "spi_driver", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(virtual spi_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("SPI_DRV", "Failed to get vif")
        end
    endfunction

    task run_phase(uvm_phase phase);
        spi_seq_item item;

        init_signal();

        wait (vif.reset == 1'b0);
        repeat (2) @(posedge vif.clk);

        forever begin
            seq_item_port.get_next_item(item);

            drive_item(item);

            seq_item_port.item_done();
        end
    endtask

    task init_signal();
        vif.start          <= 1'b0;
        vif.cpol           <= 1'b0;
        vif.cpha           <= 1'b0;
        vif.clk_div        <= 8'd4;
        vif.master_tx_data <= 8'h00;
        vif.slave_tx_data  <= 8'h00;
    endtask

    task drive_item(spi_seq_item item);

        @(posedge vif.clk);

        vif.cpol           <= item.cpol;
        vif.cpha           <= item.cpha;
        vif.clk_div        <= item.clk_div;
        vif.master_tx_data <= item.master_tx_data;
        vif.slave_tx_data  <= item.slave_tx_data;

        @(posedge vif.clk);
        vif.start <= 1'b1;

        @(posedge vif.clk);
        vif.start <= 1'b0;

        wait (vif.master_done == 1'b1);

        `uvm_info("SPI_DRV", $sformatf(
            "DRIVE DONE | M_TX=%02h S_TX=%02h CLK_DIV=%0d",
            item.master_tx_data,
            item.slave_tx_data,
            item.clk_div
        ), UVM_LOW)

        @(posedge vif.clk);

    endtask

endclass