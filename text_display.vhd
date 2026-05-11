LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_SIGNED.all;

ENTITY text_display IS
	PORT
		( clk                       : In std_logic;
          pixel_row, pixel_column	: IN std_logic_vector(9 DOWNTO 0);
		  red, green, blue 			: OUT std_logic);		
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


SIGNAL text_on : std_logic;
SIGNAL rom_pixel : std_logic;


SIGNAL rom_pixel_H : std_logic;
SIGNAL rom_pixel_I : std_logic;

SIGNAL row_H : std_logic_vector(9 downto 0);
SIGNAL col_H : std_logic_vector(9 downto 0);
SIGNAL row_I : std_logic_vector(9 downto 0);
SIGNAL col_I : std_logic_vector(9 downto 0);

Begin 

row_H <= pixel_row - CONV_STD_LOGIC_VECTOR(100,10);
col_H <= pixel_column - CONV_STD_LOGIC_VECTOR(200,10);

row_I <= pixel_row - CONV_STD_LOGIC_VECTOR(100,10);
col_I <= pixel_column - CONV_STD_LOGIC_VECTOR(210,10);

text_on <= '1' when (

    -- H
    (
        pixel_column >= CONV_STD_LOGIC_VECTOR(200,10) and
        pixel_column <  CONV_STD_LOGIC_VECTOR(208,10) and
        pixel_row    >= CONV_STD_LOGIC_VECTOR(100,10) and
        pixel_row    <  CONV_STD_LOGIC_VECTOR(108,10) and
        rom_pixel_H = '1'
    )

    or

    -- I
    (
        pixel_column >= CONV_STD_LOGIC_VECTOR(210,10) and
        pixel_column <  CONV_STD_LOGIC_VECTOR(218,10) and
        pixel_row    >= CONV_STD_LOGIC_VECTOR(100,10) and
        pixel_row    <  CONV_STD_LOGIC_VECTOR(108,10) and
        rom_pixel_I = '1'
    )

) else '0';


H_ROM: char_rom
PORT MAP (
    character_address => "001000",
    font_row => row_H(2 downto 0),
		font_col => col_H(2 downto 0),
    clock => clk,
    rom_mux_output => rom_pixel_H
);

I_ROM: char_rom
PORT MAP (
    character_address => "001001",
		font_row => row_I(2 downto 0),
font_col => col_I(2 downto 0),
    clock => clk,
    rom_mux_output => rom_pixel_I
);


Red   <= text_on;
Green <= text_on;
Blue  <= (not text_on);

END behaviour;