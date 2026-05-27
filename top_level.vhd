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
------------------------------------ COMPONENT DECLARATION START ------------------------------------
    COMPONENT BACKGROUND IS
    PORT
        (pixel_row, pixel_column	: IN std_logic_vector(9 DOWNTO 0);
                Win                     : IN STD_LOGIC;  -- logic high
                Termination             : IN STD_LOGIC;  -- logic high
                Pause_OUT               : IN STD_LOGIC;  -- logic high
                Game_state_signal       : IN std_logic_vector(1 DOWNTO 0);
                clock                   : IN STD_LOGIC;
                red, green, blue 	    : OUT std_logic_vector(3 DOWNTO 0)
        );
    END COMPONENT BACKGROUND;

    COMPONENT BAIT IS
    PORT
        ( clk                    : IN std_logic;
        pixel_row, pixel_column : IN std_logic_vector(9 DOWNTO 0);
        Game_state_signal               : IN std_logic_vector(1 DOWNTO 0);
        dolphin_enable          : IN std_logic;
        pipe_x_pos_1           : IN std_logic_vector(9 DOWNTO 0);
        gap_height             : IN std_logic_vector(9 DOWNTO 0);
        red, green, blue       : OUT std_logic_vector(3 DOWNTO 0);
        bait_on                : OUT std_logic;
        bait_enable           : OUT std_logic
        );
    END COMPONENT BAIT;

    COMPONENT BCD_TO_SEVENSEG IS
    PORT
        ( BCD_digit     : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        SevenSeg_out  : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
        );
    END COMPONENT BCD_TO_SEVENSEG;

    COMPONENT CHAR_ROM IS
    PORT
        ( character_address : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
        font_row         : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
        font_col         : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
        clock            : IN STD_LOGIC;
        rom_mux_output   : OUT STD_LOGIC
        );
    END COMPONENT CHAR_ROM;

    COMPONENT dolphin_visual IS
    PORT (
        clk                     : IN std_logic;
        pixel_row, pixel_column : IN std_logic_vector(9 DOWNTO 0);
        dolphin_x_pos           : IN std_logic_vector(9 DOWNTO 0);
        dolphin_y_pos           : IN std_logic_vector(9 DOWNTO 0);
		Game_state_signal       : IN std_logic_vector(1 DOWNTO 0);
        red, green, blue        : OUT std_logic_vector(3 DOWNTO 0);
        dolphin_on              : OUT std_logic
    );
    END COMPONENT dolphin_visual;

    COMPONENT DOLPHIN_MOVEMENT IS -- HOW IS THIS WORKING WITHOUT RGB IN DECLARATION (RGB ARE OUTPUTS IN ENTITY)
    PORT
        ( clk, vert_sync            : IN std_logic;
          pixel_row, pixel_column   : IN std_logic_vector(9 DOWNTO 0);
          left_click                : IN std_logic;
          Game_state_signal         : IN std_logic_vector(1 DOWNTO 0);

          dolphin_x_pos_out         : OUT std_logic_vector(9 DOWNTO 0);
          dolphin_y_pos_out         : OUT std_logic_vector(9 DOWNTO 0);
          dolphin_on                : OUT std_logic;
          dolphin_enable            : OUT std_logic;
          first_click_out           : OUT std_logic;
          hit_ground                : OUT std_logic
        );  
    END COMPONENT DOLPHIN_MOVEMENT;

    COMPONENT FSM IS
    PORT (
            CLK              : in STD_LOGIC;
            Reset            : in STD_LOGIC;   -- key[0]
            Start            : in STD_LOGIC;   -- key[3]
            Pause_IN         : in STD_LOGIC;   -- SW[9]  cant be a push button because need a permanent state
            Mode             : in STD_LOGIC;   -- SW[0], user selects either TRAINING OR GAME
            Life             : in STD_LOGIC;   -- logic high
            Timer            : in STD_LOGIC;   -- SW[1] NEEDS CHANGING TO USE AN ACTUAL TIMER
           
            Win              : out STD_LOGIC;  -- logic high
            Termination      : out STD_LOGIC;  -- logic high
            Pause_OUT        : out STD_LOGIC;  -- logic high
            Game_State       : out STD_LOGIC_VECTOR(1 downto 0)        
        );
    END COMPONENT FSM;

    COMPONENT GAME_WON_TEXT IS
        PORT
            ( clk                   : IN std_logic;
            pixel_row, pixel_column : IN std_logic_vector(9 DOWNTO 0);
            Win                     : IN std_logic;
            red, green, blue        : OUT std_logic_vector(3 DOWNTO 0)
            );
    END COMPONENT GAME_WON_TEXT;

    COMPONENT GAME_OVER_TEXT IS
        PORT
            ( clk                   : IN std_logic;
            pixel_row, pixel_column : IN std_logic_vector(9 DOWNTO 0);
            Win                     : IN std_logic;
            termination             : IN  std_logic;
            red, green, blue        : OUT std_logic_vector(3 DOWNTO 0)
            );
    END COMPONENT GAME_OVER_TEXT;

    COMPONENT HOME_DISPLAY_TEXT IS
    PORT
        ( clk                 : IN std_logic;
        pixel_row, pixel_column : IN std_logic_vector(9 DOWNTO 0);
        Game_state_signal           : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        red, green, blue    : OUT std_logic_vector(3 DOWNTO 0)
        );
    END COMPONENT HOME_DISPLAY_TEXT;

    COMPONENT LAYER IS
    PORT
       (    clk : IN STD_LOGIC;
            Win                     : IN STD_LOGIC;  -- logic high
            Termination             : IN STD_LOGIC;  -- logic high
            Pause_OUT               : IN STD_LOGIC;  -- logic high
            Game_state_signal       : IN std_logic_vector(1 DOWNTO 0);

        
            BACKGROUND_RED,BACKGROUND_GREEN,BACKGROUND_BLUE    : in std_logic_vector(3 downto 0);
            PIPE_RED,PIPE_GREEN, PIPE_BLUE  				: in std_logic_vector(3 DOWNTO 0);
            PIPE_ON                            			    : IN STD_LOGIC;
            BAIT_RED,BAIT_GREEN,BAIT_BLUE   				: in std_logic_vector(3 DOWNTO 0);
            BAIT_ON                         				: IN STD_LOGIC;
            SPRITE_RED, SPRITE_GREEN, SPRITE_BLUE 		    : IN std_logic_vector(3 DOWNTO 0);
            SPRITE_ON 										: IN std_logic;
            LIVES_RED,LIVES_GREEN,LIVES_BLUE				: in std_logic_vector(3 DOWNTO 0);
            LIVES_ON                        				: IN STD_LOGIC;
            SCORE_RED,SCORE_GREEN,SCORE_BLUE				: in std_logic_vector(3 DOWNTO 0);
            SCORE_ON                        				: IN STD_LOGIC;
            HOME_DISPLAY_TEXT_RED,HOME_DISPLAY_TEXT_GREEN,HOME_DISPLAY_TEXT_BLUE   				: in std_logic_vector(3 DOWNTO 0);
            GAME_WON_TEXT_RED, GAME_WON_TEXT_GREEN, GAME_WON_TEXT_BLUE :   IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            GAME_OVER_TEXT_RED, GAME_OVER_TEXT_GREEN, GAME_OVER_TEXT_BLUE : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            RED_OUT,GREEN_OUT,BLUE_OUT                      : OUT STD_LOGIC_vector(3 DOWNTO 0)
            );
    END COMPONENT LAYER;

    COMPONENT LFSR IS
    PORT
        ( clk              : IN std_logic;
        reset            : IN std_logic;
        ENABLE           : IN std_logic;
        INITIAL_VALUE    : IN std_logic_vector(7 DOWNTO 0);
        lfsr_VALUES      : OUT std_logic_vector(7 DOWNTO 0)
        );
    END COMPONENT LFSR;

    COMPONENT LIVES IS
    PORT
        ( clk                       : IN std_logic;
        pixel_row, pixel_column   : IN std_logic_vector(9 DOWNTO 0);
        Game_state_signal                 : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        life_one, life_two, life_three : IN STD_LOGIC;
        red, green, blue         : OUT std_logic_vector(3 DOWNTO 0);
        live_on                  : OUT std_logic
        );
    END COMPONENT LIVES;

    COMPONENT MOUSE IS
    PORT
        ( clock_25Mhz, reset       : IN std_logic;
        mouse_data              : INOUT std_logic;
        mouse_clk               : INOUT std_logic;
        left_button, right_button : OUT std_logic;
        mouse_cursor_row        : OUT std_logic_vector(9 DOWNTO 0);
        mouse_cursor_column     : OUT std_logic_vector(9 DOWNTO 0)
        );
    END COMPONENT MOUSE;

    COMPONENT PIPES IS
    PORT
        ( CLOCK_25Mhz	            : IN std_logic;
        vert_sync		            : IN std_logic;
        pixel_row, pixel_column	    : IN std_logic_vector(9 DOWNTO 0);
        lfsr_value				    : IN std_logic_vector(7 DOWNTO 0);
        Game_state_signal           : IN std_logic_vector(1 DOWNTO 0);
        pipe_speed_up               : IN std_logic;
        first_click                 : IN std_logic; 

        pipe_on                     : OUT std_logic;
        pipe_enable				    : OUT std_logic;
        pipe_passed                 : OUT std_logic;
        pipe_x_1                    : OUT std_logic_vector(9 DOWNTO 0); -- for bait
        pipe_y_1                    : OUT std_logic_vector(9 DOWNTO 0); -- for bait
        red, green, blue 			: OUT std_logic_vector(3 DOWNTO 0)
        );	
    END COMPONENT PIPES;

    COMPONENT PLL IS
    PORT
        ( refclk   : IN std_logic := '0';
        rst      : IN std_logic := '0';
        outclk_0 : OUT std_logic;
        locked   : OUT std_logic
        );
    END COMPONENT PLL;

    COMPONENT POSITION_TO_BCD IS
    PORT
        ( mouse_row        : IN std_logic_vector(9 DOWNTO 0);
        mouse_column     : IN std_logic_vector(9 DOWNTO 0);
        row_hundreds     : OUT std_logic_vector(3 DOWNTO 0);
        row_tens         : OUT std_logic_vector(3 DOWNTO 0);
        row_ones         : OUT std_logic_vector(3 DOWNTO 0);
        column_hundreds  : OUT std_logic_vector(3 DOWNTO 0);
        column_tens      : OUT std_logic_vector(3 DOWNTO 0);
        column_ones      : OUT std_logic_vector(3 DOWNTO 0)
        );
    END COMPONENT POSITION_TO_BCD;

    COMPONENT GAME_LOGIC IS
    PORT (
        clk                 : IN  STD_LOGIC;  
        vert_sync           : IN  STD_LOGIC;
        reset               : IN  STD_LOGIC;
        Game_state_signal   : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
        dolphin_enable      : IN  STD_LOGIC;
        pipe_enable         : IN  STD_LOGIC;
        bait_enable         : IN  STD_LOGIC;
        pipe_passed         : IN  STD_LOGIC;
        hit_ground          : IN  STD_LOGIC;   -- from dolphin movement, high when dolphin touches ground
        life_one            : OUT STD_LOGIC;
        life_two            : OUT STD_LOGIC;
        life_three          : OUT STD_LOGIC;
        dolphin_IS_alive            : OUT STD_LOGIC;
        timer_out           : OUT STD_LOGIC;
        pipe_speed_up       : OUT STD_LOGIC;
        score_ones          : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        score_tens          : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
    );
END COMPONENT GAME_LOGIC;

    COMPONENT SCORE_TEXT IS
    PORT
        ( clk                   : IN std_logic;
        pixel_row, pixel_column : IN std_logic_vector(9 DOWNTO 0);
        Game_state_signal       : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        score_ones              : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        score_tens              : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        red, green, blue        : OUT std_logic_vector(3 DOWNTO 0);
        score_on                : OUT std_logic
        );
    END COMPONENT SCORE_TEXT;

    COMPONENT VGA_SYNC IS
    PORT(	clock_25Mhz		: IN	STD_LOGIC;
			red, green, blue : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			red_out, green_out, blue_out : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
			horiz_sync_out, vert_sync_out	: OUT	STD_LOGIC;
			pixel_row, pixel_column: OUT STD_LOGIC_VECTOR(9 DOWNTO 0));
    END COMPONENT VGA_SYNC;
------------------------------------ COMPONENT DECLARATION START ------------------------------------




    SIGNAL CLOCK_25MHZ : STD_LOGIC;

    ----    FSM SIGNALS ouputs ---
    SIGNAL Life_signal              : STD_LOGIC := '1';
    SIGNAL Win_signal               : STD_LOGIC;
    SIGNAL Termination_signal       : STD_LOGIC := '0';
    SIGNAL Pause_out_signal         : STD_LOGIC := '0';
    SIGNAL Game_state_signal        : STD_LOGIC_VECTOR(1 downto 0) := "00";  -- used to be called "Game_state_signal"
    
    -- test it by using a switch so we can actually see the game won page
    -- SIGNAL win_signal : std_logic;
    --SIGNAL game_over_test : std_logic;


    -- VGA signals used in other componants
    SIGNAL PIXEL_ROW, PIXEL_COLUMN  : STD_LOGIC_VECTOR(9 DOWNTO 0); -- pixel being chosen at present
    SIGNAL VERT_SYNC, HORIZ_SYNC    : STD_LOGIC; -- VERT for dolphin, HORIZ for pipe/background movement

    -- mouse component outputs so we can use them as inputs for other components 
    SIGNAL MOUSE_ROW, MOUSE_COLUMN  : STD_LOGIC_VECTOR(9 DOWNTO 0);
    SIGNAL LEFT_CLICK, RIGHT_CLICK  : STD_LOGIC;
    SIGNAL RESET                    : STD_LOGIC; -- KEY[0] is active low

    -- Signals for game components 
    -- MOVE TO ELEMENT LAYERING FILE
    SIGNAL DOLPHIN_RED, DOLPHIN_GREEN, DOLPHIN_BLUE : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL DOLPHIN_ON          : STD_LOGIC;
    SIGNAL PIPE_RED, PIPE_GREEN, PIPE_BLUE: STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL PIPE_ON : STD_LOGIC;
    SIGNAL HOME_DISPLAY_TEXT_RED, HOME_DISPLAY_TEXT_GREEN, HOME_DISPLAY_TEXT_BLUE : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL GAME_WON_TEXT_RED, GAME_WON_TEXT_GREEN, GAME_WON_TEXT_BLUE : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL GAME_OVER_TEXT_RED, GAME_OVER_TEXT_GREEN, GAME_OVER_TEXT_BLUE : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL TEXT_ON                                              : std_logic;
    SIGNAL BACKGROUND_RED, BACKGROUND_GREEN, BACKGROUND_BLUE: STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL BAIT_RED, BAIT_GREEN, BAIT_BLUE  : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL LIVES_RED, LIVES_GREEN, LIVES_BLUE   : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL LIVES_ON                                              : STD_LOGIC;
    SIGNAL SCORE_RED, SCORE_GREEN, SCORE_BLUE   : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL SCORE_ON                                              : STD_LOGIC;

    -- final colour outputs to VGA
    SIGNAL RED_OUT, GREEN_OUT, BLUE_OUT : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL VGA_R_temp, VGA_G_temp, VGA_B_temp : STD_LOGIC_VECTOR(3 DOWNTO 0);

    SIGNAL RANDOM_VALUE : STD_LOGIC_VECTOR(7 DOWNTO 0); -- output from LFSR to connect to pipes for random pipe heights

    SIGNAL COUNT_VALUE : STD_LOGIC_VECTOR(3 DOWNTO 0); -- output from click counter to connect to HEX display

    SIGNAL row_hundreds, row_tens, row_ones : STD_LOGIC_VECTOR(3 DOWNTO 0); -- output from position_to_BCD for mouse row
    SIGNAL column_hundreds, column_tens, column_ones : STD_LOGIC_VECTOR(3 DOWNTO 0); -- output from position_to_BCD for mouse column


    -- bait pipe position wires
    SIGNAL BAIT_ON                     : std_logic;
    SIGNAL bait_pipe_x                  : std_logic_vector(9 DOWNTO 0);
    SIGNAL bait_pipe_y                  : std_logic_vector(9 DOWNTO 0);
    
    -- DOLPHIN SPRITE
    SIGNAL SPRITE_ON : STD_LOGIC;
    SIGNAL DOLPHIN_X_POS : std_logic_vector(9 downto 0);
    SIGNAL DOLPHIN_Y_POS : std_logic_vector(9 downto 0);
    SIGNAL SPRITE_RED : std_logic_vector(3 DOWNTO 0);
    SIGNAL SPRITE_GREEN : std_logic_vector(3 DOWNTO 0);
    SIGNAL SPRITE_BLUE : std_logic_vector(3 DOWNTO 0);

    --game logic outputs 
    SIGNAL DOLPHIN_ENABLE   : STD_LOGIC;
    SIGNAL PIPE_ENABLE_SIG  : STD_LOGIC;
    SIGNAL BAIT_ENABLE_SIG  : STD_LOGIC;
    SIGNAL PIPE_PASSED_SIG  : STD_LOGIC;
    SIGNAL PIPE_SPEED_UP_SIG : STD_LOGIC;
    SIGNAL LIFE_ONE_SIG, LIFE_TWO_SIG, LIFE_THREE_SIG : STD_LOGIC;
    SIGNAL SCORE_ONES_SIG, SCORE_TENS_SIG : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL TIMER_SIG        : STD_LOGIC;


    -- first click signal for dolphin movement, pipes, score, and timer to stay frozen until the first click
    SIGNAL first_click_signal : STD_LOGIC;

    -- when dolphin hits ground 
    SIGNAL HIT_GROUND_SIG : STD_LOGIC;
BEGIN




    -- Connect VGA sync signals to output, could VGA_HS/VS go straight in instance?
    VGA_HS <= HORIZ_SYNC;
    VGA_VS <= VERT_SYNC;

    RESET <= NOT KEY(0); -- active low reset
    -- testing game_won_text by making win high
    --  win_signal  <= SW(8);
     --game_over_test <= SW(7);


    -- need to change the lifes in the other components to the fsm life

    PROCESS(CLOCK_25MHZ)
    BEGIN
        IF rising_edge(CLOCK_25MHZ) THEN
            VGA_R  <= VGA_R_temp;
            VGA_G <=  VGA_G_temp;
            VGA_B  <= VGA_B_temp;
        END IF;
    END PROCESS;

------------------------------------ PORT MAP DECLARATION START ------------------------------------

    BG: BACKGROUND PORT MAP (
        pixel_row               => PIXEL_ROW,
        pixel_column            => PIXEL_COLUMN,
        Win                     => win_signal,
        Termination             => Termination_signal,
        Pause_OUT               => Pause_out_signal,
        Game_state_signal       => Game_state_signal,
        clock                   => CLOCK_25MHZ,
        -- outputs
        red                     => BACKGROUND_RED,
        green                   => BACKGROUND_GREEN,
        blue                    => BACKGROUND_BLUE
    );



    CH : BCD_TO_SEVENSEG PORT MAP (
        BCD_digit => column_hundreds,
        SevenSeg_out => HEX2
    );

    CO : BCD_TO_SEVENSEG PORT MAP (
        BCD_digit => SCORE_ONES_SIG,
        SevenSeg_out => HEX0
    );

    CT : BCD_TO_SEVENSEG PORT MAP (
        BCD_digit => SCORE_TENS_SIG,
        SevenSeg_out => HEX1
    );
    clock_divider : PLL PORT MAP (
        refclk   => CLOCK_50,
        rst      => '0',
        outclk_0 => CLOCK_25MHZ,
        locked   => OPEN
    );

    DOLPHIN_SPRITE_INST : DOLPHIN_VISUAL PORT MAP (
        clk => CLOCK_25MHZ,
        pixel_row => PIXEL_ROW,
        pixel_column => PIXEL_COLUMN,
        dolphin_x_pos => DOLPHIN_X_POS,
        dolphin_y_pos => DOLPHIN_Y_POS,
        Game_state_signal => Game_state_signal,
        red => SPRITE_RED,
        green => SPRITE_GREEN,
        blue => SPRITE_BLUE,
        dolphin_on => SPRITE_ON
    );


    GAME_RULE: GAME_LOGIC PORT MAP (
        clk => CLOCK_25MHZ,
        vert_sync => VERT_SYNC,
        reset => RESET,
        Game_state_signal => Game_state_signal,
        dolphin_enable=> SPRITE_ON,
        pipe_enable =>PIPE_ENABLE_SIG,
        bait_enable=> BAIT_ENABLE_SIG,
        pipe_passed=> PIPE_PASSED_SIG,
        hit_ground=> HIT_GROUND_SIG,
        life_one=> LIFE_ONE_SIG,
        life_two  => LIFE_TWO_SIG,
        life_three => LIFE_THREE_SIG,
        dolphin_IS_alive  => Life_signal, -- fed into the fsm, logic high
        timer_out => TIMER_SIG,    -- from the fsm
        pipe_speed_up => PIPE_SPEED_UP_SIG,
        score_ones => SCORE_ONES_SIG,
        score_tens  => SCORE_TENS_SIG
    );

    GAME_WON_TEXT_INSTANCE: GAME_WON_TEXT PORT MAP (
        clk => CLOCK_25MHZ,
        pixel_row => PIXEL_ROW,
        pixel_column => PIXEL_COLUMN,
        win => win_signal,
        red => GAME_WON_TEXT_RED,
        green => GAME_WON_TEXT_GREEN,
        blue => GAME_WON_TEXT_BLUE

    );

    GAME_OVER_TEXT_INSTANCE: GAME_OVER_TEXT PORT MAP (
        clk => CLOCK_25MHZ,
        pixel_row => PIXEL_ROW,
        pixel_column => PIXEL_COLUMN,
        win => win_signal,
        termination => Termination_signal,
        red => GAME_OVER_TEXT_RED,
        green => GAME_OVER_TEXT_GREEN,
        blue => GAME_OVER_TEXT_BLUE

    );
    

    HOME_SCREEN_TEXT: HOME_DISPLAY_TEXT PORT MAP (
        clk => CLOCK_25MHZ,
        pixel_row => PIXEL_ROW,
        pixel_column => PIXEL_COLUMN,
        Game_state_signal => Game_state_signal,
        red => HOME_DISPLAY_TEXT_RED,
        green => HOME_DISPLAY_TEXT_GREEN,
        blue => HOME_DISPLAY_TEXT_BLUE

    );

    FINITE_STATE_MACHINE : FSM PORT MAP(
        CLK             => CLOCK_25MHZ,
        Reset           => RESET,  -- declared above before port map declarations
        Start           => NOT KEY(3),
        Pause_IN        => RIGHT_CLICK, -- different to original fsm diagram
        Mode            => SW(0),  -- 0 for training, 1 for game
        Life            => Life_signal,   -- from game logic

        Timer           => TIMER_SIG,     -- from game logic 
       -- outputs
        Win             => win_signal,
        Termination     => Termination_signal,
        Pause_OUT       => Pause_out_signal,
        Game_State      => Game_state_signal
    );

    LAYER_RENDERER: LAYER PORT MAP (
        clk => CLOCK_25MHZ,
        Win             => win_signal,
        Termination     => Termination_signal,
        Pause_OUT       => Pause_out_signal,
        Game_state_signal      => Game_state_signal,




        BACKGROUND_RED => BACKGROUND_RED,
        BACKGROUND_GREEN => BACKGROUND_GREEN,
        BACKGROUND_BLUE => BACKGROUND_BLUE,
        PIPE_RED => PIPE_RED,
        PIPE_GREEN => PIPE_GREEN,
        PIPE_BLUE => PIPE_BLUE,
        PIPE_ON => PIPE_ON,
        BAIT_RED => BAIT_RED,
        BAIT_GREEN => BAIT_GREEN,
        BAIT_BLUE => BAIT_BLUE,
        BAIT_ON => BAIT_ON,
        SPRITE_RED => SPRITE_RED,
        SPRITE_GREEN => SPRITE_GREEN,
        SPRITE_BLUE => SPRITE_BLUE,
        SPRITE_ON => SPRITE_ON,
        LIVES_RED => LIVES_RED,
        LIVES_GREEN => LIVES_GREEN,
        LIVES_BLUE => LIVES_BLUE,
        LIVES_ON => LIVES_ON,
        SCORE_RED => SCORE_RED,
        SCORE_GREEN => SCORE_GREEN,
        SCORE_BLUE => SCORE_BLUE,
        SCORE_ON => SCORE_ON,
        HOME_DISPLAY_TEXT_RED => HOME_DISPLAY_TEXT_RED,
        HOME_DISPLAY_TEXT_GREEN => HOME_DISPLAY_TEXT_GREEN,
        HOME_DISPLAY_TEXT_BLUE => HOME_DISPLAY_TEXT_BLUE,

        GAME_WON_TEXT_RED   => GAME_WON_TEXT_RED,
        GAME_WON_TEXT_GREEN => GAME_WON_TEXT_GREEN,
        GAME_WON_TEXT_BLUE  => GAME_WON_TEXT_BLUE,

        GAME_OVER_TEXT_RED   => GAME_OVER_TEXT_RED,
        GAME_OVER_TEXT_GREEN => GAME_OVER_TEXT_GREEN,
        GAME_OVER_TEXT_BLUE  => GAME_OVER_TEXT_BLUE,

        RED_OUT => RED_OUT,
        GREEN_OUT => GREEN_OUT,
        BLUE_OUT => BLUE_OUT
    );

    LIFE_DISPLAY: LIVES PORT MAP (
        clk => CLOCK_25MHZ,
        pixel_row => PIXEL_ROW,
        pixel_column => PIXEL_COLUMN,
        Game_state_signal => Game_state_signal,
        life_one => LIFE_ONE_SIG,
        life_two => LIFE_TWO_SIG,
        life_three => LIFE_THREE_SIG,
        live_on => LIVES_ON,
        red => LIVES_RED,
        green => LIVES_GREEN,
        blue => LIVES_BLUE
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

    PIPE_DISPLAY: PIPES PORT MAP (
        CLOCK_25Mhz => CLOCK_25MHZ,
        vert_sync => VERT_SYNC,
        pixel_row => PIXEL_ROW,
        pixel_column => PIXEL_COLUMN,
        Game_state_signal => Game_state_signal,
        first_click => first_click_signal,
        pipe_speed_up => PIPE_SPEED_UP_SIG,
        pipe_on => PIPE_ON,
        red => PIPE_RED,
        green => PIPE_GREEN,
        blue => PIPE_BLUE,
        lfsr_value => RANDOM_VALUE,
        pipe_enable => PIPE_ENABLE_SIG,
        pipe_passed => PIPE_PASSED_SIG,
        pipe_x_1 => bait_pipe_x,
        pipe_y_1 => bait_pipe_y
    );

    PLAYER_CHARACTER: DOLPHIN_MOVEMENT PORT MAP (
        clk => CLOCK_25MHZ,
        vert_sync => VERT_SYNC,
        pixel_row => PIXEL_ROW,
        pixel_column => PIXEL_COLUMN,
        left_click => LEFT_CLICK,
        Game_state_signal => Game_state_signal,

        dolphin_x_pos_out => DOLPHIN_X_POS,
        dolphin_y_pos_out => DOLPHIN_Y_POS,
        dolphin_on => DOLPHIN_ON,
        dolphin_enable => DOLPHIN_ENABLE,
        first_click_out => first_click_signal,
        hit_ground => HIT_GROUND_SIG
    );

    RH : BCD_TO_SEVENSEG PORT MAP (
        BCD_digit => row_hundreds,
        SevenSeg_out => HEX5
    );

    RT : BCD_TO_SEVENSEG PORT MAP (
        BCD_digit => row_tens,
        SevenSeg_out => HEX4
    );

    RO : BCD_TO_SEVENSEG PORT MAP (
        BCD_digit => row_ones,
        SevenSeg_out => HEX3
    );

    RANDOM_BAIT: BAIT PORT MAP (
        clk => CLOCK_25MHZ,
        pixel_row => PIXEL_ROW,
        pixel_column => PIXEL_COLUMN,
        Game_state_signal => Game_state_signal,
        dolphin_enable => SPRITE_ON,
        pipe_x_pos_1 => bait_pipe_x,
        gap_height => bait_pipe_y,
        red => BAIT_RED,
        green => BAIT_GREEN,
        blue => BAIT_BLUE,
        bait_on => BAIT_ON,
        bait_enable => BAIT_ENABLE_SIG
    );

    RANDOM_NUMBER: LFSR PORT MAP (
        clk => CLOCK_25MHZ,
        reset => RESET,
        ENABLE => '1',
        INITIAL_VALUE => "10101010",
        lfsr_VALUES => RANDOM_VALUE
    );

    sevenseg_display : POSITION_TO_BCD PORT MAP (
        mouse_row => MOUSE_ROW,
        mouse_column => MOUSE_COLUMN,
        row_hundreds => row_hundreds,
        row_tens => row_tens,
        row_ones => row_ones,
        column_hundreds => column_hundreds,
        column_tens => column_tens,
        column_ones => column_ones
    );

    SCORE_DISPLAY: SCORE_TEXT PORT MAP (
        clk => CLOCK_25MHZ,
        pixel_row => PIXEL_ROW,
        pixel_column => PIXEL_COLUMN,
        Game_state_signal => Game_state_signal,
        score_ones => SCORE_ONES_SIG,
        score_tens => SCORE_TENS_SIG,
        score_on => SCORE_ON,
        red => SCORE_RED,
        green => SCORE_GREEN,
        blue => SCORE_BLUE
    );


    VGA_REFRESH: VGA_SYNC PORT MAP (
        clock_25Mhz => CLOCK_25MHZ,
        red => RED_OUT,
        green => GREEN_OUT,
        blue => BLUE_OUT,
        red_out => VGA_R_temp,
        green_out => VGA_G_temp,
        blue_out => VGA_B_temp,
        horiz_sync_out => HORIZ_SYNC,
        vert_sync_out => VERT_SYNC,
        pixel_row => PIXEL_ROW,
        pixel_column => PIXEL_COLUMN
    );
 ------------------------------------ PORT MAP DECLARATION END ------------------------------------


END BEHAVIOUR;
