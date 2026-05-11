LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY click_counter IS
	PORT
	(
        clk         : IN std_logic;
        reset       : IN std_logic;
        left_click  : IN std_logic;
        count       : OUT std_logic_vector(3 DOWNTO 0)
	);
END click_counter;

ARCHITECTURE behavior OF click_counter IS

    SIGNAL count_int : std_logic_vector(3 DOWNTO 0) <= "0000";

BEGIN
    PROCESS (clk, reset)
    BEGIN
        IF reset = '1' THEN
            count_int <= "0000";
        ELSIF rising_edge(clk) THEN
            IF left_click = '1' THEN
                count_int <= count_int + 1;
            END IF;
        END IF;
    END PROCESS;

    count <= count_int;

END behavior;