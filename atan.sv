// Atan(log2(y/x))
// Takes 4 cycles
module atan(
    input clk,
    input [20:0] log,
    output [19:0] out 
);

    reg [16:0] atan_table [0:576];
    initial $readmemh("atan_18_32.hex", atan_table);

    reg [9:0] index1, index2;
    reg [10:0] alpha0;

    always @(posedge clk) begin 
        index1 <= log[20:11];
        index2 <= log[20:11] + 1;
        alpha0 <= log[10:0];
    end

    reg [16:0] val1, val2;
    reg [10:0] alpha;
    reg [11:0] alpha_inv;

    always @(posedge clk) begin 
        val1 <= atan_table[index1];
        val2 <= atan_table[index2];
        alpha <= alpha0;
        alpha_inv <= {1'b0, ~alpha0} + 1;
    end
    
    reg [27:0] mult1, mult2;
    
    always @(posedge clk) begin 
        mult1 <= 28'(unsigned'(val1)) * alpha_inv;
        mult2 <= 28'(unsigned'(val2)) * alpha;
    end
    
    reg [27:0] out_buf;
    
    always @(posedge clk) begin 
        out_buf <= mult1 + mult2;
    end
    
    assign out = out_buf[27:8];


endmodule
