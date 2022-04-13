module ft_converted(
    input clk,
    input reset_offset,
    input signed [11:0] data,
    output unsigned [31:0] offset,
    output unsigned [31:0] magnitude
);

    reg unsigned [8:0] offset;
    reg signed [63:0] cos_sum;
    reg signed [63:0] sin_sum;

    ft ft(
        clk,
        data, 
        offset,
        cos_sum,
        sin_sum
    );




endmodule
