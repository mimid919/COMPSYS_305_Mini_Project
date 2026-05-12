LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY position_to_BCD IS
	PORT
	(
        mouse_row          : IN std_logic_vector(9 DOWNTO 0);
        mouse_column       : IN std_logic_vector(9 DOWNTO 0);
        row_hundreds      : OUT std_logic_vector(3 DOWNTO 0);
        row_tens          : OUT std_logic_vector(3 DOWNTO 0);
        row_ones          : OUT std_logic_vector(3 DOWNTO 0);
        column_hundreds   : OUT std_logic_vector(3 DOWNTO 0);
        column_tens       : OUT std_logic_vector(3 DOWNTO 0);
        column_ones       : OUT std_logic_vector(3 DOWNTO 0)
    );
END position_to_BCD;

ARCHITECTURE behavior OF position_to_BCD IS
BEGIN

    PROCESS (mouse_row, mouse_column)
    VARIABLE row_value : INTEGER;
    VARIABLE column_value : INTEGER;
    BEGIN
        row_value := CONV_INTEGER(mouse_row);
        column_value := CONV_INTEGER(mouse_column);

        -- Convert row value to BCD
        row_hundreds <= CONV_STD_LOGIC_VECTOR(row_value / 100, 4);
        row_tens <= CONV_STD_LOGIC_VECTOR((row_value / 10) MOD 10, 4);
        row_ones <= CONV_STD_LOGIC_VECTOR(row_value MOD 10, 4);

        -- Convert column value to BCD
        column_hundreds <= CONV_STD_LOGIC_VECTOR(column_value / 100, 4);
        column_tens <= CONV_STD_LOGIC_VECTOR((column_value / 10) MOD 10, 4);
        column_ones <= CONV_STD_LOGIC_VECTOR(column_value MOD 10, 4);
    END PROCESS;

END behavior;