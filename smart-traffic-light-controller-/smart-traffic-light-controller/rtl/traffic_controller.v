module traffic_controller (
    input  wire clk,
    input  wire rst,
    input  wire ped_request,
    input  wire emergency_request,

    output reg ns_red,
    output reg ns_yellow,
    output reg ns_green,

    output reg ew_red,
    output reg ew_yellow,
    output reg ew_green,

    output reg ped_walk,
    output reg ped_dont_walk
);

    // Phase durations in clock cycles; change for your simulation.
    parameter NS_GREEN_TIME = 10;
    parameter NS_YELLOW_TIME = 3;
    parameter EW_GREEN_TIME = 10;
    parameter EW_YELLOW_TIME = 3;
    parameter ALL_RED_TIME = 2;
    parameter PED_WALK_TIME = 5;

    localparam [3:0]
        S_NS_GREEN    = 4'd0,
        S_NS_YELLOW   = 4'd1,
        S_ALL_RED_1   = 4'd2,
        S_EW_GREEN    = 4'd3,
        S_EW_YELLOW   = 4'd4,
        S_ALL_RED_2   = 4'd5,
        S_PED         = 4'd6,
        S_EMERGENCY   = 4'd7,
        S_EMERGENCY_AR= 4'd8;

    reg [3:0] state;
    reg [15:0] timer;
    reg ped_pending;

    // Remember a pedestrian request until the crossing is served.
    always @(posedge clk or posedge rst) begin
        if (rst)
            ped_pending <= 1'b0;
        else if (ped_request)
            ped_pending <= 1'b1;
        else if (state == S_PED)
            ped_pending <= 1'b0;
    end

    // State and phase timer.
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= S_ALL_RED_1;
            timer <= 0;
        end else begin
            // Emergency request takes priority, but first go all-red.
            if (emergency_request &&
                state != S_EMERGENCY &&
                state != S_EMERGENCY_AR) begin
                state <= S_EMERGENCY_AR;
                timer <= 0;
            end else begin
                case (state)
                    S_NS_GREEN: begin
                        if (timer >= NS_GREEN_TIME-1) begin
                            state <= S_NS_YELLOW;
                            timer <= 0;
                        end else timer <= timer + 1;
                    end

                    S_NS_YELLOW: begin
                        if (timer >= NS_YELLOW_TIME-1) begin
                            state <= S_ALL_RED_1;
                            timer <= 0;
                        end else timer <= timer + 1;
                    end

                    S_ALL_RED_1: begin
                        if (timer >= ALL_RED_TIME-1) begin
                            if (ped_pending)
                                state <= S_PED;
                            else
                                state <= S_EW_GREEN;
                            timer <= 0;
                        end else timer <= timer + 1;
                    end

                    S_EW_GREEN: begin
                        if (timer >= EW_GREEN_TIME-1) begin
                            state <= S_EW_YELLOW;
                            timer <= 0;
                        end else timer <= timer + 1;
                    end

                    S_EW_YELLOW: begin
                        if (timer >= EW_YELLOW_TIME-1) begin
                            state <= S_ALL_RED_2;
                            timer <= 0;
                        end else timer <= timer + 1;
                    end

                    S_ALL_RED_2: begin
                        if (timer >= ALL_RED_TIME-1) begin
                            if (ped_pending)
                                state <= S_PED;
                            else
                                state <= S_NS_GREEN;
                            timer <= 0;
                        end else timer <= timer + 1;
                    end

                    S_PED: begin
                        if (timer >= PED_WALK_TIME-1) begin
                            state <= S_NS_GREEN;
                            timer <= 0;
                        end else timer <= timer + 1;
                    end

                    S_EMERGENCY_AR: begin
                        if (timer >= ALL_RED_TIME-1) begin
                            state <= S_EMERGENCY;
                            timer <= 0;
                        end else timer <= timer + 1;
                    end

                    S_EMERGENCY: begin
                        if (!emergency_request) begin
                            state <= S_ALL_RED_2;
                            timer <= 0;
                        end
                    end

                    default: begin
                        state <= S_ALL_RED_1;
                        timer <= 0;
                    end
                endcase
            end
        end
    end

    // Outputs are decoded from the current state.
    always @(*) begin
        ns_red       = 1'b1;
        ns_yellow    = 1'b0;
        ns_green     = 1'b0;

        ew_red       = 1'b1;
        ew_yellow    = 1'b0;
        ew_green     = 1'b0;

        ped_walk     = 1'b0;
        ped_dont_walk= 1'b1;

        case (state)
            S_NS_GREEN: begin
                ns_red = 1'b0;
                ns_green = 1'b1;
            end

            S_NS_YELLOW: begin
                ns_red = 1'b0;
                ns_yellow = 1'b1;
            end

            S_EW_GREEN: begin
                ew_red = 1'b0;
                ew_green = 1'b1;
            end

            S_EW_YELLOW: begin
                ew_red = 1'b0;
                ew_yellow = 1'b1;
            end

            S_PED: begin
                ped_walk = 1'b1;
                ped_dont_walk = 1'b0;
            end

            S_EMERGENCY: begin
                // Demonstration policy: give NS traffic priority.
                ns_red = 1'b0;
                ns_green = 1'b1;
            end

            default: begin
                // All-red states keep both directions stopped.
            end
        endcase
    end

endmodule
