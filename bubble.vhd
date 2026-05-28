LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY BUBBLES IS
    PORT (
        clk                     : IN std_logic;
        vert_sync               : IN std_logic;
        pixel_row, pixel_column : IN std_logic_vector(9 DOWNTO 0);
        Game_state_signal       : IN std_logic_vector(1 DOWNTO 0);
        red, green, blue        : OUT std_logic_vector(3 DOWNTO 0);
        bubble_on               : OUT std_logic
    );
END BUBBLES;

ARCHITECTURE behaviour OF BUBBLES IS

    COMPONENT bubble_rom IS
        PORT (
            address : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
            clock   : IN STD_LOGIC;
            q       : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
        );
    END COMPONENT;

    CONSTANT BUBBLE_SIZE : INTEGER := 8;

    SIGNAL bubble_y1 : std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(420, 10);
    SIGNAL bubble_y2 : std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(360, 10);
    SIGNAL bubble_y3 : std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(450, 10);
    SIGNAL bubble_y4 : std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(390, 10);

    CONSTANT bubble_x1 : std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(90, 10);
    CONSTANT bubble_x2 : std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(230, 10);
    CONSTANT bubble_x3 : std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(390, 10);
    CONSTANT bubble_x4 : std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(540, 10);

    SIGNAL vert_sync_prev : std_logic := '0';
    SIGNAL frame_tick     : std_logic;

    SIGNAL bubble_address : STD_LOGIC_VECTOR(5 DOWNTO 0);
    SIGNAL bubble_pixel   : STD_LOGIC_VECTOR(11 DOWNTO 0);

BEGIN

    BUBBLE_IMAGE : bubble_rom
    PORT MAP (
        address => bubble_address,
        clock   => clk,
        q       => bubble_pixel
    );

    frame_tick <= vert_sync AND NOT vert_sync_prev;

    PROCESS(clk)
    BEGIN
        IF rising_edge(clk) THEN
            vert_sync_prev <= vert_sync;

            IF (Game_state_signal = "01" OR Game_state_signal = "10") THEN
                IF frame_tick = '1' THEN

                    IF bubble_y1 <= CONV_STD_LOGIC_VECTOR(8, 10) THEN
                        bubble_y1 <= CONV_STD_LOGIC_VECTOR(470, 10);
                    ELSE
                        bubble_y1 <= bubble_y1 - CONV_STD_LOGIC_VECTOR(1, 10);
                    END IF;

                    IF bubble_y2 <= CONV_STD_LOGIC_VECTOR(8, 10) THEN
                        bubble_y2 <= CONV_STD_LOGIC_VECTOR(470, 10);
                    ELSE
                        bubble_y2 <= bubble_y2 - CONV_STD_LOGIC_VECTOR(2, 10);
                    END IF;

                    IF bubble_y3 <= CONV_STD_LOGIC_VECTOR(8, 10) THEN
                        bubble_y3 <= CONV_STD_LOGIC_VECTOR(470, 10);
                    ELSE
                        bubble_y3 <= bubble_y3 - CONV_STD_LOGIC_VECTOR(1, 10);
                    END IF;

                    IF bubble_y4 <= CONV_STD_LOGIC_VECTOR(8, 10) THEN
                        bubble_y4 <= CONV_STD_LOGIC_VECTOR(470, 10);
                    ELSE
                        bubble_y4 <= bubble_y4 - CONV_STD_LOGIC_VECTOR(2, 10);
                    END IF;

                END IF;
            END IF;
        END IF;
    END PROCESS;

    PROCESS(pixel_row, pixel_column, bubble_y1, bubble_y2, bubble_y3, bubble_y4, bubble_pixel, Game_state_signal)
        VARIABLE row_i   : INTEGER;
        VARIABLE col_i   : INTEGER;
        VARIABLE local_x : INTEGER;
        VARIABLE local_y : INTEGER;
        VARIABLE draw    : STD_LOGIC;
    BEGIN
        row_i := CONV_INTEGER(pixel_row);
        col_i := CONV_INTEGER(pixel_column);

        red <= "0000";
        green <= "0000";
        blue <= "0000";
        bubble_on <= '0';
        bubble_address <= (OTHERS => '0');

        draw := '0';
        local_x := 0;
        local_y := 0;

        IF (Game_state_signal = "01" OR Game_state_signal = "10") THEN

            IF col_i >= CONV_INTEGER(bubble_x1) AND col_i < CONV_INTEGER(bubble_x1) + BUBBLE_SIZE AND
               row_i >= CONV_INTEGER(bubble_y1) AND row_i < CONV_INTEGER(bubble_y1) + BUBBLE_SIZE THEN
                local_x := col_i - CONV_INTEGER(bubble_x1);
                local_y := row_i - CONV_INTEGER(bubble_y1);
                draw := '1';

            ELSIF col_i >= CONV_INTEGER(bubble_x2) AND col_i < CONV_INTEGER(bubble_x2) + BUBBLE_SIZE AND
                  row_i >= CONV_INTEGER(bubble_y2) AND row_i < CONV_INTEGER(bubble_y2) + BUBBLE_SIZE THEN
                local_x := col_i - CONV_INTEGER(bubble_x2);
                local_y := row_i - CONV_INTEGER(bubble_y2);
                draw := '1';

            ELSIF col_i >= CONV_INTEGER(bubble_x3) AND col_i < CONV_INTEGER(bubble_x3) + BUBBLE_SIZE AND
                  row_i >= CONV_INTEGER(bubble_y3) AND row_i < CONV_INTEGER(bubble_y3) + BUBBLE_SIZE THEN
                local_x := col_i - CONV_INTEGER(bubble_x3);
                local_y := row_i - CONV_INTEGER(bubble_y3);
                draw := '1';

            ELSIF col_i >= CONV_INTEGER(bubble_x4) AND col_i < CONV_INTEGER(bubble_x4) + BUBBLE_SIZE AND
                  row_i >= CONV_INTEGER(bubble_y4) AND row_i < CONV_INTEGER(bubble_y4) + BUBBLE_SIZE THEN
                local_x := col_i - CONV_INTEGER(bubble_x4);
                local_y := row_i - CONV_INTEGER(bubble_y4);
                draw := '1';
            END IF;

        END IF;

        IF draw = '1' THEN
            bubble_address <= CONV_STD_LOGIC_VECTOR(local_y * BUBBLE_SIZE + local_x, 6);

         IF bubble_pixel /= X"F0F" THEN
    bubble_on <= '1';
    red   <= bubble_pixel(11 DOWNTO 8);
    green <= bubble_pixel(7 DOWNTO 4);
    blue  <= bubble_pixel(3 DOWNTO 0);
END IF;
        END IF;
    END PROCESS;

END behaviour;