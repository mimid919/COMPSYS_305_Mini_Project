-- THIS FILE DOESNT IMPLEMENT TIMER, instead it takes SW[1] as the logic high input of timer to simulate states
library IEEE;
use  IEEE.STD_LOGIC_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;

entity FSM is
    Port ( CLK              : in STD_LOGIC;
           Reset            : in STD_LOGIC;   -- key[0]
           Start            : in STD_LOGIC;   -- key[1]
           Pause_IN         : in STD_LOGIC;   -- SW[9]  cant be a push button because need a permanent state
           Mode             : in STD_LOGIC;   -- SW[0], user selects either TRAINING OR GAME
           Life             : in STD_LOGIC;   -- logic high
           Timer            : in STD_LOGIC;   -- SW[1] NEEDS CHANGING TO USE AN ACTUAL TIMER
       
           Win              : out STD_LOGIC;  -- logic high
           Termination      : out STD_LOGIC;  -- logic high
           Pause_OUT        : out STD_LOGIC;  -- logic high
           Game_State       : out STD_LOGIC_VECTOR(1 downto 0)        
);
end FSM;

architecture Moore of FSM is
-- All 6 states, as seen in the FSM diagram
type state_type is (Home_Screen, TRAINING_Mode, GAME_Mode, Pause, Game_Won, Game_Over);
signal state, next_state : state_type;   -- Local states
signal start_pressed : STD_LOGIC;

begin

    -- this process just synchronises the states on the rising edge
    SYNC_PROC : process (CLK)
    begin
        if rising_edge(CLK) then
            if (reset = '1') then  -- checks reset twice    
                state <= Home_Screen;
            else
                state <= next_state;
            end if;
        end if;
    end process;

    --  only determines outputs
    OUTPUT_DECODE : process (state)
    begin
        case state is
            when Home_Screen =>
                Win                 <= '0';
                Termination         <= '0';
                Pause_OUT           <= '0';
                Game_State          <= "00";
            when TRAINING_Mode =>
                Win                 <= '0';
                Termination         <= '0';
                Pause_OUT           <= '0';
                Game_State          <= "01";
            when GAME_Mode =>
                Win                 <= '0';
                Termination         <= '0';
                Pause_OUT            <= '0';
                Game_State          <= "10";
            when Pause =>
                Win                 <= '0';
                Termination         <= '0';
                Pause_OUT           <= '1';
                Game_State          <= "11";
            when Game_Won =>
                Win                 <= '1';
                Termination         <= '1';
                Pause_OUT           <= '0';
                Game_State          <= "11";
            when Game_Over =>
                Win                 <= '0';
                Termination         <= '1';
                Pause_OUT           <= '0';
                Game_State          <= "11";
            when others =>  -- shouldnt't occur but set the others to home screen
                Win                 <= '0';
                Termination         <= '0';
                Pause_OUT           <= '0';
                Game_State          <= "00";
        end case;
    end process;

    -- reads the inputs and "state" to determines the next_state
    --      *if there is any ERROR with the states it could be because of the debouncing of the keys
    --      * if ADDING CODE please make sure the next state logic is in order of priority for example reset > pause
    NEXT_STATE_LOGIC : process (state,    Reset, Start, Pause_IN, Mode, Life, Timer)
    begin
        next_state <= state; -- default state
        case state is
            when Home_Screen =>
                -- Only changes with start and mode
                if (start = '1' ) then
                   if (Mode = '0') then
                        next_state <= TRAINING_Mode;
                   else
                        next_state <= GAME_Mode;
                   end if;
                end if;
            when TRAINING_Mode =>
                if (Reset = '1' OR Life = '0') then  -- we can change it so when it loses all its lifes it can go to game_over
                    next_state <= Home_Screen;
                elsif (Pause_IN = '1') then
                    next_state <= Pause;
                end if;  
            when GAME_Mode =>  
                if (Reset = '1') then
                    next_state <= Home_Screen;
                elsif (Pause_IN = '1') then
                    next_state <= Pause;
                elsif (Life = '0') then
                    next_state <= Game_Over;
                elsif  (life = '1' AND Timer = '1') then
                    next_state <= Game_Won;
                end if;  
            when Pause =>  --- will only chane states if they un flick the switch
                if (Pause_IN = '0') then
                    if (Mode = '0') then
                        next_state <= TRAINING_Mode;
                   else
                        next_state <= GAME_Mode;
                   end if;
                end if;
            when Game_Won | Game_Over=> -- Game_Over and Game_won both only change with timer and go to Home_screen
                if (Timer = '1') then
                    next_state <=  Home_Screen;
                end if;
        end case;
    end process;
end Moore;