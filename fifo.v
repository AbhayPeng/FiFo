`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.10.2026 19:25:54
// Design Name: 
// Module Name: fifo
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module fifo (
    input wire clk,
    input wire rst,
    input wire wr_en,
    input wire rd_en,
    input wire [7:0] data_in,

    output reg [7:0] data_out,
    output wire full,
    output wire empty
);

    // FIFO memory: 8 entries, each 8 bits wide
    reg [7:0] mem [0:7];

    // Pointers select memory locations
    reg [2:0] wr_ptr;
    reg [2:0] rd_ptr;

    // Count ranges from 0 to 8
    reg [3:0] count;

    // Status flags
    assign empty = (count == 0);
    assign full  = (count == 8);

    always @(posedge clk) begin
        if (rst) begin
            wr_ptr  <= 3'd0;
            rd_ptr  <= 3'd0;
            count   <= 4'd0;
            data_out <= 8'd0;
        end
        else begin

            // Write data only when FIFO is not full
            if (wr_en && !full) begin
                mem[wr_ptr] <= data_in;
                wr_ptr <= wr_ptr + 1'b1;
            end

            // Read data only when FIFO is not empty
            if (rd_en && !empty) begin
                data_out <= mem[rd_ptr];
                rd_ptr <= rd_ptr + 1'b1;
            end

            // Update occupancy count
            case ({wr_en && !full, rd_en && !empty})
                2'b10: count <= count + 1'b1;
                2'b01: count <= count - 1'b1;
                default: count <= count;
            endcase
        end
    end

endmodule


