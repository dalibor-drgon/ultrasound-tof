module atan_transform(
    input clk,
    input signed [63:0] cos_sum,
    input signed [63:0] sin_sum,
    //input unsigned [8:0] offset_num,
    //input unsigned [15:0] offset_hi,
    output unsigned [15:0] offset,
    output [31:0] debug
    //output unsigned [31:0] magnitude
);

    /*** Stage 0 - get absolute values **/
    
    reg [63:0] cos_sum0;
    reg [63:0] sin_sum0;
    reg cos_neg0;
    reg sin_neg0;

    always @(posedge clk) begin 
        cos_sum0 <= (cos_sum < 0) ? -cos_sum : cos_sum;
        cos_neg0 <= cos_sum < 0;
        sin_sum0 <= (sin_sum < 0) ? -sin_sum : sin_sum;
        sin_neg0 <= sin_sum < 0;
    end


    /*** Stage 1 - "normalize" logs **/

    wire [6:0] leading_zeros_cos;
    wire [6:0] leading_zeros_sin;
    clz64 clz_cos(cos_sum0, leading_zeros_cos);
    clz64 clz_sin(sin_sum0, leading_zeros_sin);

    reg [6:0] shift_left1;
    reg [63:0] cos_sum1;
    reg [63:0] sin_sum1;
    reg cos_neg1;
    reg sin_neg1;

    
    always @(posedge clk) begin 
        shift_left1 <= (leading_zeros_cos > leading_zeros_sin) ? leading_zeros_sin : leading_zeros_cos;
        cos_sum1 <= cos_sum0;
        sin_sum1 <= sin_sum0;
        cos_neg1 <= cos_neg0;
        sin_neg1 <= sin_neg0;
    end
    


    /** Stage 2 - "normalize" logs cont. **/

    reg [63:0] _cos_sum2;
    reg [63:0] _sin_sum2;
    wire [17:0] cos_sum2 = _cos_sum2[63:46];
    wire [17:0] sin_sum2 = _sin_sum2[63:46];
    reg cos_neg2;
    reg sin_neg2;
    wire cos_zero2 = cos_sum2 == 0;
    wire sin_zero2 = sin_sum2 == 0;

    // 3 cc debug
    //assign debug = {cos_sum2[17:10], sin_sum2[17:10], 6'b0, cos_neg2, cos_zero2, 6'b0, sin_neg2, sin_zero2};
    
    always @(posedge clk) begin 
        _cos_sum2 <= cos_sum1 << shift_left1;
        _sin_sum2 <= sin_sum1 << shift_left1;
        cos_neg2 <= cos_neg1;
        sin_neg2 <= sin_neg1;
    end
    
    /** Stage 3 - calculate log2 (takes 4 cycles, see log2) **/
    
    wire [20:0] cos_log3;
    wire [20:0] sin_log3;
    wire cos_neg3;
    log2 log2_cos(clk, cos_sum2, cos_log3);
    log2 log2_sin(clk, sin_sum2, sin_log3);

    wire sin_neg3;
    wire cos_neg3;
    wire sin_zero3;
    wire cos_zero3;
    delayer #(5) delayer_cos_neg3 (clk, cos_neg2, cos_neg3);
    delayer #(5) delayer_sin_neg3 (clk, sin_neg2, sin_neg3);
    delayer #(5) delayer_cos_zero3 (clk, cos_zero2, cos_zero3);
    delayer #(5) delayer_sin_zero3 (clk, sin_zero2, sin_zero3);

    // 8cc debug
    assign debug = {cos_log3[20:13], sin_log3[20:13], 6'b0, cos_neg3, cos_zero3, 6'b0, sin_neg3, sin_zero3};

    
    /** Stage 4 - calculate input for atan */

    wire sin_neg4;
    wire cos_neg4;
    wire sin_zero4;
    wire cos_zero4;
    delayer #(1) delayer_cos_neg4 (clk, cos_neg3, cos_neg4);
    delayer #(1) delayer_sin_neg4 (clk, sin_neg3, sin_neg4);
    delayer #(1) delayer_cos_zero4 (clk, cos_zero3, cos_zero4);
    delayer #(1) delayer_sin_zero4 (clk, sin_zero3, sin_zero4);

    reg [20:0] diff_log4;
    reg diff_neg4;
    
    always @(posedge clk) begin 
        if (cos_log3 <= sin_log3) begin 
            diff_neg4 <= 0;
            diff_log4 <= sin_log3 - cos_log3;
        end else begin 
            diff_neg4 <= 1;
            diff_log4 <= cos_log3 - sin_log3;
        end
    end

    /** Stage 5 - Atan */
    
    wire sin_neg5;
    wire cos_neg5;
    wire sin_zero5;
    wire cos_zero5;
    delayer #(4) delayer_cos_neg5 (clk, cos_neg4, cos_neg5);
    delayer #(4) delayer_sin_neg5 (clk, sin_neg4, sin_neg5);
    delayer #(4) delayer_cos_zero5 (clk, cos_zero4, cos_zero5);
    delayer #(4) delayer_sin_zero5 (clk, sin_zero4, sin_zero5);

    wire diff_neg5;
    delayer #(4) delayer_diff_neg5 (clk, diff_neg4, diff_neg5);

    wire [19:0] atan5;
    atan calc_atan(clk, diff_log4, atan5);

    //assign debug[15:0] = atan5[19:4];
    //assign debug[17:16] = { sin_zero5, cos_zero5};
    
    /** Stage 6 - adjust atan */

    reg [21:0] _atan6;
    reg [21:0] atan6;
    
    always @(posedge clk) begin 
        _atan6 = (diff_neg5) ? {2'b00, -{1'b1, atan5[19:1]}} : {3'b001, atan5[19:1]};
        if (!sin_neg5 && !sin_zero5) begin
            if (!cos_neg5 && !cos_zero5) begin 
                atan6 <= _atan6;
            end else if (cos_neg5 && !cos_zero5) begin 
                atan6 <= {2'b10, 20'b0} - _atan6;
            end else /* if (cos_zero4) */ begin 
                atan6 <= {2'b01, 20'b0};
            end
        end else if (sin_neg5 && !sin_zero5) begin 
            if (!cos_neg5 && !cos_zero5) begin 
                atan6 <= -_atan6;
            end else if (cos_neg5 && !cos_zero5) begin 
                atan6 <= -{2'b10, 20'b0} + _atan6;
            end else /* if (cos_zero4) */ begin 
                atan6 <= {2'b11, 20'b0};
            end

        end else /* if (sin_zero5) */ begin 
            if (!cos_neg5) begin 
                atan6 <= 0;
            end else begin 
                atan6 <= {2'b10, 20'b0};
            end
        end
    end
    
    assign offset = atan6[21:6];
    
    /*
    reg [15:0] num500_to_fraction [0:499];
    initial $readmemh("num500_to_fraction.hex", num500_to_fraction);
    
    reg [15:0] offset_low;

    always @(posedge clk) begin 
        offset_low <= num500_to_fraction[offset_num];
    end
    */
    


endmodule
