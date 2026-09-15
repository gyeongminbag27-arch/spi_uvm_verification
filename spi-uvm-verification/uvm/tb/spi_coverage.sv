class spi_coverage extends uvm_subscriber #(spi_seq_item);
    `uvm_component_utils(spi_coverage)

    spi_seq_item tr;

    covergroup spi_cg;
        option.per_instance = 1;

        // 현재 DUT는 SPI Mode 0 기준
        // CPOL=0, CPHA=0만 coverage target으로 둠
        cp_mode : coverpoint {tr.cpol, tr.cpha} {
            bins mode0 = {2'b00};
            ignore_bins unsupported_mode = {2'b01, 2'b10, 2'b11};
        }

        // Master가 Slave로 보내는 데이터 패턴
        cp_master_tx : coverpoint tr.master_tx_data {
            bins data_zero = {8'h00};
            bins data_max  = {8'hFF};
            bins data_low  = {[8'h01:8'h3F]};
            bins data_mid  = {[8'h40:8'hBF]};
            bins data_high = {[8'hC0:8'hFE]};
        }

        // Slave가 Master로 보내는 데이터 패턴
        cp_slave_tx : coverpoint tr.slave_tx_data {
            bins data_zero = {8'h00};
            bins data_max  = {8'hFF};
            bins data_low  = {[8'h01:8'h3F]};
            bins data_mid  = {[8'h40:8'hBF]};
            bins data_high = {[8'hC0:8'hFE]};
        }

        // SCLK 속도 조건
        cp_clk_div : coverpoint tr.clk_div {
            bins fast   = {[2:5]};
            bins mid    = {[6:12]};
            bins slow   = {[13:20]};
        }

        // full-duplex 조합 확인
        cp_master_nonzero : coverpoint (tr.master_tx_data != 8'h00) {
            bins zero    = {0};
            bins nonzero = {1};
        }

        cp_slave_nonzero : coverpoint (tr.slave_tx_data != 8'h00) {
            bins zero    = {0};
            bins nonzero = {1};
        }

        // Mode와 SCLK 속도 조합
        cx_mode_clk : cross cp_mode, cp_clk_div;

        // Master/Slave 양방향 데이터 조합
        cx_full_duplex : cross cp_master_nonzero, cp_slave_nonzero;

    endgroup

    function new(string name = "spi_coverage", uvm_component parent);
        super.new(name, parent);
        tr = spi_seq_item::type_id::create("tr");
        spi_cg = new();
    endfunction

    function void write(spi_seq_item t);
        if (t == null) begin
            `uvm_warning("SPI_COV", "null transaction received, skip coverage sample")
            return;
        end

        tr = t;
        spi_cg.sample();
    endfunction

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);

        `uvm_info("SPI_COV", "===============================", UVM_LOW)
        `uvm_info("SPI_COV", "==== SPI Functional Coverage ====", UVM_LOW)
        `uvm_info("SPI_COV", $sformatf("전체: %6.2f %%", spi_cg.get_inst_coverage()), UVM_LOW)
        `uvm_info("SPI_COV", $sformatf("Mode: %6.2f %%", spi_cg.cp_mode.get_inst_coverage()), UVM_LOW)
        `uvm_info("SPI_COV", $sformatf("Master TX: %6.2f %%", spi_cg.cp_master_tx.get_inst_coverage()), UVM_LOW)
        `uvm_info("SPI_COV", $sformatf("Slave TX: %6.2f %%", spi_cg.cp_slave_tx.get_inst_coverage()), UVM_LOW)
        `uvm_info("SPI_COV", $sformatf("CLK_DIV: %6.2f %%", spi_cg.cp_clk_div.get_inst_coverage()), UVM_LOW)
        `uvm_info("SPI_COV", $sformatf("Mode x CLK_DIV: %6.2f %%", spi_cg.cx_mode_clk.get_inst_coverage()), UVM_LOW)
        `uvm_info("SPI_COV", $sformatf("Full Duplex: %6.2f %%", spi_cg.cx_full_duplex.get_inst_coverage()), UVM_LOW)
        `uvm_info("SPI_COV", "===============================", UVM_LOW)

        if (spi_cg.get_inst_coverage() < 100.0) begin
            `uvm_warning("SPI_COV", "Functional coverage 100% 미달. directed sequence 추가 필요")
        end
    endfunction

endclass
