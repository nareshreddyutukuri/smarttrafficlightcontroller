`timescale 1ns/1ps

module traffic_controller_tb;

    reg clk;
    reg rst;
    reg ped_request;
    reg emergency_request;

    wire ns_red, ns_yellow, ns_green;
    wire ew_red, ew_yellow, ew_green;
    wire ped_walk, ped_dont_walk;

    traffic_controller #(
        .NS_GREEN_TIME(5),
        .NS_YELLOW_TIME(2),
        .EW_GREEN_TIME(5),
        .EW_YELLOW_TIME(2),
        .ALL_RED_TIME(1),
        .PED_WALK_TIME(3)
    ) dut (
        .clk(clk),
        .rst(rst),
        .ped_request(ped_request),
        .emergency_request(emergency_request),

        .ns_red(ns_red),
        .ns_yellow(ns_yellow),
        .ns_green(ns_green),

        .ew_red(ew_red),
        .ew_yellow(ew_yellow),
        .ew_green(ew_green),

        .ped_walk(ped_walk),
        .ped_dont_walk(ped_dont_walk)
    );

    // 10 ns clock period.
    initial clk = 0;
    always #5 clk = ~clk;

    // Check for unsafe combinations on every clock.
    always @(posedge clk) begin
        if (!rst) begin
            if (ns_green && ew_green)
                $fatal(1, "ERROR: NS and EW green simultaneously");

            if (ped_walk && (!ns_red || !ew_red))
                $fatal(1, "ERROR: Pedestrian walk while traffic is not all-red");

            if (ped_walk && !ped_dont_walk)
                $display("Pedestrian crossing active at %0t ns", $time);
        end
    end

    initial begin
        $dumpfile("traffic_controller.vcd");
        $dumpvars(0, traffic_controller_tb);

        rst = 1;
        ped_request = 0;
        emergency_request = 0;

        #20;
        rst = 0;
        $display("Reset released at %0t ns", $time);

        // Let the normal traffic sequence run.
        #100;

        // Request a pedestrian crossing.
        ped_request = 1;
        #10;
        ped_request = 0;
        $display("Pedestrian request sent at %0t ns", $time);

        #100;

        // Request emergency priority.
        emergency_request = 1;
        $display("Emergency request asserted at %0t ns", $time);

        #50;
        emergency_request = 0;
        $display("Emergency request removed at %0t ns", $time);

        #100;
        $display("Testbench completed.");
        $finish;
    end

endmodule
