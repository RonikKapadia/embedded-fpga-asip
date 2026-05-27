-- library declaration
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- entity
entity irMem is
    port (
        clka : in std_logic;
        addra : in std_logic_vector (13 downto 0);
        douta : out std_logic_vector (31 downto 0)
    );
end irMem;

-- architecture
architecture irMem of irMem is

    -- intermediate signals
    type mem_type is array (16383 downto 0) of std_logic_vector(31 downto 0);
    signal mem : mem_type := (
		0 => "10010000110000000000000000000000",
		1 => "10010001000000000000000000000000",
		2 => "10010001010000000000000000000010",
		3 => "10010001100000000010000000000000",
		4 => "10011001110001100000000000000000",
		5 => "10000001110000000000000000010010",
		6 => "01011001110000000000000000000000",
		7 => "00000000110001100101000000000000",
		8 => "11000000000000000010000000000000",
		9 => "01100010000000000000000000000000",
		10 => "10000001000011000000000000010010",
		11 => "01110001000100000000000000000000",
		12 => "00000001000010000101000000000000",
		13 => "11000000000000000101000000000000",
		others => (others => '0')
	);

begin
    
    process(clka)
    begin
        if rising_edge(clka) then

            -- read
            douta <= mem(to_integer(unsigned(addra)));

        end if;
    end process;
    
end architecture;