module FIFO(fifo_if.DUT fifo_type);

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
endmodule