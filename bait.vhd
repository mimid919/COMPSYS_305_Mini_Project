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
   PORT(  clk                  : IN std_logic;
          pixel_row, pixel_column	: IN std_logic_vector(9 DOWNTO 0);
		  Game_state_signal                 : IN std_logic_vector(1 DOWNTO 0);
          dolphin_enable           : IN std_logic;
          pipe_x_pos_1              : IN std_logic_vector(9 DOWNTO 0);
          gap_height                : IN std_logic_vector(9 DOWNTO 0);
		  red, green, blue 			: OUT std_logic_vector(3 DOWNTO 0);
          bait_on                   : OUT std_logic;
          bait_enable               : OUT std_logic);
END bait; 

ARCHITECTURE behaviour of bait is
    SIGNAL state                : std_logic;
    SIGNAL size                 : std_logic_vector(9 DOWNTO 0);
    SIGNAL bait_x_pos           : std_logic_vector(9 DOWNTO 0);
    SIGNAL bait_y_pos           : std_logic_vector(9 DOWNTO 0);
    SIGNAL randomiser           : std_logic;
    SIGNAL bait_raw_visible     : std_logic;
    SIGNAL bait_visible         : std_logic;
    SIGNAL bait_eaten           : std_logic := '0';
    SIGNAL pipe_x_pos_prev      : std_logic_vector(9 DOWNTO 0) := (OTHERS => '0');

BEGIN

    state <= '1' when (Game_state_signal = "01" or Game_state_signal = "10") else '0'; -- show bait during gameplay states

    randomiser <= gap_height(0);


	bait_enable <= bait_visible;

	size <= CONV_STD_LOGIC_VECTOR(4,10);

	bait_x_pos <= pipe_x_pos_1 + CONV_STD_LOGIC_VECTOR(25, 10);
    bait_y_pos <= gap_height + CONV_STD_LOGIC_VECTOR(100, 10);

    PROCESS(clk)
    BEGIN
        IF rising_edge(clk) THEN
            pipe_x_pos_prev <= pipe_x_pos_1;

            IF state = '0' THEN
                bait_eaten <= '0';
            ELSIF pipe_x_pos_1 > pipe_x_pos_prev THEN
                bait_eaten <= '0';
            ELSIF bait_raw_visible = '1' and dolphin_enable = '1' THEN
                bait_eaten <= '1';
            END IF;
        END IF;
    END PROCESS;
    
    bait_raw_visible <= '1' when (
    state = '1' and
    randomiser = '1' and
    pixel_column >= bait_x_pos - size and 
    pixel_column <= bait_x_pos + size and 
    pixel_row >= bait_y_pos - size and 
    pixel_row <= bait_y_pos + size
) else '0';

bait_visible <= bait_raw_visible and not bait_eaten;

bait_on <= bait_visible;
red   <= "1000" when bait_visible = '1' else "0000";
green <= "1000" when bait_visible = '1' else "0000";
blue  <= "0000";

END behaviour;
