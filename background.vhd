LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY BACKGROUND IS
    PORT (
        pixel_row, pixel_column : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        Win                     : IN STD_LOGIC;
        Termination             : IN STD_LOGIC;
        Pause_OUT               : IN STD_LOGIC;
        Game_state_signal       : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        clock                   : IN STD_LOGIC;
        red, green, blue        : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
    );
END BACKGROUND;

ARCHITECTURE behavior OF BACKGROUND IS

    COMPONENT background_index_rom IS
        PORT (
            address : IN STD_LOGIC_VECTOR(18 DOWNTO 0);
            clock   : IN STD_LOGIC;
            q       : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT background_palette_rom IS
        PORT (
            address : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            clock   : IN STD_LOGIC;
            q       : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
        );
    END COMPONENT;

    SIGNAL bg_address : STD_LOGIC_VECTOR(18 DOWNTO 0);
    SIGNAL colour_index : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL bg_pixel : STD_LOGIC_VECTOR(11 DOWNTO 0);

    SIGNAL red_int, green_int, blue_int : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');

BEGIN

    -- Full 640 x 480 address: address = row * 640 + column
    PROCESS(clock)
        VARIABLE row_i : INTEGER;
        VARIABLE col_i : INTEGER;
        VARIABLE addr_i : INTEGER;
    BEGIN
        IF rising_edge(clock) THEN
            row_i := CONV_INTEGER(pixel_row);
            col_i := CONV_INTEGER(pixel_column);
            addr_i := row_i * 640 + col_i;
            bg_address <= CONV_STD_LOGIC_VECTOR(addr_i, 19);
        END IF;
    END PROCESS;

    INDEX_ROM : background_index_rom
    PORT MAP (
        address => bg_address,
        clock   => clock,
        q       => colour_index
    );

    PALETTE_ROM : background_palette_rom
    PORT MAP (
        address => colour_index,
        clock   => clock,
        q       => bg_pixel
    );

    PROCESS(clock)
    BEGIN
        IF rising_edge(clock) THEN
            IF Pause_OUT = '1' THEN
                red_int   <= bg_pixel(11 DOWNTO 8);
                green_int <= bg_pixel(7 DOWNTO 4);
                blue_int  <= bg_pixel(3 DOWNTO 0);

            ELSIF Game_state_signal = "00" THEN
                red_int   <= "0101";
                green_int <= "0000";
                blue_int  <= "0110";

            ELSIF Win = '1' THEN
                red_int   <= "0001";
                green_int <= "0001";
                blue_int  <= "0001";

            ELSIF Win = '0' AND Termination = '1' THEN
                red_int   <= "0001";
                green_int <= "0001";
                blue_int  <= "0001";

            ELSIF Game_state_signal = "01" OR Game_state_signal = "10" THEN
                red_int   <= bg_pixel(11 DOWNTO 8);
                green_int <= bg_pixel(7 DOWNTO 4);
                blue_int  <= bg_pixel(3 DOWNTO 0);

            ELSE
                red_int   <= "1000";
                green_int <= "0000";
                blue_int  <= "0000";
            END IF;
        END IF;
    END PROCESS;

    red   <= red_int;
    green <= green_int;
    blue  <= blue_int;

END behavior;
