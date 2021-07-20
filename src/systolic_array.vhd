-- Cecil Symes

-- Instantiates PEs depending on the input generic size

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.Numeric_Std.all;

entity systolic_array is
	generic (
		size			: positive := 9
	);
	port (
		clk				: in std_logic := '0';
		en				: in std_logic := '0';
		out_res_in		: in std_logic := '0';
		img_data_in		: in std_logic_vector(7 downto 0) := x"00";
		weight_in		: in std_logic_vector(7 downto 0) := x"00"
	);
end entity systolic_array;

architecture behaviour of systolic_array is

	component processing_element is
	port (
		clk				: in std_logic;
		en				: in std_logic;
		out_res_in		: in std_logic;
		weight_in		: in std_logic_vector(7 downto 0);
		input_img_in	: in std_logic_vector(7 downto 0);
		
		output_map		: out std_logic_vector(7 downto 0) := x"00";
		weight_out		: out std_logic_vector(7 downto 0) := x"00";
		input_img_out	: out std_logic_vector(7 downto 0) := x"00";
		out_res_out		: out std_logic := '0'
	);
	end component;
	
	-- Connections for signals between PEs
	type logic_connect_type is array (0 to size-1) of std_logic;
	signal out_res_connect	: logic_connect_type;
	
	type data_connect_type is array (0 to size-1) of std_logic_vector(7 downto 0);
	signal weight_connect	: data_connect_type;
	signal input_connect	: data_connect_type;
	signal outputs_array	: data_connect_type := (others => x"00");
	
begin

-- Generate specified number of PEs
PE_GEN : for i in 0 to size-1 generate

	FIRST_PE : if i = 0 generate
		PE0 : processing_element port map(
			clk => clk,
			en => en,
			out_res_in => out_res_in,
			weight_in => weight_in,
			input_img_in => img_data_in,
			input_img_out => input_connect(i),
			output_map => outputs_array(i),
			weight_out => weight_connect(i),
			out_res_out => out_res_connect(i)
		);
	end generate FIRST_PE;
	
	REST_PE : if i > 0 generate
		PEX : processing_element port map (
			clk => clk,
			en => en,
			out_res_in => out_res_connect(i - 1),
			weight_in => weight_connect(i - 1),
			input_img_in => input_connect(i - 1),
			input_img_out => input_connect(i),
			output_map => outputs_array(i),
			weight_out => weight_connect(i),
			out_res_out => out_res_connect(i)
		);
	end generate REST_PE;
	
end generate PE_GEN;

end architecture behaviour;