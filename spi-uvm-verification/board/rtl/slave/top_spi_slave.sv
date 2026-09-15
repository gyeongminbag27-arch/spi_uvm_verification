`timescale 1ns / 1ps

module top_spi_slave (
    input  logic       clk,
    input  logic       reset,

    output logic [3:0] fnd_com,
    output logic [7:0] fnd_data,

    output logic       led_done,
    output logic       led_ss_n,

    input  logic       sclk,
    input  logic       mosi,
    output logic       miso,
    input  logic       ss_n
);

    logic [7:0] tx_data;
    logic [7:0] rx_data;
    logic       done;
    logic       done_latch;

    assign tx_data = 8'h3C;

    spi_slave u_SPI_SLAVE (
        .clk     (clk),
        .reset   (reset),
        .tx_data (tx_data),
        .rx_data (rx_data),
        .done    (done),
        .sclk    (sclk),
        .mosi    (mosi),
        .miso    (miso),
        .ss_n    (ss_n)
    );

    FND_CTRL u_FND_CTRL (
        .clk      (clk),
        .rst      (reset),
        .data     (rx_data),     // FND 테스트만 할 땐 8'hA5로 변경
        .fnd_com  (fnd_com),
        .fnd_data (fnd_data)
    );

    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            done_latch <= 1'b0;
        else if (done)
            done_latch <= 1'b1;
    end

    assign led_done = done_latch;
    assign led_ss_n = ss_n;

endmodule