LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY layer IS
	PORT
		(BACKGROUND_RED,BACKGROUND_GREEN,BACKGROUND_BLUE: in std_logic;
            PIPE_RED,PIPE_GREEN, PIPE_BLUE  : in std_logic;
            PIPE_ON                            : IN STD_LOGIC;
            BAIT_RED,BAIT_GREEN,BAIT_BLUE   : in std_logic;
            BAIT_ON                         : IN STD_LOGIC;
            SPRITE_RED, SPRITE_GREEN, SPRITE_BLUE : IN std_logic;
            SPRITE_ON : IN std_logic;
            LIVES_RED,LIVES_GREEN,LIVES_BLUE: in std_logic;
            LIVES_ON                        : IN STD_LOGIC;
            TEXT_RED,TEXT_GREEN,TEXT_BLUE   : in std_logic;
            RED_OUT,GREEN_OUT,BLUE_OUT      : OUT STD_LOGIC);

END layer;

architecture behaviour of layer is

BEGIN

process(
    TEXT_RED, TEXT_GREEN, TEXT_BLUE,
    LIVES_RED, LIVES_GREEN, LIVES_BLUE,
    SPRITE_RED, SPRITE_GREEN, SPRITE_BLUE, SPRITE_ON,
    BAIT_RED, BAIT_GREEN, BAIT_BLUE,
    PIPE_ON,BAIT_ON,LIVES_ON,
    PIPE_RED, PIPE_GREEN, PIPE_BLUE,
    BACKGROUND_RED, BACKGROUND_GREEN, BACKGROUND_BLUE
)
begin

    -- default background
    RED_OUT   <= BACKGROUND_RED;
    GREEN_OUT <= BACKGROUND_GREEN;
    BLUE_OUT  <= BACKGROUND_BLUE;

    -- pipes
    if (PIPE_ON = '1') then
        RED_OUT   <= PIPE_RED;
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

    -- text
    if (TEXT_RED = '1' or TEXT_GREEN = '1' or TEXT_BLUE = '1') then
        RED_OUT   <= TEXT_RED;
        GREEN_OUT <= TEXT_GREEN;
        BLUE_OUT  <= TEXT_BLUE;
    end if;

end process;

end behaviour;