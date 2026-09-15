`timescale 1ns / 1ps

module button_debounce #(
    parameter int F_COUNT = 1000
)(
    input  logic clk,
    input  logic reset,
    input  logic insert_start,
    output logic o_btn
);

    logic [$clog2(F_COUNT)-1:0] r_counter;
    logic tick_100khz;

    logic [7:0] sync_reg;
    logic debounce;
    logic edge_reg;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            r_counter   <= '0;
            tick_100khz <= 1'b0;
        end else begin
            if (r_counter == F_COUNT - 1) begin
                r_counter   <= '0;
                tick_100khz <= 1'b1;
            end else begin
                r_counter   <= r_counter + 1'b1;
                tick_100khz <= 1'b0;
            end
        end
    end

    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            sync_reg <= 8'd0;
        else if (tick_100khz)
            sync_reg <= {insert_start, sync_reg[7:1]};
    end

    assign debounce = &sync_reg;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            edge_reg <= 1'b0;
            o_btn    <= 1'b0;
        end else begin
            edge_reg <= debounce;
            o_btn    <= debounce & ~edge_reg;
        end
    end

endmodule