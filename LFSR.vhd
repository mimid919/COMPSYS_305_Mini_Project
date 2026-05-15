LIBRARY IEEE;
USE  IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY lfsr IS
    PORT
        ( clk                       : In std_logic;
          reset                     : In std_logic;
          ENABLE                    : In std_logic;
          INITIAL_VALUE             : IN std_logic_vector(7 DOWNTO 0); -- must be non-zero
          lfsr_VALUES                : OUT std_logic_vector(7 DOWNTO 0)
          );
END lfsr;

ARCHITECTURE behavior OF lfsr IS
    SIGNAL lfsr_reg              : std_logic_vector(7 DOWNTO 0);

BEGIN
    lfsr_VALUES <= lfsr_reg; -- output range 1 - 255

     PROCESS (clk, reset)
     BEGIN
        IF reset = '1' THEN
            lfsr_reg <= INITIAL_VALUE; -- Load initial non-zero value on reset
        ELSIF rising_edge(clk) THEN
            IF ENABLE = '1' THEN
                -- tap at 1, 2, 3, and 7 for galois 8-bit lfsr
                IF lfsr_reg(7) = '1' THEN
                    lfsr_reg <= (lfsr_reg(6 DOWNTO 0) & '0') XOR "10001110"; 
                ELSE
                    lfsr_reg <= (lfsr_reg(6 DOWNTO 0) & '0'); -- shift left
                END IF;
            END IF;
        END IF;
        END PROCESS;

END behavior;