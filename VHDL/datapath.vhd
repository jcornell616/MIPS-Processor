library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity datapath is
generic (
		WIDTH : positive := 32);
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
end datapath;

architecture str of datapath is

	-----components-----
	component reg
		 port (
			clk    : in  std_logic;
			rst    : in  std_logic;
			en	  : in  std_logic;
			input  : in  std_logic_vector(width-1 downto 0);
			output : out std_logic_vector(width-1 downto 0));
	end component;
	
	component mux_2x1
		generic(
			WIDTH : positive);
		port (
			in1    : in  std_logic_vector(width-1 downto 0);
			in2    : in  std_logic_vector(width-1 downto 0);
			sel    : in  std_logic;
			output : out std_logic_vector(width-1 downto 0));
	end component;
	
	component mux_4x1
		port (
			in1    : in  std_logic_vector(width-1 downto 0);
			in2    : in  std_logic_vector(width-1 downto 0);
			in3	  : in  std_logic_vector(width-1 downto 0);
			in4    : in  std_logic_vector(width-1 downto 0);
			sel    : in  std_logic_vector(1 downto 0);
			output : out std_logic_vector(width-1 downto 0));
	end component;
	
	component memory
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
	
	component register_file
		port (
			clk : in std_logic;
			rst : in std_logic;
			rd_addr0 : in std_logic_vector(4 downto 0);
			rd_addr1 : in std_logic_vector(4 downto 0);
			wr_addr : in std_logic_vector(4 downto 0);
			wr_en : in std_logic;
			jal	  : in std_logic;
			wr_data : in std_logic_vector(width-1 downto 0);
			rd_data0 : out std_logic_vector(width-1 downto 0);
			rd_data1 : out std_logic_vector(width-1 downto 0));
	end component;
	
	component alu
		port (
			input1 : in std_logic_vector(WIDTH-1 downto 0);
			input2 : in std_logic_vector(WIDTH-1 downto 0);
			sel : in std_logic_vector(5 downto 0);
			shift : in std_logic_vector(4 downto 0);
			output : out std_logic_vector(WIDTH-1 downto 0);
			high_out : out std_logic_vector(WIDTH-1 downto 0);
			branch_taken : out std_logic);
	end component;
	
	component alu_controller
		port (
			opcode		: in std_logic_vector(5 downto 0);
			br				: in std_logic;
			ir				: in std_logic_vector(5 downto 0);
			aluop			: in std_logic_vector(1 downto 0);
			alu_sel		: out std_logic_vector(5 downto 0);
			alu_lo_hi	: out std_logic_vector(1 downto 0);
			hi_en			: out std_logic;
			lo_en			: out std_logic);
	end component;

	
	component sign_ext
		port (
			input : in std_logic_vector(15 downto 0);
			issigned : in std_logic;
			output : out std_logic_vector(31 downto 0);
			shifted_out : out std_logic_vector(31 downto 0));
	end component;
	--------------------
	
	------signals------
	signal pc_in						: std_logic_vector(width-1 downto 0);
	signal pc_out						: std_logic_vector(width-1 downto 0);
	signal alu_out_reg_out			: std_logic_vector(width-1 downto 0);
	signal memory_addr_in			: std_logic_vector(width-1 downto 0);
	signal memory_data_out			: std_logic_vector(width-1 downto 0);
	signal memory_data_reg_out		: std_logic_vector(width-1 downto 0);
	signal inst_out					: std_logic_vector(width-1 downto 0);
	signal write_reg_file			: std_logic_vector(4 downto 0);
	signal alu_out_to_reg_file		: std_logic_vector(width-1 downto 0);
	signal reg_file_write_data		: std_logic_vector(width-1 downto 0);
	signal reg_file_out0				: std_logic_vector(width-1 downto 0);
	signal reg_file_out1				: std_logic_vector(width-1 downto 0);
	signal reg_a_out					: std_logic_vector(width-1 downto 0);
	signal reg_b_out					: std_logic_vector(width-1 downto 0);
	signal alu_in0						: std_logic_vector(width-1 downto 0);
	signal alu_in1						: std_logic_vector(width-1 downto 0);
	signal sign_ext_out				: std_logic_vector(width-1 downto 0);
	signal alu_high_out				: std_logic_vector(width-1 downto 0);
	signal alu_out						: std_logic_vector(width-1 downto 0);
	signal alu_lo_out					: std_logic_vector(width-1 downto 0);
	signal alu_hi_out					: std_logic_vector(width-1 downto 0);
	signal lo_en						: std_logic;
	signal hi_en						: std_logic;
	signal alu_lo_hi					: std_logic_vector(1 downto 0);
	signal sign_ext_shifted_out	: std_logic_vector(width-1 downto 0);
	signal alu_sel						: std_logic_vector(5 downto 0);
	signal port_in_buff				: std_logic_vector(width-1 downto 0);
	signal pc_in_mux_buff			: std_logic_vector(width-1 downto 0);
	signal branch_out					: std_logic_vector(width-1 downto 0);
	-------------------
begin

	port_in_buff 	<= "00000000000000000000000" & port_in;
	pc_in_mux_buff	<= pc_out(31 downto 28) & std_logic_vector(shift_left(unsigned("00" & inst_out(25 downto 0)), 2));

	PC : reg
		port map (
			clk		=> clk,
			rst		=> rst,
			en			=> pcwrite,	  	
			input  	=> pc_in,
			output	=> pc_out);

	PC_OUT_MUX : mux_2x1
		generic map (
			WIDTH => 32)
		port map (
			in1		=> pc_out,
			in2    	=> alu_out_reg_out,
			sel    	=> iord,
			output 	=> memory_addr_in);
			
	MEM : memory
		port map (
			clk 						=> clk,
			data_in 					=> reg_b_out,
			addr						=> memory_addr_in,
			wren 						=> memwrite,
			rden						=> memread,
			data_out 				=> memory_data_out,
			port_en 					=> port_en,
			port_sel					=> port_sel,
			port_in					=> port_in_buff,
			outport	=> port_out);
			
	MEM_DATA : reg
		port map (
			clk		=> clk,
			rst		=> rst,
			en			=> '1',	  	
			input  	=> memory_data_out,
			output	=> memory_data_reg_out);
			
	INST_REG : reg
		port map (
			clk		=> clk,
			rst		=> rst,
			en			=> irwrite,	  	
			input  	=> memory_data_out,
			output	=> inst_out);
			
	INST_MUX : mux_2x1
		generic map (
            WIDTH => 5)
		port map (
			in1		=> inst_out(20 downto 16),
			in2    	=> inst_out(15 downto 11),
			sel    	=> regdst,
			output 	=> write_reg_file);
			
	U_SIGN_EXT : sign_ext
		port map (
			input 		=> inst_out(15 downto 0),
			issigned 	=> issigned,
			output 		=> sign_ext_out,
			shifted_out => sign_ext_shifted_out);
			
	MEM_DATA_REG : mux_2x1
		generic map (
			WIDTH => 32)
		port map (
			in1		=> alu_out_to_reg_file,
			in2    	=> memory_data_reg_out,
			sel    	=> memtoreg,
			output 	=> reg_file_write_data);
			
	REG_FILE : register_file
		port map (
			clk 		=> clk,
			rst 		=> rst,
			rd_addr0 => inst_out(25 downto 21),
			rd_addr1 => inst_out(20 downto 16),
			wr_addr 	=> write_reg_file,
			wr_en 	=> regwrite,
			jal	  	=> jmpandlnk,
			wr_data 	=> reg_file_write_data,
			rd_data0 => reg_file_out0,
			rd_data1 => reg_file_out1);
			
	REG_A : reg
		port map (
			clk		=> clk,
			rst		=> rst,
			en			=> '1',	  	
			input  	=> reg_file_out0,
			output	=> reg_a_out);
			
	REG_B : reg
		port map (
			clk		=> clk,
			rst		=> rst,
			en			=> '1',	  	
			input  	=> reg_file_out1,
			output	=> reg_b_out);
			
	REG_A_MUX : mux_2x1
		generic map (
			WIDTH => 32)
		port map (
			in1		=> pc_out,
			in2    	=> reg_a_out,
			sel    	=> alusrca,
			output 	=> alu_in0);
			
	REG_B_MUX : mux_4x1
		port map (
			in1    => reg_b_out,
			in2    => std_logic_vector(to_unsigned(4, 32)),
			in3	 => sign_ext_out,
			in4    => sign_ext_shifted_out,
			sel    => alusrcb,
			output => alu_in1);
			
	ALU_CONT : alu_controller
		port map (
			opcode		=> inst_out(31 downto 26),
			br				=> inst_out(16),
			ir				=> inst_out(5 downto 0),
			aluop			=> aluop,
			alu_sel		=> alu_sel,
			alu_lo_hi	=> alu_lo_hi,
			hi_en			=> hi_en,
			lo_en			=> lo_en);
			
	U_ALU : alu
		port map (
			input1 			=> alu_in0,
			input2 			=> alu_in1,
			sel 				=> alu_sel,
			shift 			=> inst_out(10 downto 6),
			output 			=> alu_out,
			high_out 		=> alu_high_out,
			branch_taken	=> branch_tkn);
			
	ALU_OUT_REG : reg
		port map (
			clk		=> clk,
			rst		=> rst,
			en			=> '1',	  	
			input  	=> alu_out,
			output	=> alu_out_reg_out);
			
	ALU_LO: reg
		port map (
			clk		=> clk,
			rst		=> rst,
			en			=> lo_en,
			input  	=> alu_out,
			output	=> alu_lo_out);
	
	ALU_HI : reg
		port map (
			clk		=> clk,
			rst		=> rst,
			en			=> hi_en,	  	
			input  	=> alu_high_out,
			output	=> alu_hi_out);
			
	BRANCH_PC : reg
		port map (
			clk		=> clk,
			rst		=> rst,
			en			=> '1',	  	
			input  	=> alu_out_reg_out,
			output	=> branch_out);
			
	ALU_MUX : mux_4x1
		port map (
			in1    => alu_out,
			in2    => alu_lo_out,
			in3	 => alu_hi_out,
			in4    => std_logic_vector(to_unsigned(0, 32)),
			sel    => alu_lo_hi,
			output => alu_out_to_reg_file);
			
	PC_IN_MUX : mux_4x1
		port map (
			in1    => alu_out,
			in2    => branch_out,
			in3	 => pc_in_mux_buff,
			in4    => std_logic_vector(to_unsigned(0, 32)),
			sel    => pcsource,
			output => pc_in);
			
	opcode <= inst_out(31 downto 26);
	ir 	 <= inst_out(5 downto 0);
	
end str;