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

Begin 

--displaying text
text_on <= '1' when (
    pixel_column >= CONV_STD_LOGIC_VECTOR(200,10) and
    pixel_column <  CONV_STD_LOGIC_VECTOR(232,10) and
    pixel_row    >= CONV_STD_LOGIC_VECTOR(100,10) and
    pixel_row    <  CONV_STD_LOGIC_VECTOR(140,10) and
    rom_pixel = '1'
) else '0';

t: char_rom
PORT MAP (
    character_address => "000001",
    font_row => pixel_row(2 downto 0),
    font_col => pixel_column(2 downto 0),
    clock => clk,
    rom_mux_output => rom_pixel
);


Red   <= text_on;
Green <= text_on;
Blue  <= (not text_on);

END behaviour;