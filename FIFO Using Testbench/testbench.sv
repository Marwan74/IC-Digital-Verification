import shared_pkg::*;
import Transaction_pkg::*;
module testbench (interface_fifo.TEST fifo_type);
  FIFO_transaction obj = new();
  initial begin
    fifo_type.data_in = 0;
    fifo_type.rst_n = 0;
    fifo_type.wr_en = 0;
    fifo_type.rd_en= 0;
    repeat(2) @(negedge fifo_type.clk);
    fifo_type.rst_n = 1;

      repeat(10000) begin
        assert(obj.randomize());
        fifo_type.data_in = obj.data_in;
        fifo_type.rst_n = obj.rst_n;
        fifo_type.wr_en = obj.wr_en;
        fifo_type.rd_en= obj.rd_en;
        @(negedge fifo_type.clk);
    end
    finished_signal = 1;
  end
endmodule


