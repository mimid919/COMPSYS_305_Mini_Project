LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY game_logic IS
    PORT (
        clk                 : IN  STD_LOGIC;
        reset               : IN  STD_LOGIC;   
        Game_state_signal   : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
        dolphin_enable      : IN  STD_LOGIC;
        pipe_enable         : IN  STD_LOGIC;
        bait_enable         : IN  STD_LOGIC;
        pipe_passed         : IN  STD_LOGIC;
        life_one            : OUT STD_LOGIC;
        life_two            : OUT STD_LOGIC;
        life_three          : OUT STD_LOGIC;
        life_out            : OUT STD_LOGIC;
        timer_out           : OUT STD_LOGIC;
        score_ones          : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        score_tens          : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
    );
END game_logic;

ARCHITECTURE behaviour OF game_logic IS
    SIGNAL lives_count      : STD_LOGIC_VECTOR(1 DOWNTO 0) := "11";
    SIGNAL score            : STD_LOGIC_VECTOR(6 DOWNTO 0) := (OTHERS => '0');
    SIGNAL pipe_collision       : STD_LOGIC;
    SIGNAL pipe_collision_prev  : STD_LOGIC := '0';
    SIGNAL bait_collision       : STD_LOGIC;
    SIGNAL bait_collision_prev  : STD_LOGIC := '0';
    SIGNAL pipe_passed_prev     : STD_LOGIC := '0';
    SIGNAL pipe_hit_since_pass  : STD_LOGIC := '0';
    SIGNAL collision_cooldown   : STD_LOGIC_VECTOR(24 DOWNTO 0) := (OTHERS => '0');
    CONSTANT COOLDOWN_MAX       : STD_LOGIC_VECTOR(24 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(25000000, 25);
    SIGNAL bait_cooldown        : STD_LOGIC_VECTOR(24 DOWNTO 0) := (OTHERS => '0');
    CONSTANT BAIT_COOLDOWN_MAX  : STD_LOGIC_VECTOR(24 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(25000000, 25);
-- clk = 25 MHz → 25,000,000 ticks per second
    -- 20 seconds   → 500,000,000 ticks
    -- Counter needs 30 bits to hold 500,000,000 (2^29 = 536M)
    CONSTANT TIMER_20S      : STD_LOGIC_VECTOR(29 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(500000000, 30);

    SIGNAL timer_count      : STD_LOGIC_VECTOR(29 DOWNTO 0) := (OTHERS => '0');
    SIGNAL timer_done       : STD_LOGIC := '0';

    -- Active game flags
    SIGNAL game_active      : STD_LOGIC;   -- training OR game
    SIGNAL game_mode_only   : STD_LOGIC;   -- GAME mode only

    -- Internal BCD
    SIGNAL score_ones_int   : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL score_tens_int   : STD_LOGIC_VECTOR(3 DOWNTO 0);

BEGIN
    pipe_collision  <= '1' when (dolphin_enable = '1' and pipe_enable = '1') else '0';
    bait_collision  <= '1' when (dolphin_enable = '1' and bait_enable = '1') else '0';
    game_active     <= '1' when (Game_state_signal = "01" or Game_state_signal = "10") else '0';
    game_mode_only  <= '1' when  Game_state_signal = "10" else '0';  

    PROCESS (clk)
    BEGIN
        if rising_edge(clk) then
            if reset = '1' then
                lives_count         <= "11";
                score               <= (OTHERS => '0');
                collision_cooldown  <= (OTHERS => '0');
                bait_cooldown       <= (OTHERS => '0');
                pipe_collision_prev <= '0';
                bait_collision_prev <= '0';
                pipe_passed_prev    <= '0';
                pipe_hit_since_pass <= '0';
                timer_count         <= (OTHERS => '0');
                timer_done          <= '0';

            elsif game_active = '1' then
        
                -- PIPE COLLISION: lose one life on the first overlap pixel, then ignore
                -- further overlap pixels while the dolphin is passing through the object.
                
                pipe_collision_prev <= pipe_collision;
                pipe_passed_prev <= pipe_passed;

                if pipe_collision = '1' then
                    pipe_hit_since_pass <= '1';
                end if;

                if pipe_passed = '1' and pipe_passed_prev = '0' then
                    if pipe_hit_since_pass = '0' and score < CONV_STD_LOGIC_VECTOR(99, 7) then
                        score <= score + 1;
                    end if;
                    pipe_hit_since_pass <= '0';
                end if;

                if collision_cooldown > 0 then
                    collision_cooldown <= collision_cooldown - 1;
                else
                    if pipe_collision = '1' and pipe_collision_prev = '0' then
                        collision_cooldown <= COOLDOWN_MAX;
                        if lives_count > "00" then
                            lives_count <= lives_count - 1;
                        end if;
                    end if;
                      end if;
                
                -- BAIT COLLISION: gain one life (max 3) on the first overlap.
                
                bait_collision_prev <= bait_collision;
                if bait_cooldown > 0 then
                    bait_cooldown <= bait_cooldown - 1;
                else
                    if bait_collision = '1' and bait_collision_prev = '0' then
                        bait_cooldown    <= BAIT_COOLDOWN_MAX;
                        if lives_count < "11" then 
                            lives_count <= lives_count + 1;
                        end if ;
                      end if;
                 end if;

                -- 20-SECONDTIMER
                if game_mode_only = '1' and timer_done = '0' then
                    if timer_count >= TIMER_20S then
                        timer_done <= '1'; 
                    else
                        timer_count <= timer_count + 1;
                     end if;
                  end if;

            else
                -- reset
                if Game_state_signal = "00" then
                    lives_count        <= "11";
                    score              <= (OTHERS => '0');
                    collision_cooldown <= (OTHERS => '0');
                    bait_cooldown      <= (OTHERS => '0');
                    pipe_collision_prev <= '0';
                    bait_collision_prev <= '0';
                    pipe_passed_prev    <= '0';
                    pipe_hit_since_pass <= '0';
                    timer_count        <= (OTHERS => '0');
                    timer_done         <= '0';
                 end if;
            end if;
          end if;
    END PROCESS;

    --LIVES display
    
        life_three <= '1' when lives_count >= "11" else '0';
    life_two   <= '1' when lives_count >= "10" else '0';
    life_one   <= '1' when lives_count >= "01" else '0';


    life_out  <= '0' when lives_count = "00" ELSE '1';  
    timer_out <= timer_done;                            

    PROCESS (score)
        VARIABLE score_int : INTEGER;
    BEGIN
        score_int      := CONV_INTEGER(score);
        score_tens_int <= CONV_STD_LOGIC_VECTOR((score_int /10) MOD 10, 4);
        score_ones_int <= CONV_STD_LOGIC_VECTOR( score_int MOD 10,4);
    END PROCESS;

    score_ones <= score_ones_int;
    score_tens <= score_tens_int;

END behaviour;
