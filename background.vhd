LIBRARY IEEE;
USE  IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY BACKGROUND IS
    PORT
        ( pixel_row, pixel_column	: IN std_logic_vector(9 DOWNTO 0);
		  red, green, blue 			: OUT std_logic;
          fsm_state                 : IN std_logic_vector(1 DOWNTO 0)
          );
END BACKGROUND;

ARCHITECTURE behavior OF BACKGROUND IS
BEGIN
    PROCESS (pixel_row, pixel_column, fsm_state)
    BEGIN
        IF fsm_state = "00" THEN -- start screen, white (MAGENTA TXT)
            RED <= '1';
            GREEN <= '1';
            BLUE <= '1';
        ELSIF fsm_state = "01" THEN -- game screen, black (GREEN PIPES, BLUE BALL)
            RED <= '0';
            GREEN <= '0';
            BLUE <= '0';
        ELSIF fsm_state = "10" THEN -- end screen, red
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
