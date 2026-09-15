class spi_directed_seq extends uvm_sequence #(spi_seq_item);
    `uvm_object_utils(spi_directed_seq)

    // total transaction count
    int total_trans = 1000;

    // directed transaction count
    int directed_count = 8;
    

    // counter for transaction 
    // directed test 8 + random test 992
    int directed_cnt =0;
    int random_cnt   =0;

    function new(string name = "spi_directed_seq");
        super.new(name);
    endfunction
  // directed transfet task
  // coverage target  hit

    task do_transfer(
        bit [7:0] master_tx,
        bit [7:0] slave_tx,
        bit [7:0] clk_div
    );
        spi_seq_item item;

        item = spi_seq_item::type_id::create("item");

        start_item(item);

        // directed value assignment
        item.master_tx_data = master_tx;
        item.slave_tx_data  = slave_tx;
        item.clk_div        = clk_div;

        // current RTL supports SPI Mode 0
        item.cpol           = 1'b0;
        item.cpha           = 1'b0;

        finish_item(item);
        
        // directed transaction call, count up
        // do_transfer() call in directed case 8

        directed_cnt++;
        `uvm_info("SPI_SEQ",
                  $sformatf("DIRECTED[%0d] M_TX=%02h S_TX=%02h CLK_DIV=%0d",
                            directed_cnt,
                            master_tx,
                            slave_tx,
                            clk_div),
                  UVM_LOW)
           
    endtask

// random transfer task
// for variable data combination
    task do_random_transfer();
        spi_seq_item item;

        item = spi_seq_item::type_id::create("item");

        start_item(item);

        if (!item.randomize() with {
            cpol == 1'b0;
            cpha == 1'b0;
            clk_div inside {[3:20]};
        }) begin
            `uvm_error("SPI_SEQ", "Randomize failed")
        end

        finish_item(item);
   // random transaciton count up
   random_cnt++;
    endtask

    task body();
        `uvm_info(get_type_name(),
                  "SPI directed + random sequence start",
                  UVM_LOW)

        `uvm_info(get_type_name(),
                  $sformatf("TOTAL_TRANS=%0d, DIRECTED=%0d, RANDOM=%0d",
                            total_trans,
                            directed_count,
                            total_trans - directed_count),
                  UVM_LOW)

        // -------------------------------------------------
        // Directed transaction : coverage target hit
        // -------------------------------------------------
        do_transfer(8'h00, 8'h00, 8'd4);    // zero / zero, fast
        do_transfer(8'h00, 8'hA5, 8'd8);    // zero / nonzero, mid
        do_transfer(8'h5A, 8'h00, 8'd12);   // nonzero / zero, mid
        do_transfer(8'hA5, 8'h3C, 8'd16);   // nonzero / nonzero, slow

        do_transfer(8'hFF, 8'hFF, 8'd20);   // max / max, slow
        do_transfer(8'h01, 8'hFE, 8'd5);    // master low / slave high
        do_transfer(8'h80, 8'h7F, 8'd10);   // master mid / slave mid
        do_transfer(8'hC0, 8'h01, 8'd3);    // master high / slave low

        // -------------------------------------------------
        // Random transaction : total 1000 transaction 수행
        // -------------------------------------------------
        if (total_trans > directed_count) begin
            repeat (total_trans - directed_count) begin
                do_random_transfer();
            end
        end


         // 기대 출력:
        // SEQUENCE SUMMARY | DIRECTED=8 RANDOM=992 TOTAL=1000
        `uvm_info("SPI_SEQ",
                  $sformatf("SEQUENCE SUMMARY | DIRECTED=%0d RANDOM=%0d TOTAL=%0d",
                            directed_cnt,
                            random_cnt,
                            directed_cnt + random_cnt),
                  UVM_LOW)
        `uvm_info(get_type_name(),
                  "SPI directed + random sequence done",
                  UVM_LOW)
    endtask

endclass