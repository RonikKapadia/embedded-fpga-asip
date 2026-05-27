-- library declaration
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- entity
entity dMem is
    port (
        clka : in std_logic;
        wea : in std_logic_vector (0 to 0);
        addra : in std_logic_vector (14 downto 0);
        dina : in std_logic_vector (15 downto 0);
        douta : out std_logic_vector (15 downto 0)
    );
end dMem;

-- architecture
architecture dMem of dMem is

    -- intermediate signals
    type mem_type is array (32767 downto 0) of std_logic_vector(15 downto 0);
    signal mem : mem_type := (
		0 => "0000000001101000",
		1 => "0000000001100101",
		2 => "0000000001101100",
		3 => "0000000001101100",
		4 => "0000000001101111",
		5 => "0000000001011111",
		6 => "0000000001110111",
		7 => "0000000001101111",
		8 => "0000000001110010",
		9 => "0000000001101100",
		10 => "0000000001100100",
		11 => "0000000000000000",
		others => (others => '0')
	);

begin
    process(clka)
    begin
        if rising_edge(clka) then

            -- read
            douta <= mem(to_integer(unsigned(addra)));

            -- write
            if (wea(0) = '1') then
                mem(to_integer(unsigned(addra))) <= dina;
            end if;

        end if;
    end process;
end architecture;