LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY LAYER IS
	PORT
		(   Win                     : IN STD_LOGIC;  -- logic high
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
            HOME_DISPLAY_TEXT_RED,HOME_DISPLAY_TEXT_GREEN,HOME_DISPLAY_TEXT_BLUE   				: in std_logic_vector(3 DOWNTO 0);
            GAME_WON_TEXT_RED, GAME_WON_TEXT_GREEN, GAME_WON_TEXT_BLUE : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            GAME_OVER_TEXT_RED, GAME_OVER_TEXT_GREEN, GAME_OVER_TEXT_BLUE : IN STD_LOGIC_VECTOR(3 DOWNTO 0);

            RED_OUT,GREEN_OUT,BLUE_OUT                      : OUT STD_LOGIC_vector(3 DOWNTO 0)
            );

END LAYER;

architecture behaviour of LAYER is

BEGIN

process( Win, Termination, Pause_OUT, Game_state_signal,
    HOME_DISPLAY_TEXT_RED, HOME_DISPLAY_TEXT_GREEN, HOME_DISPLAY_TEXT_BLUE,
    LIVES_RED, LIVES_GREEN, LIVES_BLUE, LIVES_ON,
    SPRITE_RED, SPRITE_GREEN, SPRITE_BLUE, SPRITE_ON,
    BAIT_RED, BAIT_GREEN, BAIT_BLUE, BAIT_ON,
    PIPE_RED, PIPE_GREEN, PIPE_BLUE, PIPE_ON,
    BACKGROUND_RED, BACKGROUND_GREEN, BACKGROUND_BLUE,
    GAME_WON_TEXT_RED, GAME_WON_TEXT_GREEN, GAME_WON_TEXT_BLUE,
    GAME_OVER_TEXT_RED, GAME_OVER_TEXT_GREEN, GAME_OVER_TEXT_BLUE
)
begin
    -- =================================================================
    -- STEP 1: Default to the Background color determined by BACKGROUND.vhd
    -- =================================================================
    RED_OUT   <= BACKGROUND_RED;
    GREEN_OUT <= BACKGROUND_GREEN;
    BLUE_OUT  <= BACKGROUND_BLUE;

    -- =================================================================
    -- STEP 2: Layer game elements or state text on top based on state
    -- =================================================================
    
    -- -------------------------- HOME SCREEN --------------------------
    IF Game_state_signal = "00" THEN 
        -- If text pixel is NOT black/transparent, draw it. Otherwise, keep background.
        IF (HOME_DISPLAY_TEXT_RED /= "0000" OR HOME_DISPLAY_TEXT_GREEN /= "0000" OR HOME_DISPLAY_TEXT_BLUE /= "0000") THEN
            RED_OUT   <= HOME_DISPLAY_TEXT_RED;
            GREEN_OUT <= HOME_DISPLAY_TEXT_GREEN;
            BLUE_OUT  <= HOME_DISPLAY_TEXT_BLUE;
        END IF;

    -- -------------------------- GAME WON --------------------------
    ELSIF Win = '1' THEN 
        IF (GAME_WON_TEXT_RED /= "0000" OR GAME_WON_TEXT_GREEN /= "0000" OR GAME_WON_TEXT_BLUE /= "0000") THEN
            RED_OUT   <= GAME_WON_TEXT_RED;
            GREEN_OUT <= GAME_WON_TEXT_GREEN;                                   
            BLUE_OUT  <= GAME_WON_TEXT_BLUE;   
        END IF;

    -- -------------------------- GAME OVER --------------------------
    ELSIF Game_state_signal = "11" THEN
        IF (GAME_OVER_TEXT_RED /= "0000" OR GAME_OVER_TEXT_GREEN /= "0000" OR GAME_OVER_TEXT_BLUE /= "0000") THEN
            RED_OUT   <= GAME_OVER_TEXT_RED;
            GREEN_OUT <= GAME_OVER_TEXT_GREEN;                                   
            BLUE_OUT  <= GAME_OVER_TEXT_BLUE;   
        END IF;

    -- -------------------------- PAUSE --------------------------
    ELSIF Pause_OUT = '1' THEN
        -- Add pause text/overlay handling here later

    -- -------------------------- DURING GAMEPLAY (01 or 11) --------------------------
    ELSE 
        -- Priority: Lives > Dolphin (Sprite) > Bait > Pipes > (Background handles itself)
        IF (LIVES_ON = '1') THEN
            RED_OUT   <= LIVES_RED;
            GREEN_OUT <= LIVES_GREEN;
            BLUE_OUT  <= LIVES_BLUE;
        ELSIF (SPRITE_ON = '1') THEN
            RED_OUT   <= SPRITE_RED;
            GREEN_OUT <= SPRITE_GREEN;
            BLUE_OUT  <= SPRITE_BLUE;
        ELSIF (BAIT_ON = '1') THEN
            RED_OUT   <= BAIT_RED;
            GREEN_OUT <= BAIT_GREEN;
            BLUE_OUT  <= BAIT_BLUE;
        ELSIF (PIPE_ON = '1') THEN
            RED_OUT   <= PIPE_RED;
            GREEN_OUT <= PIPE_GREEN;
            BLUE_OUT  <= PIPE_BLUE;
       
        END IF;
        
    END IF;
end process;
end behaviour;