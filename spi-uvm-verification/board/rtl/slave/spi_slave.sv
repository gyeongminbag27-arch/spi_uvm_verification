`timescale 1ns / 1ps

module spi_slave (
    input  logic       clk,
    input  logic       reset,

    input  logic [7:0] tx_data,
    output logic [7:0] rx_data,
    output logic       done,

    input  logic       sclk,
    input  logic       mosi,
    output logic       miso,
    input  logic       ss_n
);

    typedef enum logic [1:0] {
        IDLE    = 2'b00,
        RECEIVE = 2'b01,
        STOP    = 2'b10
    } spi_state_e;

    spi_state_e state;

    logic [7:0] tx_shift_reg;
    logic [7:0] rx_shift_reg;
    logic [2:0] bit_cnt;

    logic sclk_d;
    logic ss_n_d;

    logic sclk_rise;
    logic sclk_fall;
    logic ss_start;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            sclk_d <= 1'b0;
            ss_n_d <= 1'b1;
        end else begin
            sclk_d <= sclk;
            ss_n_d <= ss_n;
        end
    end

    assign sclk_rise =  sclk & ~sclk_d;
    assign sclk_fall = ~sclk &  sclk_d;
    assign ss_start  =  ss_n_d & ~ss_n;   // ss_n falling edge

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state        <= IDLE;
            tx_shift_reg <= 8'd0;
            rx_shift_reg <= 8'd0;
            rx_data      <= 8'd0;
            bit_cnt      <= 3'd0;
            done         <= 1'b0;
            miso         <= 1'b0;
        end else begin
            done <= 1'b0;

            case (state)

                IDLE: begin
                    bit_cnt      <= 3'd0;
                    rx_shift_reg <= 8'd0;
                    tx_shift_reg <= tx_data;
                    miso         <= tx_data[7];

                    if (ss_start) begin
                        state <= RECEIVE;
                    end
                end

                RECEIVE: begin
                    if (ss_n) begin
                        state <= IDLE;
                    end else begin
                        if (sclk_rise) begin
                            rx_shift_reg <= {rx_shift_reg[6:0], mosi};

                            if (bit_cnt == 3'd7) begin
                                rx_data <= {rx_shift_reg[6:0], mosi};
                                done    <= 1'b1;
                                bit_cnt <= 3'd0;
                                state   <= STOP;
                            end else begin
                                bit_cnt <= bit_cnt + 3'd1;
                            end
                        end

                        if (sclk_fall) begin
                            tx_shift_reg <= {tx_shift_reg[6:0], 1'b0};
                            miso         <= tx_shift_reg[6];
                        end
                    end
                end

                STOP: begin
                    if (ss_n) begin
                        state <= IDLE;
                    end
                end

                default: begin
                    state <= IDLE;
                end

            endcase
        end
    end

endmodule