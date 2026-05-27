-- library declaration
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- entity
entity top_tb is
end top_tb;

-- architecture
architecture top_tb of top_tb is

    -- components
    component top is
        port (
            CTS : out std_logic;
            RTS : out std_logic;
            RXD : in std_logic;
            TXD : out std_logic;
            btn : in std_logic;
            clk : in std_logic;
            vga_b : out std_logic_vector (4 downto 0);
            vga_g : out std_logic_vector (5 downto 0);
            vga_hs : out std_logic;
            vga_r : out std_logic_vector (4 downto 0);
            vga_vs : out std_logic
        );
    end component;

    -- intermedite signals
    signal CTS, RTS: std_logic := '1';
    signal clk: std_logic := '1';
    signal btn: std_logic := '0';
    signal RXD, TXD : std_logic := '1';
    signal vga_hs, vga_vs: std_logic := '0';
    signal vga_r: std_logic_vector(4 downto 0);
    signal vga_g: std_logic_vector(5 downto 0);
    signal vga_b: std_logic_vector(4 downto 0);

begin

    top_0: top
    port map(
        CTS => CTS,
        RTS => RTS,
        RXD => RXD,
        TXD => TXD,
        btn => btn, 
        clk => clk,
        vga_hs => vga_hs,
        vga_vs => vga_vs,
        vga_r => vga_r,
        vga_g => vga_g,
        vga_b => vga_b
    );

    process begin
        clk <= '0';
        wait for 4 ns;
        clk <= '1';
        wait for 4 ns;
    end process;

    process begin

        -- waiting
        wait for 200000 ns;

        -- rst
        btn <= '1';
        wait for 100000 ns;
        btn <= '0';

        -- wait to print hello world
        wait for 2400000 ns;
        
        -- rst
        btn <= '1';
        wait for 100000 ns;
        btn <= '0';
        
        -- wait to print hello world
        wait for 6000000 ns;
        
        -- initiate uart recieve
        RXD <= '0';
        wait for 4000 ns;
        RXD <= '1';

        -- wait to output data
        wait for 200000 ns;
        
        -- rst
        btn <= '1';
        wait for 100000 ns;
        btn <= '0';
        
        -- wait to print hello world
        wait for 6000000 ns;

        report "End of testbench" severity FAILURE;
    end process;

end top_tb;
