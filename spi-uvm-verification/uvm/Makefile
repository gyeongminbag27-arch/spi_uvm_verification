VCS_OPTS  = -full64 -sverilog
VCS_OPTS += -ntb_opts uvm-1.2
VCS_OPTS += -timescale=1ns/1ps
VCS_OPTS += -debug_access+all
VCS_OPTS += -kdb -lca
VCS_OPTS += -cm line+cond+fsm+tgl+branch+assert

VCS_INCDIR = +incdir+./tb

VCS_OUTPUT = -o simv

VCS_SRC_FILES  = ./spi.sv
VCS_SRC_FILES += ./tb/spi_if.sv
VCS_SRC_FILES += ./tb/spi_pkg.sv
VCS_SRC_FILES += ./tb/tb_top.sv

TEST ?= spi_test
SEED ?= 1234
INFO_LEVEL ?= UVM_LOW

SIMV_OPTS  = +UVM_TESTNAME=$(TEST)
SIMV_OPTS += +UVM_VERBOSITY=$(INFO_LEVEL)
SIMV_OPTS += +ntb_random_seed=$(SEED)
SIMV_OPTS += -cm line+cond+fsm+tgl+branch+assert
SIMV_OPTS += -cm_dir coverage.vdb
SIMV_OPTS += -cm_name $(TEST)_$(SEED)

.PHONY: all comp simv sim urg clean

all: simv

comp:
	vcs $(VCS_OPTS) $(VCS_INCDIR) $(VCS_SRC_FILES) $(VCS_OUTPUT)
	@echo "컴파일 완료"

simv: comp
	./simv $(SIMV_OPTS)
	@echo "시뮬레이션 완료"

sim: simv

urg:
	urg -dir coverage.vdb -format both -report urgReport
	@echo "URG coverage report 생성 완료: urgReport"

clean:
	rm -rf simv* csrc *.log *.key *.vpd *.fsdb novas.* verdiLog *.h coverage.vdb urgReport
	@echo "결과물 정리 완료"