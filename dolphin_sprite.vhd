LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY dolphin_sprite IS
    PORT (
        clk                     : IN std_logic;
        pixel_row, pixel_column : IN std_logic_vector(9 DOWNTO 0);
        dolphin_x_pos           : IN std_logic_vector(9 DOWNTO 0);
        dolphin_y_pos           : IN std_logic_vector(9 DOWNTO 0);

        red, green, blue        : OUT std_logic_vector(3 DOWNTO 0);
        dolphin_on              : OUT std_logic
    );
END dolphin_sprite;

ARCHITECTURE behaviour OF dolphin_sprite IS

    COMPONENT sprite_rom IS
        PORT (
            address : IN std_logic_vector(7 DOWNTO 0);
            clock   : IN std_logic;
            q       : OUT std_logic_vector(2 DOWNTO 0)
        );
    END COMPONENT;

    SIGNAL sprite_x   : std_logic_vector(3 DOWNTO 0);
    SIGNAL sprite_y   : std_logic_vector(3 DOWNTO 0);
    SIGNAL rom_addr   : std_logic_vector(7 DOWNTO 0);
    SIGNAL sprite_rgb : std_logic_vector(2 DOWNTO 0);
    SIGNAL inside     : std_logic;

BEGIN

    inside <= '1' when (
        pixel_column >= dolphin_x_pos and
        pixel_column <  dolphin_x_pos + 16 and
        pixel_row    >= dolphin_y_pos and
        pixel_row    <  dolphin_y_pos + 16
    ) else '0';

    sprite_x <= pixel_column(3 DOWNTO 0) - dolphin_x_pos(3 DOWNTO 0);
    sprite_y <= pixel_row(3 DOWNTO 0) - dolphin_y_pos(3 DOWNTO 0);

    rom_addr <= sprite_y & sprite_x;

    DOLPHIN_ROM: sprite_rom PORT MAP (
        address => rom_addr,
        clock   => clk,
        q       => sprite_rgb
    );

    dolphin_on <= '1' when (inside = '1') else '0';

    red   <= (sprite_rgb(2) & "000") when (inside = '1') else "0000";
    green <= (sprite_rgb(1) & "000") when (inside = '1') else "0000";
    blue  <= (sprite_rgb(0) & "000") when (inside = '1') else "0000";

END behaviour;