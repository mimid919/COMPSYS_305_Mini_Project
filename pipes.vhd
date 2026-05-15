LIBRARY IEEE;
USE  IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY PIPES IS
    PORT
        ( CLOCK_25Mhz	            : IN std_logic;
          vert_sync		            : IN std_logic;
          pixel_row, pixel_column	: IN std_logic_vector(9 DOWNTO 0);
		  red, green, blue 			: OUT std_logic;
          lfsr_value				: IN std_logic_vector(7 DOWNTO 0);
		  pipe_enable				: OUT std_logic
          );	
END PIPES;

ARCHITECTURE behavior OF PIPES IS
    SIGNAL pipe_x_pos_1				: std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(0, 10); -- start off screen to the right
    SIGNAL pipe_x_pos_2				: std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(213, 10);
    SIGNAL pipe_x_pos_3				: std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(426, 10);

    SIGNAL pipe_top_height_1         : std_logic_vector(9 DOWNTO 0);
    SIGNAL pipe_top_height_2         : std_logic_vector(9 DOWNTO 0);
    SIGNAL pipe_top_height_3         : std_logic_vector(9 DOWNTO 0);

    SIGNAL pipe_bottom_height_1      : std_logic_vector(9 DOWNTO 0);
    SIGNAL pipe_bottom_height_2      : std_logic_vector(9 DOWNTO 0);
    SIGNAL pipe_bottom_height_3      : std_logic_vector(9 DOWNTO 0);

    SIGNAL random_height_1           : std_logic_vector(9 DOWNTO 0);
    SIGNAL random_height_2           : std_logic_vector(9 DOWNTO 0);
    SIGNAL random_height_3           : std_logic_vector(9 DOWNTO 0);

    SIGNAL pipe_on                    : std_logic;

BEGIN

    random_height_1 <= CONV_STD_LOGIC_VECTOR(50 + CONV_INTEGER(lfsr_value(7 DOWNTO 0)), 10);
    random_height_2 <= CONV_STD_LOGIC_VECTOR(50 + CONV_INTEGER(lfsr_value(6 DOWNTO 0) & '0'), 10);
    random_height_3 <= CONV_STD_LOGIC_VECTOR(50 + CONV_INTEGER('0' & lfsr_value(7 DOWNTO 1)), 10);

    pipe_enable <= pipe_on;

    GREEN <= pipe_on;
    RED <= '0';
    BLUE <= '0';

    PROCESS (vert_sync)
    BEGIN
        IF rising_edge(vert_sync) THEN

            pipe_x_pos_1 <= pipe_x_pos_1 - 1;
            pipe_x_pos_2 <= pipe_x_pos_2 - 1;
            pipe_x_pos_3 <= pipe_x_pos_3 - 1;

            IF pipe_x_pos_1 = 0 THEN
                pipe_x_pos_1 <= CONV_STD_LOGIC_VECTOR(640, 10);
                -- number between 50 and 440
                pipe_top_height_1 <= random_height_1;
                pipe_bottom_height_1 <= random_height_1 + CONV_STD_LOGIC_VECTOR(100, 10); -- gap size of 100
            END IF;

            IF pipe_x_pos_2 = 0 THEN
                pipe_x_pos_2 <= CONV_STD_LOGIC_VECTOR(640, 10);
                -- number between 50 and 440
                pipe_top_height_2 <= random_height_2;
                pipe_bottom_height_2 <= random_height_2 + CONV_STD_LOGIC_VECTOR(100, 10); -- gap size of 100
            END IF;

            IF pipe_x_pos_3 = 0 THEN
                pipe_x_pos_3 <= CONV_STD_LOGIC_VECTOR(640, 10);
                -- number between 50 and 440
                pipe_top_height_3 <= random_height_3;
                pipe_bottom_height_3 <= random_height_3 + CONV_STD_LOGIC_VECTOR(100, 10); -- gap size of 100
            END IF;

        END IF; 
    END PROCESS;    

    PROCESS (pixel_row, pixel_column, 
            pipe_x_pos_1, pipe_top_height_1, pipe_bottom_height_1, 
            pipe_x_pos_2, pipe_top_height_2, pipe_bottom_height_2, 
            pipe_x_pos_3, pipe_top_height_3, pipe_bottom_height_3)
    BEGIN
        pipe_on <= '0'; 
        IF (pixel_column >= pipe_x_pos_1 AND pixel_column < pipe_x_pos_1 + 50) THEN -- if within x bounds of pipe
            IF (pixel_row < pipe_top_height_1  OR pixel_row > pipe_bottom_height_1) THEN -- if outside the gap
                pipe_on <= '1';
            END IF;
        END IF;

        IF (pixel_column >= pipe_x_pos_2 AND pixel_column < pipe_x_pos_2 + 50) THEN -- if within x bounds of pipe
            IF (pixel_row < pipe_top_height_2  OR pixel_row > pipe_bottom_height_2) THEN -- if outside the gap
                pipe_on <= '1';
            END IF;
        END IF;

        IF (pixel_column >= pipe_x_pos_3 AND pixel_column < pipe_x_pos_3 + 50) THEN -- if within x bounds of pipe
            IF (pixel_row < pipe_top_height_3  OR pixel_row > pipe_bottom_height_3) THEN -- if outside the gap
                pipe_on <= '1';
            END IF;
        END IF;

    END PROCESS;

END BEHAVIOR;