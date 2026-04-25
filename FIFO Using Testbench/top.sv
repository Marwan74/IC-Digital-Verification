module top ();
  bit clk;
  initial begin
    clk =0;
    forever begin
        #25 clk = ~clk;
    end
  end
  interface_fifo fifo_type(clk);
  FIFO DUT(fifo_type);
  testbench tb (fifo_type);
  monitor Monitor(fifo_type);  
endmodule