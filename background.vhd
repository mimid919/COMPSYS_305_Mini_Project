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
            clock                   : IN STD_LOGIC;
          	red, green, blue 	    : OUT std_logic_vector(3 DOWNTO 0)
          );
END BACKGROUND;

ARCHITECTURE behavior OF BACKGROUND IS
    COMPONENT sunset_rom IS
    PORT(    --- these might need changing
        address : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
        clock   : IN STD_LOGIC;
        q       : OUT STD_LOGIC_VECTOR (11 DOWNTO 0)
    );
    END COMPONENT;

    constant SOURCE_WIDTH : integer := 260;    -- these need chanign
    constant SOURCE_HEIGHT : integer := 130;
    constant TARGET_WIDTH : integer := 640;
    constant TARGET_HEIGHT : integer := 480;


    SIGNAL rom_address : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL sunset_pixel : STD_LOGIC_VECTOR (11 DOWNTO 0);
    SIGNAL red_int, green_int, blue_int : std_logic_vector(3 DOWNTO 0) := (OTHERS => '0');

    SIGNAL row_i    : integer := 0;
    SIGNAL col_i    : integer := 0;
    SIGNAL img_addr : integer := 0;
BEGIN
    PROCESS (clock)
    begin
        IF rising_edge(clock) THEN
            row_i <=  (CONV_INTEGER(pixel_row) * 17) / 64;
            col_i <=  (CONV_INTEGER(pixel_column) * 13) / 32;

            img_addr <=  row_i * SOURCE_WIDTH + col_i;
            rom_address <= CONV_STD_LOGIC_VECTOR(img_addr, 16);
        END IF;
    End process;


    PROCESS (clock)
    
    BEGIN
        IF (rising_edge(clock)) THEN
            IF Pause_OUT = '1' THEN
                    red_int <= sunset_pixel(11 DOWNTO 8);
                    green_int <= sunset_pixel(7 DOWNTO 4);
                    blue_int <= sunset_pixel(3 DOWNTO 0);
                ELSIF Game_state_signal = "00"  THEN
                    red_int <= "0101";
                    green_int <= "0000";
                    blue_int <= "0110";
                ELSIF Win = '1'  THEN
                    red_int <= "0001";
                    green_int <= "0001";
                    blue_int <= "0001";
                ELSIF Win = '0' and Termination ='1' THEN
                    red_int <= "0001";
                    green_int <= "0001";
                    blue_int <= "0001";
                ELSIF Game_state_signal = "01" OR Game_state_signal = "10" THEN
                    red_int <= sunset_pixel(11 DOWNTO 8);
                    green_int <= sunset_pixel(7 DOWNTO 4);
                    blue_int <= sunset_pixel(3 DOWNTO 0);
                ELSE
                    red_int <= "1000";
                    green_int <= "0000";
                    blue_int <= "0000";
                END IF;
            END IF;
    END PROCESS;

    red <= red_int;
    green <= green_int;
    blue <= blue_int;

    SUNSET_BACKGROUND : sunset_rom PORT MAP (
        address => rom_address,
        clock => clock,
        q => sunset_pixel
    );

END behavior;