
global log2_size = 128;
global atan2_size = 32;
global interpolation_bits = 12;
global bits_of_precision = 24;
global sqrt_size = 64;

function res = round_bits(val) 
    global bits_of_precision;
    res = round(val * 2^bits_of_precision) / 2^bits_of_precision;
end


function log2_table = generate_log2_table(log2_size)
    log2_table = [];
    for i = 1:log2_size 
        log2_table = [log2_table; round_bits(log2(1 + (i-1)/log2_size))];
    end
    log2_table = [log2_table; 1];
end


function atan2_table = generate_atan2_table(size, z_range) 
    atan2_table = [];
    for z = 0:(z_range-1)
        for i = 1:size
            atan2_table = [atan2_table; round_bits(atan(2^(z + (i-1)/size)))];
        end
    end
    atan2_table = [atan2_table; round_bits(atan(2^(z_range)))];
end

function sqrt_table = generate_sqrt_table(size) 
    sqrt_table = [];
    for y = 1:2
        for x = 0:(size-1)j
            sqrt_table = [sqrt_table; sqrt(y*(1+x/size))];
        end
    end
    sqrt_table = [sqrt_table; 2];
end

global log2_table = generate_log2_table(log2_size);
global atan2_table = generate_atan2_table(atan2_size, 18);
global sqrt_table = generate_sqrt_table(sqrt_size);

% x must be positive
function res = log2b(x)
    global log2_size;
    global log2_table;
    global interpolation_bits;

    b = floor(log2(x));
    c = x / 2 ** b;
    c_fixed = (c-1) * log2_size;
    index = floor(c_fixed) + 1;
    alpha = floor(mod(c_fixed, 1) * (2 .** interpolation_bits)) / (2 .** interpolation_bits);
    
    v1 = log2_table(index);
    v2 = log2_table(index+1);
    res = b + v1 * (1-alpha) + v2 * alpha;

end

function res = atanb(x)
    global atan2_size;
    global atan2_table;
    global interpolation_bits;

    log = log2b(x);
    c_fixed = log * atan2_size;
    index = floor(c_fixed) + 1;
    alpha = floor(mod(c_fixed, 1) * (2 .** interpolation_bits)) / (2 .** interpolation_bits);
    
    v1 = atan2_table(index);
    v2 = atan2_table(index+1);
    res = v1 * (1-alpha) + v2 * alpha;
end


function res = sqrtb(x)
    global sqrt_size;
    global sqrt_table;
    global interpolation_bits;

    b = floor(log2(x));
    c = x / 2 ** floor(b);
    
    newb = floor(b / 2);
    index = floor((c-1) * sqrt_size) + 1;
    if mod(b, 2) == 1
        index = index + sqrt_size;
    end
    alpha = floor((c-1) * (2 .** interpolation_bits)) / (2 .** interpolation_bits);
    v1 = sqrt_table(index);
    v2 = sqrt_table(index+1);
    res = (v1 * (1-alpha) + v2 * alpha) * (2 .^ newb);
end

%sqrt_table
%sqrtb(3.934)
%sqrt(3.934)

function res = atan2b(y,x)
    if y >= 0
        if x > 0
            res = atanb(y/x)
        elseif x < 0 
            res = pi - atanb(y/-x)
        else 
            res = 0;
        end
    else 
        if x > 0
            res = -atanb(-y/x)
        elseif x < 0 
            res = -pi + atanb(-y/-x)
        else 
            res = 0;
        end

    end
end


max_error = 0;
max_error_num = 0;
for i = 1:4000 
    num = 2**(rand() * 16);
    err = abs(log2b(num) - log2(num));
    if err > max_error
        max_error = err;
        max_error_num = num;
    end
end

[ "Log2 max error: " mat2str(max_error) " at " mat2str(max_error_num) ]


max_error = 0;

for i = 1:4000 
    num = 2**(rand() * 16);
    err = abs(atanb(num) - atan(num));
    if err > max_error
        max_error = err;
        max_error_num = num;
    end
end

[ "Atan max error: " mat2str(max_error) " at " mat2str(max_error_num) ]

max_error = 0;

for i = 1:4000 
    num = 2**(rand() * 16);
    err = abs(sqrtb(num) - sqrt(num)) / (2^floor(log2(num)));
    if err > max_error
        max_error = err;
        max_error_num = num;
    end
end

[ "Sqrt max error: " mat2str(max_error) " at " mat2str(max_error_num) ]

function out = write_table(file, table, width, coef, offs=0)
    id = fopen(file, 'w');
    for i = 1:length(table)
        fprintf(id, ["%0" int2str(width) "x\n"], round((table(i) - offs) * coef))
    end
    fclose(id);
end


write_table("log2_128.hex", log2_table, 5, 2^16);
write_table("atan_18_32.hex", atan2_table, 5, 2^17/(pi/4), pi/4);

num_to_fraction_table = [];

for i = 0:499 
    num_to_fraction_table = [num_to_fraction_table, round(i * (2^16) / 500)];
end

write_table("num500_to_fraction.hex", num_to_fraction_table, 4, 1);

