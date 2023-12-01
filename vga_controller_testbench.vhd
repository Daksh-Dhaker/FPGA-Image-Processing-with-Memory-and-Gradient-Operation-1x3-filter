----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 13.10.2023 21:43:01
-- Design Name: 
-- Module Name: vga_controller_sim - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity vga_controller_sim is
end vga_controller_sim;

architecture Behavioral of vga_controller_sim is
    signal HSYNC : std_logic;
    signal VSYNC : std_logic;
    signal clock : std_logic :='0';
    signal Hcnt : integer;
    signal Vcnt : integer;
    signal video_on: std_logic;
    constant clock_period : time := 10 ns;
    
     
    
    
    
    component VGA_DRIVER1
    port(  clk : in  STD_LOGIC; --100 MHz main clock.
           hsync : out  STD_LOGIC;
           vsync : out  STD_LOGIC;
           R,G,B : out  STD_LOGIC_VECTOR (3 downto 0);
           ram_d : out std_logic_vector(7 downto 0);
           reg11 :out integer;
           reg22 :out integer;
           reg33 :out integer;
           rom_d : out std_logic_vector(7 downto 0);
           i1: out integer;
           j1: out integer;
           pixel : out integer;
           H_counter : out integer;
           V_counter : out integer;
           Video_On_sig : out std_logic);
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
        hsync => Hsync,
        vsync => Vsync,
        R => open,
        G => open,
        B => open,
        ram_d => open,
        reg11 => open,
        reg22=> open,
        reg33 => open,
        rom_d => open,
        i1=> open,
        j1=>open,
        pixel=> open,
        H_counter => Hcnt,
        V_counter => Vcnt,
        Video_On_sig => video_on);

end Behavioral;
