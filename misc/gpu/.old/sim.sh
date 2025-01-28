rm -f sim.vcd
rm -f testbench
rm -f *.out

iverilog -g2012 -o testbench \
    src/****/***.sv \
    src/***.sv \
    tb.sv

./tb

gtkwave sim.vcd waveform.gtkw