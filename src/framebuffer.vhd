-- library declaration
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- entity
entity framebuffer is 
    port(
        clk1, en1, en2, ld : in std_logic;
        addr1, addr2 : in std_logic_vector(11 downto 0);
        wr_en1 : in std_logic;
        din1 : in std_logic_vector(15 downto 0);
        dout1, dout2 : out std_logic_vector(15 downto 0)
    );
end framebuffer;

-- architecture
architecture framebuffer of framebuffer is

    -- constants
    constant MEM_SIZE : integer := 4096;

    -- intermediate signals
    type mem_type is array (0 to MEM_SIZE-1) of std_logic_vector (15 downto 0);
    signal mem : mem_type := (others => (others => '0'));

    signal count : unsigned(11 downto 0) := (others => '0');
    
begin
    
    process(clk1)
    begin
        if rising_edge(clk1) then 

            -- reset
            if (ld = '1') or (count > 0) then

                mem(to_integer(count)) <= (others => '0');

                if (count < MEM_SIZE-1) then
                    count <= count + 1;
                else
                    count <= (others => '0');
                end if;
            
            else 

                -- cpu enable
                if (en1 = '1') then
                    -- read data
                    dout1 <= mem(to_integer(unsigned(addr1)));

                    -- write data
                    if (wr_en1 = '1') then
                        mem(to_integer(unsigned(addr1))) <= din1;
                    end if;

                end if;
                
                -- vga enable
                if (en2 = '1') then
                    -- output data to pixle_pusher
                    dout2 <= mem(to_integer(unsigned(addr2)));
                end if;

            end if;

        end if;
    end process;

end framebuffer;