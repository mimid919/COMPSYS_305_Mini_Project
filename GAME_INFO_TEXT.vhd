LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY GAME_INFO_TEXT IS
    PORT (
        clk                     : IN std_logic;
        pixel_row, pixel_column : IN std_logic_vector(9 DOWNTO 0);
        Game_state_signal       : IN std_logic_vector(1 DOWNTO 0);
        Level_sig               : IN std_logic;
        Score_count             : IN std_logic_vector(3 DOWNTO 0);

        red, green, blue        : OUT std_logic_vector(3 DOWNTO 0);
        info_on                 : BUFFER std_logic
    );
END GAME_INFO_TEXT;

ARCHITECTURE behaviour OF GAME_INFO_TEXT IS

    COMPONENT char_rom IS
        PORT (
            character_address : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
            font_row, font_col : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
            clock : IN STD_LOGIC;
            rom_mux_output : OUT STD_LOGIC
        );
    END COMPONENT;

    TYPE char_addr_array IS ARRAY (natural RANGE <>) OF std_logic_vector(5 DOWNTO 0);

    CONSTANT SCORE_TEXT : char_addr_array := (
        "010011", -- S
        "000011", -- C
        "001111", -- O
        "010010", -- R
        "000101"  -- E
    );

    CONSTANT LEVEL_TEXT : char_addr_array := (
        "001100", -- L
        "000101", -- E
        "010110", -- V
        "000101", -- E
        "001100"  -- L
    );

    CONSTANT SCORE_ROW : INTEGER := 20;
    CONSTANT LEVEL_ROW : INTEGER := 38;
    CONSTANT START_COL : INTEGER := 420;
    CONSTANT DIGIT_0_COL : INTEGER := 520;
    CONSTANT DIGIT_1_COL : INTEGER := 538;
    CONSTANT CHAR_SIZE : INTEGER := 16;
    CONSTANT CHAR_SPACE : INTEGER := 18;

    SIGNAL score_pixel : STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL level_pixel : STD_LOGIC_VECTOR(4 DOWNTO 0);

    SIGNAL score_digit_pixel : STD_LOGIC;
    SIGNAL level_zero_pixel  : STD_LOGIC;
    SIGNAL level_digit_pixel : STD_LOGIC;

    SIGNAL score_digit_addr : STD_LOGIC_VECTOR(5 DOWNTO 0);
    SIGNAL level_digit_addr : STD_LOGIC_VECTOR(5 DOWNTO 0);

    SIGNAL score_row_off : STD_LOGIC_VECTOR(9 DOWNTO 0);
    SIGNAL level_row_off : STD_LOGIC_VECTOR(9 DOWNTO 0);

    SIGNAL score_digit_col_off : STD_LOGIC_VECTOR(9 DOWNTO 0);
    SIGNAL level_zero_col_off  : STD_LOGIC_VECTOR(9 DOWNTO 0);
    SIGNAL level_digit_col_off : STD_LOGIC_VECTOR(9 DOWNTO 0);

BEGIN

    score_digit_addr <= CONV_STD_LOGIC_VECTOR(48 + CONV_INTEGER(Score_count), 6);
    level_digit_addr <= "110001" WHEN Level_sig = '0' ELSE "110010";

    score_row_off <= pixel_row - CONV_STD_LOGIC_VECTOR(SCORE_ROW,10) WHEN pixel_row >= SCORE_ROW ELSE (OTHERS => '1');
    level_row_off <= pixel_row - CONV_STD_LOGIC_VECTOR(LEVEL_ROW,10) WHEN pixel_row >= LEVEL_ROW ELSE (OTHERS => '1');

    score_digit_col_off <= pixel_column - CONV_STD_LOGIC_VECTOR(DIGIT_0_COL,10) WHEN pixel_column >= DIGIT_0_COL ELSE (OTHERS => '1');
    level_zero_col_off  <= pixel_column - CONV_STD_LOGIC_VECTOR(DIGIT_0_COL,10) WHEN pixel_column >= DIGIT_0_COL ELSE (OTHERS => '1');
    level_digit_col_off <= pixel_column - CONV_STD_LOGIC_VECTOR(DIGIT_1_COL,10) WHEN pixel_column >= DIGIT_1_COL ELSE (OTHERS => '1');

    SCORE_GEN : FOR i IN 0 TO 4 GENERATE
        SIGNAL col_off : STD_LOGIC_VECTOR(9 DOWNTO 0);
    BEGIN
        col_off <= pixel_column - CONV_STD_LOGIC_VECTOR(START_COL + i*CHAR_SPACE,10)
                   WHEN pixel_column >= START_COL + i*CHAR_SPACE ELSE (OTHERS => '1');

        SCORE_ROM : char_rom PORT MAP (
            character_address => SCORE_TEXT(i),
            font_row => score_row_off(3 DOWNTO 1),
            font_col => col_off(3 DOWNTO 1),
            clock => clk,
            rom_mux_output => score_pixel(i)
        );
    END GENERATE;

    LEVEL_GEN : FOR i IN 0 TO 4 GENERATE
        SIGNAL col_off : STD_LOGIC_VECTOR(9 DOWNTO 0);
    BEGIN
        col_off <= pixel_column - CONV_STD_LOGIC_VECTOR(START_COL + i*CHAR_SPACE,10)
                   WHEN pixel_column >= START_COL + i*CHAR_SPACE ELSE (OTHERS => '1');

        LEVEL_ROM : char_rom PORT MAP (
            character_address => LEVEL_TEXT(i),
            font_row => level_row_off(3 DOWNTO 1),
            font_col => col_off(3 DOWNTO 1),
            clock => clk,
            rom_mux_output => level_pixel(i)
        );
    END GENERATE;

    SCORE_DIGIT_ROM : char_rom PORT MAP (
        character_address => score_digit_addr,
        font_row => score_row_off(3 DOWNTO 1),
        font_col => score_digit_col_off(3 DOWNTO 1),
        clock => clk,
        rom_mux_output => score_digit_pixel
    );

    LEVEL_ZERO_ROM : char_rom PORT MAP (
        character_address => "110000",
        font_row => level_row_off(3 DOWNTO 1),
        font_col => level_zero_col_off(3 DOWNTO 1),
        clock => clk,
        rom_mux_output => level_zero_pixel
    );

    LEVEL_DIGIT_ROM : char_rom PORT MAP (
        character_address => level_digit_addr,
        font_row => level_row_off(3 DOWNTO 1),
        font_col => level_digit_col_off(3 DOWNTO 1),
        clock => clk,
        rom_mux_output => level_digit_pixel
    );

    PROCESS(pixel_row, pixel_column, Game_state_signal,
            score_pixel, level_pixel,
            score_digit_pixel, level_zero_pixel, level_digit_pixel)
        VARIABLE row_v : INTEGER;
        VARIABLE col_v : INTEGER;
        VARIABLE hit : STD_LOGIC;
    BEGIN
        hit := '0';
        row_v := CONV_INTEGER(pixel_row);
        col_v := CONV_INTEGER(pixel_column);

        IF Game_state_signal = "10" THEN

            IF row_v >= SCORE_ROW AND row_v < SCORE_ROW + CHAR_SIZE THEN
                FOR i IN 0 TO 4 LOOP
                    IF col_v >= START_COL + i*CHAR_SPACE AND
                       col_v < START_COL + i*CHAR_SPACE + CHAR_SIZE AND
                       score_pixel(i) = '1' THEN
                        hit := '1';
                    END IF;
                END LOOP;

                IF col_v >= DIGIT_0_COL AND col_v < DIGIT_0_COL + CHAR_SIZE AND score_digit_pixel = '1' THEN
                    hit := '1';
                END IF;
            END IF;

            IF row_v >= LEVEL_ROW AND row_v < LEVEL_ROW + CHAR_SIZE THEN
                FOR i IN 0 TO 4 LOOP
                    IF col_v >= START_COL + i*CHAR_SPACE AND
                       col_v < START_COL + i*CHAR_SPACE + CHAR_SIZE AND
                       level_pixel(i) = '1' THEN
                        hit := '1';
                    END IF;
                END LOOP;

                IF col_v >= DIGIT_0_COL AND col_v < DIGIT_0_COL + CHAR_SIZE AND level_zero_pixel = '1' THEN
                    hit := '1';
                END IF;

                IF col_v >= DIGIT_1_COL AND col_v < DIGIT_1_COL + CHAR_SIZE AND level_digit_pixel = '1' THEN
                    hit := '1';
                END IF;
            END IF;

        END IF;

        info_on <= hit;
    END PROCESS;

    red   <= "1111" WHEN info_on = '1' ELSE "0000";
    green <= "1111" WHEN info_on = '1' ELSE "0000";
    blue  <= "1111" WHEN info_on = '1' ELSE "0000";

END behaviour;