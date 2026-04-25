interface interface_fifo(input bit clk);
parameter FIFO_WIDTH = 16;
parameter FIFO_DEPTH = 8;
//input clk;
logic [FIFO_WIDTH-1:0] data_in;
logic rst_n, wr_en, rd_en;
logic [FIFO_WIDTH-1:0] data_out;
logic wr_ack, overflow;
logic full, empty, almostfull, almostempty, underflow;

modport DUT (input data_in, wr_en, rd_en, clk, rst_n , output full, empty, almostfull, almostempty, wr_ack, overflow, underflow, data_out);

modport TEST (output data_in, wr_en, rd_en, rst_n , input clk , full, empty, almostfull, almostempty, wr_ack, overflow, underflow, data_out);

modport monitor (input data_in, wr_en, rd_en, clk, rst_n , full, empty, almostfull, almostempty, wr_ack, overflow, underflow, data_out);

endinterface //interface_fifo(clk)