module sqrt_of_sum(
    input clk,
    input signed [63:0] x,
    input signed [63:0] y,
    output unsigned [31:0] magnitude
);

    // MSB is not used
    reg [63:0] x2, y2;
    
    always @(posedge clk) begin 
        x2 <= 64'(signed'(x[63:32])) * x[63:32];
        y2 <= 64'(signed'(y[63:32])) * y[63:32];
    end
    
    reg [63:0] sum;
    
    always @(posedge clk) begin 
        sum <= x2 + y2;
    end
    
    sqrt64 sqrt(clk, sum, magnitude);


endmodule
