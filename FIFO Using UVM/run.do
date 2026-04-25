vlib work
vlog -f src_files.list +cover -covercells
vsim -voptargs=+acc work.top -cover -classdebug -uvmcontrol=all
add wave /top/fifo_type/*
coverage save FIFO.ucdb -onexit
run -all

