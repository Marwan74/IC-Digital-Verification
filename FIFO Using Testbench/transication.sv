package Transaction_pkg;
    class FIFO_transaction;
        parameter FIFO_WIDTH = 16;
        parameter FIFO_DEPTH = 8;
        int RD_EN_ON_DIST , WR_EN_ON_DIST;
        rand logic rst_n,wr_en,rd_en;
        rand logic [FIFO_WIDTH-1:0] data_in;
        logic [FIFO_WIDTH-1:0] data_out;
        logic wr_ack, overflow,full, empty, almostfull, almostempty, underflow;
        // constructor

         function new(int rd_en_on_dist = 30, wr_en_on_dist = 70);
          RD_EN_ON_DIST = rd_en_on_dist;
          WR_EN_ON_DIST = wr_en_on_dist; 
        endfunction //new()

        // constraints

        constraint reset {rst_n dist {1 := 98 , 0 := 2};};
        constraint wr_en_constant {wr_en dist {1 := WR_EN_ON_DIST , 0 := 100-WR_EN_ON_DIST};};
        constraint rd_en_constant {rd_en dist {1 := RD_EN_ON_DIST , 0 := 100-RD_EN_ON_DIST};};
    endclass //FIFO_transaction
endpackage