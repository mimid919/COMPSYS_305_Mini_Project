LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY home_display IS
	PORT
		( clk                       : In std_logic;
          pixel_row, pixel_column	: IN std_logic_vector(9 DOWNTO 0);
          FSM_STATE : STD_LOGIC_VECTOR(1 DOWNTO 0);
          red, green, blue 			: OUT std_logic);		
END home_display;

architecture behaviour of home_display is

COMPONENT char_rom IS
	PORT
	(
		character_address	:	IN STD_LOGIC_VECTOR (5 DOWNTO 0);
		font_row, font_col	:	IN STD_LOGIC_VECTOR (2 DOWNTO 0);
		clock				: 	IN STD_LOGIC ;
		rom_mux_output		:	OUT STD_LOGIC
	);
END COMPONENT char_rom;

SIGNAL text_on : std_logic;
SIGNAL text_on_cycle : std_logic;

SIGNAL rom_pixel_F : std_logic;
SIGNAL rom_pixel_L1 : std_logic;
SIGNAL rom_pixel_A  : std_logic;
SIGNAL rom_pixel_P1  : std_logic;
SIGNAL rom_pixel_P2  : std_logic;
SIGNAL rom_pixel_Y  : std_logic;
SIGNAL rom_pixel_D  : std_logic;
SIGNAL rom_pixel_O  : std_logic;
SIGNAL rom_pixel_L2  : std_logic;
SIGNAL rom_pixel_P3  : std_logic;
SIGNAL rom_pixel_H  : std_logic;
SIGNAL rom_pixel_I  : std_logic;
SIGNAL rom_pixel_N  : std_logic;

SIGNAL row_F, col_F : std_logic_vector(9 DOWNTO 0);
SIGNAL row_L1, col_L1 : std_logic_vector(9 DOWNTO 0); 
SIGNAL row_A, col_A : std_logic_vector(9 DOWNTO 0);
SIGNAL row_P1, col_P1 : std_logic_vector(9 DOWNTO 0);
SIGNAL row_P2, col_P2 : std_logic_vector(9 DOWNTO 0);
SIGNAL row_Y, col_Y : std_logic_vector(9 DOWNTO 0);
SIGNAL row_D, col_D : std_logic_vector(9 DOWNTO 0);
SIGNAL row_O, col_O : std_logic_vector(9 DOWNTO 0);
SIGNAL row_L2, col_L2 : std_logic_vector(9 DOWNTO 0);
SIGNAL row_P3, col_P3 : std_logic_vector(9 DOWNTO 0);
SIGNAL row_H, col_H : std_logic_vector(9 DOWNTO 0);
SIGNAL row_I, col_I : std_logic_vector(9 DOWNTO 0);
SIGNAL row_N, col_N : std_logic_vector(9 DOWNTO 0);

Begin 

row_F <= pixel_row - CONV_STD_LOGIC_VECTOR(240,10) when pixel_row  >= CONV_STD_LOGIC_VECTOR(240, 10) else (others => '1');
col_F <= pixel_column - CONV_STD_LOGIC_VECTOR(60,10) when pixel_column >= CONV_STD_LOGIC_VECTOR(60,  10) else (others => '1');
row_L1 <= pixel_row - CONV_STD_LOGIC_VECTOR(240,10) when pixel_row  >= CONV_STD_LOGIC_VECTOR(240, 10) else (others => '1');
col_L1 <= pixel_column - CONV_STD_LOGIC_VECTOR(100,10) when pixel_column >= CONV_STD_LOGIC_VECTOR(100,  10) else (others => '1');
row_A <= pixel_row - CONV_STD_LOGIC_VECTOR(240,10) when pixel_row  >= CONV_STD_LOGIC_VECTOR(240, 10) else (others => '1');
col_A <= pixel_column - CONV_STD_LOGIC_VECTOR(140,10) when pixel_column >= CONV_STD_LOGIC_VECTOR(140,  10) else (others => '1');
row_P1 <= pixel_row - CONV_STD_LOGIC_VECTOR(240,10) when pixel_row  >= CONV_STD_LOGIC_VECTOR(240, 10) else (others => '1');
col_P1 <= pixel_column - CONV_STD_LOGIC_VECTOR(180,10) when pixel_column >= CONV_STD_LOGIC_VECTOR(180,  10) else (others => '1');
row_P2 <= pixel_row - CONV_STD_LOGIC_VECTOR(240,10) when pixel_row  >= CONV_STD_LOGIC_VECTOR(240, 10) else (others => '1');
col_P2 <= pixel_column - CONV_STD_LOGIC_VECTOR(220,10) when pixel_column >= CONV_STD_LOGIC_VECTOR(220,  10) else (others => '1');
row_Y <= pixel_row - CONV_STD_LOGIC_VECTOR(240,10) when pixel_row  >= CONV_STD_LOGIC_VECTOR(240, 10) else (others => '1');
col_Y <= pixel_column - CONV_STD_LOGIC_VECTOR(260,10) when pixel_column >= CONV_STD_LOGIC_VECTOR(260,  10) else (others => '1');
row_D <= pixel_row - CONV_STD_LOGIC_VECTOR(240,10) when pixel_row  >= CONV_STD_LOGIC_VECTOR(240, 10) else (others => '1');
col_D <= pixel_column - CONV_STD_LOGIC_VECTOR(300,10) when pixel_column >= CONV_STD_LOGIC_VECTOR(300, 10) else (others => '1');
--halfway
row_O <= pixel_row - CONV_STD_LOGIC_VECTOR(240,10) when pixel_row  >= CONV_STD_LOGIC_VECTOR(240, 10) else (others => '1');
col_O <= pixel_column - CONV_STD_LOGIC_VECTOR(340,10) when pixel_column >= CONV_STD_LOGIC_VECTOR(340, 10) else (others => '1');
row_L2 <= pixel_row - CONV_STD_LOGIC_VECTOR(240,10) when pixel_row  >= CONV_STD_LOGIC_VECTOR(240, 10) else (others => '1');
col_L2 <= pixel_column - CONV_STD_LOGIC_VECTOR(380,10) when pixel_column >= CONV_STD_LOGIC_VECTOR(380, 10) else (others => '1');
row_P3 <= pixel_row - CONV_STD_LOGIC_VECTOR(240,10) when pixel_row  >= CONV_STD_LOGIC_VECTOR(240, 10) else (others => '1');
col_P3 <= pixel_column - CONV_STD_LOGIC_VECTOR(420,10) when pixel_column >= CONV_STD_LOGIC_VECTOR(420, 10) else (others => '1');
row_H <= pixel_row - CONV_STD_LOGIC_VECTOR(240,10) when pixel_row  >= CONV_STD_LOGIC_VECTOR(240, 10) else (others => '1');
col_H <= pixel_column - CONV_STD_LOGIC_VECTOR(460,10) when pixel_column >= CONV_STD_LOGIC_VECTOR(460, 10) else (others => '1');
row_I <= pixel_row - CONV_STD_LOGIC_VECTOR(240,10) when pixel_row  >= CONV_STD_LOGIC_VECTOR(240, 10) else (others => '1');
col_I <= pixel_column - CONV_STD_LOGIC_VECTOR(500,10) when pixel_column >= CONV_STD_LOGIC_VECTOR(500, 10) else (others => '1');
row_N <= pixel_row - CONV_STD_LOGIC_VECTOR(240,10) when pixel_row  >= CONV_STD_LOGIC_VECTOR(240, 10) else (others => '1');
col_N <= pixel_column - CONV_STD_LOGIC_VECTOR(540,10) when pixel_column >= CONV_STD_LOGIC_VECTOR(540, 10) else (others => '1');

Red   <= text_on_cycle;
Green <= '0';
Blue  <= text_on_cycle;

process(clk)
begin
    if(rising_edge(clk)) then
        text_on_cycle <= text_on;
    end if;
end process;

process(pixel_row, pixel_column, FSM_STATE,
            row_F, col_F, rom_pixel_F,
            row_L1, col_L1, rom_pixel_L1,
            row_A, col_A, rom_pixel_A,
            row_P1, col_P1, rom_pixel_P1,
            row_P2, col_P2, rom_pixel_P2,
            row_Y, col_Y, rom_pixel_Y,
            row_D, col_D, rom_pixel_D,
            row_O, col_O, rom_pixel_O,
            row_L2, col_L2, rom_pixel_L2,
            row_P3, col_P3, rom_pixel_P3,
            row_H, col_H, rom_pixel_H,
            row_I, col_I, rom_pixel_I,
            row_N, col_N, rom_pixel_N
            )
begin
    text_on <= '0';

    if FSM_STATE = "00" then -- start screen
        if col_F < 32 and row_F < 32 and rom_pixel_F = '1' then
            text_on <= '1';
        elsif
        col_L1 < 32 and row_L1 < 32 and rom_pixel_L1 = '1' then
            text_on <= '1';     
        elsif
        col_A < 32 and row_A < 32 and rom_pixel_A = '1' then
            text_on <= '1';
        elsif
        col_P1 < 32 and row_P1 < 32 and rom_pixel_P1 = '1' then
            text_on <= '1'; 
        elsif
        col_P2 < 32 and row_P2 < 32 and rom_pixel_P2 = '1' then
            text_on <= '1';
        elsif
        col_Y < 32 and row_Y < 32 and rom_pixel_Y = '1' then
            text_on <= '1';
        elsif
        col_D < 32 and row_D < 32 and rom_pixel_D = '1' then
            text_on <= '1';
        elsif
        col_O < 32 and row_O < 32 and rom_pixel_O = '1' then
            text_on <= '1';
        elsif
        col_L2 < 32 and row_L2 < 32 and rom_pixel_L2 = '1' then
            text_on <= '1'; 
        elsif 
        col_P3 < 32 and row_P3 < 32 and rom_pixel_P3 = '1' then
            text_on <= '1';
        elsif
        col_H < 32 and row_H < 32 and rom_pixel_H = '1' then
            text_on <= '1';
        elsif
        col_I < 32 and row_I < 32 and rom_pixel_I = '1' then
            text_on <= '1';
        elsif
        col_N < 32 and row_N < 32 and rom_pixel_N = '1' then
            text_on <= '1';
        end if;
    end if;
end process;



F_ROM: char_rom
PORT MAP (
    character_address => "000110",  
    font_row => row_F(4 downto 2),
    font_col => col_F(4 downto 2),
    clock => clk,
    rom_mux_output => rom_pixel_F
);

L1_ROM: char_rom
PORT MAP (
    character_address => "001100",  
	font_row => row_L1(4 downto 2),
    font_col => col_L1(4 downto 2),
    clock => clk,
    rom_mux_output => rom_pixel_L1
);

A_ROM: char_rom
PORT MAP (
    character_address => "000001",
	font_row => row_A(4 downto 2),
    font_col => col_A(4 downto 2),
    clock => clk,
    rom_mux_output => rom_pixel_A
);

P1_ROM: char_rom
PORT MAP (
    character_address => "010000",
    font_row => row_P1(4 downto 2),
	font_col => col_P1(4 downto 2),
    clock => clk,
    rom_mux_output => rom_pixel_P1
);

P2_ROM: char_rom
PORT MAP (
    character_address => "010000",
    font_row => row_P2(4 downto 2),
	font_col => col_P2(4 downto 2),
    clock => clk,
    rom_mux_output => rom_pixel_P2
);


Y_ROM: char_rom 
PORT MAP (
    character_address => "011001",
	font_row => row_Y(4 downto 2),
    font_col => col_Y(4 downto 2),
    clock => clk,
    rom_mux_output => rom_pixel_Y
);

D_ROM: char_rom
PORT MAP (
    character_address => "000100",
    font_row => row_D(4 downto 2),
    font_col => col_D(4 downto 2),
    clock => clk,
    rom_mux_output => rom_pixel_D
);

O_ROM: char_rom
PORT MAP (
    character_address => "001111",
    font_row => row_O(4 downto 2),
    font_col => col_O(4 downto 2),
    clock => clk,
    rom_mux_output => rom_pixel_O
);

L2_ROM: char_rom
PORT MAP (
    character_address => "001100",  
	font_row => row_L2(4 downto 2),
    font_col => col_L2(4 downto 2),
    clock => clk,
    rom_mux_output => rom_pixel_L2
);

P3_ROM: char_rom
PORT MAP (
    character_address => "010000",
    font_row => row_P3(4 downto 2),
	font_col => col_P3(4 downto 2),
    clock => clk,
    rom_mux_output => rom_pixel_P3
);

H_ROM: char_rom
PORT MAP (
    character_address => "001000",
    font_row => row_H(4 downto 2),
    font_col => col_H(4 downto 2),
    clock => clk,
    rom_mux_output => rom_pixel_H
);

I_ROM: char_rom
PORT MAP (
    character_address => "001001",
    font_row => row_I(4 downto 2),
    font_col => col_I(4 downto 2),
    clock => clk,
    rom_mux_output => rom_pixel_I
);

N_ROM: char_rom
PORT MAP (
    character_address => "001110",
    font_row => row_N(4 downto 2),
    font_col => col_N(4 downto 2),
    clock => clk,
    rom_mux_output => rom_pixel_N
);

END behaviour;