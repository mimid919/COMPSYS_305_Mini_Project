library IEEE;
use  IEEE.STD_LOGIC_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY top_level IS
	PORT(	CLOCK_50                            	: IN STD_LOGIC;
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

    -- flappy_dolphin needs a lot of work
    -- need to link mouse clicks to dolphin movement, and add pipes and scoring
    -- also should simulate gravity
    COMPONENT FLAPPY_DOLPHIN IS
    PORT( pb1, pb2, clk, vert_sync	: IN std_logic;
          pixel_row, pixel_column	: IN std_logic_vector(9 DOWNTO 0);
          mouse_row, mouse_column   : IN std_logic_vector(9 DOWNTO 0);
          left_click 				: IN std_logic;
		  red, green, blue 			: OUT std_logic);		
    END COMPONENT FLAPPY_DOLPHIN;

    COMPONENT CHAR_ROM IS
	PORT( character_address	        :	IN STD_LOGIC_VECTOR (5 DOWNTO 0);
		  font_row, font_col	    :	IN STD_LOGIC_VECTOR (2 DOWNTO 0);
		  clock				        : 	IN STD_LOGIC ;
		  rom_mux_output	       	:	OUT STD_LOGIC);
    END COMPONENT CHAR_ROM;

    COMPONENT click_counter IS
    PORT( clk         : IN std_logic;
        reset       : IN std_logic;
        left_click  : IN std_logic;
        count       : OUT std_logic_vector(3 DOWNTO 0));
    END COMPONENT click_counter;

    COMPONENT BCD_to_SevenSeg IS
    PORT( BCD_digit : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
          SevenSeg_out : OUT STD_LOGIC_VECTOR(6 DOWNTO 0));
    END COMPONENT BCD_to_SevenSeg;

    SIGNAL CLOCK_25MHZ : STD_LOGIC;

    -- VGA signals used in other componants
    SIGNAL PIXEL_ROW, PIXEL_COLUMN  : STD_LOGIC_VECTOR(9 DOWNTO 0); -- pixel being chosen at present
    SIGNAL VERT_SYNC, HORIZ_SYNC    : STD_LOGIC; -- VERT for dolphin, HORIZ for pipe/background movement

    -- mouse component outputs so we can use them as inputs for other components 
    SIGNAL MOUSE_ROW, MOUSE_COLUMN  : STD_LOGIC_VECTOR(9 DOWNTO 0);
    SIGNAL LEFT_CLICK, RIGHT_CLICK  : STD_LOGIC;
    SIGNAL RESET                    : STD_LOGIC; -- KEY[0] is active low

    -- Signals for game components
    SIGNAL DOLPHIN_RED, DOLPHIN_GREEN, DOLPHIN_BLUE             : STD_LOGIC;
    SIGNAL PIPE_RED, PIPE_GREEN, PIPE_BLUE                      : STD_LOGIC;
    SIGNAL TEXT_RED, TEXT_GREEN, TEXT_BLUE                      : STD_LOGIC;
    SIGNAL BACKGROUND_RED, BACKGROUND_GREEN, BACKGROUND_BLUE    : STD_LOGIC;

    -- final colour outputs to VGA
    SIGNAL RED_OUT, GREEN_OUT, BLUE_OUT : STD_LOGIC; 

    SIGNAL COUNT_VALUE : STD_LOGIC_VECTOR(3 DOWNTO 0); -- output from click counter to connect to HEX display


BEGIN

    -- Output selected in layer (priority) order: text, dolphin, pipe, background
    RED_OUT <= TEXT_RED OR DOLPHIN_RED OR PIPE_RED OR BACKGROUND_RED;
    GREEN_OUT <= TEXT_GREEN OR DOLPHIN_GREEN OR PIPE_GREEN OR BACKGROUND_GREEN;
    BLUE_OUT <= TEXT_BLUE OR DOLPHIN_BLUE OR PIPE_BLUE OR BACKGROUND_BLUE;

    -- Set unused bits to 0 for VGA output
    VGA_R(2 DOWNTO 0) <= "000";
    VGA_G(2 DOWNTO 0) <= "000";
    VGA_B(2 DOWNTO 0) <= "000";

    -- Connect VGA sync signals to output
    VGA_HS <= HORIZ_SYNC;
    VGA_VS <= VERT_SYNC;

    -- set pipe, text and background colours to 0 temporarily
    PIPE_RED <= '0';            PIPE_GREEN <= '0';          PIPE_BLUE <= '0';
    TEXT_RED <= '0';            TEXT_GREEN <= '0';          TEXT_BLUE <= '0';
    BACKGROUND_RED <= '0';      BACKGROUND_GREEN <= '0';    BACKGROUND_BLUE <= '0';

    -- Set HEX displays to 0 temporarily
    --HEX0 <= (OTHERS => '1');
    HEX1 <= (OTHERS => '1');
    HEX2 <= (OTHERS => '1');
    HEX3 <= (OTHERS => '1');
    HEX4 <= (OTHERS => '1');
    HEX5 <= (OTHERS => '1');

    RESET <= NOT KEY(0); -- active low reset

    -- Divide 50MHz clock to get 25MHz clock for VGA
    clock_divider : pll port map  (
			refclk   => CLOCK_50,
			rst      =>  '0',--   reset.reset
			outclk_0 =>    CLOCK_25MHZ,     -- outclk0.clk
			locked   =>      OPEN     --  locked.export
		);

    VS: VGA_SYNC PORT MAP (
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

    M: MOUSE PORT MAP (
        clock_25Mhz => CLOCK_25MHZ,
        reset => RESET,
        mouse_data => PS2_DAT,
        mouse_clk => PS2_CLK,
        left_button => LEFT_CLICK,
        right_button => RIGHT_CLICK,
        mouse_cursor_row => MOUSE_ROW,
        mouse_cursor_column => MOUSE_COLUMN
    );

    FD: FLAPPY_DOLPHIN PORT MAP (
        pb1 => KEY(1),
        pb2 => KEY(2),
        clk => CLOCK_25MHZ,
        vert_sync => VERT_SYNC,
        pixel_row => PIXEL_ROW,
        pixel_column => PIXEL_COLUMN,
        mouse_row => MOUSE_ROW,
        mouse_column => MOUSE_COLUMN,
        left_click => LEFT_CLICK,
        red => DOLPHIN_RED,
        green => DOLPHIN_GREEN,
        blue => DOLPHIN_BLUE
    );

    --based of lecture schematic
--    START: CHAR_ROM PORT MAP (
--        character_address => PIXEL_COLUMN(9 DOWNTO 4) & PIXEL_ROW(9 DOWNTO 4), -- top 6 bits of column and row for character address
--        font_row => PIXEL_ROW(3 DOWNTO 1),
--        font_col => PIXEL_COLUMN(3 DOWNTO 1),
--        clock => CLOCK_25MHZ,
--        rom_mux_output => TEXT_RED -- just outputting to red for now, will need to change for text
--    );

    click_display: click_counter PORT MAP (
        clk => CLOCK_25MHZ,
        reset => RESET,
        left_click => LEFT_CLICK,
        count => COUNT_VALUE -- not outputting to anything for now, will need to connect to HEX display
    );

    sevenseg: BCD_to_SevenSeg PORT MAP (
        BCD_digit => COUNT_VALUE,
        SevenSeg_out => HEX0
    );


	 LEDR(1) <= LEFT_CLICK;
	 LEDR(0) <= RIGHT_CLICK;
	 LEDR(2) <= '0';
	 LEDR(3) <= '0';
    LEDR(4) <= '0';
	 LEDR(5) <= '0';
    LEDR(6) <= '1';
	 LEDR(7) <= '1';

END BEHAVIOUR;