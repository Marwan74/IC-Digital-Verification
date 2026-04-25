package fifo_sequence_pkg;
import fifo_seq_item_pkg::*;
import uvm_pkg::*;
`include "uvm_macros.svh"
//  reset sequence
  class fifo_reset_sequence extends uvm_sequence #(fifo_seq_item);
        `uvm_object_utils(fifo_reset_sequence)

        fifo_seq_item seq_item;

        function new (string name = "fifo_reset_sequence");
            super.new (name);
        endfunction

        task body;
            seq_item = fifo_seq_item::type_id::create("seq_item");
            start_item(seq_item);
            seq_item.rst_n = 0;
            seq_item.rd_en = 0; 
            seq_item.wr_en = 0; 
            seq_item.data_in = 16'hFFFF; 
            finish_item(seq_item);
        endtask
  endclass

///// read only sequence 
  class read_only_seq extends uvm_sequence #(fifo_seq_item);
    `uvm_object_utils(read_only_seq);
    fifo_seq_item seq_item;
    function new(string name = "Alsu_reset_sequence");
        super.new(name);
    endfunction //new()
    task body;
    repeat(2000)begin
    seq_item = fifo_seq_item::type_id::create("seq_item");
    seq_item.rd_en = 1;
    seq_item.wr_en = 0;  
    start_item(seq_item);
    assert(seq_item.randomize());
    finish_item(seq_item);
    end
  endtask
  endclass
  
///// write only sequence
  class write_only_seq extends uvm_sequence #(fifo_seq_item);
    `uvm_object_utils(write_only_seq);
    fifo_seq_item seq_item;
    function new(string name = "write_only_seq");
       super.new(name); 
    endfunction //new()

    task body;
    repeat(2000)begin
    seq_item = fifo_seq_item::type_id::create("seq_item");
    seq_item.rd_en = 0;
    seq_item.wr_en = 1;  
    start_item(seq_item);
    assert(seq_item.randomize());
    finish_item(seq_item);
    end 
    endtask
  endclass 

/// write - read sequence
  class write_read_seq extends uvm_sequence #(fifo_seq_item);
  `uvm_object_utils(write_read_seq)
   fifo_seq_item seq_item;
  function new(string name = "write_read_seq");
    super.new(name);
  endfunction

  task body;
    repeat(2000)begin
    seq_item = fifo_seq_item::type_id::create("seq_item"); 
    seq_item.rd_en = 1;
    seq_item.wr_en = 1; 
    start_item(seq_item);
    assert(seq_item.randomize());
    finish_item(seq_item);
    end 
  endtask
endclass

endpackage