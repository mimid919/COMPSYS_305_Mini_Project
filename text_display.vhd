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
SIGNAL text_on : std_logic;

Begin 

--displaying text
text_on <= '1' when 
(pixel_column >= CONV_STD_LOGIC_VECTOR(200,10) 
and
    pixel_column <  CONV_STD_LOGIC_VECTOR(216,10)
and
    pixel_row    >= CONV_STD_LOGIC_VECTOR(50,10)
and
    pixel_row    <  CONV_STD_LOGIC_VECTOR(150,10))
or

(pixel_column >= CONV_STD_LOGIC_VECTOR(280,10)
and
    pixel_column <  CONV_STD_LOGIC_VECTOR(296,10)
and
    pixel_row    >= CONV_STD_LOGIC_VECTOR(50,10)
and
    pixel_row    <  CONV_STD_LOGIC_VECTOR(150,10))

or

   ( pixel_row    >= CONV_STD_LOGIC_VECTOR(95,10)
and
    pixel_row    <  CONV_STD_LOGIC_VECTOR(105,10)
and
pixel_column >= CONV_STD_LOGIC_VECTOR(216,10)
and
    pixel_column <  CONV_STD_LOGIC_VECTOR(296,10))

or

(pixel_column >= CONV_STD_LOGIC_VECTOR(300,10)
and
    pixel_column <  CONV_STD_LOGIC_VECTOR(316,10)
and
    pixel_row    >= CONV_STD_LOGIC_VECTOR(50,10)
and
    pixel_row    <  CONV_STD_LOGIC_VECTOR(150,10))

	
	
	 else '0' ;


Red   <= text_on;
Green <= text_on;
Blue  <= (not text_on);

END behaviour;