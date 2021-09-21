library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MIPS_top is
    port(
	clk			: in std_logic;
	rst			: in std_logic;
	port_en		: in std_logic;
	port_sel		: in std_logic;
	port_in		: in std_logic_vector(8 downto 0);
	port_out		: out std_logic_vector(9 downto 0));
end MIPS_top;

architecture struct of MIPS_top is

	component datapath
		port (
			clk			: in std_logic;
			rst			: in std_logic;
			port_en		: in std_logic;
			port_sel		: in std_logic;
			port_in		: in std_logic_vector(8 downto 0);
			port_out		: out std_logic_vector(9 downto 0);
			opcode		: out std_logic_vector(5 downto 0);
			ir				: out std_logic_vector(5 downto 0);
			branch_tkn	: out std_logic;
			pcwrite		: in std_logic;
			iord			: in std_logic;
			memread		: in std_logic;
			memwrite		: in std_logic;
			memtoreg		: in std_logic;
			irwrite		: in std_logic;
			jmpandlnk	: in std_logic;
			issigned		: in std_logic;
			pcsource		: in std_logic_vector(1 downto 0);
			aluop			: in std_logic_vector(1 downto 0);
			alusrcb		: in std_logic_vector(1 downto 0);
			alusrca		: in std_logic;
			regwrite		: in std_logic;
			regdst		: in std_logic);
	end component;

	component controller
		port(
			clk			: in std_logic;
			rst			: in std_logic;
			opcode		: in std_logic_vector(5 downto 0);
			ir				: in std_logic_vector(5 downto 0);
			branch_tkn	: in std_logic;
			pcwrite		: out std_logic;
			iord			: out std_logic;
			memread		: out std_logic;
			memwrite		: out std_logic;
			memtoreg		: out std_logic;
			irwrite		: out std_logic;
			jmpandlnk	: out std_logic;
			issigned		: out std_logic;
			pcsource		: out std_logic_vector(1 downto 0);
			aluop			: out std_logic_vector(1 downto 0);
			alusrcb		: out std_logic_vector(1 downto 0);
			alusrca		: out std_logic;
			regwrite		: out std_logic;
			regdst		: out std_logic);
	end component;
	
	component not_gate
		port (
			input  : in std_logic;
			output : out std_logic);
	end component;
	
	signal rst_temp	: std_logic;
	signal opcode		: std_logic_vector(5 downto 0);
	signal ir			: std_logic_vector(5 downto 0);
	signal branch_tkn	: std_logic;
	signal pcwrite		: std_logic;
	signal iord			: std_logic;
	signal memread		: std_logic;
	signal memwrite	: std_logic;
	signal memtoreg	: std_logic;
	signal irwrite		: std_logic;
	signal jmpandlnk	: std_logic;
	signal issigned	: std_logic;
	signal pcsource	: std_logic_vector(1 downto 0);
	signal aluop		: std_logic_vector(1 downto 0);
	signal alusrcb		: std_logic_vector(1 downto 0);
	signal alusrca		: std_logic;
	signal regwrite	: std_logic;
	signal regdst		: std_logic;

begin

	U_NOT_GATE : not_gate
		port map (
			input 	=> rst,
			output	=> rst_temp);
	
	U_DATAPATH : datapath
		port map (
			clk			=> clk,
			rst			=> rst_temp,
			port_en		=> port_en,
			port_sel		=> port_sel,
			port_in		=> port_in,
			port_out		=> port_out,
			opcode		=> opcode,
			ir				=> ir,
			branch_tkn	=> branch_tkn,
			pcwrite		=> pcwrite,
			iord			=> iord,
			memread		=> memread,
			memwrite		=> memwrite,
			memtoreg		=> memtoreg,
			irwrite		=> irwrite,
			jmpandlnk	=> jmpandlnk,
			issigned		=> issigned,
			pcsource		=> pcsource,
			aluop			=> aluop,
			alusrcb		=> alusrcb,
			alusrca		=> alusrca,
			regwrite		=> regwrite,
			regdst		=> regdst);

	U_CONTROLLER : controller
		port map (
			clk			=> clk,
			rst			=> rst_temp,
			opcode		=> opcode,
			ir				=> ir,
			branch_tkn	=> branch_tkn,
			pcwrite		=> pcwrite,
			iord			=> iord,
			memread		=> memread,
			memwrite		=> memwrite,
			memtoreg		=> memtoreg,
			irwrite		=> irwrite,
			jmpandlnk	=> jmpandlnk,
			issigned		=> issigned,
			pcsource		=> pcsource,
			aluop			=> aluop,
			alusrcb		=> alusrcb,
			alusrca		=> alusrca,
			regwrite		=> regwrite,
			regdst		=> regdst);
	
end struct;