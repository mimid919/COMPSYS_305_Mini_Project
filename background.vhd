LIBRARY IEEE;
USE  IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;

-- sets solid background colour depending on current state (conditional statment)

-- it takes in all of the fsm outputs 
ENTITY BACKGROUND IS
    PORT
        (pixel_row, pixel_column	: IN std_logic_vector(9 DOWNTO 0);
            Win                     : IN STD_LOGIC;  -- logic high
            Termination             : IN STD_LOGIC;  -- logic high
            Pause_OUT               : IN STD_LOGIC;  -- logic high
            Game_state_signal       : IN std_logic_vector(1 DOWNTO 0);
          	red, green, blue 	    : OUT std_logic_vector(3 DOWNTO 0)
          );
END BACKGROUND;

ARCHITECTURE behavior OF BACKGROUND IS
BEGIN
    PROCESS (pixel_row, pixel_column, Game_state_signal, Win, Termination , Pause_OUT)
    BEGIN
        IF Game_state_signal = "00" THEN -- start screen, black (MAGENTA TXT)
            RED <= "0000";
            GREEN <= "0000";
            BLUE <= "0000";
        ELSIF Game_state_signal = "01" THEN -- game screen, black (GREEN PIPES, BLUE BALL, YELLOW BAIT)
            RED <= "0000";
            GREEN <= "0000";
            BLUE <= "0000";
        ELSIF Game_state_signal = "10" THEN -- end screen, red
            RED <= "1000";
            GREEN <= "0000";
            BLUE <= "0000";
            -- GAME_WON
        ELSIF Win = '1' and Termination ='1' and Pause_OUT = '0' and Game_state_signal = "11" THEN 
            RED <= "0000";
            GREEN <= "0000";
            BLUE <= "1000";
        ELSE -- default to avoid latch
            RED <= "0000";
            GREEN <= "1000";
            BLUE <= "0000";
        END IF;
    END PROCESS;

END behavior;
