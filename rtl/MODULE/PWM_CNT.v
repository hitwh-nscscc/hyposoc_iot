// =============================================================================
//  HITwh Hypothetic MIPS Team :: Hypothetic SoC IoT
//   _    _                   _____  ____   _____            _____   _______ 
//  | |  | |                 / ____|/ __ \ / ____|          |_   _| |__   __|
//  | |__| |_   _ _ __   ___| (___ | |  | | |       ______    | |  ___ | |   
//  |  __  | | | | '_ \ / _ \\___ \| |  | | |      |______|   | | / _ \| |   
//  | |  | | |_| | |_) | (_) |___) | |__| | |____            _| || (_) | |   
//  |_|  |_|\__, | .__/ \___/_____/ \____/ \_____|          |_____\___/|_|   
//           __/ | |                                                         
//          |___/|_|                                                         
 
//  Code And Concept By HITwh Hypothetic MIPS Team
//  https://github.com/hitwh-nscscc
 
// =============================================================================
// Module PWM
//  For 66Mhz - a 50Hz PWM signal is 1,320,000 counter.
//  counter = 0.02 * freq
module PWM (
	input clk,
	input rst_n,
	input [31:0] compare,
	output pwm_out
);
	reg [31:0] counter;
    reg [31:0] counter_syn;
	reg pwm_d;
	
	assign pwm_out = pwm_d;
	
	always@(posedge clk) begin
        // reset
		if(!rst_n) counter <= 0;
        // keep counting until 1,320,000
		else if(counter < 32'd1_319_999) counter <= counter + 1;
        // at last reset the counter.
		else counter <= 0;
	end

    always@(posedge clk) begin
        counter_syn <= counter;
	end
	
    // PWM standard.
	always@(posedge clk) begin
		if(!rst_n) pwm_d <= 0;
		else if(compare > counter_syn)
			pwm_d <= 1;
		else
			pwm_d <= 0;
	end

endmodule