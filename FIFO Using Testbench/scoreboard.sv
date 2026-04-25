package FIFO_scoreboard_pkg;
  import Transaction_pkg::*;
  import shared_pkg::*;

  class FIFO_scoreboard;

    parameter FIFO_WIDTH = 16;
    parameter FIFO_DEPTH = 8;

    logic [FIFO_WIDTH-1:0] data_out_ref;
    logic wr_ack_ref, overflow_ref;
    logic full_ref, empty_ref, almostfull_ref, almostempty_ref, underflow_ref;

    bit [FIFO_WIDTH-1:0] queue[$];
    int count_ref;

    FIFO_transaction obj = new();

    function void check_data (FIFO_transaction obj);
      reference_model(obj);

      if ((obj.data_out !== data_out_ref) || (obj.wr_ack !== wr_ack_ref) || (obj.overflow !== overflow_ref) ||
          (obj.full !== full_ref) || (obj.empty !== empty_ref) || (obj.almostfull !== almostfull_ref) ||
          (obj.almostempty !== almostempty_ref) || (obj.underflow !== underflow_ref)) begin
            $display("%0t : Error - Incorrect output!", $time);
            error_count++;
      end else begin
            correct_count++;
      end
    endfunction

    function void reference_model (FIFO_transaction obj_ref);
      fork
        begin : write_thread
          if (!obj_ref.rst_n) begin
            wr_ack_ref = 0;
            overflow_ref = 0;
			full_ref = 0;
			almostfull_ref = 0;
            queue.delete();
          end else if (obj_ref.wr_en && (count_ref < FIFO_DEPTH)) begin
            queue.push_back(obj_ref.data_in);
            wr_ack_ref = 1;
            //overflow_ref = 0;
          end else begin
            wr_ack_ref = 0;
            if (obj_ref.wr_en && (count_ref == FIFO_DEPTH))
              overflow_ref = 1;
            else
              overflow_ref = 0;
          end
        end

        begin : read_thread
          if (!obj_ref.rst_n) begin
            data_out_ref = 0;
            underflow_ref = 0;
			empty_ref = 0;
			almostempty_ref = 0;
          end else if (obj_ref.rd_en && (count_ref != 0)) begin
            data_out_ref = queue.pop_front();
            //underflow_ref = 0;
          end else begin
            if (obj_ref.rd_en && (count_ref == 0))
              underflow_ref = 1;
            else
              underflow_ref = 0;
          end
        end
      join

      // Counter update after fork
      if (!obj_ref.rst_n) begin
        count_ref = 0;
      end else begin
        if (({obj_ref.wr_en, obj_ref.rd_en} == 2'b10) && (count_ref < FIFO_DEPTH))
          count_ref++;
        else if (({obj_ref.wr_en, obj_ref.rd_en} == 2'b01) && (count_ref != 0))
          count_ref--;
        else if (({obj_ref.wr_en, obj_ref.rd_en} == 2'b11) && (count_ref == FIFO_DEPTH))
          count_ref--;
        else if (({obj_ref.wr_en, obj_ref.rd_en} == 2'b11) && (count_ref == 0))
          count_ref++;
      end

      // Now update flags
      full_ref        = (count_ref == FIFO_DEPTH);
      empty_ref       = (count_ref == 0);
      almostfull_ref  = (count_ref == FIFO_DEPTH - 1);
      almostempty_ref = (count_ref == 1);

    endfunction
  endclass
endpackage



