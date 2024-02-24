PROJ     = display
ADD_SRC  = debounce.v lcd_transmit.v

PIN_DEF  = icebreaker.pcf
DEVICE   = up5k
PACKAGE  = sg48
TOOLPATH = /home/fm/oss-cad-suite/bin

all: $(PROJ).rpt $(PROJ).bin

%.json: %.v
	$(TOOLPATH)/yosys -p 'synth_ice40 -top $(PROJ) -json $@' $< $(ADD_SRC)

%.asc: %.json
	$(TOOLPATH)/nextpnr-ice40 --package $(PACKAGE) --$(DEVICE) --asc $@ --pcf $(PIN_DEF) --json $^ --force

%.bin: %.asc
	$(TOOLPATH)/icepack $< $@

%.rpt: %.asc
	$(TOOLPATH)/icetime -d $(DEVICE) -mtr $@ $<

test:
	@echo 'Running testbench simulation'
	test ! -e $(PROJ).tb || rm $(PROJ).tb
	test ! -e $(PROJ).vcd || rm $(PROJ).vcd
	$(TOOLPATH)/iverilog -o $(PROJ).tb -s $(PROJ)_tb ./*.v
	$(TOOLPATH)/vvp $(PROJ).tb

prog: $(PROJ).bin
	@echo 'Programming to Flash:'
	$(TOOLPATH)/iceprog $<

clean:
	rm -f $(PROJ).json $(PROJ).asc $(PROJ).rpt $(PROJ).bin $(PROJ).vcd $(PROJ).tb abc.history

.SECONDARY:
.PHONY: all prog test clean
