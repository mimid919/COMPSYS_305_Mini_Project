LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY LAYER IS
    PORT
        (   
            clk                     : IN STD_LOGIC;  -- The 25MHz pixel clock
            Win                     : IN STD_LOGIC;  
            Termination             : IN STD_LOGIC;  
            Pause_OUT               : IN STD_LOGIC;  
            Game_state_signal       : IN std_logic_vector(1 DOWNTO 0);

            BACKGROUND_RED,BACKGROUND_GREEN,BACKGROUND_BLUE      : IN std_logic_vector(3 downto 0);
            PIPE_RED,PIPE_GREEN, PIPE_BLUE                       : IN std_logic_vector(3 DOWNTO 0);
            PIPE_ON                                              : IN STD_LOGIC;
            BAIT_RED,BAIT_GREEN,BAIT_BLUE                        : IN std_logic_vector(3 DOWNTO 0);
            BAIT_ON                                              : IN STD_LOGIC;
            SPRITE_RED, SPRITE_GREEN, SPRITE_BLUE                : IN std_logic_vector(3 DOWNTO 0);
            SPRITE_ON                                            : IN std_logic;
            LIVES_RED,LIVES_GREEN,LIVES_BLUE                     : IN std_logic_vector(3 DOWNTO 0);
            LIVES_ON                                             : IN STD_LOGIC;
            SCORE_RED,SCORE_GREEN,SCORE_BLUE                     : IN std_logic_vector(3 DOWNTO 0);
            SCORE_ON                                             : IN STD_LOGIC;
            HOME_DISPLAY_TEXT_RED,HOME_DISPLAY_TEXT_GREEN,HOME_DISPLAY_TEXT_BLUE : IN std_logic_vector(3 DOWNTO 0);
            GAME_WON_TEXT_RED, GAME_WON_TEXT_GREEN, GAME_WON_TEXT_BLUE           : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            GAME_OVER_TEXT_RED, GAME_OVER_TEXT_GREEN, GAME_OVER_TEXT_BLUE        : IN STD_LOGIC_VECTOR(3 DOWNTO 0);

            RED_OUT,GREEN_OUT,BLUE_OUT                           : OUT STD_LOGIC_vector(3 DOWNTO 0)
        );
END LAYER;

ARCHITECTURE behaviour OF LAYER IS

    -- =================================================================
    -- STAGE 1 REGISTERS (Holding Signals)
    -- =================================================================
    SIGNAL reg_Game_state : std_logic_vector(1 DOWNTO 0);
    SIGNAL reg_Win, reg_Termination, reg_Pause_OUT : STD_LOGIC;
    
    SIGNAL reg_BACKGROUND_RED, reg_BACKGROUND_GREEN, reg_BACKGROUND_BLUE : std_logic_vector(3 downto 0);
    SIGNAL reg_PIPE_RED, reg_PIPE_GREEN, reg_PIPE_BLUE : std_logic_vector(3 DOWNTO 0);
    SIGNAL reg_PIPE_ON : STD_LOGIC;
    SIGNAL reg_BAIT_RED, reg_BAIT_GREEN, reg_BAIT_BLUE : std_logic_vector(3 DOWNTO 0);
    SIGNAL reg_BAIT_ON : STD_LOGIC;
    SIGNAL reg_SPRITE_RED, reg_SPRITE_GREEN, reg_SPRITE_BLUE : std_logic_vector(3 DOWNTO 0);
    SIGNAL reg_SPRITE_ON : STD_LOGIC;
    SIGNAL reg_LIVES_RED, reg_LIVES_GREEN, reg_LIVES_BLUE : std_logic_vector(3 DOWNTO 0);
    SIGNAL reg_LIVES_ON : STD_LOGIC;
    SIGNAL reg_SCORE_RED, reg_SCORE_GREEN, reg_SCORE_BLUE : std_logic_vector(3 DOWNTO 0);
    SIGNAL reg_SCORE_ON : STD_LOGIC;
    
    SIGNAL reg_HOME_RED, reg_HOME_GREEN, reg_HOME_BLUE : std_logic_vector(3 DOWNTO 0);
    SIGNAL reg_WON_RED, reg_WON_GREEN, reg_WON_BLUE : std_logic_vector(3 DOWNTO 0);
    SIGNAL reg_OVER_RED, reg_OVER_GREEN, reg_OVER_BLUE : std_logic_vector(3 DOWNTO 0);

BEGIN

PROCESS(clk) 
BEGIN
    IF rising_edge(clk) THEN
        
        -- =================================================================
        -- PIPELINE STAGE 1: Catch all inputs from combinational logic
        -- =================================================================
        reg_Game_state <= Game_state_signal;
        reg_Win <= Win;
        reg_Termination <= Termination;
        reg_Pause_OUT <= Pause_OUT;
        
        reg_BACKGROUND_RED <= BACKGROUND_RED; reg_BACKGROUND_GREEN <= BACKGROUND_GREEN; reg_BACKGROUND_BLUE <= BACKGROUND_BLUE;
        reg_PIPE_RED <= PIPE_RED; reg_PIPE_GREEN <= PIPE_GREEN; reg_PIPE_BLUE <= PIPE_BLUE; reg_PIPE_ON <= PIPE_ON;
        reg_BAIT_RED <= BAIT_RED; reg_BAIT_GREEN <= BAIT_GREEN; reg_BAIT_BLUE <= BAIT_BLUE; reg_BAIT_ON <= BAIT_ON;
        reg_SPRITE_RED <= SPRITE_RED; reg_SPRITE_GREEN <= SPRITE_GREEN; reg_SPRITE_BLUE <= SPRITE_BLUE; reg_SPRITE_ON <= SPRITE_ON;
        reg_LIVES_RED <= LIVES_RED; reg_LIVES_GREEN <= LIVES_GREEN; reg_LIVES_BLUE <= LIVES_BLUE; reg_LIVES_ON <= LIVES_ON;
        reg_SCORE_RED <= SCORE_RED; reg_SCORE_GREEN <= SCORE_GREEN; reg_SCORE_BLUE <= SCORE_BLUE; reg_SCORE_ON <= SCORE_ON;
        
        reg_HOME_RED <= HOME_DISPLAY_TEXT_RED; reg_HOME_GREEN <= HOME_DISPLAY_TEXT_GREEN; reg_HOME_BLUE <= HOME_DISPLAY_TEXT_BLUE;
        reg_WON_RED <= GAME_WON_TEXT_RED; reg_WON_GREEN <= GAME_WON_TEXT_GREEN; reg_WON_BLUE <= GAME_WON_TEXT_BLUE;
        reg_OVER_RED <= GAME_OVER_TEXT_RED; reg_OVER_GREEN <= GAME_OVER_TEXT_GREEN; reg_OVER_BLUE <= GAME_OVER_TEXT_BLUE;


        -- =================================================================
        -- PIPELINE STAGE 2: Evaluate priority mux (Using ONLY the reg_ signals)
        -- =================================================================
        
        -- 1. Default to the Background color
        RED_OUT   <= reg_BACKGROUND_RED;
        GREEN_OUT <= reg_BACKGROUND_GREEN;
        BLUE_OUT  <= reg_BACKGROUND_BLUE;

        -- 2. Layer Text / Game States on top
        IF reg_Game_state = "00" THEN 
            IF (reg_HOME_RED /= "0000" OR reg_HOME_GREEN /= "0000" OR reg_HOME_BLUE /= "0000") THEN 
                RED_OUT   <= reg_HOME_RED;
                GREEN_OUT <= reg_HOME_GREEN;
                BLUE_OUT  <= reg_HOME_BLUE;
            END IF;
            
        ELSIF reg_Win = '1' THEN
            IF (reg_WON_RED /= "0000" OR reg_WON_GREEN /= "0000" OR reg_WON_BLUE /= "0000") THEN
                RED_OUT   <= reg_WON_RED;
                GREEN_OUT <= reg_WON_GREEN;
                BLUE_OUT  <= reg_WON_BLUE;
            END IF;
            
        ELSIF reg_Termination = '1' THEN 
            IF (reg_OVER_RED /= "0000" OR reg_OVER_GREEN /= "0000" OR reg_OVER_BLUE /= "0000") THEN
                RED_OUT   <= reg_OVER_RED;
                GREEN_OUT <= reg_OVER_GREEN;                                   
                BLUE_OUT  <= reg_OVER_BLUE;   
            END IF;
            
        ELSIF reg_Pause_OUT = '1' THEN
            -- Defaulting to the darkened background that your BACKGROUND module generates,
            -- but if you want to add pause text overlay later, it would go here.
            NULL;

        -- 3. Layer Gameplay Elements (During State "01" or "10")
        ELSE 
            -- Priority Hierarchy: Lives > Score > Sprite > Bait > Pipes
            IF (reg_LIVES_ON = '1') THEN
                RED_OUT   <= reg_LIVES_RED;
                GREEN_OUT <= reg_LIVES_GREEN;
                BLUE_OUT  <= reg_LIVES_BLUE;
            ELSIF (reg_SCORE_ON = '1') THEN
                RED_OUT   <= reg_SCORE_RED;
                GREEN_OUT <= reg_SCORE_GREEN;
                BLUE_OUT  <= reg_SCORE_BLUE;
            ELSIF (reg_SPRITE_ON = '1') THEN
                RED_OUT   <= reg_SPRITE_RED;
                GREEN_OUT <= reg_SPRITE_GREEN;
                BLUE_OUT  <= reg_SPRITE_BLUE;
            ELSIF (reg_BAIT_ON = '1') THEN
                RED_OUT   <= reg_BAIT_RED;
                GREEN_OUT <= reg_BAIT_GREEN;
                BLUE_OUT  <= reg_BAIT_BLUE;
            ELSIF (reg_PIPE_ON = '1') THEN
                RED_OUT   <= reg_PIPE_RED;
                GREEN_OUT <= reg_PIPE_GREEN;
                BLUE_OUT  <= reg_PIPE_BLUE;
            END IF;
        END IF;

    END IF;
END PROCESS;

END behaviour;