default:build

build:
	iverilog -o test.vvp project-phase2-testbench.v ; \
	vvp test.vvp;

scan:
	open -a Scansion dump.vcd

clean:
	rm -f *.vcd *.vvp *.out *.log *.trace *.plog *.ptrace