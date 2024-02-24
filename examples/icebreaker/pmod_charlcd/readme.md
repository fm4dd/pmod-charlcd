## IceBreaker Character LCD Example "pmod_charlcd"

This Verilog example program validates the function of an HD44780-compatible character LCD display.
The PMOD character LCD module from https://github.com/fm4dd/pmod-charlcd is connected to the
IceBreaker PMOD connectors 1A/1B.

<img src=../../../images/icebreaker.jpg width="640px">

The program displays the word "Hello" on line 1, and "World" on line 2.

### Usage

```
fm@nuc7fpga:~/fpga/hardware/pmod-charlcd/examples/icebreaker/pmod_charlcd$ make
/home/fm/oss-cad-suite/bin/yosys -p 'synth_ice40 -top pmod_charlcd -json pmod_charlcd.json' pmod_charlcd.v
...
Info: 	         ICESTORM_LC:   335/ 5280     6%
Info: 	        ICESTORM_RAM:     0/   30     0%
Info: 	               SB_IO:    13/   96    13%
Info: 	               SB_GB:     2/    8    25%
...
Info: Program finished normally.
/home/fm/oss-cad-suite/bin/icetime -d up5k -mtr pmod_charlcd.rpt pmod_charlcd.asc
// Reading input .asc file..
// Reading 5k chipdb file..
// Creating timing netlist..
// Timing estimate: 24.93 ns (40.11 MHz)
/home/fm/oss-cad-suite/bin/icepack pmod_charlcd.asc pmod_charlcd.bin
```

```
fm@nuc7fpga:~/fpga/hardware/pmod-charlcd/examples/icebreaker/pmod_charlcd$ make prog
Programming to Flash:
/home/fm/oss-cad-suite/bin/iceprog pmod_charlcd.bin
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