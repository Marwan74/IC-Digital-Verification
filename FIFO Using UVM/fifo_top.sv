import uvm_pkg::*;
import fifo_test_pkg::*;
`include "uvm_macros.svh"
module top();
    bit clk;
    initial begin
        clk = 0;
        forever begin
            #10 clk = ~clk;
        end
    end
 fifo_if fifo_type (clk);
 FIFO DUT(fifo_type);
 bind FIFO fifo_sva assertions (fifo_type);
 initial begin
    uvm_config_db#(virtual fifo_if)::set(null , "uvm_test_top" , "interface" , fifo_type);
    run_test("fifo_test");
 end  
endmodule