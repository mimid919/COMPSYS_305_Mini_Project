LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;

LIBRARY altera_mf;
USE altera_mf.all;
USE altera_mf.altera_mf_components.ALL;

ENTITY sprite_rom IS
	PORT
	(
		address : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		clock   : IN STD_LOGIC;
		q       : OUT STD_LOGIC_VECTOR (2 DOWNTO 0)
	);
END sprite_rom;

ARCHITECTURE SYN OF sprite_rom IS

BEGIN

	ROM : altsyncram
	GENERIC MAP (
		operation_mode => "ROM",
		width_a => 3,
		widthad_a => 8,
		numwords_a => 256,
		outdata_reg_a => "UNREGISTERED",
		init_file => "dolphin_sprite.mif",
		intended_device_family => "Cyclone V"
	)
	PORT MAP (
		clock0 => clock,
		address_a => address,
		q_a => q
	);

END SYN;