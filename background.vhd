LIBRARY IEEE;
USE  IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;

-- sets solid background colour depending on current state (conditional statment)


ENTITY BACKGROUND IS
    PORT
        ( pixel_row, pixel_column	: IN std_logic_vector(9 DOWNTO 0);
		  red, green, blue 			: OUT std_logic;
          Game_state_signal                 : IN std_logic_vector(1 DOWNTO 0)
          );
END BACKGROUND;

ARCHITECTURE behavior OF BACKGROUND IS
BEGIN
    PROCESS (pixel_row, pixel_column, Game_state_signal)
    BEGIN
        IF Game_state_signal = "00" THEN -- start screen, black (MAGENTA TXT)
            RED <= '0';
            GREEN <= '0';
            BLUE <= '0';
        ELSIF Game_state_signal = "01" THEN -- game screen, black (GREEN PIPES, BLUE BALL, YELLOW BAIT)
            RED <= '0';
            GREEN <= '0';
            BLUE <= '0';
        ELSIF Game_state_signal = "10" THEN -- end screen, red
            RED <= '1';
            GREEN <= '0';
            BLUE <= '0';
        ELSE -- default to avoid latch
            RED <= '0';
            GREEN <= '1';
            BLUE <= '0';
        END IF;
    END PROCESS;

END behavior;
