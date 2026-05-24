LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY dolphin_visual IS
    PORT (
        clk                     : IN std_logic;
        pixel_row, pixel_column : IN std_logic_vector(9 DOWNTO 0);
        dolphin_x_pos           : IN std_logic_vector(9 DOWNTO 0);
        dolphin_y_pos           : IN std_logic_vector(9 DOWNTO 0);
		Game_state_signal       : IN std_logic_vector(1 DOWNTO 0);
        red, green, blue        : OUT std_logic_vector(3 DOWNTO 0);
        dolphin_on              : OUT std_logic
    );
END dolphin_visual;

ARCHITECTURE behaviour OF dolphin_visual IS

    COMPONENT dolphin_rom IS
        PORT (address : IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		clock   : IN STD_LOGIC;
		q       : OUT STD_LOGIC_VECTOR (11 DOWNTO 0));
    End Component dolphin_rom;

    SIGNAL sprite_x   : std_logic_vector(4 DOWNTO 0);
    SIGNAL sprite_y   : std_logic_vector(4 DOWNTO 0);
    SIGNAL rom_addr   : std_logic_vector(9 DOWNTO 0);
    SIGNAL sprite_rgb : std_logic_vector(11 DOWNTO 0);
    SIGNAL inside     : std_logic;

BEGIN

    inside <= '1' when (
        pixel_column >= dolphin_x_pos and
        pixel_column <  dolphin_x_pos + 32 and
        pixel_row    >= dolphin_y_pos and
        pixel_row    <  dolphin_y_pos + 32 and
        Game_state_signal = "01"
    ) else '0';

    sprite_x <= pixel_column(4 DOWNTO 0) - dolphin_x_pos(4 DOWNTO 0);
    sprite_y <= pixel_row(4 DOWNTO 0) - dolphin_y_pos(4 DOWNTO 0);

    rom_addr <= sprite_y & sprite_x;

    DOLPHIN: dolphin_rom PORT MAP (
        address => rom_addr,
        clock   => clk,
        q       => sprite_rgb
    );

    dolphin_on <= '1' when (inside = '1' and sprite_rgb /= "001011110000") else '0';

    red   <= sprite_rgb(11 DOWNTO 8) when (inside = '1' and sprite_rgb /= "001011110000") else "0000";
    green <= sprite_rgb(7 DOWNTO 4) when (inside = '1' and sprite_rgb /= "001011110000") else "0000";
    blue  <= sprite_rgb(3 DOWNTO 0) when (inside = '1' and sprite_rgb /= "001011110000") else "0000";

END behaviour;