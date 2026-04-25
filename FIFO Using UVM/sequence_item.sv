package fifo_seq_item_pkg;
import uvm_pkg::*;
`include "uvm_macros.svh"
class fifo_seq_item extends uvm_sequence_item;
    `uvm_object_utils(fifo_seq_item);
    parameter FIFO_WIDTH = 16;
    parameter FIFO_DEPTH = 8;
    rand logic rst_n,wr_en,rd_en;
    rand logic [FIFO_WIDTH-1:0] data_in;
    logic [FIFO_WIDTH-1:0] data_out;
    logic wr_ack, overflow,full, empty, almostfull, almostempty, underflow;
    
    // constraints 
    constraint reset {rst_n dist {1 := 98 , 0 := 2};};
    constraint wr_en_constant {wr_en dist {1 := 70 , 0 := 30};};
    constraint rd_en_constant {rd_en dist {1 := 30 , 0 := 70};};
    function new(string name = "fifo_seq_item");
        super.new(name);
    endfunction //new()

    function string convert2string ();
  return $sformatf("%s reset =0b%0b ,datain =0h%0h,wr_en =0b%0b,rd_en =0b%0b ,dataout =0h%0h,wr_ack =0b%0b,overflow =0b%0b,
  underflow =0b%0b ,full =0b%0b,empty =0b%0b,almostfull =0b%0b,almostempty =0b%0b",
  super.convert2string(),rst_n,data_in,wr_en,rd_en,data_out,wr_ack,overflow,underflow,full,empty,almostfull,almostempty);
   endfunction

function string convert2string_stimulus ();
  return $sformatf(" reset =0b%0b ,datain =0h%0h,wr_en =0b%0b,rd_en =0b%0b",rst_n,data_in,wr_en,rd_en);
endfunction
endclass //Alsu_seq_item extends superClass
    
endpackage