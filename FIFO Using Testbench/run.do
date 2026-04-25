vlib work
vlog *v +cover -covercells
vsim -voptargs=+acc work.top -cover
add wave *
add wave -position insertpoint  \
sim:/top/fifo_type/data_in \
sim:/top/fifo_type/rst_n \
sim:/top/fifo_type/wr_en \
sim:/top/fifo_type/rd_en \
sim:/top/fifo_type/data_out \
sim:/top/fifo_type/wr_ack \
sim:/top/fifo_type/overflow \
sim:/top/fifo_type/full \
sim:/top/fifo_type/empty \
sim:/top/fifo_type/almostfull \
sim:/top/fifo_type/almostempty \
sim:/top/fifo_type/underflow \
sim:/top/Monitor/obj_board
coverage save top.ucdb -onexit -du work.FIFO
add wave /top/DUT/prop1_assert /top/DUT/prop2_assert /top/DUT/prop3_assert /top/DUT/prop4_assert /top/DUT/prop5_assert /top/DUT/prop6_assert /top/DUT/prop7_assert /top/DUT/prop8_assert /top/DUT/prop9_assert /top/DUT/prop10_assert /top/DUT/prop11_assert /top/DUT/prop12_assert /top/DUT/prop13_assert /top/DUT/prop14_assert 
run -all
#quit -sim 