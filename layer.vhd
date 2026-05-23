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
    LIVES_RED, LIVES_GREEN, LIVES_BLUE,
    SPRITE_RED, SPRITE_GREEN, SPRITE_BLUE, SPRITE_ON,
    BAIT_RED, BAIT_GREEN, BAIT_BLUE,
    PIPE_ON,BAIT_ON,LIVES_ON,
    PIPE_RED, PIPE_GREEN, PIPE_BLUE,
    BACKGROUND_RED, BACKGROUND_GREEN, BACKGROUND_BLUE,
    GAME_WON_TEXT_RED, GAME_WON_TEXT_GREEN, GAME_WON_TEXT_BLUE,
    GAME_OVER_TEXT_RED, GAME_OVER_TEXT_GREEN, GAME_OVER_TEXT_BLUE

    )
begin

    ------------------------------------ SORIANAS CODE ------------------------------------
    -- current background, being outputted by background.vhd
    RED_OUT   <= BACKGROUND_RED;
    GREEN_OUT <= BACKGROUND_GREEN;
    BLUE_OUT  <= BACKGROUND_BLUE;

    -- pipes
    if (PIPE_ON = '1') then
        RED_OUT   <= PIPE_RED;              -- it might be better instead of multiple if statements we have a linked hierachal one
        GREEN_OUT <= PIPE_GREEN;
        BLUE_OUT  <= PIPE_BLUE;
    end if;

    -- bait
    if (BAIT_ON = '1') then
        RED_OUT   <= BAIT_RED;
        GREEN_OUT <= BAIT_GREEN;
        BLUE_OUT  <= BAIT_BLUE;
    end if;

    -- dolphin
    if (SPRITE_ON = '1') then
    RED_OUT   <= SPRITE_RED;
    GREEN_OUT <= SPRITE_GREEN;
    BLUE_OUT  <= SPRITE_BLUE;
    end if;

    -- lives
    if (LIVES_ON = '1') then
        RED_OUT   <= LIVES_RED;
        GREEN_OUT <= LIVES_GREEN;
        BLUE_OUT  <= LIVES_BLUE;
    end if;

    ------------------------------------ MIMIS CODE ------------------------------------    NEED TO MERGE SORIANA AND MIMIS FOR FINAL GAME 

    -------------------------- PAUSE  --------------------------
    IF Pause_OUT = '1' THEN
        -- add later 
    -------------------------- GAME WON  --------------------------
        --  black background, green text
    ELSIF Win = '1'  THEN 
        RED_OUT   <= GAME_WON_TEXT_RED;
        GREEN_OUT <= GAME_WON_TEXT_GREEN;                                  
        BLUE_OUT  <= GAME_WON_TEXT_BLUE;   
    -------------------------- GAME OVER  --------------------------
        --  black background, red text
    ELSIF Win = '0' and Termination ='1' THEN 
        RED_OUT   <= GAME_OVER_TEXT_RED;
        GREEN_OUT <= GAME_OVER_TEXT_GREEN;                                  
        BLUE_OUT  <= GAME_OVER_TEXT_BLUE;   
    -------------------------- HOME SCREEN  --------------------------
        -- purple background (blue TXT)
    ELSIF Game_state_signal = "00"  THEN 
        RED_OUT   <= HOME_DISPLAY_TEXT_RED;
        GREEN_OUT <= HOME_DISPLAY_TEXT_GREEN;
        BLUE_OUT  <= HOME_DISPLAY_TEXT_BLUE;   
     -------------------------- TRAINING & GAME MODE  --------------------------
        -- game screen, scaled sunset background image
    ELSIF Game_state_signal = "01" OR Game_state_signal = "11" THEN 
        -- add training mode/ game mode text later, need to add a file
    -------------------------- DEFAULT MODE -> RED SCREEN BECASUE ITS AN ERROR --------------------------
    ELSE -- default to avoid latch
        RED_OUT <= "1000";
        GREEN_OUT <= "0000";
        BLUE_OUT <= "0000";    
    END IF;


end process;

end behaviour;