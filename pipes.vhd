LIBRARY IEEE;
USE  IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;

-- 3 pipes equadistant are visible during state '01'
-- pipe_enable can be used for collisions
-- Pipes move [NUMBER] pixels left during each screen refresh (vert_sync)
-- Pipe gap height is determined by LFSR
-- Draws pipe shape around x and y position, in rows less than top_height and above gap

ENTITY PIPES IS
    PORT (
        CLOCK_25Mhz              : IN std_logic;
        vert_sync                : IN std_logic;
        pixel_row, pixel_column  : IN std_logic_vector(9 DOWNTO 0);
        lfsr_value               : IN std_logic_vector(7 DOWNTO 0);
        Game_state_signal        : IN std_logic_vector(1 DOWNTO 0);
        pipe_speed_up            : IN std_logic;
        first_click              : IN std_logic;
        Pause_in                 : IN std_logic;

        pipe_on                  : OUT std_logic;
        pipe_enable              : OUT std_logic;
        pipe_passed              : OUT std_logic;
        pipe_x_1                 : OUT std_logic_vector(9 DOWNTO 0);
        pipe_y_1                 : OUT std_logic_vector(9 DOWNTO 0);
        red, green, blue         : OUT std_logic_vector(3 DOWNTO 0)
    );
END PIPES;

ARCHITECTURE behavior OF PIPES IS

    COMPONENT pipe_top IS
        PORT (
            address : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
            clock   : IN STD_LOGIC;
            q       : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT pipestrip IS
        PORT (
            address : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
            clock   : IN STD_LOGIC;
            q       : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
        );
    END COMPONENT;

    CONSTANT PIPE_CAP_W  : INTEGER := 57;
    CONSTANT PIPE_CAP_H  : INTEGER := 55;
    CONSTANT PIPE_BODY_W : INTEGER := 50;
    CONSTANT GAP_HEIGHT  : INTEGER := 200;

    SIGNAL pipe_x_pos_1 : std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(0, 10);
    SIGNAL pipe_x_pos_2 : std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(213, 10);
    SIGNAL pipe_x_pos_3 : std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(426, 10);

    SIGNAL pipe_top_height_1 : std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(200, 10);
    SIGNAL pipe_top_height_2 : std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(220, 10);
    SIGNAL pipe_top_height_3 : std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(150, 10);

    SIGNAL random_height_1 : std_logic_vector(9 DOWNTO 0);
    SIGNAL random_height_2 : std_logic_vector(9 DOWNTO 0);
    SIGNAL random_height_3 : std_logic_vector(9 DOWNTO 0);

    SIGNAL state : std_logic;

    SIGNAL pipe_visible  : std_logic;
    SIGNAL pipe1_visible : std_logic;
    SIGNAL pipe2_visible : std_logic;
    SIGNAL pipe3_visible : std_logic;

    SIGNAL pipe_passed_int : std_logic := '0';
    SIGNAL pipe_1_ready    : std_logic := '1';
    SIGNAL pipe_2_ready    : std_logic := '1';
    SIGNAL pipe_3_ready    : std_logic := '1';

    SIGNAL pipe_step      : std_logic_vector(9 DOWNTO 0);
    SIGNAL vert_sync_prev : std_logic := '0';
    SIGNAL frame_tick     : std_logic;

    SIGNAL top_address   : STD_LOGIC_VECTOR(11 DOWNTO 0);
    SIGNAL strip_address : STD_LOGIC_VECTOR(5 DOWNTO 0);
    SIGNAL top_pixel     : STD_LOGIC_VECTOR(11 DOWNTO 0);
    SIGNAL strip_pixel   : STD_LOGIC_VECTOR(11 DOWNTO 0);

    -- Pipeline stage 1 -> stage 2 registers
    SIGNAL draw_pending   : STD_LOGIC := '0';
    SIGNAL use_top_reg    : STD_LOGIC := '0';
    SIGNAL sel_pipe_reg   : INTEGER RANGE 0 TO 3 := 0;
    SIGNAL top_addr_reg   : STD_LOGIC_VECTOR(11 DOWNTO 0) := (OTHERS => '0');
    SIGNAL strip_addr_reg : STD_LOGIC_VECTOR(5 DOWNTO 0)  := (OTHERS => '0');

    -- Registered pipe positions to cut long fanout into comparators
    SIGNAL pipe_x_pos_1_r      : std_logic_vector(9 DOWNTO 0) := (OTHERS => '0');
    SIGNAL pipe_x_pos_2_r      : std_logic_vector(9 DOWNTO 0) := (OTHERS => '0');
    SIGNAL pipe_x_pos_3_r      : std_logic_vector(9 DOWNTO 0) := (OTHERS => '0');
    SIGNAL pipe_top_height_1_r : std_logic_vector(9 DOWNTO 0) := (OTHERS => '0');
    SIGNAL pipe_top_height_2_r : std_logic_vector(9 DOWNTO 0) := (OTHERS => '0');
    SIGNAL pipe_top_height_3_r : std_logic_vector(9 DOWNTO 0) := (OTHERS => '0');

BEGIN

    TOP_ROM : pipe_top
    PORT MAP (
        address => top_address,
        clock   => CLOCK_25Mhz,
        q       => top_pixel
    );

    STRIP_ROM : pipestrip
    PORT MAP (
        address => strip_address,
        clock   => CLOCK_25Mhz,
        q       => strip_pixel
    );

    random_height_1 <= CONV_STD_LOGIC_VECTOR(125 + CONV_INTEGER(lfsr_value(7 DOWNTO 3) & '0'), 10);
    random_height_2 <= CONV_STD_LOGIC_VECTOR(125 + CONV_INTEGER(lfsr_value(4 DOWNTO 0) & '0'), 10);
    random_height_3 <= CONV_STD_LOGIC_VECTOR(125 + CONV_INTEGER('0' & lfsr_value(5 DOWNTO 1)), 10);

    pipe_visible <= pipe1_visible OR pipe2_visible OR pipe3_visible;

    state <= '1' when (Game_state_signal = "01" OR Game_state_signal = "10") else '0';

    pipe_on     <= pipe_visible AND state;
    pipe_enable <= pipe_visible AND state;
    pipe_passed <= pipe_passed_int AND state;

    pipe_step <= CONV_STD_LOGIC_VECTOR(2, 10) when pipe_speed_up = '1'
                 else CONV_STD_LOGIC_VECTOR(1, 10);

    frame_tick <= vert_sync AND NOT vert_sync_prev;

    pipe_x_1 <= pipe_x_pos_1;
    pipe_y_1 <= pipe_top_height_1;

    -- MOVEMENT LOGIC (unchanged)
    PROCESS (CLOCK_25Mhz)
    BEGIN
        IF rising_edge(CLOCK_25Mhz) THEN
            vert_sync_prev <= vert_sync;
            pipe_passed_int <= '0';

            IF Game_state_signal = "00" THEN
                pipe_x_pos_1 <= CONV_STD_LOGIC_VECTOR(640, 10);
                pipe_x_pos_2 <= CONV_STD_LOGIC_VECTOR(213, 10);
                pipe_x_pos_3 <= CONV_STD_LOGIC_VECTOR(426, 10);

                pipe_top_height_1 <= CONV_STD_LOGIC_VECTOR(200, 10);
                pipe_top_height_2 <= CONV_STD_LOGIC_VECTOR(220, 10);
                pipe_top_height_3 <= CONV_STD_LOGIC_VECTOR(150, 10);

                pipe_1_ready <= '1';
                pipe_2_ready <= '1';
                pipe_3_ready <= '1';

            ELSIF (state = '1' AND frame_tick = '1' AND first_click = '1') THEN

                IF pipe_x_pos_1 <= pipe_step THEN
                    IF pipe_1_ready = '1' THEN
                        pipe_passed_int <= '1';
                    END IF;
                    pipe_1_ready <= '1';
                    pipe_x_pos_1 <= CONV_STD_LOGIC_VECTOR(640, 10);
                    pipe_top_height_1 <= random_height_1;
                ELSIF Pause_in = '0' THEN
                    pipe_x_pos_1 <= pipe_x_pos_1 - pipe_step;
                END IF;

                IF pipe_x_pos_2 <= pipe_step THEN
                    IF pipe_2_ready = '1' THEN
                        pipe_passed_int <= '1';
                    END IF;
                    pipe_2_ready <= '1';
                    pipe_x_pos_2 <= CONV_STD_LOGIC_VECTOR(640, 10);
                    pipe_top_height_2 <= random_height_2;
                ELSIF Pause_in = '0' THEN
                    pipe_x_pos_2 <= pipe_x_pos_2 - pipe_step;
                END IF;

                IF pipe_x_pos_3 <= pipe_step THEN
                    IF pipe_3_ready = '1' THEN
                        pipe_passed_int <= '1';
                    END IF;
                    pipe_3_ready <= '1';
                    pipe_x_pos_3 <= CONV_STD_LOGIC_VECTOR(640, 10);
                    pipe_top_height_3 <= random_height_3;
                ELSIF Pause_in = '0' THEN
                    pipe_x_pos_3 <= pipe_x_pos_3 - pipe_step;
                END IF;

            END IF;
        END IF;
    END PROCESS;

    -- Register pipe positions one cycle ahead to shorten fanout paths
    PROCESS (CLOCK_25Mhz)
    BEGIN
        IF rising_edge(CLOCK_25Mhz) THEN
            pipe_x_pos_1_r      <= pipe_x_pos_1;
            pipe_x_pos_2_r      <= pipe_x_pos_2;
            pipe_x_pos_3_r      <= pipe_x_pos_3;
            pipe_top_height_1_r <= pipe_top_height_1;
            pipe_top_height_2_r <= pipe_top_height_2;
            pipe_top_height_3_r <= pipe_top_height_3;
        END IF;
    END PROCESS;

    -- STAGE 1: compute which pipe and which ROM address, register it
    PROCESS (CLOCK_25Mhz)
        VARIABLE row_i      : INTEGER;
        VARIABLE col_i      : INTEGER;
        VARIABLE pipe_x_i   : INTEGER;
        VARIABLE gap_y_i    : INTEGER;
        VARIABLE local_x    : INTEGER;
        VARIABLE local_y    : INTEGER;
        VARIABLE sel        : INTEGER RANGE 0 TO 3;
        VARIABLE addr_top   : INTEGER;
        VARIABLE addr_strip : INTEGER;
        VARIABLE use_top_v  : STD_LOGIC;
        VARIABLE draw_v     : STD_LOGIC;
    BEGIN
        IF rising_edge(CLOCK_25Mhz) THEN
            row_i      := CONV_INTEGER(pixel_row);
            col_i      := CONV_INTEGER(pixel_column);
            sel        := 0;
            pipe_x_i   := 0;
            gap_y_i    := 0;
            draw_v     := '0';
            use_top_v  := '0';
            addr_top   := 0;
            addr_strip := 0;

            IF state = '1' THEN
                IF col_i >= CONV_INTEGER(pipe_x_pos_1_r) AND col_i < CONV_INTEGER(pipe_x_pos_1_r) + PIPE_CAP_W THEN
                    sel := 1;  pipe_x_i := CONV_INTEGER(pipe_x_pos_1_r);  gap_y_i := CONV_INTEGER(pipe_top_height_1_r);
                ELSIF col_i >= CONV_INTEGER(pipe_x_pos_2_r) AND col_i < CONV_INTEGER(pipe_x_pos_2_r) + PIPE_CAP_W THEN
                    sel := 2;  pipe_x_i := CONV_INTEGER(pipe_x_pos_2_r);  gap_y_i := CONV_INTEGER(pipe_top_height_2_r);
                ELSIF col_i >= CONV_INTEGER(pipe_x_pos_3_r) AND col_i < CONV_INTEGER(pipe_x_pos_3_r) + PIPE_CAP_W THEN
                    sel := 3;  pipe_x_i := CONV_INTEGER(pipe_x_pos_3_r);  gap_y_i := CONV_INTEGER(pipe_top_height_3_r);
                END IF;

                IF sel /= 0 THEN
                    local_x := col_i - pipe_x_i;

                    -- top strip (body above cap)
                    IF row_i < gap_y_i - PIPE_CAP_H THEN
                        IF local_x >= PIPE_BODY_W THEN
                            addr_strip := local_x - PIPE_BODY_W;
                        ELSE
                            addr_strip := local_x;
                        END IF;
                        use_top_v  := '0';
                        draw_v     := '1';

                    -- top cap flipped vertically
                    ELSIF row_i >= gap_y_i - PIPE_CAP_H AND row_i < gap_y_i THEN
                        local_y   := PIPE_CAP_H - 1 - (row_i - (gap_y_i - PIPE_CAP_H));
                        addr_top  := (local_y * 64) - (local_y * 8) + local_y + local_x;
                        use_top_v := '1';
                        draw_v    := '1';

                    -- bottom cap
                    ELSIF row_i >= gap_y_i + GAP_HEIGHT AND row_i < gap_y_i + GAP_HEIGHT + PIPE_CAP_H THEN
                        local_y   := row_i - (gap_y_i + GAP_HEIGHT);
                        addr_top  := (local_y * 64) - (local_y * 8) + local_y + local_x;
                        use_top_v := '1';
                        draw_v    := '1';

                    -- bottom strip (body below cap)
                    ELSIF row_i >= gap_y_i + GAP_HEIGHT + PIPE_CAP_H THEN
                        IF local_x >= PIPE_BODY_W THEN
                            addr_strip := local_x - PIPE_BODY_W;
                        ELSE
                            addr_strip := local_x;
                        END IF;
                        use_top_v  := '0';
                        draw_v     := '1';
                    END IF;
                END IF;
            END IF;

            -- Latch everything for Stage 2
            draw_pending   <= draw_v;
            sel_pipe_reg   <= sel;
            use_top_reg    <= use_top_v;
            top_addr_reg   <= CONV_STD_LOGIC_VECTOR(addr_top,   12);
            strip_addr_reg <= CONV_STD_LOGIC_VECTOR(addr_strip,  6);
        END IF;
    END PROCESS;

    -- Feed registered addresses into the ROMs
    top_address   <= top_addr_reg;
    strip_address <= strip_addr_reg;

    -- STAGE 2: ROM result is ready, drive RGB outputs
    PROCESS (CLOCK_25Mhz)
        VARIABLE pixel_colour : STD_LOGIC_VECTOR(11 DOWNTO 0);
    BEGIN
        IF rising_edge(CLOCK_25Mhz) THEN
            pipe1_visible <= '0';
            pipe2_visible <= '0';
            pipe3_visible <= '0';
            red   <= "0000";
            green <= "0000";
            blue  <= "0000";

            IF draw_pending = '1' THEN
                IF use_top_reg = '1' THEN
                    pixel_colour := top_pixel;
                ELSE
                    pixel_colour := strip_pixel;
                END IF;

                IF pixel_colour /= X"F0F" THEN
                    red   <= pixel_colour(11 DOWNTO 8);
                    green <= pixel_colour(7 DOWNTO 4);
                    blue  <= pixel_colour(3 DOWNTO 0);

                    IF sel_pipe_reg = 1 THEN
                        pipe1_visible <= '1';
                    ELSIF sel_pipe_reg = 2 THEN
                        pipe2_visible <= '1';
                    ELSE
                        pipe3_visible <= '1';
                    END IF;
                END IF;
            END IF;
        END IF;
    END PROCESS;

END BEHAVIOR;