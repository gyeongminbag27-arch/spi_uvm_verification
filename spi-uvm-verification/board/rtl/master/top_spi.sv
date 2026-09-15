`timescale 1ns / 1ps

module top_spi (
    input  logic       clk,
    input  logic       reset,

    input  logic       insert_start,
    input  logic [7:0] tx_data,

    output logic       led_done,
    output logic       led_busy,
    output logic       led_ss_n,
    output logic       led_clean_start,

    output logic       sclk,
    output logic       mosi,
    input  logic       miso,
    output logic       ss_n
);

    logic clean_start;
    logic busy;
    logic [7:0] rx_data;
    logic done;

    logic done_latch;
    logic start_latch;

    button_debounce u_BTN (
        .clk          (clk),
        .reset        (reset),
        .insert_start (insert_start),
        .o_btn        (clean_start)
    );

    spi_master u_SPI_MASTER (
        .clk      (clk),
        .reset    (reset),
        .start    (clean_start),

        .cpol     (1'b0),
        .cpha     (1'b0),
        .clk_div  (8'd255),
        .tx_data  (tx_data),

        .busy     (busy),
        .rx_data  (rx_data),
        .done     (done),

        .sclk     (sclk),
        .mosi     (mosi),
        .miso     (miso),
        .ss_n     (ss_n)
    );

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            done_latch  <= 1'b0;
            start_latch <= 1'b0;
        end else begin
            if (clean_start)
                start_latch <= 1'b1;

            if (done)
                done_latch <= 1'b1;
        end
    end

    assign led_done        = done_latch;
    assign led_busy        = busy;
    assign led_ss_n        = ss_n;
    assign led_clean_start = start_latch;

endmodule