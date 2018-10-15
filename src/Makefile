default:build

build:
	@read -p "Enter module name: " file; \
	iverilog -o test.vvp $${file}_tb.v ; \
	vvp test.vvp; \
	open -a Scansion $${file}.vcd;


clean:
	rm -f *.vcd *.vvp *.out