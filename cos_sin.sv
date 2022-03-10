module cos_sin(
    input clk,
    input [8:0] angle /* range 0 - 399 */, 
    output reg signed [47:0] cos,
    output reg signed [47:0] sin
);

    reg [47:0] cos_table [0:399];
    initial $readmemh("cos400.hex", cos_table);

    reg [47:0] sin_table [0:399];
    initial $readmemh("sin400.hex", sin_table);
    
    always @(posedge clk) begin 
        cos <= cos_table[angle];
        sin <= sin_table[angle];
    end

endmodule
