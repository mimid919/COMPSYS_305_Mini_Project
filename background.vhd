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
    PORT(
        address : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
        clock   : IN STD_LOGIC;
        q       : OUT STD_LOGIC_VECTOR (11 DOWNTO 0)
    );
    END COMPONENT;

    constant SOURCE_WIDTH : integer := 260;
    constant SOURCE_HEIGHT : integer := 130;
    constant TARGET_WIDTH : integer := 640;
    constant TARGET_HEIGHT : integer := 480;

    SIGNAL rom_address : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL sunset_pixel : STD_LOGIC_VECTOR (11 DOWNTO 0);
BEGIN
    PROCESS (pixel_row, pixel_column, Game_state_signal, Win, Termination , Pause_OUT)
    VARIABLE row_i : integer;
    VARIABLE col_i : integer;
    VARIABLE img_addr : integer;
    BEGIN
        IF Game_state_signal = "00" THEN -- start screen, black (MAGENTA TXT)
            RED <= "0000";
            GREEN <= "0000";
            BLUE <= "0000";
        ELSIF Game_state_signal = "01" THEN -- game screen, scaled sunset background image
            row_i := (CONV_INTEGER(pixel_row) * SOURCE_HEIGHT) / TARGET_HEIGHT;
            col_i := (CONV_INTEGER(pixel_column) * SOURCE_WIDTH) / TARGET_WIDTH;
            img_addr := row_i * SOURCE_WIDTH + col_i;
            rom_address <= CONV_STD_LOGIC_VECTOR(img_addr, 16);
            RED <= sunset_pixel(11 DOWNTO 8);
            GREEN <= sunset_pixel(7 DOWNTO 4);
            BLUE <= sunset_pixel(3 DOWNTO 0);
        ELSIF Game_state_signal = "10" THEN -- end screen, red
            RED <= "1000";
            GREEN <= "0000";
            BLUE <= "0000";
            -- GAME_WON
            --  black backgrounf, green text
        ELSIF Win = '1'  THEN 
            RED <= "0000";
            GREEN <= "0000";
            BLUE <= "0000";
            -- GAME_OVER
            --  black background, red text
        ELSIF Win = '0' and Termination ='1' and Pause_OUT = '0' and Game_state_signal = "11" THEN 
            RED <= "0000";
            GREEN <= "0000";
            BLUE <= "0000";
        ELSE -- default to avoid latch
            RED <= "0000";
            GREEN <= "1000";
            BLUE <= "0000";
        END IF;
    END PROCESS;

    SUNSET_BACKGROUND : sunset_rom PORT MAP (
        address => rom_address,
        clock => clock,
        q => sunset_pixel
    );

END behavior;
