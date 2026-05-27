--  use this as a reference for automated text
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY HOME_DISPLAY_TEXT IS
    PORT (
        clk                     : IN  std_logic;
        pixel_row, pixel_column : IN  std_logic_vector(9 DOWNTO 0);
        Game_state_signal       : IN  std_logic_vector(1 DOWNTO 0);
        red, green, blue        : OUT std_logic_vector(3 DOWNTO 0)
    );
END HOME_DISPLAY_TEXT;

ARCHITECTURE behaviour OF HOME_DISPLAY_TEXT IS

    ----------------------------------------------------------------------------
    -- LARGE TITLE SETTINGS
    ----------------------------------------------------------------------------
    CONSTANT TEXT_ROW_START  : integer := 240;
    CONSTANT CHAR_SIZE       : integer := 32;
    CONSTANT CHAR_SPACING    : integer := 40;

    TYPE char_addr_array IS ARRAY (natural RANGE <>) OF std_logic_vector(5 DOWNTO 0);

    CONSTANT MESSAGE : char_addr_array := (
        "000110",  -- F
        "001100",  -- L
        "000001",  -- A
        "010000",  -- P
        "010000",  -- P
        "011001",  -- Y
        "100111",  -- space
        "000100",  -- D
        "001111",  -- O
        "001100",  -- L
        "010000",  -- P
        "001000",  -- H
        "001001",  -- I
        "001110"   -- N
    );

    CONSTANT NUM_CHARS : integer := MESSAGE'LENGTH;

    CONSTANT TEXT_COL_START : integer :=
        (640 - (NUM_CHARS - 1) * CHAR_SPACING) / 2;

    ----------------------------------------------------------------------------
    -- SMALL TEXT SETTINGS
    ----------------------------------------------------------------------------
    CONSTANT SMALL_TEXT_ROW_START : integer := 310;
    CONSTANT SMALL_CHAR_SIZE      : integer := 8;
    CONSTANT SMALL_CHAR_SPACING   : integer := 10;

    TYPE small_char_array IS ARRAY (natural RANGE <>) OF std_logic_vector(5 DOWNTO 0);

    CONSTANT SMALL_MESSAGE : small_char_array := (
        "010000", -- P
        "001100", -- L
        "000001", -- A
        "011001", -- Y
        "100111", -- space
        "010100", -- T
        "001111", -- O
        "100111", -- space
        "010011", -- S
        "010100", -- T
        "000001", -- A
        "010010", -- R
        "010100"  -- T
    );

    CONSTANT SMALL_NUM_CHARS : integer := SMALL_MESSAGE'LENGTH;

    CONSTANT SMALL_TEXT_COL_START : integer :=
        (640 - (SMALL_NUM_CHARS - 1) * SMALL_CHAR_SPACING) / 2;

    ----------------------------------------------------------------------------
    -- SIGNALS
    ----------------------------------------------------------------------------
    TYPE pixel_array IS ARRAY (0 TO NUM_CHARS-1) OF std_logic;
    SIGNAL rom_pixels : pixel_array;

    TYPE small_pixel_array IS ARRAY (0 TO SMALL_NUM_CHARS-1) OF std_logic;
    SIGNAL small_rom_pixels : small_pixel_array;

    SIGNAL text_on : std_logic;

    ----------------------------------------------------------------------------
    -- CHARACTER ROM
    ----------------------------------------------------------------------------
    COMPONENT char_rom IS
        PORT (
            character_address : IN  std_logic_vector(5 DOWNTO 0);
            font_row          : IN  std_logic_vector(2 DOWNTO 0);
            font_col          : IN  std_logic_vector(2 DOWNTO 0);
            clock             : IN  std_logic;
            rom_mux_output    : OUT std_logic
        );
    END COMPONENT;

BEGIN

    ----------------------------------------------------------------------------
    -- LARGE TITLE GENERATION
    ----------------------------------------------------------------------------
    GEN_CHARS: FOR i IN 0 TO NUM_CHARS-1 GENERATE

        SIGNAL row_offset : std_logic_vector(9 DOWNTO 0);
        SIGNAL col_offset : std_logic_vector(9 DOWNTO 0);

    BEGIN

        row_offset <= pixel_row -
            CONV_STD_LOGIC_VECTOR(TEXT_ROW_START, 10);

        col_offset <= pixel_column -
            CONV_STD_LOGIC_VECTOR(
                TEXT_COL_START + i * CHAR_SPACING, 10);

        CHAR_ROM_INST: char_rom
            PORT MAP (
                character_address => MESSAGE(i),

                -- 32x32 scaling
                font_row => row_offset(4 DOWNTO 2),
                font_col => col_offset(4 DOWNTO 2),

                clock => clk,
                rom_mux_output => rom_pixels(i)
            );

    END GENERATE GEN_CHARS;

    ----------------------------------------------------------------------------
    -- SMALL TEXT GENERATION
    ----------------------------------------------------------------------------
    GEN_SMALL_CHARS: FOR i IN 0 TO SMALL_NUM_CHARS-1 GENERATE

        SIGNAL row_offset_small : std_logic_vector(9 DOWNTO 0);
        SIGNAL col_offset_small : std_logic_vector(9 DOWNTO 0);

    BEGIN

        row_offset_small <= pixel_row -
            CONV_STD_LOGIC_VECTOR(SMALL_TEXT_ROW_START, 10);

        col_offset_small <= pixel_column -
            CONV_STD_LOGIC_VECTOR(
                SMALL_TEXT_COL_START + i * SMALL_CHAR_SPACING, 10);

        SMALL_CHAR_ROM: char_rom
            PORT MAP (
                character_address => SMALL_MESSAGE(i),

                -- 8x8 text (no scaling)
                font_row => row_offset_small(2 DOWNTO 0),
                font_col => col_offset_small(2 DOWNTO 0),

                clock => clk,
                rom_mux_output => small_rom_pixels(i)
            );

    END GENERATE GEN_SMALL_CHARS;

    ----------------------------------------------------------------------------
    -- TEXT DISPLAY LOGIC
    ----------------------------------------------------------------------------
    PROCESS(pixel_row, pixel_column, Game_state_signal,
            rom_pixels, small_rom_pixels)

        VARIABLE col_offset_v       : integer;
        VARIABLE row_offset_v       : integer;

        VARIABLE small_col_offset_v : integer;
        VARIABLE small_row_offset_v : integer;

        VARIABLE hit                : std_logic;
        VARIABLE small_hit          : std_logic;

    BEGIN

        hit       := '0';
        small_hit := '0';

        IF Game_state_signal = "00" THEN

            ----------------------------------------------------------------------------
            -- LARGE TITLE CHECK
            ----------------------------------------------------------------------------
            row_offset_v :=
                CONV_INTEGER(pixel_row) - TEXT_ROW_START;

            FOR i IN 0 TO NUM_CHARS-1 LOOP

                col_offset_v :=
                    CONV_INTEGER(pixel_column) -
                    (TEXT_COL_START + i * CHAR_SPACING);

                IF col_offset_v >= 0 AND
                   col_offset_v < CHAR_SIZE AND
                   row_offset_v >= 0 AND
                   row_offset_v < CHAR_SIZE AND
                   rom_pixels(i) = '1' THEN

                    hit := '1';

                END IF;

            END LOOP;

            ----------------------------------------------------------------------------
            -- SMALL TEXT CHECK
            ----------------------------------------------------------------------------
            small_row_offset_v :=
                CONV_INTEGER(pixel_row) - SMALL_TEXT_ROW_START;

            FOR i IN 0 TO SMALL_NUM_CHARS-1 LOOP

                small_col_offset_v :=
                    CONV_INTEGER(pixel_column) -
                    (SMALL_TEXT_COL_START + i * SMALL_CHAR_SPACING);

                IF small_col_offset_v >= 0 AND
                   small_col_offset_v < SMALL_CHAR_SIZE AND
                   small_row_offset_v >= 0 AND
                   small_row_offset_v < SMALL_CHAR_SIZE AND
                   small_rom_pixels(i) = '1' THEN

                    small_hit := '1';

                END IF;

            END LOOP;

        END IF;

        text_on <= hit OR small_hit;

    END PROCESS;

    ----------------------------------------------------------------------------
    -- OUTPUT COLOURS
    ----------------------------------------------------------------------------
    red   <= "1111" WHEN text_on = '1' ELSE "0000";
    green <= "0000";
    blue  <= "1000" WHEN text_on = '1' ELSE "0000";

END behaviour;