library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity memory is
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
end memory;
		
architecture bhv of memory is

	component RAM
		port (
			clock		: in std_logic;
			data 		: in std_logic_vector(31 downto 0);
			wren 		: in std_logic;
			address 	: in std_logic_vector(7 downto 0);
			q			: out std_logic_vector(31 downto 0));
	end component;
	
	component reg
		port (
			clk    : in  std_logic;
			rst    : in  std_logic;
			en	  : in  std_logic;
			input  : in  std_logic_vector(width-1 downto 0);
			output : out std_logic_vector(width-1 downto 0));
	end component;
	
	component mux_4x1
		port (
			in1    : in  std_logic_vector(width-1 downto 0);
			in2    : in  std_logic_vector(width-1 downto 0);
			in3    : in  std_logic_vector(width-1 downto 0);
			in4    : in  std_logic_vector(width-1 downto 0);
			sel    : in  std_logic_vector(1 downto 0);
			output : out std_logic_vector(width-1 downto 0));
	end component;
	
	component memory_controller
		port (
			sel 		: out std_logic_vector(1 downto 0);
			wr_ram	: out std_logic;
			port0_en	: out std_logic;
			port1_en : out std_logic;
			oport_en	: out std_logic;
			wren		: in std_logic;
			rden		: in std_logic;
			port_en	: in std_logic;
			port_sel	: in std_logic;
			addr		: in std_logic_vector(31 downto 0));
	end component;
	
	signal ram_out 			: std_logic_vector(31 downto 0);
	signal port0_out, port1_out			: std_logic_vector(31 downto 0);
	signal sel					: std_logic_vector(1 downto 0);
	signal outport_buff		: std_logic_vector(31 downto 0);
	signal wr_ram, port1_en, port0_en, oport_en			: std_logic;

begin

	U_RAM : RAM port map (
		address	=> addr(9 downto 2),
		clock	 	=> clk,
		data	 	=> data_in,
		wren	 	=> wr_ram,
		q			=> ram_out);
		
	U_MUX : mux_4x1 port map (
		in1    => ram_out,
		in2    => port0_out,
		in3	 => port1_out,
		in4	 => "00000000000000000000000000000000",
		sel    => sel,
		output => data_out);
		
	U_CONT : memory_controller port map (
		sel 		=> sel,
		wr_ram	=> wr_ram,
		port0_en	=> port0_en,
		port1_en => port1_en,
		oport_en	=> oport_en,
		wren		=> wren,
		rden		=> rden,
		port_en	=> port_en,
		port_sel	=> port_sel,
		addr		=> addr);
		
	PORT0 : reg port map (
		clk    => clk,
		rst    => '0',
		en	  	 => port0_en,
		input  => port_in,
		output => port0_out);
		
	PORT1 : reg port map (
		clk    => clk,
		rst    => '0',
		en	  	 => port1_en,
		input  => port_in,
		output => port1_out);
		
	U_OUTPORT : reg port map (
		clk    => clk,
		rst    => '0',
		en	  	 => oport_en,
		input  => data_in,
		output => outport_buff);

	outport <= outport_buff(9 downto 0);

end bhv;