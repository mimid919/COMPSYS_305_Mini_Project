library IEEE;
use  IEEE.STD_LOGIC_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY top_level IS
	PORT(	CLOCK_50                            : IN STD_LOGIC;
            KEY                                 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            SW                                  : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
            PS2_CLK, PS2_DAT                    : INOUT STD_LOGIC;
            VGA_R, VGA_G, VGA_B                 : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
            VGA_HS, VGA_VS                      : OUT STD_LOGIC;
            HEX0, HEX1, HEX2, HEX3, HEX4, HEX5  : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
            LEDR                                : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
        );
END top_level;

ARCHITECTURE BEHAVIOUR OF TOP_LEVEL IS

    COMPONENT pll is
		port (
			refclk   : in  std_logic := '0'; --  refclk.clk
			rst      : in  std_logic := '0'; --   reset.reset
			outclk_0 : out std_logic;        -- outclk0.clk
			locked   : out std_logic         --  locked.export
		);
	end COMPONENT pll;

    COMPONENT VGA_SYNC IS
	PORT(	clock_25Mhz, red, green, blue		                        	: IN	STD_LOGIC;
			red_out, green_out, blue_out, horiz_sync_out, vert_sync_out	: OUT	STD_LOGIC;
			pixel_row, pixel_column                                     : OUT STD_LOGIC_VECTOR(9 DOWNTO 0));
    END COMPONENT VGA_SYNC;

    COMPONENT MOUSE IS
    PORT(	clock_25Mhz, reset 		    : IN std_logic;
            mouse_data					: INOUT std_logic;
            mouse_clk 					: INOUT std_logic;
            left_button, right_button	: OUT std_logic;
            mouse_cursor_row 			: OUT std_logic_vector(9 DOWNTO 0); 
            mouse_cursor_column 		: OUT std_logic_vector(9 DOWNTO 0));       	
    END COMPONENT MOUSE;

    COMPONENT lfsr IS
    PORT
        ( clk                       : In std_logic;
          reset                     : In std_logic;
          ENABLE                    : In std_logic;
          INITIAL_VALUE             : IN std_logic_vector(7 DOWNTO 0); -- must be non-zero
          lfsr_VALUES                : OUT std_logic_vector(7 DOWNTO 0)
          );
    END COMPONENT lfsr;

    COMPONENT FLAPPY_DOLPHIN IS
    PORT( clk, vert_sync	: IN std_logic;
          pixel_row, pixel_column	: IN std_logic_vector(9 DOWNTO 0);
          left_click 				: IN std_logic;
          fsm_state                 : IN std_logic_vector(1 DOWNTO 0);
		  red, green, blue 			: OUT std_logic;
          dolphin_enable				: OUT std_logic);		
    END COMPONENT FLAPPY_DOLPHIN;

    COMPONENT  PIPES IS
    PORT
        ( CLOCK_25Mhz	            : IN std_logic;
          vert_sync		            : IN std_logic;
          pixel_row, pixel_column	: IN std_logic_vector(9 DOWNTO 0);
          fsm_state                 : IN std_logic_vector(1 DOWNTO 0);
		  red, green, blue 			: OUT std_logic;
          lfsr_value				: IN std_logic_vector(7 DOWNTO 0);
		  pipe_enable				: OUT std_logic;
          pipe_x_1                  : OUT std_logic_vector(9 DOWNTO 0); -- for bait
          pipe_y_1                  : OUT std_logic_vector(9 DOWNTO 0) -- for bait
          );	
    END COMPONENT PIPES;

    COMPONENT bait IS
    PORT(  pixel_row, pixel_column	 : IN std_logic_vector(9 DOWNTO 0);
           fsm_state                 : IN std_logic_vector(1 DOWNTO 0);
           pipe_x_pos_1              : IN std_logic_vector(9 DOWNTO 0);
           gap_height                : IN std_logic_vector(9 DOWNTO 0);
           red, green, blue 		 : OUT std_logic;
           bait_enable               : OUT std_logic);
    END COMPONENT bait; 

    COMPONENT BACKGROUND IS
    PORT
        ( pixel_row, pixel_column	: IN std_logic_vector(9 DOWNTO 0);
		  red, green, blue 			: OUT std_logic;
          fsm_state                 : IN std_logic_vector(1 DOWNTO 0)
          );	
    END COMPONENT BACKGROUND;

    COMPONENT home_display IS
	PORT
		( clk                       : In std_logic;
          pixel_row, pixel_column	: IN std_logic_vector(9 DOWNTO 0);
          FSM_STATE : STD_LOGIC_VECTOR(1 DOWNTO 0);
          red, green, blue 			: OUT std_logic);		
    END COMPONENT home_display;


    COMPONENT text_display IS
	PORT
		( clk                       : In std_logic;
          pixel_row, pixel_column	: IN std_logic_vector(9 DOWNTO 0);
            SW                                  : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		  red, green, blue 			: OUT std_logic);		
    END COMPONENT text_display;

    COMPONENT CHAR_ROM IS
	PORT( character_address	        :	IN STD_LOGIC_VECTOR (5 DOWNTO 0);
		  font_row, font_col	    :	IN STD_LOGIC_VECTOR (2 DOWNTO 0);
		  clock				        : 	IN STD_LOGIC ;
		  rom_mux_output	       	:	OUT STD_LOGIC);
    END COMPONENT CHAR_ROM;

    COMPONENT BCD_to_SevenSeg IS
    PORT( BCD_digit : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
          SevenSeg_out : OUT STD_LOGIC_VECTOR(6 DOWNTO 0));
    END COMPONENT BCD_to_SevenSeg;

    COMPONENT position_to_BCD IS
	PORT
	(
        mouse_row          : IN std_logic_vector(9 DOWNTO 0);
        mouse_column       : IN std_logic_vector(9 DOWNTO 0);
        row_hundreds      : OUT std_logic_vector(3 DOWNTO 0);
        row_tens          : OUT std_logic_vector(3 DOWNTO 0);
        row_ones          : OUT std_logic_vector(3 DOWNTO 0);
        column_hundreds   : OUT std_logic_vector(3 DOWNTO 0);
        column_tens       : OUT std_logic_vector(3 DOWNTO 0);
        column_ones       : OUT std_logic_vector(3 DOWNTO 0)
    );
    END COMPONENT position_to_BCD;

    SIGNAL CLOCK_25MHZ : STD_LOGIC;

    -- VGA signals used in other componants
    SIGNAL PIXEL_ROW, PIXEL_COLUMN  : STD_LOGIC_VECTOR(9 DOWNTO 0); -- pixel being chosen at present
    SIGNAL VERT_SYNC, HORIZ_SYNC    : STD_LOGIC; -- VERT for dolphin, HORIZ for pipe/background movement

    -- mouse component outputs so we can use them as inputs for other components 
    SIGNAL MOUSE_ROW, MOUSE_COLUMN  : STD_LOGIC_VECTOR(9 DOWNTO 0);
    SIGNAL LEFT_CLICK, RIGHT_CLICK  : STD_LOGIC;
    SIGNAL RESET                    : STD_LOGIC; -- KEY[0] is active low

    -- Signals for game components 
    -- MOVE TO ELEMENT LAYERING FILE
    SIGNAL DOLPHIN_RED, DOLPHIN_GREEN, DOLPHIN_BLUE             : STD_LOGIC;
    SIGNAL PIPE_RED, PIPE_GREEN, PIPE_BLUE                      : STD_LOGIC;
    SIGNAL TEXT_RED, TEXT_GREEN, TEXT_BLUE                      : STD_LOGIC;
    SIGNAL BACKGROUND_RED, BACKGROUND_GREEN, BACKGROUND_BLUE    : STD_LOGIC;
    SIGNAL BAIT_RED, BAIT_GREEN, BAIT_BLUE                      : STD_LOGIC;

    -- final colour outputs to VGA
    SIGNAL RED_OUT, GREEN_OUT, BLUE_OUT : STD_LOGIC; 

    SIGNAL RANDOM_VALUE : STD_LOGIC_VECTOR(7 DOWNTO 0); -- output from LFSR to connect to pipes for random pipe heights

    SIGNAL COUNT_VALUE : STD_LOGIC_VECTOR(3 DOWNTO 0); -- output from click counter to connect to HEX display

    SIGNAL row_hundreds, row_tens, row_ones : STD_LOGIC_VECTOR(3 DOWNTO 0); -- output from position_to_BCD for mouse row
    SIGNAL column_hundreds, column_tens, column_ones : STD_LOGIC_VECTOR(3 DOWNTO 0); -- output from position_to_BCD for mouse column

    SIGNAL FSM_STATE : STD_LOGIC_VECTOR(1 DOWNTO 0); -- for controlling background colour and game state

    -- bait pipe position wires
    SIGNAL bait_pipe_x                  : std_logic_vector(9 DOWNTO 0);
    SIGNAL bait_pipe_y                  : std_logic_vector(9 DOWNTO 0);
BEGIN

--TO BE MOVED OR DELETED {
    
    -- Output selected in layer (priority) order: text, dolphin, pipe, background
    -- MOVE TO ELEMENT LAYERING FILE
    RED_OUT     <= TEXT_RED OR DOLPHIN_RED OR BAIT_RED OR PIPE_RED OR BACKGROUND_RED;
    GREEN_OUT   <= TEXT_GREEN OR DOLPHIN_GREEN OR BAIT_GREEN OR PIPE_GREEN OR BACKGROUND_GREEN;
    BLUE_OUT    <= TEXT_BLUE OR DOLPHIN_BLUE OR BAIT_BLUE OR PIPE_BLUE OR BACKGROUND_BLUE;

    -- REPLACE WITH FSM CONTROLLING GAME STATE
    FSM_STATE <= "10" when SW(1) = '1' else -- end screen
                 "00" when SW(0) = '0' else -- start screen
                 "01" when SW(0) = '1' else -- game screen
                 "00"; -- default to start screen if no switches on

    -- DELETE WHEN ADDING MORE COLOURS
    VGA_R(2 DOWNTO 0) <= "000";
    VGA_G(2 DOWNTO 0) <= "000";
    VGA_B(2 DOWNTO 0) <= "000";

    
    -- set pipe, text and background colours to 0 temporarily
    --PIPE_RED <= '0';            PIPE_GREEN <= '0';          PIPE_BLUE <= '0';
    --TEXT_RED <= '0';            TEXT_GREEN <= '0';          TEXT_BLUE <= '0';
    --BACKGROUND_RED <= '0';      BACKGROUND_GREEN <= '0';    BACKGROUND_BLUE <= '0';


    -- MOVE TO NEW FILE OR DELETE IF NOT USING
	 LEDR(1) <= '0';
	 LEDR(0) <= RIGHT_CLICK;
	 LEDR(2) <= '0';
	 LEDR(3) <= '0';
     LEDR(4) <= '0';
	 LEDR(5) <= '0';
     LEDR(6) <= '1';
	 LEDR(7) <= '1';

--}

    -- Connect VGA sync signals to output, could VGA_HS/VS go straight in instance?
    VGA_HS <= HORIZ_SYNC;
    VGA_VS <= VERT_SYNC;

    RESET <= NOT KEY(0); -- active low reset

    -- Divide 50MHz clock to get 25MHz clock for VGA
    clock_divider : pll port map  (
			refclk   => CLOCK_50,
			rst      =>  '0',--   reset.reset
			outclk_0 =>    CLOCK_25MHZ,     -- outclk0.clk
			locked   =>      OPEN     --  locked.export
		);

    VGA_REFRESH: VGA_SYNC PORT MAP (
        clock_25Mhz => CLOCK_25MHZ,
        red => RED_OUT,
        green => GREEN_OUT,
        blue => BLUE_OUT,
        red_out => VGA_R(3), -- MSB
        green_out => VGA_G(3),
        blue_out => VGA_B(3),
        horiz_sync_out => HORIZ_SYNC,
        vert_sync_out => VERT_SYNC,
        pixel_row => PIXEL_ROW,
        pixel_column => PIXEL_COLUMN
    );

    MOUSE_CONTROLS: MOUSE PORT MAP (
        clock_25Mhz => CLOCK_25MHZ,
        reset => RESET,
        mouse_data => PS2_DAT,
        mouse_clk => PS2_CLK,
        left_button => LEFT_CLICK,
        right_button => RIGHT_CLICK,
        mouse_cursor_row => MOUSE_ROW,
        mouse_cursor_column => MOUSE_COLUMN
    );

    RANDOM_NUMBER: lfsr PORT MAP (
        clk => CLOCK_25MHZ,
        reset => RESET,
        ENABLE => '1', -- always enabled for now, but could connect to game state
        INITIAL_VALUE => "10101010", -- must be non-zero
        lfsr_VALUES => RANDOM_VALUE
    );

    PLAYER_CHARACTER: FLAPPY_DOLPHIN PORT MAP (
        clk => CLOCK_25MHZ,
        vert_sync => VERT_SYNC,
        pixel_row => PIXEL_ROW,
        pixel_column => PIXEL_COLUMN,
        left_click => LEFT_CLICK,
        fsm_state => FSM_STATE,
        red => DOLPHIN_RED,
        green => DOLPHIN_GREEN,
        blue => DOLPHIN_BLUE,
        DOLPHIN_ENABLE => OPEN -- not using for now, but will need to connect to collision counter when we add pipes
    );

    PIPE_DISPLAY: PIPES PORT MAP (
        CLOCK_25Mhz => CLOCK_25MHZ,
        vert_sync => VERT_SYNC,
        pixel_row => PIXEL_ROW,
        pixel_column => PIXEL_COLUMN,
        fsm_state => FSM_STATE,
        red => PIPE_RED,
        green => PIPE_GREEN,
        blue => PIPE_BLUE,
        lfsr_value => RANDOM_VALUE,
        pipe_enable => OPEN,
        pipe_x_1 => bait_pipe_x,
        pipe_y_1 => bait_pipe_y
    );

    RANDOM_BAIT: bait PORT MAP (
        pixel_row => PIXEL_ROW,
        pixel_column => PIXEL_COLUMN,
        fsm_state => FSM_STATE,
        pipe_x_pos_1 => bait_pipe_x,
        gap_height => bait_pipe_y,
        red => BAIT_RED,
        green => BAIT_GREEN,
        blue => BAIT_BLUE,
        bait_enable => OPEN
    );

    BG: BACKGROUND PORT MAP (
        pixel_row => PIXEL_ROW,
        pixel_column => PIXEL_COLUMN,
        red => BACKGROUND_RED,
        green => BACKGROUND_GREEN,
        blue => BACKGROUND_BLUE,
        fsm_state => FSM_STATE
    );

    HOME_SCREEN_TEXT: home_display PORT MAP (
        clk => CLOCK_25MHZ,
        pixel_row => PIXEL_ROW,
        pixel_column => PIXEL_COLUMN,
        FSM_STATE => FSM_STATE,
        red => TEXT_RED,
        green => TEXT_GREEN,
        blue => TEXT_BLUE
    );


--     TXT: text_display PORT MAP (
--     clk => CLOCK_25MHZ,
--     pixel_row => PIXEL_ROW,
--     pixel_column => PIXEL_COLUMN,
--     SW  =>   SW,
--     red => TEXT_RED,
--     green => TEXT_GREEN,
--     blue => TEXT_BLUE
-- );

    sevenseg_display : position_to_BCD PORT MAP (
        mouse_row => MOUSE_ROW,
        mouse_column => MOUSE_COLUMN,
        row_hundreds => row_hundreds,
        row_tens => row_tens,
        row_ones => row_ones,
        column_hundreds => column_hundreds,
        column_tens => column_tens,
        column_ones => column_ones
    );

    -- mouse coordinate hex instances
    RH : BCD_to_SevenSeg PORT MAP (
        BCD_digit => row_hundreds,
        SevenSeg_out => HEX5
    );
    RT : BCD_to_SevenSeg PORT MAP (
        BCD_digit => row_tens,
        SevenSeg_out => HEX4
    );
    RO : BCD_to_SevenSeg PORT MAP (
        BCD_digit => row_ones,
        SevenSeg_out => HEX3
    );
    CH : BCD_to_SevenSeg PORT MAP (
        BCD_digit => column_hundreds,
        SevenSeg_out => HEX2
    );
    CT : BCD_to_SevenSeg PORT MAP (
        BCD_digit => column_tens,
        SevenSeg_out => HEX1
    );
    CO : BCD_to_SevenSeg PORT MAP (
        BCD_digit => column_ones,
        SevenSeg_out => HEX0
    );

END BEHAVIOUR;