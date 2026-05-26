LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY lives IS
    PORT
        ( clk                      : In std_logic;
          reset        : IN STD_LOGIC;
          pipe_hit     : IN STD_LOGIC;
          bait_hit     : IN STD_LOGIC;
          dolphin_IS_alive    : OUT STD_LOGIC;
          pixel_row, pixel_column : IN std_logic_vector(9 DOWNTO 0);
          Game_state_signal : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
          life_one, life_two, life_three : OUT STD_LOGIC;
          red, green, blue : OUT std_logic_VECTOR(3 DOWNTO 0);
          live_on : out std_logic);		
END lives;

architecture behaviour of lives is

    COMPONENT char_rom IS
        PORT
        (   character_address : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
            font_row, font_col : IN STD_LOGIC_VECTOR (2 DOWNTO 0); 
            clock              : IN STD_LOGIC;
            rom_mux_output     : OUT STD_LOGIC
        );
    END COMPONENT char_rom;

    SIGNAL lives_visible : std_logic;

    SIGNAL rom_pixel_heart_1 : std_logic;
    SIGNAL rom_pixel_heart_2 : std_logic;
    SIGNAL rom_pixel_heart_3 : std_logic;

    SIGNAL row_heart_1, col_heart_1 : std_logic_vector(9 DOWNTO 0);
    SIGNAL row_heart_2, col_heart_2 : std_logic_vector(9 DOWNTO 0);
    SIGNAL row_heart_3, col_heart_3 : std_logic_vector(9 DOWNTO 0);

    SIGNAL font_row_1, font_col_1 : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL font_row_2, font_col_2 : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL font_row_3, font_col_3 : STD_LOGIC_VECTOR(2 DOWNTO 0);

    SIGNAL life_count : INTEGER RANGE 0 TO 3 := 3;
    SIGNAL prev_hit   : STD_LOGIC := '0'; 

BEGIN

PROCESS(clk, reset)
BEGIN
    IF reset = '1' THEN
        life_count <= 3;
        prev_hit   <= '0';

    ELSIF rising_edge(clk) THEN

        IF Game_state_signal = "00" OR Game_state_signal = "01" THEN
            life_count <= 3;
            prev_hit   <= '0';

      ELSIF Game_state_signal = "10" THEN
    IF (pipe_hit = '1' OR bait_hit = '1') AND life_count > 0 THEN
        IF prev_hit = '0' THEN
            life_count <= life_count - 1;
        END IF;
    END IF;

    prev_hit <= pipe_hit OR bait_hit;
END IF;
    END IF;
END PROCESS;

life_one   <= '1' WHEN life_count >= 1 ELSE '0';
life_two   <= '1' WHEN life_count >= 2 ELSE '0';
life_three <= '1' WHEN life_count >= 3 ELSE '0';

dolphin_IS_alive <= '1' WHEN life_count > 0 ELSE '0';


row_heart_1 <= pixel_row - CONV_STD_LOGIC_VECTOR(20,10) WHEN pixel_row >= 20 ELSE (OTHERS => '1');
col_heart_1 <= pixel_column - CONV_STD_LOGIC_VECTOR(15,10)  WHEN pixel_column >= 5  ELSE (OTHERS => '1');
row_heart_2 <= pixel_row - CONV_STD_LOGIC_VECTOR(20,10) WHEN pixel_row >= 20 ELSE (OTHERS => '1');
col_heart_2 <= pixel_column - CONV_STD_LOGIC_VECTOR(35,10) WHEN pixel_column >= 25 ELSE (OTHERS => '1');
row_heart_3 <= pixel_row - CONV_STD_LOGIC_VECTOR(20,10) WHEN pixel_row >= 20 ELSE (OTHERS => '1');
col_heart_3 <= pixel_column - CONV_STD_LOGIC_VECTOR(55,10) WHEN pixel_column >= 45 ELSE (OTHERS => '1');


font_row_1 <= row_heart_1(3 DOWNTO 1);
font_col_1 <= col_heart_1(3 DOWNTO 1);
font_row_2 <= row_heart_2(3 DOWNTO 1);
font_col_2 <= col_heart_2(3 DOWNTO 1);
font_row_3 <= row_heart_3(3 DOWNTO 1);
font_col_3 <= col_heart_3(3 DOWNTO 1);

process(pixel_row, pixel_column, Game_state_signal,
        row_heart_1, col_heart_1, rom_pixel_heart_1,
        row_heart_2, col_heart_2, rom_pixel_heart_2,
        row_heart_3, col_heart_3, rom_pixel_heart_3,
        life_count)
begin
    lives_visible <= '0';

    if Game_state_signal = "10" then  -- FIXED: was "01" (training), now "10" (game mode)

        if life_count >= 1 and col_heart_1 < 16 and row_heart_1 < 16 and rom_pixel_heart_1 = '1' then
            lives_visible <= '1';  -- FIXED: heart 1 was missing this line

        elsif life_count >= 2 and col_heart_2 < 16 and row_heart_2 < 16 and rom_pixel_heart_2 = '1' then
            lives_visible <= '1';  -- FIXED: heart 2 was missing this line

        elsif life_count >= 3 and col_heart_3 < 16 and row_heart_3 < 16 and rom_pixel_heart_3 = '1' then
            lives_visible <= '1';

        end if;
    end if;
end process;

HEART_ROM_1: char_rom PORT MAP (
    character_address => "100000",
    font_row => font_row_1, 
    font_col => font_col_1,
    clock => clk,
    rom_mux_output => rom_pixel_heart_1
);

HEART_ROM_2: char_rom PORT MAP (
    character_address => "100000",
    font_row => font_row_2,
    font_col => font_col_2,
    clock => clk,
    rom_mux_output => rom_pixel_heart_2
);

HEART_ROM_3: char_rom PORT MAP (
    character_address => "100000",
    font_row => font_row_3,
    font_col => font_col_3,
    clock => clk,
    rom_mux_output => rom_pixel_heart_3
);

live_on <= lives_visible;
Red   <= "1000" when lives_visible = '1' else "0000";
Green <= "0000";
Blue  <= "0000";

END behaviour;