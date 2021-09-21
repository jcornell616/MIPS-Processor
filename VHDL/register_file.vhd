library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity register_file is
	 generic (
		WIDTH : positive := 32
	 );
    port(
        clk : in std_logic;
        rst : in std_logic;
        rd_addr0 : in std_logic_vector(4 downto 0);
        rd_addr1 : in std_logic_vector(4 downto 0);
        wr_addr : in std_logic_vector(4 downto 0);
        wr_en : in std_logic;
		  jal	  : in std_logic;
        wr_data : in std_logic_vector(width-1 downto 0);
        rd_data0 : out std_logic_vector(width-1 downto 0);
        rd_data1 : out std_logic_vector(width-1 downto 0)
        );
end register_file;


architecture async_read of register_file is
    type reg_array is array(0 to 31) of std_logic_vector(width-1 downto 0);
    signal regs : reg_array;
begin
    process (clk, rst) is
    begin
        if (rst = '1') then
            for i in regs'range loop
                regs(i) <= (others => '0');
            end loop;
        elsif (rising_edge(clk)) then

            if (wr_en = '1') then
                regs(to_integer(unsigned(wr_addr))) <= wr_data;
            end if;                
        end if;
    end process;

    rd_data0 <= regs(to_integer(unsigned(rd_addr0)));
    rd_data1 <= regs(to_integer(unsigned(rd_addr1)));
   
end async_read;


architecture sync_read_during_write of register_file is
    type reg_array is array(0 to 31) of std_logic_vector(width-1 downto 0);
    signal regs : reg_array;
    signal rd_addr0_r : std_logic_vector(4 downto 0);
    signal rd_addr1_r : std_logic_vector(4 downto 0);
    
begin
    process (clk, rst) is
    begin
        if (rst = '1') then
            for i in regs'range loop
                regs(i) <= (others => '0');
            end loop;
        elsif (rising_edge(clk)) then
            if (wr_en = '1') then
					if (jal = '1') then
					  regs(31) <= wr_data;
					else
                regs(to_integer(unsigned(wr_addr))) <= wr_data;
					end if;
            end if;

            rd_addr0_r <= rd_addr0;
            rd_addr1_r <= rd_addr1;
        end if;
    end process;

    rd_data0 <= regs(to_integer(unsigned(rd_addr0_r)));
    rd_data1 <= regs(to_integer(unsigned(rd_addr1_r)));
    
end sync_read_during_write;


architecture sync_read of register_file is
    type reg_array is array(0 to 31) of std_logic_vector(width-1 downto 0);
    signal regs : reg_array;
    
begin
    process (clk, rst) is
    begin
        if (rst = '1') then
            for i in regs'range loop
                regs(i) <= (others => '0');
            end loop;
        elsif (rising_edge(clk)) then
            if (wr_en = '1') then
                regs(to_integer(unsigned(wr_addr))) <= wr_data;
            end if;
				
				if (rd_addr0 = "00000" AND rd_addr1 = "00000") then
					rd_data0 <= "00000000000000000000000000000000";
					rd_data1 <= "00000000000000000000000000000000";
				elsif (rd_addr0 = "00000") then
					rd_data0 <= "00000000000000000000000000000000";
					rd_data1 <= regs(to_integer(unsigned(rd_addr1)));
				elsif (rd_addr1 = "00000") then
					rd_data0 <= regs(to_integer(unsigned(rd_addr0)));
					rd_data1 <= "00000000000000000000000000000000";
				else
					rd_data0 <= regs(to_integer(unsigned(rd_addr0)));
					rd_data1 <= regs(to_integer(unsigned(rd_addr1)));
				end if;
        end if;
    end process;
    
end sync_read;

