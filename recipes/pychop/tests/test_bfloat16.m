addpath("chop");
file = fopen("verified_data.txt");
values = fscanf(file, '%f');

%% half precision rounding to nearest ties to even and subnormal=0 
delete 'bfloat16/bfloat16_rmode_1_subnormal_0.txt';

options.format = 'bfloat16';
options.round = 1;
options.subnormal = 0;
chop([],options)

for i=1:10
    emu_val = chop(values(i))
    lines = string(emu_val);
    filename = "bfloat16/bfloat16_rmode_1_subnormal_0.txt";
    writelines(lines, filename, WriteMode="append")
end

emu_vals = chop(values);
save("bfloat16/bfloat16_rmode_1_subnormal_0.mat", "emu_vals")

%% half precision round up and subnormal=0 
delete 'bfloat16/bfloat16_rmode_2_subnormal_0.txt';

options.format = 'bfloat16';
options.round = 2;
options.subnormal = 0;
chop([],options)


for i=1:10
    emu_val = chop(values(i))
    lines = string(emu_val);
    filename = "bfloat16/bfloat16_rmode_2_subnormal_0.txt";
    writelines(lines, filename, WriteMode="append")
end

emu_vals = chop(values);
save("bfloat16/bfloat16_rmode_2_subnormal_0.mat", "emu_vals")



%% half precision round up and subnormal=0 
delete 'bfloat16/bfloat16_rmode_3_subnormal_0.txt';

options.format = 'bfloat16';
options.round = 3;
options.subnormal = 0;
chop([],options)

for i=1:10
    emu_val = chop(values(i))
    lines = string(emu_val);
    filename = "bfloat16/bfloat16_rmode_3_subnormal_0.txt";
    writelines(lines, filename, WriteMode="append")
end

emu_vals = chop(values);
save("bfloat16/bfloat16_rmode_3_subnormal_0.mat", "emu_vals")


%% half precision round up and subnormal=0 
delete 'bfloat16/bfloat16_rmode_4_subnormal_0.txt';

options.format = 'bfloat16';
options.round = 4;
options.subnormal = 0;
chop([],options)

for i=1:10
    emu_val = chop(values(i))
    lines = string(emu_val);
    filename = "bfloat16/bfloat16_rmode_4_subnormal_0.txt";
    writelines(lines, filename, WriteMode="append")
end

emu_vals = chop(values);
save("bfloat16/bfloat16_rmode_4_subnormal_0.mat", "emu_vals")

%% half precision rounding to nearest ties to even and subnormal=1 
scaling = 1000;
delete 'bfloat16/bfloat16_rmode_1_subnormal_1.txt';

options.format = 'bfloat16';
options.round = 1;
options.subnormal = 1;
chop([],options)

for i=1:10
    emu_val = chop(values(i)/scaling)
    lines = string(emu_val);
    filename = "bfloat16/bfloat16_rmode_1_subnormal_1.txt";
    writelines(lines, filename, WriteMode="append")
end

emu_vals = chop(values/scaling);
save("bfloat16/bfloat16_rmode_1_subnormal_1.mat", "emu_vals")


%% half precision round up and subnormal=1 
delete 'bfloat16/bfloat16_rmode_2_subnormal_1.txt';

options.format = 'bfloat16';
options.round = 2;
options.subnormal = 1;
chop([],options)


for i=1:10
    emu_val = chop(values(i)/scaling)
    lines = string(emu_val);
    filename = "bfloat16/bfloat16_rmode_2_subnormal_1.txt";
    writelines(lines, filename, WriteMode="append")
end

emu_vals = chop(values/scaling);
save("bfloat16/bfloat16_rmode_2_subnormal_1.mat", "emu_vals")


%% half precision round up and subnormal=0 
delete 'bfloat16/bfloat16_rmode_3_subnormal_1.txt';

options.format = 'bfloat16';
options.round = 3;
options.subnormal = 1;
chop([],options)

for i=1:10
    emu_val = chop(values(i)/scaling)
    lines = string(emu_val);
    filename = "bfloat16/bfloat16_rmode_3_subnormal_1.txt";
    writelines(lines, filename, WriteMode="append")
end

emu_vals = chop(values/scaling);
save("bfloat16/bfloat16_rmode_3_subnormal_1.mat", "emu_vals")


%% half precision round up and subnormal=0 
delete 'bfloat16/bfloat16_rmode_4_subnormal_1.txt';

options.format = 'bfloat16';
options.round = 4;
options.subnormal = 1;
chop([],options)

for i=1:10
    emu_val = chop(values(i)/scaling)
    lines = string(emu_val);
    filename = "bfloat16/bfloat16_rmode_4_subnormal_1.txt";
    writelines(lines, filename, WriteMode="append")
end

emu_vals = chop(values/scaling);
save("bfloat16/bfloat16_rmode_4_subnormal_1.mat", "emu_vals")
