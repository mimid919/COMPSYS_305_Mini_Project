LIBRARY IEEE;
USE  IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY COLLISION_COUNTER IS
    PORT
        ( pixel_row, pixel_column	: IN std_logic_vector(9 DOWNTO 0);
          dolphin_ENABLE, pipe_ENABLE			: IN std_logic;
          collision				: OUT std_logic);
END COLLISION_COUNTER;

ARCHITECTURE behavior OF COLLISION_COUNTER IS
BEGIN
    COLLISION <= '1' when (dolphin_ENABLE = '1' and pipe_ENABLE = '1') else '0';

END behavior;