LIBRARY IEEE;
USE  IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;

-- Creates bait between every third pipe during state '01'
-- Visibility is randomised so bait does not appear in a pattern (randomisation needs work) 
-- Uses gap_height of pipe_1 to determine bait height
-- Uses x position of pipe_1 to determine horizontal movement
-- bait_enable outputs '1' if bait is visible so this can be used for collisions

ENTITY bait IS
   PORT(  clk                       : IN std_logic;
          pixel_row, pixel_column	: IN std_logic_vector(9 DOWNTO 0);
		  Game_state_signal         : IN std_logic_vector(1 DOWNTO 0);   -- fsm
          dolphin_enable            : IN std_logic;
          pipe_x_pos_1              : IN std_logic_vector(9 DOWNTO 0);
          gap_height                : IN std_logic_vector(9 DOWNTO 0);
		  red, green, blue 			: OUT std_logic_vector(3 DOWNTO 0);
          bait_on                   : OUT std_logic;
          bait_enable               : OUT std_logic);
END bait; 

ARCHITECTURE behaviour OF bait IS

    COMPONENT bait_rom IS
        PORT (
            address : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            clock   : IN STD_LOGIC;
            q       : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
        );
    END COMPONENT;

    CONSTANT BAIT_W : INTEGER := 16;
    CONSTANT BAIT_H : INTEGER := 16;

    SIGNAL state            : std_logic;
    SIGNAL bait_x_pos       : std_logic_vector(9 DOWNTO 0);
    SIGNAL bait_y_pos       : std_logic_vector(9 DOWNTO 0);
    SIGNAL randomiser       : std_logic;
    SIGNAL bait_raw_visible : std_logic;
    SIGNAL bait_visible     : std_logic;
    SIGNAL bait_eaten       : std_logic := '0';
    SIGNAL pipe_x_pos_prev  : std_logic_vector(9 DOWNTO 0) := (OTHERS => '0');

    SIGNAL bait_address     : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL bait_pixel       : STD_LOGIC_VECTOR(11 DOWNTO 0);

BEGIN

    BAIT_IMAGE : bait_rom
    PORT MAP (
        address => bait_address,
        clock   => clk,
        q       => bait_pixel
    );

    state <= '1' when (Game_state_signal = "01" or Game_state_signal = "10") else '0';

    randomiser <= gap_height(0);

    bait_x_pos <= pipe_x_pos_1 + CONV_STD_LOGIC_VECTOR(25, 10);
    bait_y_pos <= gap_height + CONV_STD_LOGIC_VECTOR(100, 10);

    bait_enable <= bait_visible;
    bait_on <= bait_visible;

    PROCESS(clk)
    BEGIN
        IF rising_edge(clk) THEN
            pipe_x_pos_prev <= pipe_x_pos_1;

            IF Game_state_signal = "00" THEN
                bait_eaten <= '0';

            ELSIF state = '1' THEN
                IF pipe_x_pos_1 > pipe_x_pos_prev THEN
                    bait_eaten <= '0';

                ELSIF bait_raw_visible = '1' AND dolphin_enable = '1' THEN
                    bait_eaten <= '1';
                END IF;
            END IF;
        END IF;
    END PROCESS;

    PROCESS(pixel_row, pixel_column, state, randomiser, bait_eaten, bait_x_pos, bait_y_pos, bait_pixel)
        VARIABLE row_i   : INTEGER;
        VARIABLE col_i   : INTEGER;
        VARIABLE local_x : INTEGER;
        VARIABLE local_y : INTEGER;
    BEGIN
        row_i := CONV_INTEGER(pixel_row);
        col_i := CONV_INTEGER(pixel_column);

        red <= "0000";
        green <= "0000";
        blue <= "0000";
        bait_raw_visible <= '0';
        bait_visible <= '0';
        bait_address <= (OTHERS => '0');

        IF state = '1' AND randomiser = '1' AND bait_eaten = '0' THEN

            IF col_i >= CONV_INTEGER(bait_x_pos) AND
               col_i <  CONV_INTEGER(bait_x_pos) + BAIT_W AND
               row_i >= CONV_INTEGER(bait_y_pos) AND
               row_i <  CONV_INTEGER(bait_y_pos) + BAIT_H THEN

                local_x := col_i - CONV_INTEGER(bait_x_pos);
                local_y := row_i - CONV_INTEGER(bait_y_pos);

                bait_address <= CONV_STD_LOGIC_VECTOR(local_y * BAIT_W + local_x, 8);

                IF bait_pixel /= X"F0F" THEN
                    bait_raw_visible <= '1';
                    bait_visible <= '1';

                    red   <= bait_pixel(11 DOWNTO 8);
                    green <= bait_pixel(7 DOWNTO 4);
                    blue  <= bait_pixel(3 DOWNTO 0);
                END IF;

            END IF;
        END IF;
    END PROCESS;

END behaviour;