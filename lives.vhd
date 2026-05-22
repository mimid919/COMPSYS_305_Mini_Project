LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;

-- Displays three hearts (as text) in top left of screen during state '01'
-- Each heart has a seperate enable (life_one - three) which can be set to '0' when a life is lost

ENTITY lives IS
	PORT
		( clk                       : In std_logic;
          pixel_row, pixel_column	: IN std_logic_vector(9 DOWNTO 0);
          Game_state_signal : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
          life_one, life_two, life_three : IN STD_LOGIC; -- for enabling lives
          red, green, blue 			: OUT std_logic;
          live_on                   : out std_logic);		
END lives;

architecture behaviour of lives is

    COMPONENT char_rom IS
        PORT
        (   character_address	:	IN STD_LOGIC_VECTOR (5 DOWNTO 0);
            font_row, font_col	:	IN STD_LOGIC_VECTOR (2 DOWNTO 0);
            clock				: 	IN STD_LOGIC;
            rom_mux_output		:	OUT STD_LOGIC
        );
    END COMPONENT char_rom;

    SIGNAL lives_visible : std_logic;

    SIGNAL rom_pixel_heart_1 : std_logic;
    SIGNAL rom_pixel_heart_2 : std_logic;
    SIGNAL rom_pixel_heart_3 : std_logic;

    SIGNAL row_heart_1, col_heart_1 : std_logic_vector(9 DOWNTO 0);
    SIGNAL row_heart_2, col_heart_2 : std_logic_vector(9 DOWNTO 0);
    SIGNAL row_heart_3, col_heart_3 : std_logic_vector(9 DOWNTO 0);


Begin 

row_heart_1 <= pixel_row - CONV_STD_LOGIC_VECTOR(20,10);
col_heart_1 <= pixel_column - CONV_STD_LOGIC_VECTOR(5,10);

row_heart_2 <= pixel_row - CONV_STD_LOGIC_VECTOR(20,10);
col_heart_2 <= pixel_column - CONV_STD_LOGIC_VECTOR(35,10);

row_heart_3 <= pixel_row - CONV_STD_LOGIC_VECTOR(20,10);
col_heart_3 <= pixel_column - CONV_STD_LOGIC_VECTOR(70,10);


process(pixel_row, pixel_column, Game_state_signal,
            row_heart_1, col_heart_1, rom_pixel_heart_1,
            row_heart_2, col_heart_2, rom_pixel_heart_2,
            row_heart_3, col_heart_3, rom_pixel_heart_3,
            life_one, life_two, life_three)
begin
    lives_visible <= '0';

    if Game_state_signal = "01" then 

        if life_one = '1' and col_heart_1 < 16 and row_heart_1 < 16 and rom_pixel_heart_1 = '1' then
            lives_visible <= '1';
        elsif life_two = '1' and col_heart_2 < 16 and row_heart_2 < 16 and rom_pixel_heart_2 = '1' then
            lives_visible <= '1';
        elsif life_three = '1' and col_heart_3 < 16 and row_heart_3 < 16 and rom_pixel_heart_3 = '1' then
            lives_visible <= '1';
        end if;
    end if;
end process;

HEART_ROM_1: char_rom
PORT MAP (
    character_address => "100000",
	font_row => row_heart_1(3 downto 1),
    font_col => col_heart_1(3 downto 1),
    clock => clk,
    rom_mux_output => rom_pixel_Heart_1
);

HEART_ROM_2: char_rom
PORT MAP (
    character_address => "100000",
	font_row => row_heart_2(3 downto 1),
    font_col => col_heart_2(3 downto 1),
    clock => clk,
    rom_mux_output => rom_pixel_Heart_2
);

HEART_ROM_3: char_rom
PORT MAP (
    character_address => "100000",
	font_row => row_heart_3(3 downto 1),
    font_col => col_heart_3(3 downto 1),
    clock => clk,
    rom_mux_output => rom_pixel_Heart_3
);

live_on <= lives_visible;
Red   <= lives_visible;
Green <= '0';
Blue  <= '0';

END behaviour;