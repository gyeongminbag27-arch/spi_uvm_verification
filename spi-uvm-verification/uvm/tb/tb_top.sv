`timescale 1ns/1ps

import uvm_pkg::*;
`include "uvm_macros.svh"

import spi_pkg::*;



module tb_top;

    logic clk;

    spi_if spi_vif(clk);

    spi dut (
        .clk            (clk),
        .reset          (spi_vif.reset),

        .start          (spi_vif.start),
        .cpol           (spi_vif.cpol),
        .cpha           (spi_vif.cpha),
        .clk_div        (spi_vif.clk_div),

        .master_tx_data (spi_vif.master_tx_data),
        .slave_tx_data  (spi_vif.slave_tx_data),

        .busy           (spi_vif.busy),
        .master_done    (spi_vif.master_done),
        .slave_done     (spi_vif.slave_done),
        .master_rx_data (spi_vif.master_rx_data),
        .slave_rx_data  (spi_vif.slave_rx_data)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        spi_vif.reset = 1'b1;

        spi_vif.start          = 1'b0;
        spi_vif.cpol           = 1'b0;
        spi_vif.cpha           = 1'b0;
        spi_vif.clk_div        = 8'd4;
        spi_vif.master_tx_data = 8'h00;
        spi_vif.slave_tx_data  = 8'h00;

        repeat (5) @(posedge clk);
        spi_vif.reset = 1'b0;
    end

    initial begin
        uvm_config_db#(virtual spi_if)::set(null, "*", "vif", spi_vif);
        run_test("spi_test");
    end

    initial begin
        $fsdbDumpfile("spi_tb.fsdb");
        $fsdbDumpvars(0, tb_top);
        $fsdbDumpMDA();
    end

endmodule