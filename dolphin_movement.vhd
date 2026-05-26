LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;

-- Sets dolphin visibility to 8x8 square around fixed x and click-dependant y position
-- When Game_state_signal changes to '01' or '10' dolphin is initialised to verticle center of screen
-- dolphin_enable outputs '1' when dolphin is visible so can be used for collisions
-- dolphin_y_motion is made up of jumps or accumulating gravity (fall gets faster)
-- dolphin_y_motion is added to dolphin_y_position, refreshing each Vert_sync frame
-- set conditions for bouncing down from ceiling


-- no dolphin movement after touching ground (could add change of state instead)
--  NEED TO ADD THIS TO THE FSM, WHEN IT TOUCHES THE GORUND MAKE LIVES 0 SO IT GOES TO HOME SCREEN ON "01" AND GAME_OVER ON "10"

ENTITY DOLPHIN_MOVEMENT IS
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
END DOLPHIN_MOVEMENT;

architecture behavior of DOLPHIN_MOVEMENT is

SIGNAL size                         : std_logic_vector(9 DOWNTO 0);  
SIGNAL dolphin_y_pos                : std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(240,10); -- start on the ground
SIGNAL dolphin_x_pos                : std_logic_vector(9 DOWNTO 0);
SIGNAL dolphin_y_motion             : std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(0, 10);
SIGNAL left_click_prev              : std_logic := '0'; -- to avoid holding click
SIGNAL state                         : std_logic;
SIGNAL prev_game_state_signal       : std_logic_vector(1 DOWNTO 0) := "00";
SIGNAL first_click                  : std_logic := '0';
SIGNAL dolphin_visible              : std_logic;
SIGNAL vert_sync_prev               : std_logic := '0';
SIGNAL frame_tick                   : std_logic;

-- increase gravity to fall faster
CONSTANT gravity                    : std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(1,10);
-- for bigger jump --> 1016 or 1010
-- for smaller jump --> 1020 
CONSTANT jump                       : std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(1014, 10); 
CONSTANT dolphin_ground             : std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(472,10); -- ground level for dolphin

BEGIN  

    dolphin_x_pos_out <= dolphin_x_pos;
    dolphin_y_pos_out <= dolphin_y_pos;

    state <= '1' when (Game_state_signal = "01" or Game_state_signal = "10") else '0'; -- only show pipes during training/game mode

    size <= CONV_STD_LOGIC_VECTOR(8,10);

    dolphin_x_pos <= CONV_STD_LOGIC_VECTOR(50,10);

    -- reuse the first click signal, in pipes and ?
    first_click_out <=  first_click;

    -- sets dolphin visibility to 8x8 square
    dolphin_visible <= '1' when (
    (state = '1') and
    (dolphin_y_pos >= size) and
    (pixel_column >= dolphin_x_pos - size) and
    (pixel_column <= dolphin_x_pos + size) and
    (pixel_row >= dolphin_y_pos - size) and
    (pixel_row <= dolphin_y_pos + size)
    ) else '0';

    dolphin_on <= dolphin_visible;
    dolphin_enable <= dolphin_visible;
    frame_tick <= vert_sync and not vert_sync_prev;

    process (clk)
        variable left_click_edge : std_logic;
    begin
        if (rising_edge(clk)) then
            vert_sync_prev <= vert_sync;

            if frame_tick = '1' then
                prev_game_state_signal <= Game_state_signal;

                left_click_prev <= left_click; -- update previous left click value
                left_click_edge := left_click and (not left_click_prev); -- detect rising edge of left click

                if (Game_state_signal = "00") then
                    dolphin_y_pos <= CONV_STD_LOGIC_VECTOR(240, 10);
                    dolphin_y_motion <= CONV_STD_LOGIC_VECTOR(0, 10);
                    first_click <= '0';
                elsif (state = '1') then
                    if (prev_game_state_signal = "00") then
                        dolphin_y_pos <= CONV_STD_LOGIC_VECTOR(240, 10);
                        dolphin_y_motion <= CONV_STD_LOGIC_VECTOR(0, 10);
                        first_click <= '0';
                    else
                        if first_click = '0' then
                            -- hold dolphin at centre until the first left click
                            if left_click_edge = '1' then
                                first_click <= '1';
                                dolphin_y_motion <= jump; -- start movement on first click
                            else
                                dolphin_y_pos <= CONV_STD_LOGIC_VECTOR(240, 10);
                                dolphin_y_motion <= CONV_STD_LOGIC_VECTOR(0, 10);
                            end if;
                        else
                            -- normal game movement after the first click
                            if (left_click_edge = '1') then
                                dolphin_y_motion <= jump;
                            else
                                dolphin_y_motion <= dolphin_y_motion + gravity;
                            end if;

                            dolphin_y_pos <=  dolphin_y_pos + dolphin_y_motion;

                            if dolphin_y_pos < size then
                                dolphin_y_pos <= size;
                            end if;

                            -- set hit_ground to '1' when dolphin touches the ground, fed into game logic and FSM
                            if dolphin_y_pos >= dolphin_ground then
                                dolphin_y_pos <= dolphin_ground;
                                dolphin_y_motion <= CONV_STD_LOGIC_VECTOR(0, 10);
                                hit_ground <= '1';
                            else
                                hit_ground <= '0';
                            end if;
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;

END behavior;
