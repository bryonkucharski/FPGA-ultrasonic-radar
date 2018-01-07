module top(
	input clk, 
	input rst, 
	output servoPWM,  
	output [3:0] R,
	output [3:0] G,
	output [3:0] B,
	output horizontal_sync, 
	output vertical_sync,
	input echo,
	output trigger,
	output echoLED,
	output triggerLED,
	output object,
	output resetSensor,
	output reg [6:0] display1,
	output reg [6:0] display2,
	output reg [6:0] display3,
	output reg [6:0] display4,
	output speaker,
	output [3:0] stateLEDS
	);


wire pwmOut, objectDetected, speakerOut;
wire [31:0]  cm_distance;

reg getNewDistance;
reg [31:0] counter, tens, ones, hundreds, soundSpeed, halfsecond, quarterSecond, eigthSecond, positionToDraw, distanceToDraw;
reg [3:0] state;
reg [16:0] thres, zeroDegrees, ninetyDegrees, oneEightyDegrees,fortyFiveDegrees, onethirtyFiveDrgrees;
reg [6:0] one, two, three, four, five, six, seven, eight, nine, zero , off;

reg [31:0] allDistances [0:3];
reg [3:0]i;
reg [2:0] soundState;
reg dangerZone1[0:4];
reg dangerZone2[0:4];


assign servoPWM = pwmOut;
assign object = getNewDistance;
assign speaker = speakerOut;
assign stateLEDS = state;

initial begin
	counter = 0;
	state = 4'b0000;
	
	zeroDegrees =  17'd50000;
	fortyFiveDegrees = 17'd62500;
	ninetyDegrees = 17'd75000;
	onethirtyFiveDrgrees = 17'd87500;
	oneEightyDegrees = 17'd100000;
	
	halfsecond = 32'd25000000;
	quarterSecond = 32'd12500000;
	eigthSecond = 32'd6250000;
	
	dangerZone1[0] = 1'b0;
	dangerZone1[1] = 1'b0;
	dangerZone1[2] = 1'b0;
	dangerZone1[3] = 1'b0;
	dangerZone1[4] = 1'b0;
	
	dangerZone2[0] = 1'b0;
	dangerZone2[1] = 1'b0;
	dangerZone2[2] = 1'b0;
	dangerZone2[3] = 1'b0;
	dangerZone2[4] = 1'b0;
	
	
	
	
	zero = 7'b1000000;
	one  = 7'b1111001;
	two = 7'b0100100;
	three  = 7'b0110000;
	four = 7'b0011001;
	five  = 7'b0010010;
	six = 7'b0000010;
	seven = 7'b1111000;
	eight = 7'b0000000;
	nine = 7'b0011000;
	off = 7'b1111111;

	display1 = off;
	display2 = off;
	display3 = off;
	display4 = off;
	
	getNewDistance = 0;


end


PwmGenerator servo(
								.clk(clk),
								.thres(thres),
								.reset(rst),
								.pwmsignal(pwmOut),
									);
								
						
DrawRadar background(
								.clk(clk), 
								.state(state),
								.centimeters(distanceToDraw),
								.distanceOnes(ones),
								.distanceTens(tens),
								.distanceHundreds(hundreds),	
								.positionToDraw(positionToDraw),
								.R(R),
								.G(G),
								.B(B),
								.horizontal_sync(horizontal_sync), 
								.vertical_sync(vertical_sync),
								);
									
									
ultrasonicSensor sensor(
								.clk(clk),
								.rst(rst), 
								.echo(echo),
								.enable(getNewDistance),
								.trigger(trigger),
								.output_distance(cm_distance),
								.echoLED(echoLED), 
								.triggerLED(triggerLED)
								);
								
								
sound mySound(
							.signalout(speakerOut),
							.clk(clk),
							.speed(soundSpeed)
							);


always@(posedge clk)begin

	counter = counter + 1;
	

	if(counter > 12500000)begin
		counter = 0;
	
			case(state)
				4'b0000: begin
					thres = zeroDegrees;
					state = 4'b0001;
				end
				4'b0001: begin
					getNewDistance = 1'b1;
					state = 4'b0010;
				end
				4'b0010: begin
					getNewDistance = 1'b0;
					if(cm_distance <= 10)begin
						dangerZone1[0] = 1'b1;
					end
					else if((cm_distance > 10 ) && (cm_distance <= 30))begin
						dangerZone2[0] = 1'b1;
					end
					//draw
					
					distanceToDraw = cm_distance;
					positionToDraw = 0;
					
					allDistances[0] = cm_distance;
					state = 4'b0011;
				end
				4'b0011: begin
					thres = ninetyDegrees;
					state = 4'b0100;
				end
				
				4'b0100:begin
					getNewDistance = 1'b1;
					state = 4'b0101;
				end
				4'b0101: begin
				getNewDistance = 1'b0;
					//draw
					if(cm_distance <= 10)begin
						dangerZone1[1] = 1'b1;
					end
					else if((cm_distance > 10 ) && (cm_distance <= 30))begin
						dangerZone2[1] = 1'b1;
					end
					distanceToDraw = cm_distance;
					positionToDraw = 90;
					
					allDistances[1] = cm_distance;
					state = 4'b0110;
				end
				4'b0110:begin
					thres = oneEightyDegrees;
					state = 4'b0111;
				end
				4'b0111:begin
					getNewDistance = 1'b1;
					state = 4'b1000;
				end
				4'b1000: begin
					getNewDistance = 1'b0;
					//draw
					if(cm_distance <= 10)begin
						dangerZone1[2] = 1'b1;
					end
					else if((cm_distance > 10 ) && (cm_distance <= 30))begin
						dangerZone2[2] = 1'b1;
					end
					
					distanceToDraw = cm_distance;
					positionToDraw = 180;
					
					allDistances[2] = cm_distance;
					state = 4'b1001;
				end
				4'b1001:begin
					thres = ninetyDegrees;
					state = 4'b1010;
				end
				4'b1010:begin
					getNewDistance = 1'b1;
					state = 4'b1011;
				end
				4'b1011: begin
					//draw
					getNewDistance = 1'b0;
					if(cm_distance <= 10)begin
						dangerZone1[3] = 1'b1;
					end
					else if((cm_distance > 10 ) && (cm_distance <= 30))begin
						dangerZone2[3] = 1'b1;
					end
					
					distanceToDraw = cm_distance;
					positionToDraw = 90;
					
					allDistances[3] = cm_distance;
					state = 4'b1100;
				end
				4'b1100: begin
				
					soundState = 3'b100;
					for(i = 0; i < 4; i=i+1)begin
						if(dangerZone1[i])begin
							soundState = 3'b001;
						end
						else if(dangerZone2[i])begin
							soundState = 3'b010;
						end

					end
					
						dangerZone1[0] = 1'b0;
						dangerZone1[1] = 1'b0;
						dangerZone1[2] = 1'b0;
						dangerZone1[3] = 1'b0;
						dangerZone1[4] = 1'b0;
						
						dangerZone2[0] = 1'b0;
						dangerZone2[1] = 1'b0;
						dangerZone2[2] = 1'b0;
						dangerZone2[3] = 1'b0;
						dangerZone2[4] = 1'b0;
					
					state = 4'b0000;
				end
			
			endcase
			
			case(soundState)
			3'b001: begin 
				soundSpeed = eigthSecond;
			end
			3'b010: begin 
				soundSpeed = quarterSecond;
			end
			3'b100: begin 
				soundSpeed = halfsecond;
			end
			endcase
	end


		
	


	
	
end

always@(posedge getNewDistance)begin

		tens = (cm_distance % 32'd100);
		ones = tens % 32'd10;

		if((cm_distance <= 32'd450) && (cm_distance >=32'd400))begin
			hundreds = 32'd4;
			display3 = four;
		end
		else if((cm_distance <= 32'd399) && (cm_distance >=32'd300))begin
			hundreds = 32'd3;
			display3 = three;
		end
		else if((cm_distance <= 32'd299) && (cm_distance >=32'd200))begin
			hundreds = 32'd2;
			display3 = two;
		end
		else if((cm_distance <= 32'd199) && (cm_distance >=32'd100))begin
			hundreds = 32'd1;
			display3 = one;
		end
		else begin
			hundreds = 32'd0;
			display3 = zero;
		end
		
		if((tens <= 32'd99) && (tens >=32'd90))begin
			display2 = nine;
		end
		else if((tens <= 32'd89) && (tens >=32'd80))begin
			display2 = eight;
		end
		else if((tens <= 32'd79) && (tens >=32'd70))begin
			display2 = seven;
		end
		else if((tens <= 32'd69) && (tens >=32'd60))begin
			display2 = six;
		end
		else if((tens <= 32'd59) && (tens >=32'd50))begin
			display2 = five;
		end
		else if((tens <= 32'd49) && (tens >=32'd40))begin
			display2 = four;
		end
		else if((tens <= 32'd39) && (tens >=32'd30))begin
			display2 = three;
		end
		else if((tens <= 32'd29) && (tens >=32'd20))begin
			display2 = two;
		end
		else if((tens <= 32'd19) && (tens >=32'd10))begin
			display2 = one;
		end
		else begin
			display2 = zero;
		end
		
		
		case(ones)
		
			32'd0: begin
				display1 = zero;
			end
			32'd1: begin
				display1 = one;
			end
			32'd2: begin
				display1 = two;
			end
			32'd3: begin
				display1 = three;
			end
			32'd4: begin
				display1 = four;
			end
			32'd5: begin
				display1 = five;
			end
			32'd6: begin
				display1 = six;
			end
			32'd7: begin
				display1 = seven;
			end
			32'd8: begin
				display1 = eight;
			end
			32'd9: begin
				display1 = nine;
			end
			default: begin
				display1 = off;
			end
		endcase
end



endmodule




module PwmGenerator(input clk,input [16:0] thres, input reset ,output pwmsignal);


reg [16:0] counter;
reg sig;


assign led = pwmsignal;
assign pwmsignal = sig;


always@(posedge clk)begin


if(reset)begin
	counter = 17'b0;
end


counter = counter +1;

if(counter > thres)begin
	sig = 1'b1;
end
else 
	sig = 1'b0;
end

endmodule


module DrawRadar(
	input clk,
	input [3:0] state,
	input [31:0] centimeters,
	input [31:0] distanceOnes,
	input [31:0] distanceTens,
	input [31:0] distanceHundreds,
	input [31:0] positionToDraw,
	output [3:0] R,
	output [3:0] G,
	output [3:0] B,
	output horizontal_sync, 
	output vertical_sync);


VGA_Ctrl controller(
						.iRed(mRed),
						.iGreen(mGreen),
						.iBlue(mBlue),
						.oCurrent_X(VGA_X),
						.oCurrent_Y(VGA_Y),
						.oAddress(),
						.oRequest(),
						//	VGA Side
						.oVGA_R(R),
						.oVGA_G(G),
						.oVGA_B(B),
						.oVGA_HS(horizontal_sync),
						.oVGA_VS(vertical_sync),
						.oVGA_SYNC(),
						.oVGA_BLANK(displayWithinLimits),
						.oVGA_CLOCK(),
						//	Control Signal
						.iCLK(clk25),
						.iRST_N(1'b1)
						);

reg clk25;
reg	[9:0]	mRed; // red portion of vga output
reg	[9:0]	mGreen;// green portion of vga output
reg	[9:0]	mBlue;// blue portion of vga output
wire	[10:0]	VGA_X;
wire	[10:0]	VGA_Y;

reg[31:0] slopeLine;
reg[31:0] slope_2, slope_3, width, slope_counter;
reg [31:0] objects_x[0:2];
reg [31:0] objects_y[0:2];
reg [2:0]i, detectedObject;
reg[31:0] j,k;

reg number1Matrix [0:4][0:2] ;
reg number2Matrix [0:4][0:2] ;
reg number3Matrix [0:4][0:2] ;
reg[31:0] numberStartPos_x, numberStartPos_y;

wire displayWithinLimits; //variable if the hcount and vcount is within display bounds

initial begin

	slope_2 = 32'd0;
	slope_3 = 32'd0;
	slope_counter = 32'd0;
	
	width = 32'd1;
	
	numberStartPos_x = 0;
	numberStartPos_y = 0;
	detectedObject = 3'b000;

end 
always@(posedge clk)begin


	
	clk25 = ~clk25; //creates the 25Mhz clock since input clock is 50Mhz
		

			case(displayWithinLimits)
				//if not on screen, display black
				0: begin
					mRed = 4'b0000;
					mGreen = 4'b0000;
					mBlue = 4'b0000;
				end
				
				//if on screen, display logic
				1: begin
					
					
					
					//draw the circles
					if(((VGA_X - 320)**2 + (VGA_Y - 480)**2) <= 400**2)begin
						mRed = 4'b0000;
						mGreen = 4'b0011;
						mBlue = 4'b0000;
					end
					else begin
				
						mRed = 4'b0000;
						mGreen = 4'b0000;
						mBlue = 4'b0000;
					end
					
					if(((VGA_X - 320)**2 + (VGA_Y - 480)**2) <= 395**2)begin
						mRed = 4'b0000;
						mGreen = 4'b0000;
						mBlue = 4'b0000;
					end
					
					if(((VGA_X - 320)**2 + (VGA_Y - 480)**2) <= 300**2)begin
						mRed = 4'b0000;
						mGreen = 4'b0011;
						mBlue = 4'b0000;
					end
					if(((VGA_X - 320)**2 + (VGA_Y - 480)**2) <= 295**2)begin
						mRed = 4'b0000;
						mGreen = 4'b0000;
						mBlue = 4'b0000;
					end
					if(((VGA_X - 320)**2 + (VGA_Y - 480)**2) <= 200**2)begin
						mRed = 4'b0000;
						mGreen = 4'b0011;
						mBlue = 4'b0000;
					end
					if(((VGA_X - 320)**2 + (VGA_Y - 480)**2) <= 195**2)begin
						mRed = 4'b0000;
						mGreen = 4'b0000;
						mBlue = 4'b0000;
					end
					if(((VGA_X - 320)**2 + (VGA_Y - 480)**2) <= 100**2)begin
						mRed = 4'b0000;
						mGreen = 4'b0011;
						mBlue = 4'b0000;
					end
					if(((VGA_X - 320)**2 + (VGA_Y - 480)**2) <= 95**2)begin
						mRed = 4'b0000;
						mGreen = 4'b0000;
						mBlue = 4'b0000;
					end
					
					
					//Draw the background lines
					if((VGA_X >= 640 - slope_2) && (VGA_X <= (640 - slope_2)+width) && (VGA_Y  >= 320) && (VGA_Y <= 480))begin
						
						mRed = 4'b0000;
						mGreen = 4'b1111;
						mBlue = 4'b0000;
					end
					else if((VGA_X >= 0 + slope_2) && (VGA_X <= (0 + slope_2)+width) && (VGA_Y  >= 320) && (VGA_Y <= 480))begin
						
						mRed = 4'b0000;
						mGreen = 4'b1111;
						mBlue = 4'b0000;
					end
					else if((VGA_X >= (160+ slope_3)) && (VGA_X <= (160+slope_3)+width) && (VGA_Y  >= 0) && (VGA_Y <= 480)) begin
						mRed = 4'b0000;
						mGreen = 4'b1111;
						mBlue = 4'b0000;
					end
					else if((VGA_X >= (480 - slope_3)) && (VGA_X <= (480-slope_3)+width) && (VGA_Y  >= 0) && (VGA_Y <= 480)) begin
						mRed = 4'b0000;
						mGreen = 4'b1111;
						mBlue = 4'b0000;
					end

					
					if(positionToDraw == 0)begin //0
						//if((VGA_X >= 320 + (centimeters - 5))&& (VGA_X <=  320 + (centimeters + 5) ) && ((VGA_Y >= (480 - centimeters) - 5 )) && ((VGA_Y <= (480 - centimeters) + 5) ))
						//begin
								
									//mRed = 4'b1111;
									//mGreen = 4'b0000;
									//mBlue = 4'b0000;
									
									
									objects_x[0] = 320 + (centimeters);
									objects_y[0] = 480 - (centimeters);
									
									numberStartPos_x = 320 + (centimeters) - 5;
									numberStartPos_y = 480 - (centimeters) - 10;
									if(centimeters > 0)begin
										detectedObject[0] = 1'b1;
									end
									else begin
										detectedObject[0] = 1'b0;
									end

					end
					if(positionToDraw == 90)begin // 90
						
									objects_x[1] = 32'd320;
									objects_y[1] = 480 - (centimeters << 1);
						
									numberStartPos_x = 32'd320 - 5;
									numberStartPos_y = (480-(centimeters << 1)) - 10;
									
									if(centimeters > 0)begin
										detectedObject[1] = 1'b1;
									end
									else begin
										detectedObject[1] = 1'b0;
									end
								
						
					end
					if(positionToDraw == 180) begin // 180

						objects_x[2] = 320 - (centimeters);
						objects_y[2] = 480 - (centimeters);
						
						numberStartPos_x = 320 - (centimeters) - 5;
						numberStartPos_y = 480 - (centimeters) - 10;
						
						if(centimeters > 0)begin
										detectedObject[2] = 1'b1;
									end
									else begin
										detectedObject[2] = 1'b0;
									end
								
					end
		
		
					//draw all the object detected
					for(i = 0;i<3;i=i+1) 
					begin
						if((VGA_X >= (objects_x[i] - 5)) && (VGA_X <= (objects_x[i] + 5)) && ((VGA_Y >= objects_y[i] - 5)) && ((VGA_Y <= objects_y[i] + 5)) && (detectedObject[i] == 1'b1))
						begin
								
									mRed = 4'b1111;
									mGreen = 4'b0000;
									mBlue = 4'b0000;
								
						end
					end
					//draw the three numbers based on the distance
					
					
			//decide which matrix to use
		case (distanceHundreds)
			32'd0: begin
				number1Matrix[0][0] =1; number1Matrix[0][1] =1; number1Matrix[0][2] =1;
				number1Matrix[1][0] =1; number1Matrix[1][1] =0; number1Matrix[1][2] =1;
				number1Matrix[2][0] =1; number1Matrix[2][1] =0; number1Matrix[2][2] =1;
				number1Matrix[3][0] =1; number1Matrix[3][1] =0; number1Matrix[3][2] =1;
				number1Matrix[4][0] =1; number1Matrix[4][1] =1; number1Matrix[4][2] =1;
			end
			32'd1: begin
				number1Matrix[0][0] =0; number1Matrix[0][1] =1; number1Matrix[0][2] =0;
				number1Matrix[1][0] =0; number1Matrix[1][1] =1; number1Matrix[1][2] =0;
				number1Matrix[2][0] =0; number1Matrix[2][1] =1; number1Matrix[2][2] =0;
				number1Matrix[3][0] =0; number1Matrix[3][1] =1; number1Matrix[3][2] =0;
				number1Matrix[4][0] =0; number1Matrix[4][1] =1; number1Matrix[4][2] =0;
			end
			32'd2: begin
				number1Matrix[0][0] =1; number1Matrix[0][1] =1; number1Matrix[0][2] =1;
				number1Matrix[1][0] =0; number1Matrix[1][1] =0; number1Matrix[1][2] =1;
				number1Matrix[2][0] =1; number1Matrix[2][1] =1; number1Matrix[2][2] =1;
				number1Matrix[3][0] =1; number1Matrix[3][1] =0; number1Matrix[3][2] =0;
				number1Matrix[4][0] =1; number1Matrix[4][1] =1; number1Matrix[4][2] =1;
			end
			32'd3: begin
				number1Matrix[0][0] =1; number1Matrix[0][1] =1; number1Matrix[0][2] =1;
				number1Matrix[1][0] =0; number1Matrix[1][1] =0; number1Matrix[1][2] =1;
				number1Matrix[2][0] =1; number1Matrix[2][1] =1; number1Matrix[2][2] =1;
				number1Matrix[3][0] =0; number1Matrix[3][1] =0; number1Matrix[3][2] =1;
				number1Matrix[4][0] =1; number1Matrix[4][1] =1; number1Matrix[4][2] =1;
			end
			32'd4: begin
				number1Matrix[0][0] =1; number1Matrix[0][1] =0; number1Matrix[0][2] =1;
				number1Matrix[1][0] =1; number1Matrix[1][1] =0; number1Matrix[1][2] =1;
				number1Matrix[2][0] =1; number1Matrix[2][1] =1; number1Matrix[2][2] =1;
				number1Matrix[3][0] =0; number1Matrix[3][1] =0; number1Matrix[3][2] =1;
				number1Matrix[4][0] =0; number1Matrix[4][1] =0; number1Matrix[4][2] =1;
			end
		endcase
		
		if((distanceTens <= 32'd99) && (distanceTens >=32'd90))begin
				number2Matrix[0][0] =1; number2Matrix[0][1] =1; number2Matrix[0][2] =1;
				number2Matrix[1][0] =1; number2Matrix[1][1] =0; number2Matrix[1][2] =1;
				number2Matrix[2][0] =1; number2Matrix[2][1] =1; number2Matrix[2][2] =1;
				number2Matrix[3][0] =0; number2Matrix[3][1] =0; number2Matrix[3][2] =1;
				number2Matrix[4][0] =0; number2Matrix[4][1] =0; number2Matrix[4][2] =1;
		end
		else if((distanceTens <= 32'd89) && (distanceTens >=32'd80))begin
				number2Matrix[0][0] =1; number2Matrix[0][1] =1; number2Matrix[0][2] =1;
				number2Matrix[1][0] =1; number2Matrix[1][1] =0; number2Matrix[1][2] =1;
				number2Matrix[2][0] =1; number2Matrix[2][1] =1; number2Matrix[2][2] =1;
				number2Matrix[3][0] =1; number2Matrix[3][1] =0; number2Matrix[3][2] =1;
				number2Matrix[4][0] =1; number2Matrix[4][1] =1; number2Matrix[4][2] =1;
		end
		else if((distanceTens <= 32'd79) && (distanceTens >=32'd70))begin
				number2Matrix[0][0] =1; number2Matrix[0][1] =1; number2Matrix[0][2] =1;
				number2Matrix[1][0] =0; number2Matrix[1][1] =0; number2Matrix[1][2] =1;
				number2Matrix[2][0] =0; number2Matrix[2][1] =0; number2Matrix[2][2] =1;
				number2Matrix[3][0] =0; number2Matrix[3][1] =0; number2Matrix[3][2] =1;
				number2Matrix[4][0] =0; number2Matrix[4][1] =0; number2Matrix[4][2] =1;
		end
		else if((distanceTens <= 32'd69) && (distanceTens >=32'd60))begin
				number2Matrix[0][0] =1; number2Matrix[0][1] =0; number2Matrix[0][2] =0;
				number2Matrix[1][0] =1; number2Matrix[1][1] =0; number2Matrix[1][2] =0;
				number2Matrix[2][0] =1; number2Matrix[2][1] =1; number2Matrix[2][2] =1;
				number2Matrix[3][0] =1; number2Matrix[3][1] =0; number2Matrix[3][2] =1;
				number2Matrix[4][0] =1; number2Matrix[4][1] =1; number2Matrix[4][2] =1;
		end
		else if((distanceTens <= 32'd59) && (distanceTens >=32'd50))begin
				number2Matrix[0][0] =1; number2Matrix[0][1] =1; number2Matrix[0][2] =1;
				number2Matrix[1][0] =1; number2Matrix[1][1] =0; number2Matrix[1][2] =0;
				number2Matrix[2][0] =1; number2Matrix[2][1] =1; number2Matrix[2][2] =1;
				number2Matrix[3][0] =0; number2Matrix[3][1] =0; number2Matrix[3][2] =1;
				number2Matrix[4][0] =1; number2Matrix[4][1] =1; number2Matrix[4][2] =1;
		end
		else if((distanceTens <= 32'd49) && (distanceTens >=32'd40))begin
				number2Matrix[0][0] =1; number2Matrix[0][1] =0; number2Matrix[0][2] =1;
				number2Matrix[1][0] =1; number2Matrix[1][1] =0; number2Matrix[1][2] =1;
				number2Matrix[2][0] =1; number2Matrix[2][1] =1; number2Matrix[2][2] =1;
				number2Matrix[3][0] =0; number2Matrix[3][1] =0; number2Matrix[3][2] =1;
				number2Matrix[4][0] =0; number2Matrix[4][1] =0; number2Matrix[4][2] =1;
		end
		else if((distanceTens <= 32'd39) && (distanceTens >=32'd30))begin
				number2Matrix[0][0] =1; number2Matrix[0][1] =1; number2Matrix[0][2] =1;
				number2Matrix[1][0] =0; number2Matrix[1][1] =0; number2Matrix[1][2] =1;
				number2Matrix[2][0] =1; number2Matrix[2][1] =1; number2Matrix[2][2] =1;
				number2Matrix[3][0] =0; number2Matrix[3][1] =0; number2Matrix[3][2] =1;
				number2Matrix[4][0] =1; number2Matrix[4][1] =1; number2Matrix[4][2] =1;
		end
		else if((distanceTens <= 32'd29) && (distanceTens >=32'd20))begin
				number2Matrix[0][0] =1; number2Matrix[0][1] =1; number2Matrix[0][2] =1;
				number2Matrix[1][0] =0; number2Matrix[1][1] =0; number2Matrix[1][2] =1;
				number2Matrix[2][0] =1; number2Matrix[2][1] =1; number2Matrix[2][2] =1;
				number2Matrix[3][0] =1; number2Matrix[3][1] =0; number2Matrix[3][2] =0;
				number2Matrix[4][0] =1; number2Matrix[4][1] =1; number2Matrix[4][2] =1;
		end
		else if((distanceTens <= 32'd19) && (distanceTens >=32'd10))begin
				number2Matrix[0][0] =0; number2Matrix[0][1] =1; number2Matrix[0][2] =0;
				number2Matrix[1][0] =0; number2Matrix[1][1] =1; number2Matrix[1][2] =0;
				number2Matrix[2][0] =0; number2Matrix[2][1] =1; number2Matrix[2][2] =0;
				number2Matrix[3][0] =0; number2Matrix[3][1] =1; number2Matrix[3][2] =0;
				number2Matrix[4][0] =0; number2Matrix[4][1] =1; number2Matrix[4][2] =0;
		end
		else begin
				number2Matrix[0][0] =1; number2Matrix[0][1] =1; number2Matrix[0][2] =1;
				number2Matrix[1][0] =1; number2Matrix[1][1] =0; number2Matrix[1][2] =1;
				number2Matrix[2][0] =1; number2Matrix[2][1] =0; number2Matrix[2][2] =1;
				number2Matrix[3][0] =1; number2Matrix[3][1] =0; number2Matrix[3][2] =1;
				number2Matrix[4][0] =1; number2Matrix[4][1] =1; number2Matrix[4][2] =1;
		end
		
		
		
		case(distanceOnes)
		
			32'd0: begin
				number3Matrix[0][0] =1; number3Matrix[0][1] =1; number3Matrix[0][2] =1;
				number3Matrix[1][0] =1; number3Matrix[1][1] =0; number3Matrix[1][2] =1;
				number3Matrix[2][0] =1; number3Matrix[2][1] =0; number3Matrix[2][2] =1;
				number3Matrix[3][0] =1; number3Matrix[3][1] =0; number3Matrix[3][2] =1;
				number3Matrix[4][0] =1; number3Matrix[4][1] =1; number3Matrix[4][2] =1;
			end
			32'd1: begin
				number3Matrix[0][0] =0; number3Matrix[0][1] =1; number3Matrix[0][2] =0;
				number3Matrix[1][0] =0; number3Matrix[1][1] =1; number3Matrix[1][2] =0;
				number3Matrix[2][0] =0; number3Matrix[2][1] =1; number3Matrix[2][2] =0;
				number3Matrix[3][0] =0; number3Matrix[3][1] =1; number3Matrix[3][2] =0;
				number3Matrix[4][0] =0; number3Matrix[4][1] =1; number3Matrix[4][2] =0;
			end
			32'd2: begin
				number3Matrix[0][0] =1; number3Matrix[0][1] =1; number3Matrix[0][2] =1;
				number3Matrix[1][0] =0; number3Matrix[1][1] =0; number3Matrix[1][2] =1;
				number3Matrix[2][0] =1; number3Matrix[2][1] =1; number3Matrix[2][2] =1;
				number3Matrix[3][0] =1; number3Matrix[3][1] =0; number3Matrix[3][2] =0;
				number3Matrix[4][0] =1; number3Matrix[4][1] =1; number3Matrix[4][2] =1;
			end
			32'd3: begin
				number3Matrix[0][0] =1; number3Matrix[0][1] =1; number3Matrix[0][2] =1;
				number3Matrix[1][0] =0; number3Matrix[1][1] =0; number3Matrix[1][2] =1;
				number3Matrix[2][0] =1; number3Matrix[2][1] =1; number3Matrix[2][2] =1;
				number3Matrix[3][0] =0; number3Matrix[3][1] =0; number3Matrix[3][2] =1;
				number3Matrix[4][0] =1; number3Matrix[4][1] =1; number3Matrix[4][2] =1;
			end
			32'd4: begin
				number3Matrix[0][0] =1; number3Matrix[0][1] =0; number3Matrix[0][2] =1;
				number3Matrix[1][0] =1; number3Matrix[1][1] =0; number3Matrix[1][2] =1;
				number3Matrix[2][0] =1; number3Matrix[2][1] =1; number3Matrix[2][2] =1;
				number3Matrix[3][0] =0; number3Matrix[3][1] =0; number3Matrix[3][2] =1;
				number3Matrix[4][0] =0; number3Matrix[4][1] =0; number3Matrix[4][2] =1;
			end
			32'd5: begin
				number3Matrix[0][0] =1; number3Matrix[0][1] =1; number3Matrix[0][2] =1;
				number3Matrix[1][0] =1; number3Matrix[1][1] =0; number3Matrix[1][2] =0;
				number3Matrix[2][0] =1; number3Matrix[2][1] =1; number3Matrix[2][2] =1;
				number3Matrix[3][0] =0; number3Matrix[3][1] =0; number3Matrix[3][2] =1;
				number3Matrix[4][0] =1; number3Matrix[4][1] =1; number3Matrix[4][2] =1;
			end
			32'd6: begin
				number3Matrix[0][0] =1; number3Matrix[0][1] =0; number3Matrix[0][2] =0;
				number3Matrix[1][0] =1; number3Matrix[1][1] =0; number3Matrix[1][2] =0;
				number3Matrix[2][0] =1; number3Matrix[2][1] =1; number3Matrix[2][2] =1;
				number3Matrix[3][0] =1; number3Matrix[3][1] =0; number3Matrix[3][2] =1;
				number3Matrix[4][0] =1; number3Matrix[4][1] =1; number3Matrix[4][2] =1;
			end
			32'd7: begin
				number3Matrix[0][0] =1; number3Matrix[0][1] =1; number3Matrix[0][2] =1;
				number3Matrix[1][0] =0; number3Matrix[1][1] =0; number3Matrix[1][2] =1;
				number3Matrix[2][0] =0; number3Matrix[2][1] =0; number3Matrix[2][2] =1;
				number3Matrix[3][0] =0; number3Matrix[3][1] =0; number3Matrix[3][2] =1;
				number3Matrix[4][0] =0; number3Matrix[4][1] =0; number3Matrix[4][2] =1;
			end
			32'd8: begin
				number3Matrix[0][0] =1; number3Matrix[0][1] =1; number3Matrix[0][2] =1;
				number3Matrix[1][0] =1; number3Matrix[1][1] =0; number3Matrix[1][2] =1;
				number3Matrix[2][0] =1; number3Matrix[2][1] =1; number3Matrix[2][2] =1;
				number3Matrix[3][0] =1; number3Matrix[3][1] =0; number3Matrix[3][2] =1;
				number3Matrix[4][0] =1; number3Matrix[4][1] =1; number3Matrix[4][2] =1;
			end
			32'd9: begin
				number3Matrix[0][0] =1; number3Matrix[0][1] =1; number3Matrix[0][2] =1;
				number3Matrix[1][0] =1; number3Matrix[1][1] =0; number3Matrix[1][2] =1;
				number3Matrix[2][0] =1; number3Matrix[2][1] =1; number3Matrix[2][2] =1;
				number3Matrix[3][0] =0; number3Matrix[3][1] =0; number3Matrix[3][2] =1;
				number3Matrix[4][0] =0; number3Matrix[4][1] =0; number3Matrix[4][2] =1;
			end

		endcase
					

							
						for(j = 0; j < 5; j=j+1)
						begin	
								for(k = 0; k< 3; k=k+1)
								begin
									if((VGA_X == numberStartPos_x+k) && (VGA_Y == (numberStartPos_y + j)) && (number1Matrix[j][k] == 1 ) && (centimeters > 0))begin
											mRed = 4'b1111;
											mGreen = 4'b1111;
											mBlue = 4'b0000;
									end
								end
							end
						//end
						
						for(j = 0; j < 5; j=j+1)
							begin	
								for(k = 0; k< 3; k=k+1)
								begin
									if((VGA_X == (numberStartPos_x + 5)+k) && (VGA_Y == (numberStartPos_y + j)) && (number2Matrix[j][k] == 1 ) && (centimeters > 0))begin
											mRed = 4'b1111;
											mGreen = 4'b1111;
											mBlue = 4'b0000;
									end
								end
							end
						
						
						for(j = 0; j < 5; j=j+1)
							begin	
								for(k = 0; k< 3; k=k+1)
								begin
									if((VGA_X == (numberStartPos_x + 10)+k) && (VGA_Y == (numberStartPos_y + j)) && (number3Matrix[j][k] == 1 ) && (centimeters > 0))begin
											mRed = 4'b1111;
											mGreen = 4'b1111;
											mBlue = 4'b0000;
									end
								end
							end
				end			
			endcase
			
end


//fires every time the bottom of the screen moves back up to the beginning of the screen.
	
	//happens every 60Hhz -> 15 * 1/60Hz = .25 seconds
	always@(posedge vertical_sync)begin

	end
	
	//happens at the end of every vertical line
	always@(posedge horizontal_sync)begin
	
		if( (VGA_Y >= 320) && (VGA_Y <= 480)) begin
			
			slope_2 = slope_2 + 32'd2;
		
		end
		else begin
			slope_2 = 32'd0;
			//line_Y = 32'd320;
		end
	
		if( (VGA_Y >= 1) && (VGA_Y <= 480)) begin
			
			//slope_3 = slope_3 + 32'd2;
			slope_counter = slope_counter + 1;
			if(slope_counter > 2)
			begin
				slope_counter = 0;
				slope_3 = slope_3 + 32'd1;
			end
		
		end
		else begin
			slope_3 = 32'd0;
			//line_Y = 32'd320;
		end
	end


						
endmodule

module sound(output reg signalout, input  clk, input [31:0] speed);

	reg [31:0] mycounter1, mycounter2, myonesecond, countlow, counthigh; 
	reg [3:0] progress, lastnote;
	
	
	initial begin 
		mycounter1=0;
		mycounter2=0; 
		signalout=0; 
		myonesecond = 50000000/8; 
		progress = 4'b0001; 
		countlow = 23889; 
				counthigh = 47778; 
	end

	always@(posedge clk) begin
	
		case(progress)
			default: begin end
			4'b0000: 
			begin
				//increment both counters
				mycounter1 = mycounter1 + 1'b1; 
				mycounter2 = mycounter2 + 1'b1;
				
				//output low while counter1 is less than count low
				if (mycounter1 < countlow) begin
					signalout = 0;
				end
				//input 1 if counter 1 is between countlow and counthigh
				if ((mycounter1 >= countlow) && (mycounter1 < counthigh)) begin 
					signalout = 1;
				end 
				
				//reset counters if greater than high, reset signal back to 0
				if (mycounter1 >= counthigh) begin 
					signalout = 0; 
					mycounter1 = 0;	
					
					//play the next note if more than input time
					if (mycounter2 >= speed) begin
						progress = lastnote; 
						mycounter2 = 0;
					end 
				end 
			end
			
			//defines each note
			
		
			4'b1001: begin //blank note
			signalout = 0;
				countlow = 0; 
				counthigh = 0; 
				progress = 0; 
				lastnote = 4'b1000;
			end	
			4'b1000: begin //C6
				countlow = 23889; 
				counthigh = 47778; 
				progress = 0; 
				lastnote = 4'b1001;
			end
		endcase 
	end
	

endmodule 

module ultrasonicSensor(
	input clk,
	input rst, 
	input echo,
	input enable,
	output reg trigger,
	output reg [31:0] totalCounter,
	output reg [31:0] output_distance,	
	output echoLED, 
	output triggerLED
);


reg [31:0] counter, counter_cm, distance_cm;

assign echoLED = echo;
assign triggerLED = trigger;

initial begin
	counter = 0;
	totalCounter = 0;
end

always@(posedge clk) begin

	if(rst) begin
			counter = 0;
			totalCounter = 0;
			distance_cm = 0;
			counter_cm = 0;
	end
	else begin

		//set trigger to high for 50 microseconds
		counter = counter + 1;
		if(counter <= 500) begin 
			
			trigger = 1'b1;
		
		end
		else begin
			trigger = 1'b0;
		end
		
		//count how long the echo is. Every 2942 ticks increase the centimeter counter
		if(echo)begin
			totalCounter = totalCounter + 1;
			counter_cm = counter_cm + 1;
			if(counter_cm >= 2942)begin
				counter_cm = 0;
				distance_cm = distance_cm + 1;
			end
		end
		
		//Flip Flop - if enable is high set the outout distance
		if(enable)begin
			
			//max software range is 200m. Set output to 0 if above 200m.
			if(distance_cm < 200) begin
				output_distance = distance_cm;
			end
			else begin
				output_distance = 0;
			end
		
		end
		
		if(counter > 12500000) begin //refresh sensor
			counter = 0;
			totalCounter = 0;
			counter_cm = 0;
			distance_cm = 0;
		end	
		
		
		
	end
end		


endmodule