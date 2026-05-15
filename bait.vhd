LIBRARY IEEE;
USE  IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY bait IS
   PORT(  pixel_row, pixel_column	: IN std_logic_vector(9 DOWNTO 0);
		  fsm_state                 : IN std_logic_vector(1 DOWNTO 0);
          pipe_x_pos_1              : IN std_logic_vector(9 DOWNTO 0);
          gap_height                : IN std_logic_vector(9 DOWNTO 0);
		  red, green, blue 			: OUT std_logic;
          bait_enable               : OUT std_logic);
END bait; 

ARCHITECTURE behaviour of bait is
    SIGNAL bait_on              : std_logic;
    SIGNAL state                : std_logic;
    SIGNAL size                 : std_logic_vector(9 DOWNTO 0);
    SIGNAL bait_x_pos           : std_logic_vector(9 DOWNTO 0);
    SIGNAL bait_y_pos           : std_logic_vector(9 DOWNTO 0);
    SIGNAL randomiser           : std_logic;

BEGIN

    state <= '1' when FSM_STATE = "01" else '0'; -- only show bait during game state

    randomiser <= gap_height(0); -- random 1 or 0

	bait_enable <= bait_on and state and randomiser; -- for collisions

	size <= CONV_STD_LOGIC_VECTOR(4,10);

	bait_x_pos <= pipe_x_pos_1 + CONV_STD_LOGIC_VECTOR(25, 10);
    bait_y_pos <= gap_height + CONV_STD_LOGIC_VECTOR(50, 10);

    bait_on <= '1' when (
        state = '1' and
        randomiser = '1' and
        pixel_column >= bait_x_pos - size and 
        pixel_column <= bait_x_pos + size and 
        pixel_row >= bait_y_pos - size and 
        pixel_row <= bait_y_pos + size)
        else '0';
    
    red <= bait_on;
    green <= bait_on;
    blue <=  '0';

END behaviour;