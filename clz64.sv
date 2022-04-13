
module clzi
    #(parameter n=2)();

    function [n:0] clzi(input [2*n-1:0] in);
        if (in[n-1+n] == 0) begin 
            return { (in[n-1+n] & in[n-1]), 1'b0, in[(2*n-2):n] };
        end else begin 
            return { (in[n-1+n] & in[n-1]), !in[n-1], in[(n-2):0] };
        end
    endfunction

endmodule

module clz64
(
    input [63:0] x,
    output [5:0] y
);


    function [1:0] enc(input [1:0] in);
        return (in == 2'b00) ? 2'b10 : (in == 2'b01) ? 2'b01 : 2'b00;
    endfunction

    clzi#(2) clzi2();
    clzi#(3) clzi4();
    clzi#(4) clzi8();
    clzi#(5) clzi16();
    clzi#(6) clzi32();
    
    wire [63:0] e;
    for(genvar i = 0; i < 32; i++) 
        assign e[i*2+1:i*2] = enc(x[i*2+1:i*2]);

    wire [47:0] a;
    for(genvar i = 0; i < 16; i++) 
        assign a[i*3+2:i*3] = clzi2.clzi(e[i*4+3:i*4]);

    wire [31:0] b;
    for(genvar i = 0; i < 8; i++) 
        assign b[i*4+3:i*4] = clzi4.clzi(a[i*6+5:i*6]);

    wire [19:0] c;
    for(genvar i = 0; i < 4; i++) 
        assign c[i*5+4:i*5] = clzi8.clzi(b[i*8+7:i*8]);

    wire [11:0] d;
    for(genvar i = 0; i < 2; i++) 
        assign d[i*6+5:i*6] = clzi16.clzi(c[i*10+9:i*10]);

    wire [6:0] res = clzi32.clzi(d[11:0]);
    assign y = res[5:0];

endmodule