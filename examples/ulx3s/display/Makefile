PROJ     = display
ADD_SRC  = debounce.v lcd_transmit.v

PIN_DEF  = ulx3s.lpf
DEVICE   = 85k
PACKAGE  = CABGA381
TOOLPATH = /home/fm/oss-cad-suite/bin


all: $(PROJ).svf $(PROJ).bit

%.json: %.v
	$(TOOLPATH)/yosys -p 'synth_ecp5 -top $(PROJ) -noccu2 -nomux -nodram -json $@' $< $(ADD_SRC)

%.asc: %.json
	$(TOOLPATH)/nextpnr-ecp5 --$(DEVICE) --package $(PACKAGE) --textcfg $@ --lpf $(PIN_DEF) --json $^ --force

%.bit: %.asc
	$(TOOLPATH)/ecppack $< --bit $@

%.svf: %.asc
	$(TOOLPATH)/ecppack $< --svf $@

prog: $(PROJ).bit
	@echo 'Programming FPGA:'
	$(TOOLPATH)/fujprog -b 115200 -j sram -T bit $<

flash: $(PROJ).bit
	@echo 'Programming FPGA Flash:'
	$(TOOLPATH)/openFPGALoader --board=ulx3s --write-flash $<

clean:
	rm -f $(PROJ).json $(PROJ).asc $(PROJ).svf $(PROJ).bit

.SECONDARY:
.PHONY: all prog clean
