
generate-tables:
	gcc table-generator.c -lm -o table-generator 
	./table-generator
	gcc table-generator.c -lm -o table-generator -DDAC_SINE
	./table-generator

sim:
	verilator --cc ft.sv --exe sim-ft.cpp
	make -C obj_dir/ -f Vft.mk

sim-run:
	./obj_dir/Vft
