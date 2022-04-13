module delayer
#(
    parameter CYCLES = 1;
    parameter WIDTH = 1
)
(
    input clk,
    input [WIDTH-1:0] in,
    output [WIDTH-1:0] out
);

    reg [WIDTH-1:0] delay_reg [0:CYCLES-1];
    
    always @(posedge clk) begin 
        delay_reg[0] <= in;
        for(genvar i = 1; i < CYCLES; i++) begin 
            delay_reg[i] <= delay_reg[i-1];
        end
    end
    
    assign out = delay_reg[CYCLES-1];

endmodule
