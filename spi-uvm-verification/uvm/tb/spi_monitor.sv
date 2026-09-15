class spi_monitor extends uvm_monitor;
    `uvm_component_utils(spi_monitor)

    virtual spi_if vif;

    uvm_analysis_port #(spi_seq_item) ap;

    function new(string name = "spi_monitor", uvm_component parent);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(virtual spi_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("SPI_MON", "Failed to get vif")
        end
    endfunction

    task run_phase(uvm_phase phase);
        spi_seq_item item;

        wait (vif.reset == 1'b0);

        forever begin
            @(posedge vif.clk);

            if (vif.start == 1'b1) begin
                item = spi_seq_item::type_id::create("item");

                item.master_tx_data = vif.master_tx_data;
                item.slave_tx_data  = vif.slave_tx_data;
                item.cpol           = vif.cpol;
                item.cpha           = vif.cpha;
                item.clk_div        = vif.clk_div;

                wait (vif.master_done == 1'b1);

                item.master_rx_data = vif.master_rx_data;
                item.slave_rx_data  = vif.slave_rx_data;

                ap.write(item);

                `uvm_info("SPI_MON", $sformatf(
                    "MONITOR | %s", item.convert2string()
                ), UVM_LOW)
            end
        end
    endtask

endclass
