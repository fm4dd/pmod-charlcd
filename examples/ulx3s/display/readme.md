## ULX3S Character LCD Example "display"

This Verilog example program validates the function of an HD44780-compatible character LCD display.
I am using a PMOD character LCD module from https://github.com/fm4dd/pmod-charlcd, connected to the
ULX3S PMOD connectors on the right-side pin socket J2.

<img src=./ulx3s-progrun.jpg width="640px">

The ULX3S push-button F1 is used to toggle the display message on, and off (CLS).

The LCD control line status is shown on the onboard LEDs.
The communication data is shown on LEDs D0..D5, while LEDs D6 and D7 show the F1 toggle state.

### Pin Assignment

<img src=./ulx3s-pinout.svg width="600px">

### Usage

```
fm@nuc7fpga:~/fpga/hardware/pmod-charlcd/examples/ulx3s/display$ make all
/home/fm/oss-cad-suite/bin/yosys -p 'synth_ecp5 -top display -noccu2 -nomux -nodram -json display.json' display.v debounce.v lcd_transmit.v
...
=== display ===

   Number of wires:                149
   Number of wire bits:            747
   Number of public wires:         149
   Number of public wire bits:     747
   Number of memories:               0
   Number of memory bits:            0
   Number of processes:              0
   Number of cells:                255
     LUT4                          179
     TRELLIS_FF                     76

...
/home/fm/oss-cad-suite/bin/nextpnr-ecp5 --85k --package CABGA381 --textcfg display.asc --lpf ulx3s.lpf --json display.json --force
...
Info: Device utilisation:
Info: 	          TRELLIS_IO:    21/  365     5%
Info: 	                DCCA:     1/   56     1%
...
Info: 	          TRELLIS_FF:    76/83640     0%
Info: 	        TRELLIS_COMB:   180/83640     0%
...
Info: Program finished normally.
/home/fm/oss-cad-suite/bin/ecppack display.asc --svf display.svf
/home/fm/oss-cad-suite/bin/ecppack display.asc --bit display.bit
```

```
fm@nuc7fpga:~/fpga/hardware/pmod-charlcd/examples/ulx3s/display$ make prog
Programming FPGA:
/home/fm/oss-cad-suite/bin/fujprog -b 115200 -j sram -T bit display.bit
ULX2S / ULX3S JTAG programmer v4.8 (git cc3ea93 built Nov 15 2022 18:03:02)
Copyright (C) Marko Zec, EMARD, gojimmypi, kost and contributors
Using USB cable: ULX3S FPGA 85K v3.0.8
Programming: 100%  
Completed in 44.65 seconds.
```


