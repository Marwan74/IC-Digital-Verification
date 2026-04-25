package fifo_test_pkg;
 import fifo_env_pkg::*;
 import fifo_config_pkg::*;
 import fifo_sequence_pkg::*;
 import uvm_pkg::*;
`include "uvm_macros.svh"
class fifo_test extends uvm_test;
     `uvm_component_utils(fifo_test);
     fifo_env env;
     fifo_config_obj fifo_config_obj_test;
     read_only_seq r_seq;
     write_only_seq w_seq;
     write_read_seq wr_seq;
     fifo_reset_sequence rst_seq;
     int i=0;
    function new(string name = "fifo_test" , uvm_component parent = null);
        super.new(name,parent);
    endfunction //new()

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = fifo_env::type_id::create("env",this);
        fifo_config_obj_test = fifo_config_obj::type_id::create("fifo_config_obj_test");
        r_seq = read_only_seq::type_id::create("r_seq");
        w_seq = write_only_seq::type_id::create("w_seq");
        wr_seq = write_read_seq::type_id::create("wr_seq");
        rst_seq = fifo_reset_sequence::type_id::create("rst_seq", this);
        if(!uvm_config_db#(virtual fifo_if)::get(this , "" , "interface" , fifo_config_obj_test.fifo_config_vif))begin
            `uvm_fatal("build_phase","the test unable to get config object");
        end
        uvm_config_db#(fifo_config_obj)::set(this , "env.agt" , "CFG" , fifo_config_obj_test);
    endfunction

    task run_phase (uvm_phase phase);
            super.run_phase(phase);
            phase.raise_objection(this);
            //#100; `uvm_info("run_phase", "Welcome to the UVM env.", UVM_MEDIUM);

            //reset sequence
            `uvm_info("run_phase","reset asserted", UVM_LOW); 
            rst_seq.start(env.agt.sqr); 
            `uvm_info("run_phase","reset deasserted", UVM_LOW);

            //write sequence
            #100;
            `uvm_info("run_phase","write stimulus generated started", UVM_LOW); 
            w_seq.start(env.agt.sqr); 
            `uvm_info("run_phase","write stimulus generated ended", UVM_LOW);

             //read sequence
            `uvm_info("run_phase","read stimulus generated started", UVM_LOW); 
            r_seq.start(env.agt.sqr); 
            `uvm_info("run_phase","read stimulus generated ended", UVM_LOW);

             //mixed sequence
            `uvm_info("run_phase","mixed stimulus generated started", UVM_LOW); 
            wr_seq.start(env.agt.sqr); 
            `uvm_info("run_phase","mixed stimulus generated ended", UVM_LOW);

            phase.drop_objection(this);
    endtask
endclass //fifo_test extends superClass
    
endpackage