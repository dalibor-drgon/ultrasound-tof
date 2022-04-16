
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

