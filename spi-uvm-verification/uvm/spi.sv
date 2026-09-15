module spi(
    input  logic       clk,
    input  logic       reset,

    input  logic       start,
    input  logic       cpol,
    input  logic       cpha,
    input  logic [7:0] clk_div,

    input  logic [7:0] master_tx_data,
    input  logic [7:0] slave_tx_data,

    output logic       busy,
    output logic       master_done,
    output logic       slave_done,
    output logic [7:0] master_rx_data,
    output logic [7:0] slave_rx_data
);

    logic sclk;
    logic mosi;
    logic miso;
    logic ss_n;

    spi_master u_SPI_MASTER (
        .clk     (clk),
        .reset   (reset),
        .start   (start),
        .cpol    (cpol),
        .cpha    (cpha),
        .clk_div (clk_div),
        .tx_data (master_tx_data),

        .busy    (busy),
        .rx_data (master_rx_data),
        .done    (master_done),

        .sclk    (sclk),
        .mosi    (mosi),
        .miso    (miso),
        .ss_n    (ss_n)
    );

    spi_slave u_SPI_SLAVE (
        .clk     (clk),
        .reset   (reset),
        .tx_data (slave_tx_data),

        .rx_data (slave_rx_data),
        .done    (slave_done),

        .sclk    (sclk),
        .mosi    (mosi),
        .miso    (miso),
        .ss_n    (ss_n)
    );

endmodule


module spi_master (
    input  logic       clk,
    input  logic       reset,

    input  logic       start,
    input  logic       cpol,
    input  logic       cpha,
    input  logic [7:0] clk_div,
    input  logic [7:0] tx_data,

    output logic       busy,
    output logic [7:0] rx_data,
    output logic       done,

    output logic       sclk,
    output logic       mosi,
    input  logic       miso,
    output logic       ss_n
);

    typedef enum logic [1:0] {
        IDLE  = 2'b00,
        START = 2'b01,
        DATA  = 2'b10,
        STOP  = 2'b11
    } spi_state_e;

    spi_state_e state;

    logic [7:0] div_cnt;
    logic [7:0] clk_div_r;
    logic       half_tick;

    logic [7:0] tx_shift_reg;
    logic [7:0] rx_shift_reg;
    logic [2:0] bit_cnt;

    logic       step;
    logic       cpol_r;
    logic       cpha_r;
    logic       sclk_r;

    assign sclk = sclk_r;

    // SCLK half period tick generator
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            div_cnt   <= 8'd0;
            half_tick <= 1'b0;
        end else begin
            if (state == DATA) begin
                if (div_cnt == clk_div_r) begin
                    div_cnt   <= 8'd0;
                    half_tick <= 1'b1;
                end else begin
                    div_cnt   <= div_cnt + 1'b1;
                    half_tick <= 1'b0;
                end
            end else begin
                div_cnt   <= 8'd0;
                half_tick <= 1'b0;
            end
        end
    end

    // SPI master FSM
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state        <= IDLE;
            mosi         <= 1'b1;
            ss_n         <= 1'b1;
            busy         <= 1'b0;
            done         <= 1'b0;

            tx_shift_reg <= 8'd0;
            rx_shift_reg <= 8'd0;
            rx_data      <= 8'd0;

            bit_cnt      <= 3'd0;
            step         <= 1'b0;

            sclk_r       <= 1'b0;
            cpol_r       <= 1'b0;
            cpha_r       <= 1'b0;
            clk_div_r    <= 8'd0;
        end else begin
            done <= 1'b0;

            case (state)

                IDLE: begin
                    mosi   <= 1'b1   <= 1'b1;
                    busy   <= 1'b0;
                    sclk_r <= cpol;

                    if (start) begin
                        state        <= START;

                        cpol_r       <= cpol;
                        cpha_r       <= cpha;
                        clk_div_r    <= clk_div;

                        tx_shift_reg <= tx_data;
                        rx_shift_reg <= 8'd0;

                        bit_cnt      <= 3'd0;
                        step         <= 1'b0;

                        busy         <= 1'b1;
                        ss_n         <= 1'b0;
                    end
                end

                START: begin
                    // CPHA=0은 첫 번째 edge 전에 MOSI가 미리 준비되어 있어야 함
                    if (cpha_r == 1'b0) begin
                        mosi         <= tx_shift_reg[7];
                        tx_shift_reg <= {tx_shift_reg[6:0], 1'b0};
                    end

                    state <= DATA;
                end

                DATA: begin
                    if (half_tick) begin
                        sclk_r <= ~sclk_r;

                        if (step == 1'b0) begin
                            // 첫 번째 edge
                            step <= 1'b1;

                            if (cpha_r == 1'b0) begin
                                // CPHA=0 : 첫 번째 edge에서 sample
                                rx_shift_reg <= {rx_shift_reg[6:0], miso};
                            end else begin
                                // CPHA=1 : 첫 번째 edge에서 shift
                                mosi         <= tx_shift_reg[7];
                                tx_shift_reg <= {tx_shift_reg[6:0], 1'b0};
                            
                            end
                        end else begin
                            // 두 번째 edge
                            step <= 1'b0;

                            if (cpha_r == 1'b0) begin
                                // CPHA=0 : 두 번째 edge에서 다음 bit 준비
                                if (bit_cnt < 3'd7) begin
                                    mosi         <= tx_shift_reg[7];
                                    tx_shift_reg <= {tx_shift_reg[6:0], 1'b0};
                                end
                            end else begin
                                // CPHA=1 : 두 번째 edge에서 sample
                                rx_shift_reg <= {rx_shift_reg[6:0], miso};
                            end

                            // 8bit 완료 판단
                            if (bit_cnt == 3'd7) begin
                                state   <= STOP;

                                if (cpha_r == 1'b0) begin
                                    rx_data <=rx_shift_reg;
                                
                                end else begin
                                rx_data <= {rx_shift_reg[6:0], miso};
                                end

                            end else begin
                                bit_cnt <= bit_cnt + 1'b1;
                            
                        end
                    end
                end
                end

                STOP: begin
                    sclk_r <= cpol_r;
                    ss_n   <= 1'b1;
                    done   <= 1'b1;
                    busy   <= 1'b0;
                    mosi   <= 1'b1;
                    state  <= IDLE;
                end

                default: begin
                    state <= IDLE;
                end

            endcase
        end
    end
    

endmodule


module spi_slave(
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
    logic sclk_rise;
    logic sclk_fall;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            sclk_d <= 1'b0;
        end else begin
            sclk_d <= sclk;
        end
    end

    assign sclk_rise =  sclk & ~sclk_d;
    assign sclk_fall = ~sclk &  sclk_d;

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

                    if (!ss_n) begin
                        state <= RECEIVE;
                    end
                end

                RECEIVE: begin
                    if (ss_n) begin
                        state <= IDLE;
                    end else begin

                        // mode 0 기준: rising edge에서 sample
                        if (sclk_rise) begin
                            rx_shift_reg <= {rx_shift_reg[6:0], mosi};

                            if (bit_cnt == 3'd7) begin
                                rx_data <= {rx_shift_reg[6:0], mosi};
                                done    <= 1'b1;
                                bit_cnt <= 3'd0;
                                state   <= STOP;
                            end else begin
                                bit_cnt <= bit_cnt + 1'b1;
                            end
                        end

                        // mode 0 기준: falling edge에서 shift
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