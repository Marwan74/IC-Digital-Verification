package FIFO_coverage_pkg;
import Transaction_pkg::*;
    class FIFO_coverage;
        FIFO_transaction F_cvg_txn = new();
        covergroup cg ;
         write : coverpoint F_cvg_txn.wr_en
         {
            bins write_0 = {0};
            bins write_1 = {1};
         }
         read : coverpoint F_cvg_txn.rd_en
         {
            bins read_0 = {0};
            bins read_1 = {1};
         }
         wr_ack_cp : coverpoint F_cvg_txn.wr_ack
         {
            bins wr_ack_0 = {0};
            bins wr_ack_1 = {1};
         }
         overflow_cp : coverpoint F_cvg_txn.overflow
         {
            bins overflow_0 = {0};
            bins overflow_1 = {1};
         }
         full_cp : coverpoint F_cvg_txn.full
         {
            bins full_0 = {0};
            bins full_1 = {1};
        }
         empty_cp : coverpoint F_cvg_txn.empty
         {
            bins empty_0 = {0};
            bins empty_1 = {1};
         }
         almostfull_cp : coverpoint F_cvg_txn.almostfull
         {
            bins almostfull_0 = {0};
            bins almostfull_1 = {1};
         }
         almostempty_cp : coverpoint F_cvg_txn.almostempty
         {
            bins almostempty_0 = {0};
            bins almostempty_1 = {1};
         }
         underflow_cp : coverpoint F_cvg_txn.underflow
         {
            bins underflow_0 = {0};
            bins underflow_1 = {1};
         }
         // cross coverage 
         cross_wr_ack : cross write , read , wr_ack_cp
         {
            illegal_bins wack_001 = binsof (write.write_0) && binsof (read.read_0) && binsof (wr_ack_cp.wr_ack_1);
            illegal_bins wack_011 = binsof (write.write_0) && binsof (read.read_1) && binsof (wr_ack_cp.wr_ack_1);
         }
         cross_overflow : cross write,read,overflow_cp 
         {
            illegal_bins ov_001 = binsof (write.write_0) && binsof (read.read_0) && binsof (overflow_cp.overflow_1);
            illegal_bins ov_011 = binsof (write.write_0) && binsof (read.read_1) && binsof (overflow_cp.overflow_1);
         }
         cross_full : cross read,write,full_cp
         {
            illegal_bins f_111 = binsof (write.write_1) && binsof (read.read_1) && binsof (full_cp.full_1);
            illegal_bins f_011 = binsof (write.write_0) && binsof (read.read_1) && binsof (full_cp.full_1);
         }
         cross_empty : cross read,write,F_cvg_txn.empty;
         cross_almostfull : cross read,write,almostfull_cp;
         cross_almostempty: cross read,write,almostempty_cp;
         cross_underflow : cross read , write , underflow_cp
         {
            illegal_bins uv_101 = binsof (write.write_1) && binsof (read.read_0) && binsof (underflow_cp.underflow_1);
            illegal_bins f_001 = binsof (write.write_0) && binsof (read.read_0) && binsof (underflow_cp.underflow_1);
         }

        endgroup
      function new();
         cg = new(); 
      endfunction

      function void sample_data(FIFO_transaction F_txn);
         F_cvg_txn = F_txn;
         cg.sample();
      endfunction  
    endclass //FIFO_coverage
endpackage