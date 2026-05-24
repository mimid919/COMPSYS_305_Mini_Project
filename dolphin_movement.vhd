LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;

-- Sets dolphin visibility to 8x8 square around fixed x and click-dependant y position
-- When Game_state_signal changes to '01' dolphin is initialised to verticle center of screen
-- dolphin_enable outputs '1' when dolphin is visible so can be used for collisions
-- dolphin_y_motion is made up of jumps or accumulating gravity (fall gets faster)
-- dolphin_y_motion is added to dolphin_y_position, refreshing each Vert_sync frame
-- set conditions for bouncing down from ceiling 
-- no dolphin movement after touching ground (could add change of state instead)

ENTITY flappy_dolphin IS
	PORT
		( clk, vert_sync	: IN std_logic;
          pixel_row, pixel_column	: IN std_logic_vector(9 DOWNTO 0);
		  dolphin_x_pos_out : OUT std_logic_vector(9 DOWNTO 0);
		dolphin_y_pos_out : OUT std_logic_vector(9 DOWNTO 0);
		  left_click 				: IN std_logic;
		  Game_state_signal                 : IN std_logic_vector(1 DOWNTO 0);
		  dolphin_on				: OUT std_logic;
		  dolphin_enable			: OUT std_logic); -- for collisions
END flappy_dolphin; 

architecture behavior of flappy_dolphin is

SIGNAL size 						: std_logic_vector(9 DOWNTO 0);  
SIGNAL dolphin_y_pos				: std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(240,10); -- start on the ground
SIGNAL dolphin_x_pos				: std_logic_vector(9 DOWNTO 0);
SIGNAL dolphin_y_motion				: std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(0, 10);
SIGNAL left_click_prev				: std_logic := '0'; -- to avoid holding click
SIGNAL state						 : std_logic;
SIGNAL prev_state					: std_logic := '0';

-- increase gravity to fall faster
CONSTANT gravity 					: std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(1,10); 
-- for bigger jump --> 1008 (-16) or smaller jump --> 1020 (-4)
CONSTANT jump				: std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(1010, 10); -- -8 is 1016
CONSTANT dolphin_ground 			: std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(472,10); -- ground level for dolphin

BEGIN   

dolphin_x_pos_out <= dolphin_x_pos;
dolphin_y_pos_out <= dolphin_y_pos;

  	state <= '1' when Game_state_signal = "01" else '0'; -- only show pipes during game state

	size <= CONV_STD_LOGIC_VECTOR(8,10);

	dolphin_x_pos <= CONV_STD_LOGIC_VECTOR(50,10);

	-- sets dolphin visibility to 8x8 square
	dolphin_on <= '1' when (
	(state = '1') and
	(dolphin_y_pos >= size) and
	(pixel_column >= dolphin_x_pos - size) and 
	(pixel_column <= dolphin_x_pos + size) and
	(pixel_row >= dolphin_y_pos - size) and 
	(pixel_row <= dolphin_y_pos + size)
) else '0';

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

			else
				if (left_click_edge = '1') then
					dolphin_y_motion <= jump;
				else 
					dolphin_y_motion <= dolphin_y_motion + gravity;
				end if;

				dolphin_y_pos <=  dolphin_y_pos + dolphin_y_motion;

				if dolphin_y_pos < size then
					dolphin_y_pos <= size;
					--dolphin_y_motion <= CONV_STD_LOGIC_VECTOR(0, 10);
				end if;

				if dolphin_y_pos >= dolphin_ground then
					dolphin_y_pos <= dolphin_ground;
					dolphin_y_motion <= CONV_STD_LOGIC_VECTOR(0, 10);
				end if;
			end if;
			
		end if;
	end process;

END behavior;

