library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity VGA_DRIVER1 is
    Port(
        R: out std_logic_vector(3 downto 0);
        G: out std_logic_vector(3 downto 0);
        B: out std_logic_vector(3 downto 0);
        clk:in std_logic;
        Hsync: out std_logic;
        Vsync: out std_logic
--        i1 : out integer;
--        j1 : out integer;
--        reg11 : out integer;
--        reg22 : out integer;
--        reg33 : out integer;
--        ram_d : out std_logic_vector(7 downto 0);
--        rom_d : out std_logic_vector(7 downto 0);
--        pixel : out integer;
--        H_counter : out integer;
--        V_counter : out integer;
--        Video_On_sig : out std_logic
    );
end VGA_DRIVER1;

architecture Behavioral of VGA_DRIVER1 is

    signal clk_slow : std_logic:='0';
    signal hcnt: integer:=0;
    signal reset : std_logic :='0';
    signal Vcnt: integer:=0;
    signal reg10 : integer :=0;
    signal reg20 : integer :=0;
    signal reg30 : integer :=0;
    signal Video_On: std_logic:='0';


    constant HACTIVE: integer:=639;
    constant HFRONT: integer:=16;
    constant HSYNC_PIXEL: integer:=96;
    constant HBACK: integer:=48;
    constant VACTIVE: integer:=479;
    constant VFRONT: integer:=10;
    constant VSYNC_PIXEL: integer:=2;
    constant VBACK: integer:=33;
    signal rom_add: std_logic_vector(15 downto 0) := (others => '0');
    signal data_to_read: std_logic_vector(7 downto 0) := (others => '0');
    signal ram_add : std_logic_vector(15 downto 0) := (others => '0');
    signal data_to_write : std_logic_vector(7 downto 0) := (others => '0');
    signal write_enable: std_logic:= '0';
    signal ram_out : std_logic_vector(7 downto 0) := (others => '0');
    signal i,j: integer:=0;
    signal pixel_idx: integer:=0;
    signal wr_comp: integer :=0;
    signal image_cnt: integer :=0;

    component dist_mem_gen_0
        port(a: in std_logic_vector(15 downto 0);
             spo: out std_logic_vector(7 downto 0);
             clk: in std_logic);
    end component;

    component dist_mem_gen_1
        port(a: in std_logic_vector(15 downto 0);
             d:in std_logic_vector(7 downto 0);
             clk: in std_logic;
             we: in std_logic;
             spo:out std_logic_vector(7 downto 0));
    end component;

begin

-------------Clock Divider-----------------------------------
process(clk)
variable helper : integer := 0;
begin
    if(rising_edge(clk)) then
        case helper is
        when 0 =>
            clk_slow <= '1';
            helper := helper+1;
        when 1 =>
            helper := helper+1;
        when 2 =>
            clk_slow <= '0';
            helper := helper+1;
        when others =>
            helper := 0;
        end case;
    end if;
end process;
---------------------------------------------------------------

rom: dist_mem_gen_0 port map(a=>rom_add,clk=>clk_slow,spo=>data_to_read);

ram: dist_mem_gen_1 port map(a=>ram_add,d=>data_to_write,clk=>clk_slow,we=>write_enable,spo=>ram_out);
-----------------------------------------------------------------
--ram_d <= data_out_rom;

--i1<=i;
--j1<=j;
--reg11 <= reg10;--------------These signals are used for testbenches
--reg22 <= reg20;---------------so they are commented out in synthesis.
--reg33 <= reg30;
--rom_d <= data_in;
--------------------------------------------------------------------
--i1 <= i;
--j1 <= j;
--rom_d <= data_to_read;---------These signals are used for test benches so they 
--ram_d <= ram_out;--------------are commented out in synthesis.
--H_counter <= hcnt;
--V_counter <= vcnt;
--Video_On_sig <= video_On;

process(clk_slow)
variable reg1, reg2, reg3 : integer :=0;
variable sum: integer :=0;
begin
    if(i<256) then
        if(rising_edge(clk_slow)) then
            if(j=0) then
                if(wr_comp=0) then
                    if(j/=0) then
                        reg1 := reg2;
                    end if;
                        wr_comp<=wr_comp+1;
                end if;
                if(wr_comp=1) then
                    reg2 := reg3;
                    wr_comp<=wr_comp+1;
                end if;
                if(wr_comp=2) then
                    if(j/=255) then
                        rom_add<=std_logic_vector(to_unsigned(256*i+j+1, 16));
                    end if;
                    reg3:=to_integer(unsigned(data_to_read));
                    wr_comp<=wr_comp+1;
                end if;
                    if(wr_comp=3) then
                        if(j=0) then
                            if(-2*reg2+reg3<0) then
                                sum:=0;
                            elsif(-2*reg2+reg3>255) then
                                sum:=255;
                            else
                                sum:=-2*reg2+reg3;
                            end if;
                        elsif (j=255) then
                            if(reg1-2*reg2<0) then
                                sum:=0;
                            elsif(reg1-2*reg2>255) then
                                sum:=255;
                            else
                                sum:=reg1-2*reg2;
                            end if;
                        else
                            if(reg1-2*reg2+reg3<0) then
                                sum:=0;
                            elsif(reg1-2*reg2+reg3>255) then
                                sum:=255;
                            else
                                sum:=reg1-2*reg2+reg3;
                            end if;
                        end if;
                        wr_comp<=wr_comp+1;
                    end if;
                    if(wr_comp=4) then
                        data_to_write<=std_logic_vector(to_unsigned(sum, 8));
                        wr_comp<=wr_comp+1;
                    end if;
                    if(wr_comp=5) then
                        wr_comp<=wr_comp+1;
                    end if;
                    if(wr_comp=6) then
                        sum:=0;
                        if(j=255)then
                            j<=0;
                            i<=i+1;
                        else
                            j<=j+1;
                        end if;
                        pixel_idx<=pixel_idx+1;
                        wr_comp<=0;
                    end if;
            elsif(j=255) then
                if(wr_comp=0) then
                    if(j/=0) then
                        reg1 := reg2;
                    end if;
                    wr_comp<=wr_comp+1;
                end if;
                if(wr_comp=1) then
                    reg2 := reg3;
                    wr_comp<=wr_comp+1;
                end if;
                if(wr_comp=2) then
                    if(j/=255) then
                        rom_add<=std_logic_vector(to_unsigned(256*i+j+1, 16));
                    end if;
                    reg3:=to_integer(unsigned(data_to_read));
                    wr_comp<=wr_comp+1;
                end if;
                if(wr_comp=3) then
                    if(j=0) then
                        if(-2*reg2+reg3<0) then
                            sum:=0;
                        elsif(-2*reg2+reg3>255) then
                            sum:=255;
                        else
                            sum:=-2*reg2+reg3;
                        end if;
                    elsif (j=255) then
                        if(reg1-2*reg2<0) then
                            sum:=0;
                        elsif(reg1-2*reg2>255) then
                            sum:=255;
                        else
                            sum:=reg1-2*reg2;
                        end if;
                    else
                        if(reg1-2*reg2+reg3<0) then
                            sum:=0;
                        elsif(reg1-2*reg2+reg3>255) then
                            sum:=255;
                        else
                            sum:=reg1-2*reg2+reg3;
                        end if;
                    end if;
                    wr_comp<=wr_comp+1;
                end if;
                if(wr_comp=4) then
                    data_to_write<=std_logic_vector(to_unsigned(sum, 8));
                    wr_comp<=wr_comp+1;
                end if;
                if(wr_comp=5) then
                    wr_comp<=wr_comp+1;
                end if;
                if(wr_comp=6) then
                    sum:=0;
                    if(j=255)then
                        j<=0;
                        i<=i+1;
                    else
                        j<=j+1;
                    end if;
                    pixel_idx<=pixel_idx+1;
                    wr_comp<=0;
                end if;
            else
                if(wr_comp=0) then
                    if(j/=0) then
                        reg1 := reg2;
                    end if;
                    wr_comp<=wr_comp+1;
                end if;
                if(wr_comp=1) then
                    reg2 := reg3;
                        wr_comp<=wr_comp+1;
                end if;
                if(wr_comp=2) then
                    if(j/=255) then
                        rom_add<=std_logic_vector(to_unsigned(256*i+j+1, 16));
                    end if;
                    reg3:=to_integer(unsigned(data_to_read));
                    wr_comp<=wr_comp+1;
                end if;
                if(wr_comp=3) then
                    if(j=0) then
                        if(-2*reg2+reg3<0) then
                            sum:=0;
                        elsif(-2*reg2+reg3>255) then
                            sum:=255;
                        else
                            sum:=-2*reg2+reg3;
                        end if;
                    elsif (j=255) then
                        if(reg1-2*reg2<0) then
                            sum:=0;
                        elsif(reg1-2*reg2>255) then
                            sum:=255;
                        else
                            sum:=reg1-2*reg2;
                        end if;
                    else
                        if(reg1-2*reg2+reg3<0) then
                            sum:=0;
                        elsif(reg1-2*reg2+reg3>255) then
                            sum:=255;
                        else
                            sum:=reg1-2*reg2+reg3;
                        end if;
                    end if;
                    wr_comp<=wr_comp+1;
                end if;
                if(wr_comp=4) then
                    if(j<4) then
                        data_to_write<=std_logic_vector(to_unsigned(sum, 8));
                    else
                        data_to_write<=std_logic_vector(to_unsigned(sum, 8));
                    end if;
                        wr_comp<=wr_comp+1;
                end if;
                if(wr_comp=5) then
                    wr_comp<=wr_comp+1;
                end if;
                if(wr_comp=6) then
                    sum:=0;
                    if(j=255)then
                        j<=0;
                        i<=i+1;
                    else
                        j<=j+1;
                    end if;
                    pixel_idx<=pixel_idx+1;
                    wr_comp<=0;
                end if;
            end if;
        end if;
    end if;
--reg11 <= reg1;
--reg22 <= reg2;--------These signals are used for testbenches
--reg33 <= reg3;--------so they are commented out in synthesis part.
--pixel <= sum;
end process;
-----------------------------------------------------------

--------------------------This Process assigns values to ram_add ------------------------
--------------------------in image_gradient operation and in image display---------------
--------------------------This acts as ram_add controller ------------------------------- 
process(clk_slow)
begin
    if(rising_edge(clk_slow)) then
        if( pixel_idx<65536) then
            ram_add<=std_logic_vector(TO_UNSIGNED(256*i+j, 16));
            write_enable<='1';
        else
            ram_add<=std_logic_vector(TO_UNSIGNED(image_cnt, 16));
            write_enable<='0';
        end if;
    end if;
end process;
----------------------------------------------------------------------------

--------VGA Controller--------------------------------------------------------
--------This process controlls the draw process of image----------------------
process(reset,clk_slow , hcnt, Vcnt, Video_On)
begin
    if(pixel_idx=65536) then
        if(reset='1') then
            R<=(others => '0');G <= (others=>'0');B<=(others =>'0');
        elsif(rising_edge(clk_slow)) then
            if (Video_On='1') then
                if((hcnt>=10+90 and hcnt<=265+90 ) and (Vcnt>=10+90 and Vcnt<=265+90 )) then
                    R <= ram_out(7 downto 4);
                    G <= ram_out(7 downto 4);
                    B <= ram_out(7 downto 4);
                    if(hcnt=265+90 and Vcnt=265+90) then
                        image_cnt<=0;
                    else
                        image_cnt<=image_cnt+1;
                    end if;
                else
                    R<=(others => '0');
                    G<=(others => '0');
                    B<=(others => '0');
                end if;
            else
                R<=(others => '0');
                G<=(others => '0');
                B<=(others => '0');
            end if;
        end if;
    end if;
end process;
---------------------------------------------------------------------


-------------- Horizontal Counter------------------------------------
process(clk_slow,reset)
begin
    if(reset='1') then
        hcnt<=0;
    elsif(rising_edge(clk_slow)) then
        if(hcnt= HACTIVE+HFRONT+HSYNC_PIXEL+HBACK) then
            hcnt<=0;
        else
            hcnt<=hcnt+1;
        end if;
    end if;
end process;
--------------------------------------------------------------------

---------------Vertical Counter--------------------------------------
process(clk_slow,hcnt,reset)
begin
    if(reset='1') then
        Vcnt<=0;
    elsif(rising_edge(clk_slow)) then
        if(hcnt= HACTIVE+HFRONT+HSYNC_PIXEL+HBACK) then
            if(Vcnt= VACTIVE+VFRONT+VSYNC_PIXEL+VBACK) then
                Vcnt<=0;
            else
                Vcnt<=Vcnt+1;
            end if;
        end if;
    end if;
end process;
----------------------------------------------------------------------

--------------Horizontal Synchronization------------------------------
process(clk_slow,hcnt,reset)
begin
    if(reset='1') then
        Hsync <= '0';
    elsif(rising_edge(clk_slow)) then
        if(hcnt<=(HACTIVE+HFRONT) or hcnt>(HACTIVE+HFRONT+HSYNC_PIXEL)) then
            Hsync<='1';
                else
            Hsync<='0';
        end if;
    end if;
end process;
----------------------------------------------------------------------------

------------Vertical Synchronization----------------------------------------
process(clk_slow,Vcnt,reset)
begin
    if(reset='1') then
        Vsync <= '0';
    elsif(rising_edge(clk_slow)) then
        if(Vcnt<=(VACTIVE+VFRONT) or Vcnt>(VACTIVE+VFRONT+VSYNC_PIXEL)) then
            Vsync<='1';
        else
            Vsync<='0';
        end if;
    end if;
end process;
------------------------------------------------------------------------------

-------------------Video_On process-------------------------------------------
process(reset,clk_slow,hcnt,Vcnt)
begin
    if(reset='1') then
        Video_On <= '0';
    elsif(rising_edge(clk_slow)) then
        if(hcnt<=HACTIVE and Vcnt<=VACTIVE) then
            Video_On<='1';
        else
            Video_On<='0';
        end if;
    end if;
end process;
------------------------------------------------------------------------------


end Behavioral;

