LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_SIGNED.all;

ENTITY text_display IS
	PORT
		( clk                       : In std_logic;
          pixel_row, pixel_column	: IN std_logic_vector(9 DOWNTO 0);
          -- adding a switch for interim display, to show the etxt changing colour, can remove for real project
            SW                                  : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		  red, green, blue 			: OUT std_logic;
          text_on   : out std_logic);		
END text_display;

architecture behaviour of text_display is

COMPONENT char_rom IS
	PORT
	(
		character_address	:	IN STD_LOGIC_VECTOR (5 DOWNTO 0);
		font_row, font_col	:	IN STD_LOGIC_VECTOR (2 DOWNTO 0);
		clock				: 	IN STD_LOGIC ;
		rom_mux_output		:	OUT STD_LOGIC
	);
END COMPONENT char_rom;

SIGNAL rom_pixel : std_logic;
SIGNAL text_visible : std_logic;


SIGNAL rom_pixel_P : std_logic;
SIGNAL rom_pixel_L : std_logic;
SIGNAL rom_pixel_A  : std_logic;
SIGNAL rom_pixel_Y  : std_logic;
SIGNAL rom_pixel_H  : std_logic;


SIGNAL row_P : std_logic_vector(9 downto 0);
SIGNAL col_P : std_logic_vector(9 downto 0);
SIGNAL row_L : std_logic_vector(9 downto 0);
SIGNAL col_L : std_logic_vector(9 downto 0);
SIGNAL row_A : std_logic_vector(9 downto 0);
SIGNAL col_A : std_logic_vector(9 downto 0);
SIGNAL row_Y : std_logic_vector(9 downto 0);
SIGNAL col_Y : std_logic_vector(9 downto 0);
SIGNAL row_H : std_logic_vector(9 downto 0);
SIGNAL col_h : std_logic_vector(9 downto 0);

Begin 

row_P <= pixel_row - CONV_STD_LOGIC_VECTOR(100,10);
col_P <= pixel_column - CONV_STD_LOGIC_VECTOR(200,10);

row_L <= pixel_row - CONV_STD_LOGIC_VECTOR(100,10);
col_L <= pixel_column - CONV_STD_LOGIC_VECTOR(210,10);

row_A <= pixel_row - CONV_STD_LOGIC_VECTOR(100,10);
col_A <= pixel_column - CONV_STD_LOGIC_VECTOR(220,10);

row_Y <= pixel_row - CONV_STD_LOGIC_VECTOR(100,10);
col_Y <= pixel_column - CONV_STD_LOGIC_VECTOR(230,10);

row_h <= pixel_row - CONV_STD_LOGIC_VECTOR(100,10);
col_h <= pixel_column - CONV_STD_LOGIC_VECTOR(240,10);


-- only turn text on when SW[9] is on
text_visible <= '1' when SW(9) = '1' and (

    --P
    (
        pixel_column >= CONV_STD_LOGIC_VECTOR(200,10) and
        pixel_column <  CONV_STD_LOGIC_VECTOR(208,10) and
        pixel_row    >= CONV_STD_LOGIC_VECTOR(100,10) and
        pixel_row    <  CONV_STD_LOGIC_VECTOR(108,10) and
        rom_pixel_P = '1'
    )

    or

    --L
    (
        pixel_column >= CONV_STD_LOGIC_VECTOR(210,10) and
        pixel_column <  CONV_STD_LOGIC_VECTOR(218,10) and
        pixel_row    >= CONV_STD_LOGIC_VECTOR(100,10) and
        pixel_row    <  CONV_STD_LOGIC_VECTOR(108,10) and
        rom_pixel_L = '1'
    )
or
    --A
    (
        pixel_column >= CONV_STD_LOGIC_VECTOR(220,10) and
        pixel_column <  CONV_STD_LOGIC_VECTOR(228,10) and
        pixel_row    >= CONV_STD_LOGIC_VECTOR(100,10) and
        pixel_row    <  CONV_STD_LOGIC_VECTOR(108,10) and
        rom_pixel_A = '1'
    )
or
     --Y
    (
        pixel_column >= CONV_STD_LOGIC_VECTOR(230,10) and
        pixel_column <  CONV_STD_LOGIC_VECTOR(238,10) and
        pixel_row    >= CONV_STD_LOGIC_VECTOR(100,10) and
        pixel_row    <  CONV_STD_LOGIC_VECTOR(108,10) and
        rom_pixel_Y = '1'
    )
or
     --HEART
    (
        pixel_column >= CONV_STD_LOGIC_VECTOR(240,10) and
        pixel_column <  CONV_STD_LOGIC_VECTOR(272,10) and
        pixel_row    >= CONV_STD_LOGIC_VECTOR(100,10) and
        pixel_row    <  CONV_STD_LOGIC_VECTOR(132,10) and
        rom_pixel_H = '1'
    )


) else '0';


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
	font_row => row_H(4 downto 2),
    font_col => col_H(4 downto 2),
    clock => clk,
    rom_mux_output => rom_pixel_H
);

text_on <= text_visible;
Red   <= text_visible;
Green <= '0';
Blue  <= text_visible;

END behaviour;