package fifo_scoreboard_pkg;
import fifo_seq_item_pkg::*;
import uvm_pkg::*;
`include "uvm_macros.svh"
  class fifo_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(fifo_scoreboard);

    uvm_analysis_export #(fifo_seq_item) sb_export;
    uvm_tlm_analysis_fifo #(fifo_seq_item) sb_fifo;
    fifo_seq_item seq_item_sb;
    parameter FIFO_WIDTH = 16;
    parameter FIFO_DEPTH = 8;

    logic [FIFO_WIDTH-1:0] data_out_ref;
    logic wr_ack_ref, overflow_ref;
    logic full_ref, empty_ref, almostfull_ref, almostempty_ref, underflow_ref;

    logic [FIFO_WIDTH-1:0] queue[$];
    int count_ref;

    int error_count = 0;
    int correct_count = 0;
    function new(string name = "fifo_scoreboard" , uvm_component parent = null);
        super.new(name,parent);
    endfunction //new()

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        sb_export = new("sb_export", this);
        sb_fifo = new("sb_fifo", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        sb_export.connect(sb_fifo.analysis_export);
    endfunction

    task run_phase(uvm_phase phase);
      super.run_phase(phase);
      forever begin
        sb_fifo.get(seq_item_sb);
        reference_model(seq_item_sb);
        if ((seq_item_sb.data_out !== data_out_ref) || (seq_item_sb.wr_ack !== wr_ack_ref) || (seq_item_sb.overflow !== overflow_ref) ||
                   (seq_item_sb.full !== full_ref) || (seq_item_sb.empty !== empty_ref) || (seq_item_sb.almostfull !== almostfull_ref) ||
                   (seq_item_sb.almostempty !== almostempty_ref) || (seq_item_sb.underflow !== underflow_ref)) begin
                    `uvm_error("SCOREBOARD",
                        $sformatf("Mismatch: DUT output = 0x%0h, Expected = 0x%0h | Transaction: %s",
                        seq_item_sb.data_out, data_out_ref, seq_item_sb.convert2string()))
                        error_count++;
                end else begin
                  `uvm_info("SCOREBOARD",
                    $sformatf("Match: DUT output = 0x%0h | Transaction: %s",
                    seq_item_sb.data_out, seq_item_sb.convert2string()), UVM_HIGH)
                    correct_count++;
                end
      end
    endtask

    task reference_model (fifo_seq_item seq_item_sb);
            fork
                
                begin: write_thread
                    if (!seq_item_sb.rst_n) begin
                       wr_ack_ref = 0;
                       overflow_ref = 0;
			           full_ref = 0;
			           almostfull_ref = 0;
                       queue.delete();
                    end else if (seq_item_sb.wr_en && (count_ref < FIFO_DEPTH)) begin
                        queue.push_back(seq_item_sb.data_in);
                        wr_ack_ref = 1;
                    end else begin
                        wr_ack_ref = 0;
                    if (seq_item_sb.wr_en && (count_ref == FIFO_DEPTH))
                       overflow_ref = 1;
                    else
                       overflow_ref = 0;
                    end
                end

                begin: read_thred
                    if (!seq_item_sb.rst_n) begin
                       data_out_ref = 0;
                       underflow_ref = 0;
			           empty_ref = 0;
			           almostempty_ref = 0;
                    end else if (seq_item_sb.rd_en && (count_ref != 0)) begin
                        data_out_ref = queue.pop_front();
                    end else begin
                    if (seq_item_sb.rd_en && (count_ref == 0))
                        underflow_ref = 1;
                    else
                        underflow_ref = 0;
                    end
                end

            join

            if (!seq_item_sb.rst_n) begin
                count_ref = 0;
            end else begin
            if (({seq_item_sb.wr_en, seq_item_sb.rd_en} == 2'b10) && (count_ref < FIFO_DEPTH))
                count_ref++;
            else if (({seq_item_sb.wr_en, seq_item_sb.rd_en} == 2'b01) && (count_ref != 0))
                count_ref--;
            else if (({seq_item_sb.wr_en, seq_item_sb.rd_en} == 2'b11) && (count_ref == FIFO_DEPTH))
                count_ref--;
            else if (({seq_item_sb.wr_en, seq_item_sb.rd_en} == 2'b11) && (count_ref == 0))
                count_ref++;
            end

            full_ref = (count_ref == FIFO_DEPTH);
            empty_ref = (count_ref == 0);
            almostfull_ref = (count_ref == FIFO_DEPTH - 1);
            almostempty_ref = (count_ref == 1);
        endtask
    

    
    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("report_phase",$sformatf("total successful transications: %0d",correct_count), UVM_MEDIUM);
        `uvm_info("report_phase",$sformatf("total failed transications: %0d",error_count), UVM_MEDIUM);
    endfunction
  endclass //Alsu_scoreboard extends superClass
endpackage