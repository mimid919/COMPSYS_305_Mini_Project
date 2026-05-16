LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY flappy_dolphin IS
	PORT
		( clk, vert_sync	: IN std_logic;
          pixel_row, pixel_column	: IN std_logic_vector(9 DOWNTO 0);
		  left_click 				: IN std_logic;
		  fsm_state                 : IN std_logic_vector(1 DOWNTO 0);
		  red, green, blue 			: OUT std_logic;
		  dolphin_enable				: OUT std_logic); -- for collisions
END flappy_dolphin; 



architecture behavior of flappy_dolphin is

SIGNAL dolphin_on					: std_logic;
SIGNAL size 						: std_logic_vector(9 DOWNTO 0);  
SIGNAL dolphin_y_pos				: std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(240,10); -- start on the ground
SIGNAL dolphin_x_pos				: std_logic_vector(9 DOWNTO 0);
SIGNAL dolphin_y_motion				: std_logic_vector(9 DOWNTO 0);
SIGNAL left_click_prev				: std_logic := '0'; -- to avoid holding click
SIGNAL state						 : std_logic;
SIGNAL prev_state					: std_logic := '0';

-- increase gravity to fall faster
CONSTANT gravity 					: std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(2,10); 
-- for bigger jump --> 1008 (-16) or smaller jump --> 1020 (-4)
CONSTANT jump				: std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(1000, 10); -- -8 is 1016
CONSTANT dolphin_ground 			: std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(472,10); -- ground level for dolphin

BEGIN           
  	state <= '1' when FSM_STATE = "01" else '0'; -- only show pipes during game state

	dolphin_enable <= dolphin_on and state; -- for collisions

	size <= CONV_STD_LOGIC_VECTOR(8,10);

	dolphin_x_pos <= CONV_STD_LOGIC_VECTOR(50,10);

	dolphin_on <= '1' when (
		(dolphin_y_pos >= size) and
		(pixel_column >= dolphin_x_pos - size) and (pixel_column <= dolphin_x_pos + size) and
		(pixel_row >= dolphin_y_pos - size) and (pixel_row <= dolphin_y_pos + size))
		else '0';

	-- blue dolphin
	Red <= '0';
	Green <= '0';
	Blue <=  dolphin_on and state;

	process (vert_sync)
		variable left_click_edge : std_logic;
	begin
		if (rising_edge(vert_sync)) then
			prev_state <= state;

			left_click_prev <= left_click; -- update previous left click value			
			left_click_edge := left_click and (not left_click_prev); -- detect rising edge of left click

			if (state = '1' and prev_state = '0') then
				dolphin_y_pos <= CONV_STD_LOGIC_VECTOR(240, 10);
				dolphin_y_motion <= CONV_STD_LOGIC_VECTOR(0, 10);

			elsif (left_click_edge = '1') then
				dolphin_y_motion <= jump;
				if dolphin_y_pos <= size then -- dolphin at top of screen
					dolphin_y_pos <= dolphin_y_pos + gravity;
				elsif dolphin_y_pos >= dolphin_ground then -- dolphin at bottom of screen
					dolphin_y_pos <= dolphin_ground;
				else
					dolphin_y_pos <= dolphin_y_pos + dolphin_y_motion;
				end if;
			else
				dolphin_y_motion <= gravity;
				if dolphin_y_pos <= size then -- dolphin at top of screen
					dolphin_y_pos <= dolphin_y_pos + gravity;
				elsif dolphin_y_pos >= dolphin_ground then -- dolphin at bottom of screen
					dolphin_y_pos <= dolphin_ground;
				else
					dolphin_y_pos <= dolphin_y_pos + dolphin_y_motion;
				end if;
			end if;
			
		end if;
	end process;

END behavior;

