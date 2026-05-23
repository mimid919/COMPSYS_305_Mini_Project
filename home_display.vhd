LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY home_display IS
    PORT (
        clk                     : IN  std_logic;
        pixel_row, pixel_column : IN  std_logic_vector(9 DOWNTO 0);
        Game_state_signal       : IN  std_logic_vector(1 DOWNTO 0);
        red, green, blue        : OUT std_logic_vector(3 DOWNTO 0)
    );
END home_display;

ARCHITECTURE behaviour OF home_display IS

    -- Configuration: adjust these for your text
    CONSTANT TEXT_ROW_START  : integer := 240;   -- Y position of text
    CONSTANT TEXT_COL_START  : integer := 60;    -- X position of first char
    CONSTANT CHAR_SIZE       : integer := 32;    -- Pixel size of each char
    CONSTANT CHAR_SPACING    : integer := 40;    -- Distance between char origins

    -- Your message as character addresses (6-bit each)
    -- "FLAPPYD OLPHIN" example — adjust to your ROM encoding
    TYPE char_addr_array IS ARRAY (natural RANGE <>) OF std_logic_vector(5 DOWNTO 0);
    CONSTANT MESSAGE : char_addr_array := (
        "000110",  -- F
        "001100",  -- L
        "000001",  -- A
        "010000",  -- P
        "010000",  -- P
        "011001",  -- Y
        
        "000100",  -- D
        "001111",  -- O
        "001100",  -- L
        "010000",  -- P
        "001000",  -- H
        "001001",  -- I
        "001110"   -- N
    );
    CONSTANT NUM_CHARS : integer := MESSAGE'LENGTH;

    -- Internal signals
    TYPE pixel_array IS ARRAY (0 TO NUM_CHARS-1) OF std_logic;
    SIGNAL rom_pixels : pixel_array;
    SIGNAL text_on    : std_logic;

    COMPONENT char_rom IS
        PORT (
            character_address : IN  std_logic_vector(5 DOWNTO 0);
            font_row, font_col: IN  std_logic_vector(2 DOWNTO 0);
            clock             : IN  std_logic;
            rom_mux_output    : OUT std_logic
        );
    END COMPONENT;

BEGIN

    ----------------------------------------------------------------------------
    -- Generate one char_rom instance per character
    ----------------------------------------------------------------------------
    GEN_CHARS: FOR i IN 0 TO NUM_CHARS-1 GENERATE
        SIGNAL row_offset : std_logic_vector(9 DOWNTO 0);
        SIGNAL col_offset : std_logic_vector(9 DOWNTO 0);
    BEGIN
        row_offset <= pixel_row    - CONV_STD_LOGIC_VECTOR(TEXT_ROW_START, 10);
        col_offset <= pixel_column - CONV_STD_LOGIC_VECTOR(TEXT_COL_START + i * CHAR_SPACING, 10);

        CHAR_ROM_INST: char_rom
            PORT MAP (
                character_address => MESSAGE(i),
                font_row          => row_offset(4 DOWNTO 2),
                font_col          => col_offset(4 DOWNTO 2),
                clock             => clk,
                rom_mux_output    => rom_pixels(i)
            );
    END GENERATE GEN_CHARS;

    ----------------------------------------------------------------------------
    -- Combine all characters into text_on
    ----------------------------------------------------------------------------
    PROCESS(pixel_row, pixel_column, Game_state_signal, rom_pixels)
        VARIABLE col_offset_v : integer;
        VARIABLE row_offset_v : integer;
        VARIABLE hit          : std_logic;
    BEGIN
        hit := '0';

        IF Game_state_signal = "00" THEN
            row_offset_v := CONV_INTEGER(pixel_row) - TEXT_ROW_START;

            FOR i IN 0 TO NUM_CHARS-1 LOOP
                col_offset_v := CONV_INTEGER(pixel_column) - (TEXT_COL_START + i * CHAR_SPACING);

                IF col_offset_v >= 0 AND col_offset_v < CHAR_SIZE AND
                   row_offset_v >= 0 AND row_offset_v < CHAR_SIZE AND
                   rom_pixels(i) = '1' THEN
                    hit := '1';
                END IF;
            END LOOP;
        END IF;

        text_on <= hit;
    END PROCESS;

    ----------------------------------------------------------------------------
    -- Output colors
    ----------------------------------------------------------------------------
    red   <= "1000" WHEN text_on = '1' ELSE "0000";
    green <= "0000";
    blue  <= "1000" WHEN text_on = '1' ELSE "0000";

END behaviour;
