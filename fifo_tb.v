`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.10.2026 19:25:54
// Design Name: 
// Module Name: fifo_tb
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

module fifo_tb;

    reg clk;
    reg rst;
    reg wr_en;
    reg rd_en;
    reg [7:0] data_in;

    wire [7:0] data_out;
    wire full;
    wire empty;

    // Instantiate the FIFO
    fifo dut (
        .clk(clk),
        .rst(rst),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .data_in(data_in),
        .data_out(data_out),
        .full(full),
        .empty(empty)
    );

    // Clock period = 10 ns
    initial clk = 0;
    always #5 clk = ~clk;

    // Write one byte
    task write_byte;
        input [7:0] value;
        begin
            @(negedge clk);
            data_in = value;
            wr_en = 1;
            rd_en = 0;

            @(posedge clk);
            #1;

            @(negedge clk);
            wr_en = 0;
        end
    endtask

    // Read one byte and check its value
    task read_byte;
        input [7:0] expected;
        begin
            @(negedge clk);
            wr_en = 0;
            rd_en = 1;

            @(posedge clk);
            #1;

            if (data_out !== expected) begin
                $display("FAIL: Expected %h, got %h",
                         expected, data_out);
                $fatal(1);
            end
            else begin
                $display("PASS: Read %h", data_out);
            end

            @(negedge clk);
            rd_en = 0;
        end
    endtask

    integer i;

    initial begin
        $dumpfile("fifo.vcd");
        $dumpvars(0, fifo_tb);

        rst = 1;
        wr_en = 0;
        rd_en = 0;
        data_in = 0;

        // Apply reset
        repeat (2) @(negedge clk);
        rst = 0;

        if (empty !== 1'b1)
            $fatal(1, "FAIL: FIFO should be empty after reset");

        $display("PASS: FIFO reset");

        // Test 1: Write and read in FIFO order
        write_byte(8'h12);
        write_byte(8'h25);

        read_byte(8'h12);
        read_byte(8'h25);

        if (empty !== 1'b1)
            $fatal(1, "FAIL: FIFO should be empty");

        $display("PASS: FIFO order and empty flag");

        // Test 2: Fill all eight entries
        for (i = 0; i < 8; i = i + 1)
            write_byte(i + 8'h40);

        if (full !== 1'b1)
            $fatal(1, "FAIL: FIFO should be full");

        $display("PASS: FIFO full flag"); 

        // Test 3: Attempt an extra write
        write_byte(8'hFF);

        if (full !== 1'b1)
            $fatal(1, "FAIL: FIFO should remain full");

        // Test 4: Read all eight original entries
        for (i = 0; i < 8; i = i + 1)
            read_byte(i + 8'h40);

        if (empty !== 1'b1)
            $fatal(1, "FAIL: FIFO should be empty");

        $display("ALL TESTS PASSED");
        $finish;
    end

endmodule

