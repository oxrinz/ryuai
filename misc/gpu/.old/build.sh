rm -f top.json top.asc top.bin 

yosys -p "synth_ice40 -top top -json top.json" src/**/*.sv src/*.sv

nextpnr-ice40 --hx1k --package vq100 \
    --json top.json \
    --pcf pins.pcf \
    --pcf-allow-unconstrained \
    --freq 3300 \
    --asc top.asc

icepack top.asc top.bin
iceprog top.bin