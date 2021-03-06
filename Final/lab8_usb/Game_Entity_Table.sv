module game_entity_table(input Reset, frame_clk,
								 input logic [9:0] Entity,
								 input        [9:0]  BallX, BallY,
								 output logic eaten,hurt,
								 output logic [9:0] TLX, TLY, BRX, BRY);

	logic [9:0] Enemy_X_Pos, Enemy_X_Motion, Enemy_Y_Pos, Enemy_Y_Motion;
	logic [9:0] Food_X_Pos,Food_Y_Pos;
	
	parameter [9:0] Enemy_X_Center=400;  // Center position on the X axis
   parameter [9:0] Enemy_Y_Center=300;  // Center position on the Y axis
   parameter [9:0] Enemy_X_Min=200;       // Leftmost point on the X axis
   parameter [9:0] Enemy_X_Max=600;     // Rightmost point on the X axis
   parameter [9:0] Enemy_Y_Min=50;       // Topmost point on the Y axis
   parameter [9:0] Enemy_Y_Max=425;     // Bottommost point on the Y axis
   parameter [9:0] Enemy_X_Step=2;      // Step size on the X axis
   parameter [9:0] Enemy_Y_Step=2;      // Step size on the Y axis
	parameter [9:0]  Enemy_Size = 5;
	parameter [9:0] Food_Size = 4;
	
	int randseed [15]= '{215,320,472,519,268,410,371,444,205,350,498,398,460,333,500};
	int randseed2 [15]= '{420,319,350,100,398,205,75,268,190,371,250,215,320,333,163};
	int randcount, random;
	
	always_ff @ (posedge Reset or posedge frame_clk )
    begin: Move_Enemy
        if (Reset)  // Asynchronous Reset
        begin 
            Enemy_Y_Motion <= 10'd1;
				Enemy_X_Motion <= 10'd0;
				Enemy_Y_Pos <= Enemy_Y_Center;
				Enemy_X_Pos <= Enemy_X_Center;
				Food_X_Pos <= 300;
				Food_Y_Pos <= 100;
				randcount = 0;
        end
        
		  else
			begin 
				if(randcount < 15)
					random = randseed[randcount];
				else
					randcount = 0;
				randcount = randcount +1;
				//random = 2'b10;
				if(random > 200 && random <= 300) //up
					begin
						Enemy_X_Motion <= 10'd0;
						if(Enemy_Y_Motion > 0)
							Enemy_Y_Motion <= (~ (Enemy_Y_Step) + 1'b1); 
						else
							Enemy_Y_Motion <= Enemy_Y_Step;
					end
				if(random > 300 && random <=350) //down
					begin
						Enemy_X_Motion <= 10'd0;
						if(Enemy_Y_Motion < 0)
							Enemy_Y_Motion <= (~ (Enemy_Y_Step) + 1'b1); 
						else
							Enemy_Y_Motion <= Enemy_Y_Step;
					end
				if(random > 350 && random <=450) //left
					begin
						Enemy_Y_Motion <= 10'd0;
						if(Enemy_X_Motion > 0)
							Enemy_X_Motion <= (~ (Enemy_X_Step) + 1'b1); 
						else
							Enemy_X_Motion <= Enemy_X_Step;
					end
				if(random > 450 && random <=600) //right
					begin
						Enemy_Y_Motion <= 10'd0;
						if(Enemy_X_Motion < 0)
							Enemy_X_Motion <= (~ (Enemy_X_Step) + 1'b1); 
						else
							Enemy_X_Motion <= Enemy_X_Step;
					end
				
				 if ( ((Enemy_Y_Pos + Enemy_Size) >= Enemy_Y_Max) )
				 begin
						Enemy_Y_Motion <= (~ (Enemy_Y_Step) + 1'b1);  // 2's complement.	
						Enemy_X_Motion <= 10'd0;
				 end
				 else if(((Enemy_Y_Pos - Enemy_Size) <= Enemy_Y_Min))
				 begin
					   Enemy_Y_Motion <= Enemy_Y_Step;
						Enemy_X_Motion <= 10'd0;
				 end
				 if ( ((Enemy_X_Pos + Enemy_Size) >= Enemy_X_Max) )
				 begin
						Enemy_X_Motion <= (~ (Enemy_X_Step) + 1'b1);  // 2's complement.	
						Enemy_Y_Motion <= 10'd0;
				 end
				 else if(((Enemy_X_Pos - Enemy_Size) <= Enemy_X_Min))
				 begin
					   Enemy_X_Motion <= Enemy_X_Step;
						Enemy_Y_Motion <= 10'd0;
				 end
				 
				 Enemy_Y_Pos <= (Enemy_Y_Pos + Enemy_Y_Motion);  // Update Enemy position
				 Enemy_X_Pos <= (Enemy_X_Pos + Enemy_X_Motion);
				 
				 if(BallX >= (Enemy_X_Pos-Enemy_Size) && BallX <= (Enemy_X_Pos+Enemy_Size) && BallY >= (Enemy_Y_Pos-Enemy_Size) && BallY >= (Enemy_Y_Pos+Enemy_Size))
						hurt = 1'b1;
				 else
						hurt = 1'b0;
				 if(BallX >= (Food_X_Pos-Food_Size) && BallX < (Food_X_Pos+Food_Size) && BallY >= (Food_Y_Pos-Food_Size) && BallY < (Food_Y_Pos+Food_Size))
					begin
						eaten = 1'b1;
						Food_X_Pos <= randseed[randcount] ;
						Food_Y_Pos <= randseed2[randcount] ;
					end
				 else
						eaten = 1'b0;
						
				unique case (Entity)
					2: begin
						TLX = Enemy_X_Pos-Enemy_Size;
						TLY = Enemy_Y_Pos-Enemy_Size;
						BRX = Enemy_X_Pos+Enemy_Size;
						BRY = Enemy_Y_Pos+Enemy_Size;
						end
					0: begin
						TLX = Food_X_Pos-Food_Size;
						TLY = Food_Y_Pos-Food_Size;
						BRX = Food_X_Pos+Food_Size;
						BRY = Food_Y_Pos+Food_Size;
						end
				endcase
			end
	
	end
		
endmodule