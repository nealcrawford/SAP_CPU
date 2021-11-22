SCRIPT = $(shell basename `pwd`)

cpu_targets := $(wildcard hdl/*.v hdl/*.sv)

all: ip

ip: component.xml

component.xml: $(cpu_targets)
	vivado -mode batch -source tcl/$(SCRIPT).tcl
	rm -rf ip_* vivado*.* xgui/ .Xil* *.*~ webtalk*

clean:
	rm -rf ip_* vivado*.* *.xml xgui/ .Xil* *.*~ webtalk*