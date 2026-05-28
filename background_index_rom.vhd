LIBRARY ieee;
USE ieee.std_logic_1164.all;

LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;

ENTITY background_index_rom IS
    PORT (
        address : IN STD_LOGIC_VECTOR (18 DOWNTO 0);
        clock   : IN STD_LOGIC := '1';
        q       : OUT STD_LOGIC_VECTOR (2 DOWNTO 0)
    );
END background_index_rom;

ARCHITECTURE SYN OF background_index_rom IS
    SIGNAL sub_wire0 : STD_LOGIC_VECTOR (2 DOWNTO 0);
BEGIN
    q <= sub_wire0;

    ROM : altsyncram
    GENERIC MAP (
        operation_mode => "ROM",
        width_a => 3,
        widthad_a => 19,
        numwords_a => 307200,
        outdata_reg_a => "UNREGISTERED",
        init_file => "background_index_3bit.mif",
        intended_device_family => "Cyclone V",
        lpm_type => "altsyncram",
        width_byteena_a => 1
    )
    PORT MAP (
        address_a => address,
        clock0 => clock,
        q_a => sub_wire0
    );
END SYN;
