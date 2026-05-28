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
    CONSTANT mode_TEXT_ROW_START : integer := 310;
    CONSTANT mode_CHAR_SIZE      : integer := 8;
    CONSTANT mode_CHAR_SPACING   : integer := 10;
    
    CONSTANT start_TEXT_ROW_START : integer := 325;
    CONSTANT start_CHAR_SIZE      : integer := 8;
    CONSTANT start_CHAR_SPACING   : integer := 10;

    TYPE small_char_array IS ARRAY (natural RANGE <>) OF std_logic_vector(5 DOWNTO 0);
    CONSTANT mode_message : small_char_array := (
        -- TRAINING MODE
        "010100", -- T
        "010010", -- R
        "000001", -- A
        "001001", -- I
        "001110", -- N
        "001001", -- I
        "001110", -- N
        "000111", -- G
        "100111", -- space
        "001101", -- M
        "001111", -- O
        "000100", -- D
        "000101", -- E
        "100111", -- space
        "011111", -- arrow
        "100111", -- space
        "010011", -- S
        "010111", -- w
        "011011", -- [
        "110000", -- 0 
        "011101", -- ]
        "100111", -- space
        "100001", -- = 
        "100111", -- space
        "110000", -- 1
        "100111", -- space
        "100111", -- space
        "100111", -- space
        -- GAME MODE
        "000111", -- G
        "000001", -- A
        "001101", -- M
        "000101", -- E
        "100111", -- space
        "001101", -- M
        "001111", -- O
        "000100", -- D
        "000101", -- E
        "100111", -- space
        "011111", -- arrow 
        "100111", -- space
        "010011", -- S
        "010111", -- w
        "011011", -- [
        "110000", -- 0 
        "011101", -- ]
        "100111", -- space
        "100001", -- = 
        "100111", -- space
        "110001", -- 1
        "100111", -- space
        "100111", -- space
        "100111"  -- space
    );

    CONSTANT start_message : small_char_array := (
        -- TRAINING MODE
        "010011", -- S
        "010100", -- T
        "000001", -- A
        "010010", -- R
        "010100", -- T
        "100111", -- space
        "011111", -- arrow 
        "100111", -- space
        "001011", -- k
        "000101", -- E
        "011001", -- Y
        "011011", -- [
        "110011", -- 0 
        "011101", -- ]
        "100111", -- space
        "100111", -- space
        "100111", -- space
        "010000", -- P
        "000001", -- A
        "010101", -- u
        "010011", -- S
        "000101", -- E
        "100111", -- space
        "011111", -- arrow 
        "100111", -- space
        "010010", -- R
        "001001", -- I
        "000111", -- G
        "001000", -- H 
        "010100", -- T
        "100111", -- space
        "000011", -- C
        "001100", -- L
        "001001", -- I
        "000011", -- C
        "001011"  -- k
    );

    CONSTANT mode_NUM_CHARS  : integer := mode_message'LENGTH;
    CONSTANT start_NUM_CHARS : integer := start_message'LENGTH;

    CONSTANT mode_TEXT_COL_START : integer :=
        (640 - (mode_NUM_CHARS - 1) * mode_CHAR_SPACING) / 2;
    CONSTANT start_TEXT_COL_START : integer :=
        (640 - (start_NUM_CHARS - 1) * start_CHAR_SPACING) / 2;

    ----------------------------------------------------------------------------
    -- SIGNALS & ARRAYS FOR DISTRIBUTED PIPELINING
    ----------------------------------------------------------------------------
    TYPE pixel_array IS ARRAY (0 TO NUM_CHARS-1) OF std_logic;
    SIGNAL rom_pixels : pixel_array;
    SIGNAL char_hits  : std_logic_vector(0 TO NUM_CHARS-1);

    TYPE mode_pixel_array IS ARRAY (0 TO mode_NUM_CHARS-1) OF std_logic;
    SIGNAL mode_rom_pixels : mode_pixel_array;
    SIGNAL mode_char_hits  : std_logic_vector(0 TO mode_NUM_CHARS-1);

    TYPE start_pixel_array IS ARRAY (0 TO start_NUM_CHARS-1) OF std_logic;
    SIGNAL start_rom_pixels : start_pixel_array;
    SIGNAL start_char_hits  : std_logic_vector(0 TO start_NUM_CHARS-1);

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
    -- LARGE TITLE GENERATION WITH PARALLEL HIT DETECTION
    ----------------------------------------------------------------------------
    GEN_CHARS: FOR i IN 0 TO NUM_CHARS-1 GENERATE
        SIGNAL row_offset : std_logic_vector(9 DOWNTO 0);
        SIGNAL col_offset : std_logic_vector(9 DOWNTO 0);
    BEGIN
        row_offset <= pixel_row - CONV_STD_LOGIC_VECTOR(TEXT_ROW_START, 10);
        col_offset <= pixel_column - CONV_STD_LOGIC_VECTOR(TEXT_COL_START + i * CHAR_SPACING, 10);

        CHAR_ROM_INST: char_rom
            PORT MAP (
                character_address => MESSAGE(i),
                font_row          => row_offset(4 DOWNTO 2), -- 32x32 scaling
                font_col          => col_offset(4 DOWNTO 2),
                clock             => clk,
                rom_mux_output    => rom_pixels(i)
            );

        -- Distributed fast bounding box check
        char_hits(i) <= '1' WHEN (row_offset < CHAR_SIZE AND col_offset < CHAR_SIZE AND rom_pixels(i) = '1') ELSE '0';
    END GENERATE GEN_CHARS;

    ----------------------------------------------------------------------------
    -- MODE TEXT GENERATION WITH PARALLEL HIT DETECTION
    ----------------------------------------------------------------------------
    GEN_MODE_CHARS: FOR i IN 0 TO mode_NUM_CHARS-1 GENERATE
        SIGNAL row_offset_mode : std_logic_vector(9 DOWNTO 0);
        SIGNAL col_offset_mode : std_logic_vector(9 DOWNTO 0);
    BEGIN
        row_offset_mode <= pixel_row - CONV_STD_LOGIC_VECTOR(mode_TEXT_ROW_START, 10);
        col_offset_mode <= pixel_column - CONV_STD_LOGIC_VECTOR(mode_TEXT_COL_START + i * mode_CHAR_SPACING, 10);

        mode_CHAR_ROM: char_rom
            PORT MAP (
                character_address => mode_message(i),
                font_row          => row_offset_mode(2 DOWNTO 0), -- 8x8 text
                font_col          => col_offset_mode(2 DOWNTO 0),
                clock             => clk,
                rom_mux_output    => mode_rom_pixels(i)
            );

        mode_char_hits(i) <= '1' WHEN (row_offset_mode < mode_CHAR_SIZE AND col_offset_mode < mode_CHAR_SIZE AND mode_rom_pixels(i) = '1') ELSE '0';
    END GENERATE GEN_MODE_CHARS;

    ----------------------------------------------------------------------------
    -- START TEXT GENERATION WITH PARALLEL HIT DETECTION
    ----------------------------------------------------------------------------
    GEN_start_CHARS: FOR i IN 0 TO start_NUM_CHARS-1 GENERATE
        SIGNAL row_offset_start : std_logic_vector(9 DOWNTO 0);
        SIGNAL col_offset_start : std_logic_vector(9 DOWNTO 0);
    BEGIN
        row_offset_start <= pixel_row - CONV_STD_LOGIC_VECTOR(start_TEXT_ROW_START, 10);
        col_offset_start <= pixel_column - CONV_STD_LOGIC_VECTOR(start_TEXT_COL_START + i * start_CHAR_SPACING, 10);

        start_CHAR_ROM: char_rom
            PORT MAP (
                character_address => start_message(i),
                font_row          => row_offset_start(2 DOWNTO 0), -- 8x8 text
                font_col          => col_offset_start(2 DOWNTO 0),
                clock             => clk,
                rom_mux_output    => start_rom_pixels(i)
            );

        start_char_hits(i) <= '1' WHEN (row_offset_start < start_CHAR_SIZE AND col_offset_start < start_CHAR_SIZE AND start_rom_pixels(i) = '1') ELSE '0';
    END GENERATE GEN_start_CHARS;

    ----------------------------------------------------------------------------
    -- HIGH-SPEED SYNCHRONOUS VIDEO DISPLAY LOGIC
    ----------------------------------------------------------------------------
    PROCESS(clk)
        VARIABLE hit_v       : std_logic;
        VARIABLE mode_hit_v  : std_logic;
        VARIABLE start_hit_v : std_logic;
    BEGIN
        IF rising_edge(clk) THEN
            hit_v       := '0';
            mode_hit_v  := '0';
            start_hit_v := '0';

            -- Check active frame layout safely
            IF Game_state_signal = "00" THEN
                -- Flattened reduction logic (Quartus converts this into a rapid OR-tree structure)
                FOR i IN 0 TO NUM_CHARS-1 LOOP
                    IF char_hits(i) = '1' THEN hit_v := '1'; END IF;
                END LOOP;

                FOR i IN 0 TO mode_NUM_CHARS-1 LOOP
                    IF mode_char_hits(i) = '1' THEN mode_hit_v := '1'; END IF;
                END LOOP;

                FOR i IN 0 TO start_NUM_CHARS-1 LOOP
                    IF start_char_hits(i) = '1' THEN start_hit_v := '1'; END IF;
                END LOOP;
            END IF;

            -- Registered Output Drive (Breaks critical path wide open)
            IF (hit_v = '1' OR mode_hit_v = '1' OR start_hit_v = '1') THEN
                red   <= "1111";
                blue  <= "1000";
            ELSE
                red   <= "0000";
                blue  <= "0000";
            END IF;
            green <= "0000";
            
        END IF;
    END PROCESS;

END behaviour;