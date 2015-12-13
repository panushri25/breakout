module breakout(disp, left, right, clock, hsync, vsync, r, g, b);

	input clock, left, right, disp;
	output hsync, vsync, r, g, b;
	
	integer i, j, k, brickIndex, brW = 40, brH = 10, pW = 32, pH = 4, pointValue = 1;
	
	wire inDispArea, border, ball, ballX, ballY, paddle, paddleX, paddleY, bouncingObject, resetFrame, brickCollision;
	wire[23:0] num;
	wire[9:0] cX, cY;
	wire[3:0] sTens, sOnes;
	wire[1:0] scoreDispX;
	wire scoreDispY;
	
	reg[9:0] ballPX = 320, ballPY = 460, paddlePX = 320, paddlePY = 468, scoreDispPX[3:0], scoreDispPY;
	reg[2:0] bricks = 3'b0, scoreWriterX = 3'b0, scoreWriterY = 3'b0, strikePos = 3'b0;
	//bX(n) = 34 + 38 * n, bY(n) = 64 + 20 * n
	reg[9:0] brickPX[0:15], brickPY[0:4];
	reg[63:0] brickState, brickX, brickY;
	reg[7:0] font0[7:0], font1[7:0], font2[7:0], font3[7:0], font4[7:0], font5[7:0], font6[7:0], font7[7:0], font8[7:0], font9[7:0];
	reg[6:0] playerScore = 7'b0000000;
	reg[3:0] tens, ones;
	reg[1:0] ballSpeedX = 2'b10, ballSpeedY = 2'b10;
	reg endGame = 1'b0, score;
	
	initial begin
		for(i = 0; i < 64; i = i + 1)
			brickState[i] = 1;
			
		brickIndex = -1;
			
		brickPX[0] = 10'b100010;
		brickPX[1] = 10'b1001000;
		brickPX[2] = 10'b1101110;
		brickPX[3] = 10'b10010100;
		brickPX[4] = 10'b10111010;
		brickPX[5] = 10'b11100000;
		brickPX[6] = 10'b100000110;
		brickPX[7] = 10'b100101100;
		brickPX[8] = 10'b101010010;
		brickPX[9] = 10'b101111000;
		brickPX[10] = 10'b110011110;
		brickPX[11] = 10'b111000100;
		brickPX[12] = 10'b111101010;
		brickPX[13] = 10'b1000010000;
		brickPX[14] = 10'b1000110110;
		brickPX[15] = 10'b1001011100;
		
		brickPY[0] = 10'b1000000;
		brickPY[1] = 10'b1001010;
		brickPY[2] = 10'b1010100;
		brickPY[3] = 10'b1011110;
		brickPY[4] = 10'b1101000;
		
		scoreDispPX[0] = 16;
		scoreDispPX[1] = 25;
		scoreDispPX[2] = 34;
		scoreDispPX[3] = 43;
		
		scoreDispPY = 458;
		
		font0[0] = 8'b00000000;
		font0[1] = 8'b01111100;
		font0[2] = 8'b01101100;
		font0[3] = 8'b01101100;
		font0[4] = 8'b01101100;
		font0[5] = 8'b01101100;
		font0[6] = 8'b01111100;
		font0[7] = 8'b00000000;
		
		font1[7] = 8'b00000000;
		font1[6] = 8'b01111100;
		font1[5] = 8'b00011100;
		font1[4] = 8'b00011100;
		font1[3] = 8'b00011100;
		font1[2] = 8'b00011100;
		font1[1] = 8'b01111111;
		font1[0] = 8'b00000000;
		
		font2[7] = 8'b00000000;
		font2[6] = 8'b01111110;
		font2[5] = 8'b00011110;
		font2[4] = 8'b00011110;
		font2[3] = 8'b01111000;
		font2[2] = 8'b01111000;
		font2[1] = 8'b01111110;
		font2[0] = 8'b00000000;
		
		font3[7] = 8'b00000000;
		font3[6] = 8'b01111100;
		font3[5] = 8'b00011100;
		font3[4] = 8'b00111100;
		font3[3] = 8'b00111100;
		font3[2] = 8'b00011100;
		font3[1] = 8'b01111100;
		font3[0] = 8'b00000000;
		
		font5[7] = 8'b00000000;
		font5[6] = 8'b01111100;
		font5[5] = 8'b01110000;
		font5[4] = 8'b01110000;
		font5[3] = 8'b00011100;
		font5[2] = 8'b00011100;
		font5[1] = 8'b01111100;
		font5[0] = 8'b00000000;
		
		font4[7] = 8'b00000000;
		font4[6] = 8'b01100000;
		font4[5] = 8'b01100000;
		font4[4] = 8'b01101100;
		font4[3] = 8'b01101100;
		font4[2] = 8'b01111111;
		font4[1] = 8'b00011100;
		font4[0] = 8'b00000000;
		
		font6[7] = 8'b00000000;
		font6[6] = 8'b01111100;
		font6[5] = 8'b01100000;
		font6[4] = 8'b01100000;
		font6[3] = 8'b01111100;
		font6[2] = 8'b01101100;
		font6[1] = 8'b01111100;
		font6[0] = 8'b00000000;
		
		font7[7] = 8'b00000000;
		font7[6] = 8'b01111100;
		font7[5] = 8'b00001100;
		font7[4] = 8'b00011000;
		font7[3] = 8'b00110000;
		font7[2] = 8'b01100000;
		font7[1] = 8'b01100000;
		font7[0] = 8'b00000000;
		
		font8[7] = 8'b00000000;
		font8[6] = 8'b01111100;
		font8[5] = 8'b01101100;
		font8[4] = 8'b01111100;
		font8[3] = 8'b01111100;
		font8[2] = 8'b01101100;
		font8[1] = 8'b01111100;
		font8[0] = 8'b00000000;
		
		font9[7] = 8'b00000000;
		font9[6] = 8'b01111100;
		font9[5] = 8'b01101100;
		font9[4] = 8'b01111100;
		font9[3] = 8'b01111100;
		font9[2] = 8'b00001100;
		font9[1] = 8'b01111100;
		font9[0] = 8'b00000000;
	end
	
	always @(posedge num[0]) begin
		bricks = 3'b0;
		for(i = 0; i < 64; i = i + 1) begin
			j = i % 16;
			k = i / 16;
			
			if(brickState[i])	begin
				brickX[i] = cX == (brickPX[j] - brW / 2) ? 1 : cX == (brickPX[j] + brW / 2 - 1) ? 0 : brickX[i];
				brickY[i] = cY == (brickPY[k] - brH / 2) ? 1 : cY == (brickPY[k] + brH / 2 - 1) ? 0 : brickY[i];
				
				if(k == 0) begin
					bricks[0] = bricks[0] | (brickX[i] & brickY[i]);
					bricks[1] = bricks[1] | (brickX[i] & brickY[i]);
				end
				
				else if(k == 1) begin
					bricks[2] = bricks[2] | (brickX[i] & brickY[i]);
					bricks[1] = bricks[1] | (brickX[i] & brickY[i]);
				end
				
				else if(k == 2) begin
					bricks[2] = bricks[2] | (brickX[i] & brickY[i]);
					bricks[0] = bricks[0] | (brickX[i] & brickY[i]);
				end
				
				else if(k == 3) begin
					bricks[0] = bricks[0] | (brickX[i] & brickY[i]);
				end
				
				else if(k == 4) begin
					bricks[1] = bricks[1] | (brickX[i] & brickY[i]);
				end
			end
		end
	end

	//bricksDisp d(.clock(num[0]), .brickState(brickState), .bricks(bricks), .brickX(brickX), .brickY(brickY));
	
	counter c(.clock(clock), .out(num));

	binaryToBCD convert(.data(playerScore), .t(sTens), .o(sOnes));
	
	syncGen generator(.clock(num[0]), .hsync(hsync), .vsync(vsync), .hcount(cX), .vcount(cY), .inDispArea(inDispArea));
	
	/*Right collision - x = (34 + brW/2) + 38 * m;  */
	reg collisionX1, collisionX2, collisionY1, collisionY2;
		
	always @(posedge num[0])
		if(resetFrame) begin
			collisionX1 <= 0; 
		end
		else if(bouncingObject & (cX == (ballPX - 4)) & (cY == ballPY)) begin 
			collisionX1 <= 1; 
		end
		
	always @(posedge num[0]) 
		if(resetFrame) begin
			collisionX2 <= 0;
		end
		else if(bouncingObject & (cX == (ballPX + 4)) & (cY == ballPY)) begin 
			collisionX2 <= 1; 
		end
		
	always @(posedge num[0]) 
		if(resetFrame) begin 
			collisionY1 <= 0; 
		end
		else if(bouncingObject & (cX == ballPX) & (cY == (ballPY - 4))) begin 
			collisionY1 <= 1; 
		end
		
	always @(posedge num[0]) 
		if(resetFrame) begin
			collisionY2 <= 0; 
		end
		else if(bouncingObject & (cX == ballPX) & ((cY == ballPY + 4))) begin 
			if(cY[9:3] == 59)	endGame <= 1;
			if(paddle) begin
				if(cX - ballPX > 4)	strikePos <= 3'b000;
				else if(ballPX - cX > 4)	strikePos <= 3'b001;
				//else strikePos <= 3'b010;
			end
			collisionY2 <= 1; 
		end
	
	always @(posedge num[0]) begin
		if(|scoreDispX & scoreDispY) begin
			scoreWriterX <= scoreWriterX + 1;
			if(scoreDispX[0]) begin
				case(tens)
					4'b0000: score <= font0[scoreWriterY][scoreWriterX];
					4'b0001: score <= font1[scoreWriterY][scoreWriterX];
					4'b0010: score <= font2[scoreWriterY][scoreWriterX];
					4'b0011: score <= font3[scoreWriterY][scoreWriterX];
					4'b0100: score <= font4[scoreWriterY][scoreWriterX];
					4'b0101: score <= font5[scoreWriterY][scoreWriterX];
					4'b0110: score <= font6[scoreWriterY][scoreWriterX];
					4'b0111: score <= font7[scoreWriterY][scoreWriterX];
					4'b1000: score <= font8[scoreWriterY][scoreWriterX];
					4'b1001: score <= font9[scoreWriterY][scoreWriterX];
					default: score <= font0[scoreWriterY][scoreWriterX];
				endcase
			end
			else if(scoreDispX[1])	begin 
				if(scoreWriterX == 3'b111) scoreWriterY <= scoreWriterY + 1;
				case(ones)
					4'b0000: score <= font0[scoreWriterY][scoreWriterX];
					4'b0001: score <= font1[scoreWriterY][scoreWriterX];
					4'b0010: score <= font2[scoreWriterY][scoreWriterX];
					4'b0011: score <= font3[scoreWriterY][scoreWriterX];
					4'b0100: score <= font4[scoreWriterY][scoreWriterX];
					4'b0101: score <= font5[scoreWriterY][scoreWriterX];
					4'b0110: score <= font6[scoreWriterY][scoreWriterX];
					4'b0111: score <= font7[scoreWriterY][scoreWriterX];
					4'b1000: score <= font8[scoreWriterY][scoreWriterX];
					4'b1001: score <= font9[scoreWriterY][scoreWriterX];
					default: score <= font0[scoreWriterY][scoreWriterX];
				endcase
			end
		end
		else score <= 0;
	end
	
	reg ball_dirX, ball_dirY = 1;
	always @(posedge num[0]) begin
		if(brickCollision) begin
		  for(i = 0; i < 64; i = i + 1)
			 if(brickX[i] & brickY[i])	begin 
				brickIndex <= i;
			 end	
		end
			 
		if(resetFrame) begin	
		  if(brickIndex != -1)	begin
			brickState[brickIndex] <= 0;
			playerScore <= playerScore + pointValue;
			ones <= sOnes;
			tens <= sTens;
			brickIndex <= -1;
		  end
		  
			/*case(strikePos)
				3'b000: ballSpeedX <= 2'b11;
				3'b001: ballSpeedX <= 2'b10;
				3'b010: ballSpeedY <= ballSpeedX;
			endcase*/
		  
		  if(~(collisionX1 & collisionX2))
		  begin
			 ballPX <= ballPX + (ball_dirX ? -ballSpeedX : ballSpeedX);
			 if(collisionX2) ball_dirX <= 1; else if(collisionX1) ball_dirX <= 0;
		  end

		  if(~(collisionY1 & collisionY2))
		  begin
			 ballPY <= ballPY + (ball_dirY ? -ballSpeedY : ballSpeedY);
			 if(collisionY2) ball_dirY <= 1; else if(collisionY1) ball_dirY <= 0;
		  end
		  
		  if(~left)	paddlePX <= paddlePX - 3; else if(~right)	paddlePX <= paddlePX + 3;
		end
	end
	
	assign scoreDispX[0] = cX == scoreDispPX[0] ? 1 : cX == (scoreDispPX[0] + 8) ? 0 : scoreDispX[0];
	assign scoreDispX[1] = cX == scoreDispPX[1] ? 1 : cX == (scoreDispPX[1] + 8) ? 0 : scoreDispX[1];
	//assign scoreDispX[2] = cX == scoreDispPX[2] ? 1 : cX == (scoreDispPX[2] + 8) ? 0 : scoreDispX[2];
	//assign scoreDispX[3] = cX == scoreDispPX[3] ? 1 : cX == (scoreDispPX[3] + 8) ? 0 : scoreDispX[3];
	assign scoreDispY = cY == scoreDispPY ? 1 : cY == (scoreDispPY + 8) ? 0 : scoreDispY;
	
	assign brickCollision = (|bricks) & ball;
	assign bouncingObject = border | paddle | bricks | cY[9:3] == 59;
	assign resetFrame = cX == 639 & cY == 479;
	assign border = cX[9:3] == 0 | cX[9:3] == 79  | cY[9:3] == 0;// | cY[9:3] == 59;
	
	assign ballX = cX == (ballPX - 4) ? 1 : cX == (ballPX + 4) ? 0 : ballX;
	assign ballY = cY == (ballPY - 2) ? 1 : cY == (ballPY + 2) ? 0 : ballY;
	assign paddleX = cX == (paddlePX - pW / 2) ? 1 : cX == (paddlePX + pW / 2 - 1) ? 0 : paddleX;
	assign paddleY = cY == (paddlePY - pH / 2) ? 1 : cY == (paddlePY + pH / 2 - 1) ? 0 : paddleY;
	assign ball = ballX & ballY;
	assign paddle = (paddleX & paddleY);
	
	assign r = (endGame) ? 1 : (border | bricks[0] | score | paddle | /*disp ? (cX[5] ^ cY[5]) : */0);
	assign g = (endGame) ? 0 : (border | bricks[1] | score | paddle | ball);
	assign b = (endGame) ? 1 : (border | bricks[2] | score | paddle | ball);
	
endmodule