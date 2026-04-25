module fifo_sva(fifo_if fifo_type);
parameter FIFO_WIDTH = 16;
parameter FIFO_DEPTH = 8;
logic [FIFO_WIDTH-1:0] data_in;
logic clk,rst_n, wr_en, rd_en;
logic [FIFO_WIDTH-1:0] data_out;
logic wr_ack, overflow;
logic full, empty, almostfull, almostempty, underflow;
localparam max_fifo_addr = $clog2(fifo_type.FIFO_DEPTH);
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
assign clk = fifo_type.clk;
assign rst_n = fifo_type.rst_n;
assign rd_en = fifo_type.rd_en;
assign wr_en = fifo_type.wr_en;
assign data_in = fifo_type.data_in;
assign wr_ack = fifo_type.wr_ack;
assign data_out = fifo_type.data_out;
assign overflow = fifo_type.overflow;
assign underflow = fifo_type.underflow;
assign full = fifo_type.full;
assign empty = fifo_type.empty;
assign almostempty = fifo_type.almostempty;
assign almostfull = fifo_type.almostfull;

property prop1;
	@(posedge clk) (! rst_n) |=> ((DUT.wr_ptr === 0) && (DUT.rd_ptr === 0) && (DUT.count === 0));
endproperty

property prop2;
	@(posedge clk) disable iff (! rst_n) (wr_en && !full) |=> (wr_ack);
endproperty

property prop3;
	@(posedge clk) disable iff (! rst_n) (wr_en && full) |=> (wr_ack === 0);
endproperty

property prop4;
	@(posedge clk) disable iff (! rst_n) (wr_en && full) |=> (overflow);
endproperty

property prop5;
	@(posedge clk) disable iff (! rst_n) (rd_en && empty) |=> (underflow);
endproperty

property prop6;
	@(posedge clk) disable iff (! rst_n) (DUT.count == 0) |-> (empty);
endproperty

property prop7;
	@(posedge clk) disable iff (! rst_n) (DUT.count == FIFO_DEPTH) |-> (full);
endproperty

property prop8;
	@(posedge clk) disable iff (! rst_n) (DUT.count == FIFO_DEPTH - 1) |-> (almostfull)
endproperty

property prop9;
	@(posedge clk) disable iff (! rst_n) (DUT.count == 1) |-> (almostempty);
endproperty

//internal DUT.counters properties
property prop10;
	@(posedge clk) disable iff (! rst_n) 
	(wr_en && ! rd_en && !full) |=> ($stable(DUT.rd_ptr) && ((DUT.wr_ptr == $past(DUT.wr_ptr) + 1'b1) || ($past(DUT.wr_ptr) ==7 && DUT.wr_ptr == 0)) && (DUT.count == $past(DUT.count) + 1'b1));
endproperty

property prop11;
	@(posedge clk) disable iff (! rst_n)
	(!wr_en && rd_en && ! empty) |=> ($stable(DUT.wr_ptr) && ((DUT.rd_ptr == $past(DUT.rd_ptr) + 1'b1) || ($past(DUT.rd_ptr) ==7 && DUT.rd_ptr == 0)) && (DUT.count == $past(DUT.count) - 1'b1));
endproperty

property prop12;
	@(posedge clk) disable iff (! rst_n)
	(wr_en && rd_en && full) |=> ($stable(DUT.wr_ptr) && ((DUT.rd_ptr == $past(DUT.rd_ptr) + 1'b1) || ($past(DUT.rd_ptr) ==7 && DUT.rd_ptr == 0)) && (DUT.count == $past(DUT.count) - 1'b1));
endproperty

property prop13;
	@(posedge clk) disable iff (! rst_n)
	(wr_en && rd_en && empty) |=> ($stable(DUT.rd_ptr) && ((DUT.wr_ptr == $past(DUT.wr_ptr) + 1'b1) || ($past(DUT.wr_ptr) ==7 && DUT.wr_ptr == 0)) && (DUT.count == $past(DUT.count) + 1'b1));
endproperty

property prop14;
	@(posedge clk) disable iff (! rst_n)
	(!wr_en && ! rd_en && ! full && ! empty) |=> ($stable(DUT.wr_ptr) && $stable(DUT.rd_ptr) && $stable(DUT.count));
endproperty

      /* ------------------------------------ asserting properties ----------------------------------------------*/
	  
prop1_assert : assert property (prop1);
prop2_assert : assert property (prop2);
prop3_assert : assert property (prop3);
prop4_assert : assert property (prop4);
prop5_assert : assert property (prop5);
prop6_assert : assert property (prop6);
prop7_assert : assert property (prop7);
prop8_assert : assert property (prop8);
prop9_assert : assert property (prop9);
prop10_assert : assert property (prop10);
prop11_assert : assert property (prop11);
prop12_assert : assert property (prop12);
prop13_assert : assert property (prop13);
prop14_assert : assert property (prop14);

     /* ----------------------------------------- cover properties ------------------------------------------------*/

prop1_cover : cover property (prop1);
prop2_cover : cover property (prop2);
prop3_cover : cover property (prop3);
prop4_cover : cover property (prop4);
prop5_cover : cover property (prop5);
prop6_cover : cover property (prop6);
prop7_cover : cover property (prop7);
prop8_cover : cover property (prop8);
prop9_cover : cover property (prop9);
prop10_cover : cover property (prop10);
prop11_cover : cover property (prop11);
prop12_cover : cover property (prop12);
prop13_cover : cover property (prop13);
prop14_cover : cover property (prop14);
endmodule