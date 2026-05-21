LIBRARY IEEE;
USE  IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;

-- Creates bait between every third pipe during state '01'
-- Visibility is randomised so bait does not appear in a pattern (randomisation needs work) 
-- Uses gap_height of pipe_1 to determine bait height
-- Uses x position of pipe_1 to determine horizontal movement
-- bait_enable outputs '1' if bait is visible so this can be used for collisions

ENTITY bait IS
   PORT(  pixel_row, pixel_column	: IN std_logic_vector(9 DOWNTO 0);
		  fsm_state                 : IN std_logic_vector(1 DOWNTO 0);
          pipe_x_pos_1              : IN std_logic_vector(9 DOWNTO 0);
          gap_height                : IN std_logic_vector(9 DOWNTO 0);
		  red, green, blue 			: OUT std_logic;
          bait_on                   : OUT std_logic;
          bait_enable               : OUT std_logic);
END bait; 

ARCHITECTURE behaviour of bait is
    SIGNAL state                : std_logic;
    SIGNAL size                 : std_logic_vector(9 DOWNTO 0);
    SIGNAL bait_x_pos           : std_logic_vector(9 DOWNTO 0);
    SIGNAL bait_y_pos           : std_logic_vector(9 DOWNTO 0);
    SIGNAL randomiser           : std_logic;
    SIGNAL bait_visible : std_logic;

BEGIN

    state <= '1' when FSM_STATE = "01" else '0'; -- only show bait during game state

    randomiser <= gap_height(0);


	bait_enable <= bait_visible;

	size <= CONV_STD_LOGIC_VECTOR(4,10);

	bait_x_pos <= pipe_x_pos_1 + CONV_STD_LOGIC_VECTOR(25, 10);
    bait_y_pos <= gap_height + CONV_STD_LOGIC_VECTOR(100, 10);
    
    bait_visible <= '1' when (
    state = '1' and
    randomiser = '1' and
    pixel_column >= bait_x_pos - size and 
    pixel_column <= bait_x_pos + size and 
    pixel_row >= bait_y_pos - size and 
    pixel_row <= bait_y_pos + size
) else '0';

bait_on <= bait_visible;
red   <= bait_visible;
green <= bait_visible;
blue  <= '0';

END behaviour;