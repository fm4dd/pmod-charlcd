## Gatemate E1 Character LCD Example "display-2"

This Verilog example program validates the function of an HD44780-compatible character LCD display.
I am using a PMOD character LCD module from https://github.com/fm4dd/pmod-charlcd, connected to the
E1 PMOD connectors A/B.

<img src=./pmod-charlcd.jpg width="640px">

The E1 evaluation board switch SW3 is used to toggle the display message on, and off (CLS).

The LCD control line status is shown on the E1 onboard LEDs D1..D6, while LEDs D7 and D8 show the SW3 toggle state.

### Usage

```
fm@nuc7fpga:~/fpga/hardware/pmod-charlcd/examples/gatemate/display-2$ make all
/home/fm/cc-toolchain-linux/bin/yosys/yosys -ql log/synth.log -p 'read -sv src/debounce.v src/display.v src/lcd_transmit.v; synth_gatemate -top display -nomx8 -vlog net/display_synth.v'
/home/fm/cc-toolchain-linux/bin/p_r/p_r -i net/display_synth.v -o display -ccf src/gm-bare-pmod.ccf > log/impl.log
/home/fm/cc-toolchain-linux/bin/openFPGALoader/openFPGALoader  -b gatemate_evb_jtag display_00.cfg
Jtag frequency : requested 6.00MHz   -> real 6.00MHz  
Load SRAM via JTAG: [==================================================] 100.00%
Done
Wait for CFG_DONE DONE


```

