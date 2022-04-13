module log2(
    input clk,
    input unsigned [17:0] in,
    output unsigned [20:0] out
);

    reg [16:0] lookup_table [0:128];
    initial $readmemh("log2_128.hex", lookup_table);
    

    wire [31:0] in32 = {in, 1'b1, 13'b0};
    wire [5:0] leading_zeros;
    clz32 clz(in32, leading_zeros);
    reg [17:0] in1;
    reg [4:0] full_valp0;
    
    always @(posedge clk) begin 
        in1 <= in << leading_zeros;
        full_valp0 <= 17 - leading_zeros[4:0];
    end

    reg [7:0] index1, index2;
    reg [10:0] alpha0;
    reg [4:0] full_val0;
    
    always @(posedge clk) begin 
        index1 <= {1'b0, in1[16:10]};
        index2 <= {1'b0, in1[16:10]} + 1;
        alpha0 <= {in1[9:0], 1'b0};
        full_val0 <= full_valp0;
    end

    reg [16:0] val1, val2;
    reg [10:0] alpha;
    reg [11:0] alpha_inv;
    reg [4:0] full_val1;
    

    always @(posedge clk) begin 
        val1 <= lookup_table[index1];
        val2 <= lookup_table[index2];
        alpha <= alpha0;
        alpha_inv <= {1'b0, ~alpha0} + 1;
        full_val1 <= full_val0;
    end
    
    reg [27:0] mult1, mult2;
    reg [4:0] full_val2;
    
    always @(posedge clk) begin 
        mult1 <= 28'(unsigned'(val1)) * alpha_inv;
        mult2 <= 28'(unsigned'(val2)) * alpha;
        full_val2 <= full_val1;
    end
    
    reg [31:0] out_buf;
    
    always @(posedge clk) begin 
        out_buf <= {4'b0, mult1 + mult2} + {full_val2, 27'b0};
    end
    
    assign out = out_buf[31:11];

    
    /* verilator lint_off WIDTH */
    //assign debug = out_buf;
    /* verilator lint_on WIDTH */

endmodule
