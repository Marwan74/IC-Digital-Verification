import shared_pkg::*;
import Transaction_pkg::*;
import FIFO_coverage_pkg::*;
import FIFO_scoreboard_pkg::*;

module monitor(interface_fifo.monitor fifo_type);
  FIFO_transaction obj_trans = new();
  FIFO_coverage obj_cover = new();
  FIFO_scoreboard obj_board = new();

  initial begin
    
    forever begin
      @(negedge fifo_type.clk);
      obj_trans.rst_n = fifo_type.rst_n;
      obj_trans.wr_en = fifo_type.wr_en;
      obj_trans.rd_en = fifo_type.rd_en;
      obj_trans.data_in = fifo_type.data_in;
      obj_trans.overflow = fifo_type.overflow;
      obj_trans.underflow = fifo_type.underflow;
      obj_trans.empty = fifo_type.empty;
      obj_trans.full = fifo_type.full;
      obj_trans.almostempty = fifo_type.almostempty;
      obj_trans.almostfull = fifo_type.almostfull;
      obj_trans.wr_ack = fifo_type.wr_ack;
      obj_trans.data_out = fifo_type.data_out;

      fork
        begin
          obj_cover.sample_data(obj_trans);
        end
        begin
          @(posedge fifo_type.clk);
          #10;
          obj_board.check_data(obj_trans);
        end
      join

      if(finished_signal == 1) begin
        $display("no of error count : %0d , no of correct count : %0d ", error_count, correct_count);
        $stop;
      end
    end
  end
endmodule
