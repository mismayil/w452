source=w452.v regfile.v mem.v w452_tb.v ieee754_sp.v

.PHONY: run
run: fetch ldst fp branch jump mult

# tb_fetch
.PHONY: fetch
fetch: tb_fetch.vvp
	vvp $<

.PHONY: fetch-debug
fetch-debug: tb_fetch.lx2
	gtkwave -A $< &

tb_fetch.vvp: $(source) fetch.data
	iverilog -s tb_fetch -o $@ $(source)

# tb_math
.PHONY: math
math: tb_math.vvp
	vvp $<

.PHONY: math-debug
math-debug: tb_math.lx2
	gtkwave -A $< &

tb_math.vvp: $(source) math.data
	iverilog -s tb_math -o $@ $(source)

# tb_ldst
.PHONY: ldst
ldst: tb_ldst.vvp
	vvp $<

.PHONY: ldst-debug
ldst-debug: tb_ldst.lx2
	gtkwave -A $< &

tb_ldst.vvp: $(source) ldst.data
	iverilog -s tb_ldst -o $@ $(source)

# tb_fp
.PHONY: fp
fp: tb_fp.vvp
	vvp $<

.PHONY: fp-debug
fp-debug: tb_fp.lx2
	gtkwave -A $< &

tb_fp.vvp: $(source) fp.data
	iverilog -s tb_fp -o $@ $(source)

# tb_branch
.PHONY: branch
branch: tb_branch.vvp
	vvp $<

.PHONY: branch-debug
branch-debug: tb_branch.lx2
	gtkwave -A $< &

tb_branch.vvp: $(source) branch.data
	iverilog -s tb_branch -o $@ $(source)

# tb_jump
.PHONY: jump
jump: tb_jump.vvp
	vvp $<

.PHONY: jump-debug
jump-debug: tb_jump.lx2
	gtkwave -A $< &

tb_jump.vvp: $(source) jump.data
	iverilog -s tb_jump -o $@ $(source)

# tb_mult
.PHONY: mult
mult: tb_mult.vvp
	vvp $<

.PHONY: mult-debug
mult-debug: tb_mult.lx2
	gtkwave -A $< &

tb_mult.vvp: $(source) mult.data
	iverilog -s tb_mult -o $@ $(source)

%.lx2: %.vvp
	vvp $< -lxt2
	mv dump.lx2 $@

clean:
	rm -f *.vvp *.lx2 *.vcd
