LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;


ENTITY dolphin IS
	PORT
		( clk 						: IN std_logic;
		  pixel_row, pixel_column	: IN std_logic_vector(9 DOWNTO 0);
		  dolphin_on 			: OUT std_logic);		
END dolphin;

architecture behavior of dolphin is

SIGNAL size 					: std_logic_vector(9 DOWNTO 0);  
SIGNAL dolphin_y_pos, dolphin_x_pos	: std_logic_vector(9 DOWNTO 0);

BEGIN           

size <= CONV_STD_LOGIC_VECTOR(8,10);
-- dolphin_x_pos and dolphin_y_pos show the (x,y) for the centre of dolphin

dolphin_x_pos <= CONV_STD_LOGIC_VECTOR(590,10);
dolphin_y_pos <= CONV_STD_LOGIC_VECTOR(350,10);


dolphin_on <= '1' when ( ('0' & dolphin_x_pos <= pixel_column + size) and ('0' & pixel_column <= dolphin_x_pos + size) 	-- x_pos - size <= pixel_column <= x_pos + size
					and ('0' & dolphin_y_pos <= pixel_row + size) and ('0' & pixel_row <= dolphin_y_pos + size) )  else	-- y_pos - size <= pixel_row <= y_pos + size
			'0';

END behavior;

