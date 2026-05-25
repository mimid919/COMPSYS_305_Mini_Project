LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY score_text IS
    PORT
        ( clk                   : IN std_logic;
          pixel_row, pixel_column : IN std_logic_vector(9 DOWNTO 0);
          Game_state_signal     : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
          score_ones            : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
          score_tens            : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
          red, green, blue      : OUT std_logic_vector(3 DOWNTO 0);
          score_on              : OUT std_logic
        );
END score_text;

ARCHITECTURE behaviour OF score_text IS

    COMPONENT char_rom IS
        PORT
        (   character_address : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
            font_row, font_col : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
            clock             : IN STD_LOGIC;
            rom_mux_output    : OUT STD_LOGIC
        );
    END COMPONENT char_rom;

    SIGNAL score_visible : std_logic;

    SIGNAL rom_pixel_s, rom_pixel_c, rom_pixel_o, rom_pixel_r, rom_pixel_e : std_logic;
    SIGNAL rom_pixel_tens, rom_pixel_ones : std_logic;

    SIGNAL row_s, col_s       : std_logic_vector(9 DOWNTO 0);
    SIGNAL row_c, col_c       : std_logic_vector(9 DOWNTO 0);
    SIGNAL row_o, col_o       : std_logic_vector(9 DOWNTO 0);
    SIGNAL row_r, col_r       : std_logic_vector(9 DOWNTO 0);
    SIGNAL row_e, col_e       : std_logic_vector(9 DOWNTO 0);
    SIGNAL row_tens, col_tens : std_logic_vector(9 DOWNTO 0);
    SIGNAL row_ones, col_ones : std_logic_vector(9 DOWNTO 0);

BEGIN

    row_s <= pixel_row - CONV_STD_LOGIC_VECTOR(20, 10);
    col_s <= pixel_column - CONV_STD_LOGIC_VECTOR(420, 10);

    row_c <= pixel_row - CONV_STD_LOGIC_VECTOR(20, 10);
    col_c <= pixel_column - CONV_STD_LOGIC_VECTOR(438, 10);

    row_o <= pixel_row - CONV_STD_LOGIC_VECTOR(20, 10);
    col_o <= pixel_column - CONV_STD_LOGIC_VECTOR(456, 10);

    row_r <= pixel_row - CONV_STD_LOGIC_VECTOR(20, 10);
    col_r <= pixel_column - CONV_STD_LOGIC_VECTOR(474, 10);

    row_e <= pixel_row - CONV_STD_LOGIC_VECTOR(20, 10);
    col_e <= pixel_column - CONV_STD_LOGIC_VECTOR(492, 10);

    row_tens <= pixel_row - CONV_STD_LOGIC_VECTOR(20, 10);
    col_tens <= pixel_column - CONV_STD_LOGIC_VECTOR(528, 10);

    row_ones <= pixel_row - CONV_STD_LOGIC_VECTOR(20, 10);
    col_ones <= pixel_column - CONV_STD_LOGIC_VECTOR(546, 10);

    PROCESS(pixel_row, pixel_column, Game_state_signal,
            row_s, col_s, rom_pixel_s,
            row_c, col_c, rom_pixel_c,
            row_o, col_o, rom_pixel_o,
            row_r, col_r, rom_pixel_r,
            row_e, col_e, rom_pixel_e,
            row_tens, col_tens, rom_pixel_tens,
            row_ones, col_ones, rom_pixel_ones)
    BEGIN
        score_visible <= '0';

        IF Game_state_signal = "01" or Game_state_signal = "10" THEN
            IF col_s < 16 and row_s < 16 and rom_pixel_s = '1' THEN
                score_visible <= '1';
            ELSIF col_c < 16 and row_c < 16 and rom_pixel_c = '1' THEN
                score_visible <= '1';
            ELSIF col_o < 16 and row_o < 16 and rom_pixel_o = '1' THEN
                score_visible <= '1';
            ELSIF col_r < 16 and row_r < 16 and rom_pixel_r = '1' THEN
                score_visible <= '1';
            ELSIF col_e < 16 and row_e < 16 and rom_pixel_e = '1' THEN
                score_visible <= '1';
            ELSIF col_tens < 16 and row_tens < 16 and rom_pixel_tens = '1' THEN
                score_visible <= '1';
            ELSIF col_ones < 16 and row_ones < 16 and rom_pixel_ones = '1' THEN
                score_visible <= '1';
            END IF;
        END IF;
    END PROCESS;

    S_ROM: char_rom PORT MAP (
        character_address => "010011",
        font_row => row_s(3 DOWNTO 1),
        font_col => col_s(3 DOWNTO 1),
        clock => clk,
        rom_mux_output => rom_pixel_s
    );

    C_ROM: char_rom PORT MAP (
        character_address => "000011",
        font_row => row_c(3 DOWNTO 1),
        font_col => col_c(3 DOWNTO 1),
        clock => clk,
        rom_mux_output => rom_pixel_c
    );

    O_ROM: char_rom PORT MAP (
        character_address => "001111",
        font_row => row_o(3 DOWNTO 1),
        font_col => col_o(3 DOWNTO 1),
        clock => clk,
        rom_mux_output => rom_pixel_o
    );

    R_ROM: char_rom PORT MAP (
        character_address => "010010",
        font_row => row_r(3 DOWNTO 1),
        font_col => col_r(3 DOWNTO 1),
        clock => clk,
        rom_mux_output => rom_pixel_r
    );

    E_ROM: char_rom PORT MAP (
        character_address => "000101",
        font_row => row_e(3 DOWNTO 1),
        font_col => col_e(3 DOWNTO 1),
        clock => clk,
        rom_mux_output => rom_pixel_e
    );

    TENS_ROM: char_rom PORT MAP (
        character_address => "11" & score_tens,
        font_row => row_tens(3 DOWNTO 1),
        font_col => col_tens(3 DOWNTO 1),
        clock => clk,
        rom_mux_output => rom_pixel_tens
    );

    ONES_ROM: char_rom PORT MAP (
        character_address => "11" & score_ones,
        font_row => row_ones(3 DOWNTO 1),
        font_col => col_ones(3 DOWNTO 1),
        clock => clk,
        rom_mux_output => rom_pixel_ones
    );

    score_on <= score_visible;
    red   <= "1111" when score_visible = '1' else "0000";
    green <= "1111" when score_visible = '1' else "0000";
    blue  <= "1111" when score_visible = '1' else "0000";

END behaviour;
