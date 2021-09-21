library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity memory_tb is
end memory_tb;

architecture TB of memory_tb is
	 
	 component memory
	 
			generic (
				width : positive := 32
			);
			port (
				clk 		: in std_logic;
				data_in 	: in std_logic_vector(width-1 downto 0);
				addr		: in std_logic_vector(width-1 downto 0);
				wren 		: in std_logic;
				rden		: in std_logic;
				data_out : out std_logic_vector(width-1 downto 0);
				port_sel : in std_logic;
				port_en	: in std_logic;
				port_in	: in std_logic_vector(width-1 downto 0);
				outport	: out std_logic_vector(9 downto 0));
				
	 end component;

    constant WIDTH  		: positive                           := 32;
		
	 signal clk				: std_logic									 := '0';
    signal data_in   	: std_logic_vector(WIDTH-1 downto 0) := (others => '0');
    signal addr   		: std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	 signal wren			: std_logic := '0';
	 signal rden			: std_logic := '0';
    signal port_sel     : std_logic := '0';
	 signal port_en		: std_logic := '1';
	 signal port_in		: std_logic_vector(WIDTH-1 downto 0) := (others => '0');
    signal data_out   	: std_logic_vector(WIDTH-1 downto 0);
    signal outport 		: std_logic_vector(9 downto 0);

begin  -- TB

    UUT : memory
        generic map (WIDTH => WIDTH)
        port map (
            clk 		=> clk,
				data_in 	=> data_in,
				addr		=> addr,
				wren 		=> wren,
				rden		=> rden,
				data_out => data_out,
				port_sel => port_sel,
				port_en	=> port_en,
				port_in	=> port_in,
				outport	=>outport);
				
	 clk <= not clk after 10 ns;

    process
    begin

        -- RAM write 1
        wren <= '1';
		  rden <= '0';
		  data_in <= "00001010000010100000101000001010";
		  addr 	 <= "00000000000000000000000000000000";
        wait for 40 ns;
        
		  -- RAM write 2
		  wren <= '1';
		  rden <= '0';
		  data_in <= "11110000111100001111000011110000";
		  addr 	 <= "00000000000000000000000000000100";
        wait for 40 ns;

		  -- RAM read 1
		  wren <= '0';
		  rden <= '1';
		  addr <= "00000000000000000000000000000000";
		  wait for 40 ns;
		  assert (data_out = "00001010000010100000101000001010") report "RAM read 1 incorrect" severity warning;
		  wait for 40 ns;
		  
		  -- RAM read 2
		  addr <= "00000000000000000000000000000001";
		  wait for 40 ns;
		  assert (data_out = "00001010000010100000101000001010") report "RAM read 2 incorrect" severity warning;
		  wait for 40 ns;
		  
		  -- RAM read 3
		  addr 	 <= "00000000000000000000000000000100";
		  wait for 40 ns;
		  assert (data_out = "11110000111100001111000011110000") report "RAM read 3 incorrect" severity warning;
		  wait for 40 ns;
		  
		  -- RAM read 4
		  addr 	 <= "00000000000000000000000000000101";
		  wait for 40 ns;
		  assert (data_out = "11110000111100001111000011110000") report "RAM read 4 incorrect" severity warning;
		  wait for 40 ns;
		  wren <= '0';
		  rden <= '0';
		  
		  -- outport write
		  wren <= '1';
		  rden <= '0';
		  data_in <= "00000000000000000001000100010001";
		  addr	 <= "00000000000000001111111111111100";
		  wait for 40 ns;
		  
		  -- output read
		  wren <= '0';
		  assert (outport = "0100010001") report "outport read incorrect" severity warning;
		  wait for 40 ns;
		  
		  -- port 0 write
		  port_en <= '0';
		  port_sel <= '0';
		  port_in <= "00000000000000000000000000010000";
		  addr 	 <= "00000000000000001111111111111000";
        wait for 40 ns;
		  
		  -- port 1 write
		  port_en <= '0';
		  port_sel <= '1';
		  port_in <= "00000000000000000000000000000001";
		  addr 	 <= "00000000000000001111111111111100";
        wait for 40 ns;
		  
		  -- port 0 read
		  wren <= '0';
		  rden <= '1';
		  addr 	 <= "00000000000000001111111111111000";
		  wait for 40 ns;
		  assert (data_out = "00000000000000000000000000010000") report "port 0 read incorrect" severity warning;
		  wait for 40 ns;
		  
		  -- port 1 read
		  wren <= '0';
		  rden <= '1';
		  addr 	 <= "00000000000000001111111111111100";
		  wait for 40 ns;
		  assert (data_out = "00000000000000000000000000000001") report "port 1 read incorrect" severity warning;
		  wait for 40 ns;
		  
		  report "Simulation finished";
        wait;

    end process;

end TB;
