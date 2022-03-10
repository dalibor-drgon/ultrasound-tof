module ft(
    input clk,
    input rst,
    input signed [11:0] data,
    output unsigned [8:0] offset,
    output signed [63:0] cos_sum,
    output signed [63:0] sin_sum
);


    /** Offset **/

    reg [8:0] offset_cnt = 0;
    assign offset = offset_cnt;
    always @(posedge clk) begin 
        if (rst == 1) begin 
            offset_cnt <= 0;
        end else if (offset_cnt == 399) begin
            offset_cnt <= 0;
        end else begin 
            offset_cnt <= offset_cnt + 1;
        end
    end
    

    /** Cos & Sin table **/
    reg signed [47:0] cos;
    reg signed [47:0] sin;

    cos_sin cos_sin_table(
        clk,
        offset_cnt,
        cos,
        sin
    );
    
    /** Sum calculation **/
    reg signed [12:0] data_diff;
    reg signed [11:0] circular_buffer [0:399];
    reg signed [11:0] read_val;
    reg signed [11:0] data_pipelined;

    always @(posedge clk) begin 
        if (rst == 1) begin 
            //data_diff <= 0;
        end else begin 
            read_val <= circular_buffer[offset_cnt];
            circular_buffer[offset_cnt] <= data;
            data_pipelined <= data;
        end
    end
    
    always @(posedge clk) begin 
        data_diff <= 13'(signed'(data_pipelined)) - 13'(signed'(read_val));
    end
    

    /** Difference calculation **/
    reg signed [60:0] diff_cos = 0;
    reg signed [60:0] diff_sin = 0;

    always @(posedge clk) begin
        diff_cos <= 61'(signed'(data_diff)) * 61'(signed'(cos));
        diff_sin <= 61'(signed'(data_diff)) * 61'(signed'(sin));
    end

    reg signed [69:0] sum_cos = 0;
    reg signed [69:0] sum_sin = 0;
    assign cos_sum = sum_cos[69:6];
    assign sin_sum = sum_sin[69:6];
    always @(posedge clk) begin 
        if (rst == 1) begin 
            //sum_cos <= 0;
            //sum_sin <= 0;
        end else begin 
            sum_cos <= sum_cos + 70'(signed'(diff_cos));
            sum_sin <= sum_sin + 70'(signed'(diff_sin));
        end
    end
    

endmodule
