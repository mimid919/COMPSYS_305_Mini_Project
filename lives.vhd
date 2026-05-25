LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY lives IS
    PORT
        ( clk                         : IN std_logic;
          pixel_row, pixel_column     : IN std_logic_vector(9 DOWNTO 0);
          Game_state_signal           : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
          life_one, life_two, life_three : IN STD_LOGIC;
          red, green, blue            : OUT std_logic_VECTOR(3 DOWNTO 0);
          live_on                     : OUT std_logic
        );
END lives;

ARCHITECTURE behaviour OF lives IS

    COMPONENT char_rom IS
        PORT
        (   character_address : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
            font_row, font_col : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
            clock             : IN STD_LOGIC;
            rom_mux_output    : OUT STD_LOGIC
        );
    END COMPONENT char_rom;

    SIGNAL heart_selected : std_logic;
    SIGNAL heart_selected_d : std_logic := '0';
    SIGNAL rom_pixel      : std_logic;
    SIGNAL font_row_sel   : std_logic_vector(2 DOWNTO 0);
    SIGNAL font_col_sel   : std_logic_vector(2 DOWNTO 0);

    SIGNAL row_heart_1, col_heart_1 : std_logic_vector(9 DOWNTO 0);
    SIGNAL row_heart_2, col_heart_2 : std_logic_vector(9 DOWNTO 0);
    SIGNAL row_heart_3, col_heart_3 : std_logic_vector(9 DOWNTO 0);

BEGIN

    row_heart_1 <= pixel_row - CONV_STD_LOGIC_VECTOR(20,10);
    col_heart_1 <= pixel_column - CONV_STD_LOGIC_VECTOR(5,10);

    row_heart_2 <= pixel_row - CONV_STD_LOGIC_VECTOR(20,10);
    col_heart_2 <= pixel_column - CONV_STD_LOGIC_VECTOR(35,10);

    row_heart_3 <= pixel_row - CONV_STD_LOGIC_VECTOR(20,10);
    col_heart_3 <= pixel_column - CONV_STD_LOGIC_VECTOR(70,10);

    PROCESS(pixel_row, pixel_column, Game_state_signal,
            row_heart_1, col_heart_1,
            row_heart_2, col_heart_2,
            row_heart_3, col_heart_3,
            life_one, life_two, life_three)
    BEGIN
        heart_selected <= '0';
        font_row_sel <= (OTHERS => '0');
        font_col_sel <= (OTHERS => '0');

        IF Game_state_signal = "01" or Game_state_signal = "10" THEN
            IF life_one = '1' and col_heart_1 < 16 and row_heart_1 < 16 THEN
                heart_selected <= '1';
                font_row_sel <= row_heart_1(3 DOWNTO 1);
                font_col_sel <= col_heart_1(3 DOWNTO 1);
            ELSIF life_two = '1' and col_heart_2 < 16 and row_heart_2 < 16 THEN
                heart_selected <= '1';
                font_row_sel <= row_heart_2(3 DOWNTO 1);
                font_col_sel <= col_heart_2(3 DOWNTO 1);
            ELSIF life_three = '1' and col_heart_3 < 16 and row_heart_3 < 16 THEN
                heart_selected <= '1';
                font_row_sel <= row_heart_3(3 DOWNTO 1);
                font_col_sel <= col_heart_3(3 DOWNTO 1);
            END IF;
        END IF;
    END PROCESS;

    HEART_ROM: char_rom
    PORT MAP (
        character_address => "100000",
        font_row => font_row_sel,
        font_col => font_col_sel,
        clock => clk,
        rom_mux_output => rom_pixel
    );

    PROCESS(clk)
    BEGIN
        IF rising_edge(clk) THEN
            heart_selected_d <= heart_selected;
        END IF;
    END PROCESS;

    live_on <= heart_selected_d and rom_pixel;
    red   <= "1000" when (heart_selected_d = '1' and rom_pixel = '1') else "0000";
    green <= "0000";
    blue  <= "0000";

END behaviour;
