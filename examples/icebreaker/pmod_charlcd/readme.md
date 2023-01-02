## Build the code

```
fm@nuc7vm2204:~/fpga/hardware/pmod-charlcd/examples/icebreaker/pmod_charlcd$ make all
/usr/bin/yosys -p 'synth_ice40 -json pmod_charlcd.json' pmod_charlcd.v 

...

 Yosys 0.9+3619 (git sha1 c8f052bb, g++ 8.3.0 -Os)


-- Parsing `pmod_charlcd.v' using frontend `verilog' --

...

Info: Max frequency for clock 'clk$SB_IO_IN_$glb_clk': 41.22 MHz (PASS at 12.00 MHz)

Info: Max delay <async>                       -> posedge clk$SB_IO_IN_$glb_clk: 11.45 ns
Info: Max delay posedge clk$SB_IO_IN_$glb_clk -> <async>                      : 7.69 ns

Info: Slack histogram:
Info:  legend: * represents 1 endpoint(s)
Info:          + represents [1,1) endpoint(s)
Info: [ 59075,  60090) |************+
Info: [ 60090,  61105) |***********************************************+
Info: [ 61105,  62120) |******+
Info: [ 62120,  63135) |*+
Info: [ 63135,  64150) |*+
Info: [ 64150,  65165) |**+
Info: [ 65165,  66180) | 
Info: [ 66180,  67195) |*+
Info: [ 67195,  68210) |*******+
Info: [ 68210,  69225) |+
Info: [ 69225,  70240) |****+
Info: [ 70240,  71255) |************ 
Info: [ 71255,  72270) |**************************************+
Info: [ 72270,  73285) |*****+
Info: [ 73285,  74300) |*************+
Info: [ 74300,  75315) |***********+
Info: [ 75315,  76330) |************************+
Info: [ 76330,  77345) |******+
Info: [ 77345,  78360) |*******+
Info: [ 78360,  79375) |************************************************************ 
Info: Checksum: 0xbe39d6d2

Info: Routing..
Info: Setting up routing queue.
Info: Routing 1038 arcs.
Info:            |   (re-)routed arcs  |   delta    | remaining|       time spent     |
Info:    IterCnt |  w/ripup   wo/ripup |  w/r  wo/r |      arcs| batch(sec) total(sec)|
Info:       1000 |      188        793 |  188   793 |       265|       0.09       0.09|
Info:       1475 |      364       1071 |  176   278 |         0|       0.10       0.19|
Info: Routing complete.
Info: Router1 time 0.19s
Info: Checksum: 0xc59733d0

Info: Slack histogram:
Info:  legend: * represents 1 endpoint(s)
Info:          + represents [1,1) endpoint(s)
Info: [ 58557,  59606) |***************+
Info: [ 59606,  60655) |***************************+
Info: [ 60655,  61704) |**************************+
Info: [ 61704,  62753) |**+
Info: [ 62753,  63802) |*+
Info: [ 63802,  64851) |**+
Info: [ 64851,  65900) | 
Info: [ 65900,  66949) |*+
Info: [ 66949,  67998) |*******+
Info: [ 67998,  69047) |+
Info: [ 69047,  70096) |*****+
Info: [ 70096,  71145) |******+
Info: [ 71145,  72194) |********+
Info: [ 72194,  73243) |*****+
Info: [ 73243,  74292) |******************+
Info: [ 74292,  75341) |***************************************************+
Info: [ 75341,  76390) |***********************+
Info: [ 76390,  77439) |**+
Info: [ 77439,  78488) |**********+
Info: [ 78488,  79537) |************************************************************ 
/usr/bin/icetime -d up5k -mtr pmod_charlcd.rpt pmod_charlcd.asc
// Reading input .asc file..
// Reading 5k chipdb file..
// Creating timing netlist..
// Timing estimate: 24.97 ns (40.04 MHz)
/usr/bin/icepack pmod_charlcd.asc pmod_charlcd.bin
```

## Program the bitstream:

```
fm@nuc7vm2204:~/fpga/hardware/pmod-charlcd/examples/icebreaker/pmod_charlcd$ make prog
Executing prog as root!!!
sudo /usr/bin/iceprog pmod_charlcd.bin
init..
cdone: high
reset..
cdone: low
flash ID: 0xEF 0x40 0x18 0x00
file size: 104090
erase 64kB sector at 0x000000..
erase 64kB sector at 0x010000..
programming..
reading..
VERIFY OK
cdone: high
Bye.
```
