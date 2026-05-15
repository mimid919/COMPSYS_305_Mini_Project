LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY home_display IS
	PORT
		( clk                       : In std_logic;
          pixel_row, pixel_column	: IN std_logic_vector(9 DOWNTO 0);
          FSM_STATE : STD_LOGIC_VECTOR(1 DOWNTO 0);
          red, green, blue 			: OUT std_logic);		
END home_display;

architecture behaviour of home_display is

COMPONENT char_rom IS
	PORT
	(
		character_address	:	IN STD_LOGIC_VECTOR (5 DOWNTO 0);
		font_row, font_col	:	IN STD_LOGIC_VECTOR (2 DOWNTO 0);
		clock				: 	IN STD_LOGIC ;
		rom_mux_output		:	OUT STD_LOGIC
	);
END COMPONENT char_rom;

SIGNAL text_on : std_logic;

SIGNAL rom_pixel_P : std_logic;
SIGNAL rom_pixel_L : std_logic;
SIGNAL rom_pixel_A  : std_logic;
SIGNAL rom_pixel_Y  : std_logic;
SIGNAL rom_pixel_Heart  : std_logic;


SIGNAL row_P, col_P : std_logic_vector(9 downto 0);
SIGNAL row_L, col_L : std_logic_vector(9 downto 0);
SIGNAL row_A, col_A : std_logic_vector(9 downto 0);
SIGNAL row_Y, col_Y : std_logic_vector(9 downto 0);
SIGNAL row_Heart, col_Heart : std_logic_vector(9 downto 0);

Begin 

row_P <= pixel_row - CONV_STD_LOGIC_VECTOR(100,10);
col_P <= pixel_column - CONV_STD_LOGIC_VECTOR(200,10);

row_L <= pixel_row - CONV_STD_LOGIC_VECTOR(100,10);
col_L <= pixel_column - CONV_STD_LOGIC_VECTOR(210,10);

row_A <= pixel_row - CONV_STD_LOGIC_VECTOR(100,10);
col_A <= pixel_column - CONV_STD_LOGIC_VECTOR(220,10);

row_Y <= pixel_row - CONV_STD_LOGIC_VECTOR(100,10);
col_Y <= pixel_column - CONV_STD_LOGIC_VECTOR(230,10);

row_Heart <= pixel_row - CONV_STD_LOGIC_VECTOR(100,10);
col_Heart <= pixel_column - CONV_STD_LOGIC_VECTOR(240,10);

process(pixel_row, pixel_column, FSM_STATE,
            row_P, col_P, rom_pixel_P,
            row_L, col_L, rom_pixel_L,
            row_A, col_A, rom_pixel_A,
            row_Y, col_Y, rom_pixel_Y,
            row_Heart, col_Heart, rom_pixel_Heart)
begin
    text_on <= '0';

    if FSM_STATE = "00" then -- start screen
        --P (8x8)
        if (col_p) < 8 and (row_P) < 8 and rom_pixel_P = '1' then
            text_on <= '1';
        elsif
        --L (8x8)
        (col_L) < 8 and (row_L) < 8 and rom_pixel_L = '1' then
            text_on <= '1';     
        elsif
        --A (8x8)   
        (col_A) < 8 and (row_A) < 8 and rom_pixel_A = '1' then
            text_on <= '1';
        elsif
        --Y (8x8)
        (col_Y) < 8 and (row_Y) < 8 and rom_pixel_Y = '1' then
            text_on <= '1';
        elsif
        --HEART (32x32)
        (col_Heart) < 32 and (row_Heart) < 32 and rom_pixel_Heart = '1' then
            text_on <= '1';
        end if;
    end if;
end process;

P_ROM: char_rom
PORT MAP (
    character_address => "010000",
    font_row => row_P(2 downto 0),
	font_col => col_P(2 downto 0),
    clock => clk,
    rom_mux_output => rom_pixel_P
);

L_ROM: char_rom
PORT MAP (
    character_address => "001100",  
	font_row => row_L(2 downto 0),
    font_col => col_L(2 downto 0),
    clock => clk,
    rom_mux_output => rom_pixel_L
);

A_ROM: char_rom
PORT MAP (
    character_address => "000001",
	font_row => row_A(2 downto 0),
    font_col => col_A(2 downto 0),
    clock => clk,
    rom_mux_output => rom_pixel_A
);

Y_ROM: char_rom   -- 01100110
PORT MAP (
    character_address => "011001",
	font_row => row_Y(2 downto 0),
    font_col => col_Y(2 downto 0),
    clock => clk,
    rom_mux_output => rom_pixel_Y
);

HEART_ROM: char_rom
PORT MAP (
    character_address => "100000",
	font_row => row_Heart(4 downto 2),
    font_col => col_Heart(4 downto 2),
    clock => clk,
    rom_mux_output => rom_pixel_Heart
);


Red   <= text_on;
Green <= (not text_on);
Blue  <= text_on;

END behaviour;