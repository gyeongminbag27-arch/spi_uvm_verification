`timescale 1ns / 1ps

module FND_CTRL (
    input  logic       clk,
    input  logic       rst,
    input  logic [7:0] data,

    output logic [3:0] fnd_com,
    output logic [7:0] fnd_data
);

    logic [15:0] div_cnt;
    logic        digit_sel;
    logic [3:0]  digit;

    // two-digit scan
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            div_cnt   <= 16'd0;
            digit_sel <= 1'b0;
        end else begin
            if (div_cnt == 16'd50000) begin
                div_cnt   <= 16'd0;
                digit_sel <= ~digit_sel;
            end else begin
                div_cnt <= div_cnt + 16'd1;
            end
        end
    end

    always_comb begin
        if (digit_sel == 1'b0) begin
            fnd_com = 4'b1110;      // right digit
            digit   = data[3:0];    // low nibble
        end else begin
            fnd_com = 4'b1101;      // next digit
            digit   = data[7:4];    // high nibble
        end
    end

    // common-anode Basys3 7-segment, active-low
    always_comb begin
        case (digit)
            4'h0: fnd_data = 8'b1100_0000;
            4'h1: fnd_data = 8'b1111_1001;
            4'h2: fnd_data = 8'b1010_0100;
            4'h3: fnd_data = 8'b1011_0000;
            4'h4: fnd_data = 8'b1001_1001;
            4'h5: fnd_data = 8'b1001_0010;
            4'h6: fnd_data = 8'b1000_0010;
            4'h7: fnd_data = 8'b1111_1000;
            4'h8: fnd_data = 8'b1000_0000;
            4'h9: fnd_data = 8'b1001_0000;
            4'hA: fnd_data = 8'b1000_1000;
            4'hB: fnd_data = 8'b1000_0011;
            4'hC: fnd_data = 8'b1100_0110;
            4'hD: fnd_data = 8'b1010_0001;
            4'hE: fnd_data = 8'b1000_0110;
            4'hF: fnd_data = 8'b1000_1110;
            default: fnd_data = 8'b1111_1111;
        endcase
    end

endmodule
