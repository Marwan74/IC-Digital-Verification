package fifo_coverage_collector_pkg;
import fifo_seq_item_pkg::*;
 import uvm_pkg::*;
`include "uvm_macros.svh"
  class fifo_coverage extends uvm_component;
     `uvm_component_utils(fifo_coverage);
     uvm_analysis_export #(fifo_seq_item) cov_export;
     uvm_tlm_analysis_fifo #(fifo_seq_item) cov_fifo;
     fifo_seq_item seq_item_cov;

     covergroup cg ;
         write : coverpoint seq_item_cov.wr_en
         {
            bins write_0 = {0};
            bins write_1 = {1};
         }
         read : coverpoint seq_item_cov.rd_en
         {
            bins read_0 = {0};
            bins read_1 = {1};
         }
         wr_ack_cp : coverpoint seq_item_cov.wr_ack
         {
            bins wr_ack_0 = {0};
            bins wr_ack_1 = {1};
         }
         overflow_cp : coverpoint seq_item_cov.overflow
         {
            bins overflow_0 = {0};
            bins overflow_1 = {1};
         }
         full_cp : coverpoint seq_item_cov.full
         {
            bins full_0 = {0};
            bins full_1 = {1};
        }
         empty_cp : coverpoint seq_item_cov.empty
         {
            bins empty_0 = {0};
            bins empty_1 = {1};
         }
         almostfull_cp : coverpoint seq_item_cov.almostfull
         {
            bins almostfull_0 = {0};
            bins almostfull_1 = {1};
         }
         almostempty_cp : coverpoint seq_item_cov.almostempty
         {
            bins almostempty_0 = {0};
            bins almostempty_1 = {1};
         }
         underflow_cp : coverpoint seq_item_cov.underflow
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
         cross_empty : cross read,write,seq_item_cov.empty;
         cross_almostfull : cross read,write,almostfull_cp;
         cross_almostempty: cross read,write,almostempty_cp;
         cross_underflow : cross read , write , underflow_cp
         {
            illegal_bins uv_101 = binsof (write.write_1) && binsof (read.read_0) && binsof (underflow_cp.underflow_1);
            illegal_bins f_001 = binsof (write.write_0) && binsof (read.read_0) && binsof (underflow_cp.underflow_1);
         }

        endgroup

    function new(string name = "fifo_coverage" , uvm_component parent = null);
        super.new(name,parent);
        cg = new();
    endfunction //new()

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        cov_export = new("cov_export" , this);
        cov_fifo = new("cov_fifo" , this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        cov_export.connect(cov_fifo.analysis_export);
    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        seq_item_cov = fifo_seq_item::type_id::create("seq_item_cov");
        forever begin
            cov_fifo.get(seq_item_cov);
            cg.sample();
        end
    endtask
  endclass //Alsu_coverage_collector extends superClass    
endpackage