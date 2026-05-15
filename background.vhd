LIBRARY IEEE;
USE  IEEE.STD_LOGIC_1164.all;
USE IEEE.NUMERIC_STD.all;

ENTITY BACKGROUND IS
    PORT
        ( pixel_row, pixel_column	: IN std_logic_vector(9 DOWNTO 0);
		  red, green, blue 			: OUT std_logic_vector(3 DOWNTO 0);
          fsm_state                 : IN std_logic_vector(1 DOWNTO 0)
          );
END BACKGROUND;

ARCHITECTURE behavior OF BACKGROUND IS

    component game_background_rom is
    port (
        x : in  unsigned(9 downto 0);  -- 0..639
        y : in  unsigned(8 downto 0);  -- 0..479
        r : out std_logic_vector(3 downto 0);
        g : out std_logic_vector(3 downto 0);
        b : out std_logic_vector(3 downto 0)
    );
    end component;

    signal rom_r, rom_g, rom_b : std_logic_vector(3 downto 0);

BEGIN

    FINAL_STATE_ROM : game_background_rom
    port map (
        x => unsigned(pixel_column),
        y => unsigned(pixel_row(8 downto 0)),
        r => rom_r,
        g => rom_g,
        b => rom_b
    );

    PROCESS (pixel_row, pixel_column, fsm_state, rom_r, rom_g, rom_b)
    BEGIN
        IF fsm_state = "00" THEN -- start screen, white (MAGENTA TXT)
            RED <= "1111";
            GREEN <= "1111";
            BLUE <= "1111";
        ELSIF fsm_state = "01" THEN -- game screen, black (GREEN PIPES, BLUE BALL)
            RED <= "0000";
            GREEN <= "0000";
            BLUE <= "0000";
        ELSIF fsm_state = "10" THEN -- end screen, red
            RED <= rom_r;
            GREEN <= rom_g;
            BLUE <= rom_b;
        ELSE -- default to avoid latch
            RED <= "0000";
            GREEN <= "1111";
            BLUE <= "0000";
        END IF;
    END PROCESS;

END behavior;
