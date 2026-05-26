LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY game_logic IS
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
        dolphin_IS_alive            : OUT STD_LOGIC;   -- high when alive, low when dead, fed into FSM
        timer_out           : OUT STD_LOGIC;
        pipe_speed_up       : OUT STD_LOGIC;
        score_ones          : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        score_tens          : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
    );
END game_logic;

ARCHITECTURE behaviour OF game_logic IS
    SIGNAL lives_count          : STD_LOGIC_VECTOR(1 DOWNTO 0) := "11"; -- 3 lives 
    SIGNAL score_ones_int      : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0'); 
    SIGNAL score_tens_int      : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');

    SIGNAL pipe_collision      : STD_LOGIC;
    SIGNAL pipe_collision_prev : STD_LOGIC := '0';
    SIGNAL bait_collision      : STD_LOGIC;
    SIGNAL bait_collision_prev : STD_LOGIC := '0';
    SIGNAL pipe_passed_prev    : STD_LOGIC := '0';
    SIGNAL pipe_hit_since_pass : STD_LOGIC := '0';

    SIGNAL collision_cooldown  : STD_LOGIC_VECTOR(5 DOWNTO 0) := (OTHERS => '0');
    SIGNAL bait_cooldown       : STD_LOGIC_VECTOR(5 DOWNTO 0) := (OTHERS => '0');
    CONSTANT COOLDOWN_MAX      : STD_LOGIC_VECTOR(5 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(60, 6);

    CONSTANT TIMER_20S         : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(1200, 11);
    CONSTANT TIMER_30S         : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(1800, 11);

    SIGNAL speed_timer_count    : STD_LOGIC_VECTOR(10 DOWNTO 0) := (OTHERS => '0');
    SIGNAL speed_phase_count    : STD_LOGIC_VECTOR(10 DOWNTO 0) := (OTHERS => '0');
    SIGNAL training_timer_count : STD_LOGIC_VECTOR(10 DOWNTO 0) := (OTHERS => '0');
    SIGNAL training_timer_done  : STD_LOGIC := '0';
    SIGNAL speed_timer_done     : STD_LOGIC := '0';
    SIGNAL speed_phase_done     : STD_LOGIC := '0';

    SIGNAL game_active        : STD_LOGIC;
    SIGNAL training_mode_only : STD_LOGIC;
    SIGNAL game_mode_only     : STD_LOGIC;
    SIGNAL vert_sync_prev     : STD_LOGIC := '0';
    SIGNAL frame_tick         : STD_LOGIC;

BEGIN
    pipe_collision     <= '1' when (dolphin_enable = '1' and pipe_enable = '1') else '0';
    bait_collision     <= '1' when (dolphin_enable = '1' and bait_enable = '1') else '0';
    frame_tick         <= vert_sync and not vert_sync_prev;
    game_active        <= '1' when (Game_state_signal = "01" or Game_state_signal = "10") else '0';
    training_mode_only <= '1' when Game_state_signal = "01" else '0';
    game_mode_only     <= '1' when Game_state_signal = "10" else '0';


    PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF reset = '1' THEN
                lives_count          <= "11";
                score_ones_int       <= (OTHERS => '0');
                score_tens_int       <= (OTHERS => '0');
                collision_cooldown   <= (OTHERS => '0');
                bait_cooldown        <= (OTHERS => '0');
                pipe_collision_prev  <= '0';
                bait_collision_prev  <= '0';
                pipe_passed_prev     <= '0';
                pipe_hit_since_pass  <= '0';
                speed_timer_count    <= (OTHERS => '0');
                speed_phase_count    <= (OTHERS => '0');
                training_timer_count <= (OTHERS => '0');
                training_timer_done  <= '0';
                speed_timer_done     <= '0';
                speed_phase_done     <= '0';
                vert_sync_prev       <= '0';
            ELSE
                vert_sync_prev <= vert_sync;

                IF game_active = '1' THEN
                    pipe_collision_prev <= pipe_collision;
                    bait_collision_prev <= bait_collision;
                    pipe_passed_prev    <= pipe_passed;

                    IF pipe_collision = '1' THEN
                        pipe_hit_since_pass <= '1';
                    END IF;

                    IF pipe_passed = '1' and pipe_passed_prev = '0' THEN
                        IF pipe_hit_since_pass = '0' THEN
                            IF score_ones_int = "1001" THEN
                                IF score_tens_int < "1001" THEN
                                    score_ones_int <= "0000";
                                    score_tens_int <= score_tens_int + 1;
                                END IF;
                            ELSE
                                score_ones_int <= score_ones_int + 1;
                            END IF;
                        END IF;
                        pipe_hit_since_pass <= '0';
                    END IF;

                    IF collision_cooldown > 0 THEN
                        IF frame_tick = '1' THEN
                            collision_cooldown <= collision_cooldown - 1;
                        END IF;
                    ELSIF pipe_collision = '1' and pipe_collision_prev = '0' THEN
                        collision_cooldown <= COOLDOWN_MAX;
                        IF lives_count > "00" THEN
                            lives_count <= lives_count - 1;
                        END IF;
                    END IF;

                    IF bait_cooldown > 0 THEN
                        IF frame_tick = '1' THEN
                            bait_cooldown <= bait_cooldown - 1;
                        END IF;
                    ELSIF bait_collision = '1' and bait_collision_prev = '0' THEN
                        bait_cooldown <= COOLDOWN_MAX;
                        IF lives_count < "11" THEN
                            lives_count <= lives_count + 1;
                        END IF;
                    END IF;

                    IF frame_tick = '1' and game_mode_only = '1' THEN
                        IF speed_timer_done = '0' THEN
                            IF speed_timer_count >= TIMER_20S THEN
                                speed_timer_done <= '1';
                            ELSE
                                speed_timer_count <= speed_timer_count + 1;
                            END IF;
                        ELSIF speed_phase_done = '0' THEN
                            IF speed_phase_count >= TIMER_20S THEN
                                speed_phase_done <= '1';
                            ELSE
                                speed_phase_count <= speed_phase_count + 1;
                            END IF;
                        END IF;
                    END IF;

                    IF frame_tick = '1' and training_mode_only = '1' and training_timer_done = '0' THEN
                        IF training_timer_count >= TIMER_30S THEN
                            training_timer_done <= '1';
                        ELSE
                            training_timer_count <= training_timer_count + 1;
                        END IF;
                    END IF;
                ELSIF Game_state_signal = "00" THEN
                    lives_count          <= "11";
                    score_ones_int       <= (OTHERS => '0');
                    score_tens_int       <= (OTHERS => '0');
                    collision_cooldown   <= (OTHERS => '0');
                    bait_cooldown        <= (OTHERS => '0');
                    pipe_collision_prev  <= '0';
                    bait_collision_prev  <= '0';
                    pipe_passed_prev     <= '0';
                    pipe_hit_since_pass  <= '0';
                    speed_timer_count    <= (OTHERS => '0');
                    speed_phase_count    <= (OTHERS => '0');
                    training_timer_count <= (OTHERS => '0');
                    training_timer_done  <= '0';
                    speed_timer_done     <= '0';
                    speed_phase_done     <= '0';
                END IF;
            END IF;
        END IF;
    END PROCESS;

    life_three <= '1' when lives_count >= "11" else '0';
    life_two   <= '1' when lives_count >= "10" else '0';
    life_one   <= '1' when lives_count >= "01" else '0';

    dolphin_IS_alive <= '0' when (lives_count = "00" OR hit_ground = '1') else '1';  -- logic high
    timer_out <= training_timer_done when training_mode_only = '1' else
                 speed_phase_done when game_mode_only = '1' else
                 '0';
    pipe_speed_up <= speed_timer_done;
    score_ones <= score_ones_int;
    score_tens <= score_tens_int;

END behaviour;
