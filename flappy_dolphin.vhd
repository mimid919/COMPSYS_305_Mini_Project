LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_SIGNED.all;

-- ball -> dolphin (square?)
-- bouncy -> flappy

-- Added mouse_row/column as inputs
-- added line to link mouse to dolphin movement
-- dolphin moves with mouse movement not with clicks so need to add gravity!

-- Adding gravity
-- spwan in middle of screen, then fall down until mouse moves it up
-- left click = dolphin surges up, then gravity pulls it down again
-- stop when hits ground
-- bounces down when hits top 

ENTITY flappy_dolphin IS
	PORT
		( pb1, pb2, clk, vert_sync	: IN std_logic;
          pixel_row, pixel_column	: IN std_logic_vector(9 DOWNTO 0);
		  mouse_row, mouse_column 	: IN std_logic_vector(9 DOWNTO 0);
		  left_click 				: IN std_logic;
		  red, green, blue 			: OUT std_logic);		
END flappy_dolphin;



architecture behavior of flappy_dolphin is

COMPONENT char_rom IS
	PORT
	(
		character_address	:	IN STD_LOGIC_VECTOR (5 DOWNTO 0);
		font_row, font_col	:	IN STD_LOGIC_VECTOR (2 DOWNTO 0);
		clock				: 	IN STD_LOGIC ;
		rom_mux_output		:	OUT STD_LOGIC
	);
END COMPONENT;

SIGNAL dolphin_on					: std_logic;
SIGNAL size 						: std_logic_vector(9 DOWNTO 0);  
SIGNAL dolphin_y_pos				: std_logic_vector(9 DOWNTO 0);
SiGNAL dolphin_x_pos				: std_logic_vector(10 DOWNTO 0);
-- SIGNAL dolphin_y_motion			: std_logic_vector(9 DOWNTO 0);

-----text rendering
SIGNAL text_on 						: std_logic;
SIGNAL rom_pixel					: std_logic;




BEGIN           

size <= CONV_STD_LOGIC_VECTOR(8,10);
-- dolphin_x_pos and dolphin_y_pos show the (x,y) for the centre of dolphin
dolphin_x_pos <= CONV_STD_LOGIC_VECTOR(50,11);

dolphin_on <= '1' when ( ('0' & dolphin_x_pos <= '0' & pixel_column + size) and ('0' & pixel_column <= '0' & dolphin_x_pos + size) 	-- x_pos - size <= pixel_column <= x_pos + size
					and ('0' & dolphin_y_pos <= pixel_row + size) and ('0' & pixel_row <= dolphin_y_pos + size) )  else	-- y_pos - size <= pixel_row <= y_pos + size
			'0';


----text

text_on <= '1' when (pixel_column >= CONV_STD_LOGIC_VECTOR(20,10) 
and
    pixel_column <  CONV_STD_LOGIC_VECTOR(28,10) 
and
    pixel_row    >= CONV_STD_LOGIC_VECTOR(50,10) 
and
    pixel_row    <  CONV_STD_LOGIC_VECTOR(58,10) 
and
rom_pixel ='1') else '0';



-- Colours for pixel data on video signal
-- Changing the background and dolphin colour by pushbuttons
Red <= '1' when text_on='1' else pb1;
Green <= (not pb2) and (not dolphin_on);
Blue <=  not dolphin_on;

-- Move dolphin up and down with mouse
dolphin_y_pos <= mouse_row;

-- Move_dolphin: process (vert_sync)  	
-- begin
-- 	-- Move dolphin once every vertical sync
-- 	if (rising_edge(vert_sync)) then			
-- 		-- Bounce off top or bottom of the screen
-- 		if ( ('0' & dolphin_y_pos >= CONV_STD_LOGIC_VECTOR(479,10) - size) ) then
-- 			dolphin_y_motion <= - CONV_STD_LOGIC_VECTOR(2,10);
-- 		elsif (dolphin_y_pos <= size) then 
-- 			dolphin_y_motion <= CONV_STD_LOGIC_VECTOR(2,10);
-- 		end if;
-- 		-- Compute next dolphin Y position
-- 		dolphin_y_pos <= dolphin_y_pos + dolphin_y_motion;
-- 	end if;
-- end process Move_dolphin;


-------------displaying text 
t: char_rom
port map(
	character_address => "001000",
		font_row => pixel_row(2 downto 0),
		 font_col=> pixel_column(2 downto 0),
		clock => clk,
		rom_mux_output => rom_pixel

);

END behavior;

