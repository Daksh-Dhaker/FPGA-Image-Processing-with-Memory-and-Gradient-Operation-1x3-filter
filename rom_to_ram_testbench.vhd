library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity rom_to_ram_sim is
end rom_to_ram_sim;

architecture Behavioral of rom_to_ram_sim is
    signal rom_data : std_logic_vector(7 downto 0);
       
    signal i : integer;
    signal j : integer;
    signal reg1 : integer;
    signal reg2 : integer;
    signal reg3 : integer;
    signal clock : std_logic := '0';
    signal ram_data : std_logic_vector(7 downto 0) := (others =>'0');
    constant clock_period : time := 10 ns;
   
    signal output_pixel : integer;
    
    component VGA_DRIVER1
    port(   clk : in  STD_LOGIC; 
           Hsync : out  STD_LOGIC;
           Vsync : out  STD_LOGIC;
           R,G,B : out  STD_LOGIC_VECTOR (3 downto 0);
           ram_d : out std_logic_vector(7 downto 0);
           reg11 :out integer;
           reg22 :out integer;
           reg33 :out integer;
           rom_d : out std_logic_vector(7 downto 0);
           i1: out integer;
           j1: out integer;
           pixel : out integer);
    end component;

begin

clock_process :process
begin
    clock <= '0';
    wait for clock_period/2;
    clock <= '1';
    wait for clock_period/2;
end process;

    u1: VGA_DRIVER1 port map(
        clk => clock,
        Hsync => open,
        Vsync => open,
        R => open,
        G => open,
        B => open,
        ram_d => ram_data,
        reg11 => reg1,
        reg22=> reg2,
        reg33 => reg3,
        rom_d => rom_data,
        i1=> i,
        j1=>j,
        pixel=>output_pixel);

end Behavioral;
