## IceBreaker Character LCD Example "display"

This Verilog example program validates the function of an HD44780-compatible character LCD display,
using the PMOD character LCD PMOD module connected to the IceBreaker PMOD connectors 1A/1B.

<img src=./icebreaker-progrun.jpg width="640px">

The IceBreaker push-button UBUTTON is used to toggle the display message on, and off (CLS). The LCD control line status is shown on  a (optional) Digilent PMOD 8LD, connected to PMOD2. The communication data is shown on LEDs D1..D6, while LEDs D7 and D8 show the UBUTTON toggle state.

### Pin Assignment

<img src=./icebreaker-pinout.svg width="600px">

### Usage

```
fm@nuc7fpga:~/fpga/hardware/pmod-charlcd/examples/icebreaker/display$ make
/home/fm/oss-cad-suite/bin/yosys -p 'synth_ice40 -top display -json display.json' display.v debounce.v lcd_transmit.v
...
/home/fm/oss-cad-suite/bin/nextpnr-ice40 --package sg48 --up5k --asc display.asc --pcf icebreaker.pcf --json display.json --force
...
Info: Device utilisation:
Info: 	         ICESTORM_LC:   186/ 5280     3%
Info: 	        ICESTORM_RAM:     0/   30     0%
Info: 	               SB_IO:    21/   96    21%
Info: 	               SB_GB:     3/    8    37%
...
Info: Program finished normally.
/home/fm/oss-cad-suite/bin/icetime -d up5k -mtr display.rpt display.asc
// Reading input .asc file..
// Reading 5k chipdb file..
// Creating timing netlist..
// Timing estimate: 1000010.68 ns (0.00 MHz)
/home/fm/oss-cad-suite/bin/icepack display.asc display.bin
```

```
fm@nuc7fpga:~/fpga/hardware/pmod-charlcd/examples/icebreaker/display$ make prog
Programming to Flash:
/usr/bin/iceprog display.bin
init..
cdone: high
reset..
cdone: low
flash ID: 0xEF 0x40 0x18 0x00
file size: 104090
erase 64kB sector at 0x000000..
erase 64kB sector at 0x010000..
programming..
done.
reading..
VERIFY OK
cdone: high
Bye.
```


