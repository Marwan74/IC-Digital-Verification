////////////////////////////////////////////////////////////////////////////////
// Author: Kareem Waseem
// Course: Digital Verification using SV & UVM
//
// Description: FIFO Design 
// 
////////////////////////////////////////////////////////////////////////////////
module FIFO(interface_fifo.DUT fifo_type);

localparam max_fifo_addr = $clog2(fifo_type.FIFO_DEPTH);
reg [fifo_type.FIFO_WIDTH-1:0] mem [fifo_type.FIFO_DEPTH-1:0];

reg [max_fifo_addr-1:0] wr_ptr, rd_ptr;
reg [max_fifo_addr:0] count;

always @(posedge fifo_type.clk or negedge fifo_type.rst_n) begin
	if (!fifo_type.rst_n) begin
		wr_ptr <= 0;
		// Bug1 : in case of reset there was no defined behaviour for wr_ack,overflow
		fifo_type.wr_ack <= 0;
		fifo_type.overflow <= 0;
	end
	else if (fifo_type.wr_en && (count < fifo_type.FIFO_DEPTH)) begin
		mem[wr_ptr] <= fifo_type.data_in;
		fifo_type.wr_ack <= 1;
		wr_ptr <= wr_ptr + 1;
		//fifo_type.overflow <= 0;
	end
	else begin 
		fifo_type.wr_ack <= 0; 
		if (fifo_type.full & fifo_type.wr_en)
			fifo_type.overflow <= 1;
		else
			fifo_type.overflow <= 0;
	end
end

always @(posedge fifo_type.clk or negedge fifo_type.rst_n) begin
	if (!fifo_type.rst_n) begin
		rd_ptr <= 0;
		// Bug2 : in case of reset there was no defined behaviour for data_out,underflow
        fifo_type.underflow <= 0;
		fifo_type.data_out <= 0;
	end
	else if (fifo_type.rd_en && (count != 0)) begin
		fifo_type.data_out <= mem[rd_ptr];
		rd_ptr <= rd_ptr + 1;
		//fifo_type.underflow <= 0;
	end
	// bug3 : underflow is sequential noy combinational output
	else begin
		//fifo_type.data_out <= 0;
		if(fifo_type.empty && fifo_type.rd_en) begin
			fifo_type.underflow <= 1;
		end
		else begin
			fifo_type.underflow <= 0;
		end
	end
end

always @(posedge fifo_type.clk or negedge fifo_type.rst_n) begin
	if (! fifo_type.rst_n) begin
		count <= 0;
	end
	else begin
		if	( ({fifo_type.wr_en, fifo_type.rd_en} == 2'b10) && (! fifo_type.full)) 
			count <= count + 1;
		else if ( ({fifo_type.wr_en, fifo_type.rd_en} == 2'b01) && (! fifo_type.empty))
			count <= count - 1;
		//bugs detected
		else if (({fifo_type.wr_en, fifo_type.rd_en} == 2'b11) && fifo_type.full)
            count <= count - 1; 
		else if (({fifo_type.wr_en, fifo_type.rd_en} == 2'b11) && fifo_type.empty)
            count <= count + 1;
	end
end

assign fifo_type.full = (count == fifo_type.FIFO_DEPTH)? 1 : 0;
assign fifo_type.empty = (count == 0)? 1 : 0; 
assign fifo_type.almostfull = (count == (fifo_type.FIFO_DEPTH-1))? 1 : 0; // it must be -1 not -2
assign fifo_type.almostempty = (count == 1)? 1 : 0;

// assertions 
property prop1;
	@(posedge fifo_type.clk) (! fifo_type.rst_n) |=> ((wr_ptr === 0) && (rd_ptr === 0) && (count === 0));
endproperty

property prop2;
	@(posedge fifo_type.clk) disable iff (! fifo_type.rst_n) (fifo_type.wr_en && ! fifo_type.full) |=> (fifo_type.wr_ack);
endproperty

property prop3;
	@(posedge fifo_type.clk) disable iff (! fifo_type.rst_n) (fifo_type.wr_en && fifo_type.full) |=> (fifo_type.wr_ack === 0);
endproperty

property prop4;
	@(posedge fifo_type.clk) disable iff (! fifo_type.rst_n) (fifo_type.wr_en && fifo_type.full) |=> (fifo_type.overflow);
endproperty

property prop5;
	@(posedge fifo_type.clk) disable iff (! fifo_type.rst_n) (fifo_type.rd_en && fifo_type.empty) |=> (fifo_type.underflow);
endproperty

property prop6;
	@(posedge fifo_type.clk) disable iff (! fifo_type.rst_n) (count == 0) |-> (fifo_type.empty);
endproperty

property prop7;
	@(posedge fifo_type.clk) disable iff (! fifo_type.rst_n) (count == fifo_type.FIFO_DEPTH) |-> (fifo_type.full);
endproperty

property prop8;
	@(posedge fifo_type.clk) disable iff (! fifo_type.rst_n) (count == fifo_type.FIFO_DEPTH - 1) |-> (fifo_type.almostfull)
endproperty

property prop9;
	@(posedge fifo_type.clk) disable iff (! fifo_type.rst_n) (count == 1) |-> (fifo_type.almostempty);
endproperty

//internal counters properties
property prop10;
	@(posedge fifo_type.clk) disable iff (! fifo_type.rst_n) 
	(fifo_type.wr_en && ! fifo_type.rd_en && ! fifo_type.full) |=> ($stable(rd_ptr) && ((wr_ptr == $past(wr_ptr) + 1'b1) || ($past(wr_ptr) ==7 && wr_ptr == 0)) && (count == $past(count) + 1'b1));
endproperty

property prop11;
	@(posedge fifo_type.clk) disable iff (! fifo_type.rst_n)
	(! fifo_type.wr_en && fifo_type.rd_en && ! fifo_type.empty) |=> ($stable(wr_ptr) && ((rd_ptr == $past(rd_ptr) + 1'b1) || ($past(rd_ptr) ==7 && rd_ptr == 0)) && (count == $past(count) - 1'b1));
endproperty

property prop12;
	@(posedge fifo_type.clk) disable iff (! fifo_type.rst_n)
	(fifo_type.wr_en && fifo_type.rd_en && fifo_type.full) |=> ($stable(wr_ptr) && ((rd_ptr == $past(rd_ptr) + 1'b1) || ($past(rd_ptr) ==7 && rd_ptr == 0)) && (count == $past(count) - 1'b1));
endproperty

property prop13;
	@(posedge fifo_type.clk) disable iff (! fifo_type.rst_n)
	(fifo_type.wr_en && fifo_type.rd_en && fifo_type.empty) |=> ($stable(rd_ptr) && ((wr_ptr == $past(wr_ptr) + 1'b1) || ($past(wr_ptr) ==7 && wr_ptr == 0)) && (count == $past(count) + 1'b1));
endproperty

property prop14;
	@(posedge fifo_type.clk) disable iff (! fifo_type.rst_n)
	(! fifo_type.wr_en && ! fifo_type.rd_en && ! fifo_type.full && ! fifo_type.empty) |=> ($stable(wr_ptr) && $stable(rd_ptr) && $stable(count));
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