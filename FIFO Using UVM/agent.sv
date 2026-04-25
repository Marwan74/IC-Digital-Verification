package fifo_agent_pkg;
import uvm_pkg::*;
import fifo_driver_pkg::*;
import fifo_sequencer_pkg::*;
import fifo_seq_item_pkg::*;
import fifo_monitor_pkg::*;
import fifo_config_pkg::*;
`include "uvm_macros.svh"
  class fifo_agent extends uvm_agent;
   `uvm_component_utils(fifo_agent);
    fifo_sequencer sqr;
    fifo_driver drv;
    fifo_monitor mon;
    fifo_config_obj fifo_config_obj_driver;
    uvm_analysis_port #(fifo_seq_item) agt_ap;
    function new(string name = "fifo_agent" , uvm_component parent = null);
        super.new(name,parent);
    endfunction //new()

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        sqr = fifo_sequencer::type_id::create("sqr",this);
        drv = fifo_driver::type_id::create("drv",this);
        mon = fifo_monitor::type_id::create("mon",this);
        fifo_config_obj_driver = fifo_config_obj::type_id::create("fifo_config_obj_driver",this);
        agt_ap = new("agt_ap" , this);
        if(!uvm_config_db#(fifo_config_obj)::get(this , "" , "CFG" , fifo_config_obj_driver))begin
            `uvm_fatal("build_phase","agent unable to get configuration object");
        end
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        drv.fifo_driver_vif = fifo_config_obj_driver.fifo_config_vif;
        mon.fifo_driver_vif = fifo_config_obj_driver.fifo_config_vif;
        drv.seq_item_port.connect(sqr.seq_item_export);
        mon.mon_ap.connect(agt_ap); 
    endfunction
  endclass //fifo_agent extends superClass
endpackage