library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity game_background_rom is
    port (
        x : in  unsigned(9 downto 0);  -- 0..639
        y : in  unsigned(8 downto 0);  -- 0..479
        r : out std_logic_vector(3 downto 0);
        g : out std_logic_vector(3 downto 0);
        b : out std_logic_vector(3 downto 0)
    );
end entity;

architecture rtl of game_background_rom is

    -- 640 * 480 = 307200 pixels
    type rom_array is array (0 to 307199) of std_logic_vector(11 downto 0);
    signal rom : rom_array;

    -- address = y * 640 + x
    signal addr : integer range 0 to 307199;

begin

    addr <= to_integer(y) * 640 + to_integer(x);

    -- output pixel
    r <= rom(addr)(11 downto 8);
    g <= rom(addr)(7 downto 4);
    b <= rom(addr)(3 downto 0);

    -- load ROM contents
    init_rom : process
        file romfile : text open read_mode is "sunset.hex";
        variable linebuf : line;
        variable hexval  : std_logic_vector(11 downto 0);
        variable i       : integer := 0;
    begin
        while not endfile(romfile) loop
            readline(romfile, linebuf);
            hread(linebuf, hexval);
            rom(i) <= hexval;
            i := i + 1;
        end loop;
        wait;
    end process;

end architecture;
