library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
entity main is
port(

UpP1 : in std_logic;
DownP1 : in std_logic;
LeftP1 : in std_logic;
RightP1 : in std_logic;
Reset : in std_logic;
clk : in std_logic;
collision : out std_logic;
win : out std_logic;
hsyncOut: out std_logic;
vsyncOut: out std_logic;
 colors: out std_logic_vector(5 downto 0)
);
end main;
architecture synth of main is
signal clk_out : std_logic;
signal currValid : std_logic;
signal currRow : unsigned(9 downto 0);
signal currCol: unsigned(9 downto 0);
component GameLogic is port (
	clk : in std_logic;
	GoUp : in std_logic;
	GoDown : in std_logic;
	GoLeft : in std_logic;
	GoRight : in std_logic;
	Reset : in std_logic;
	Collision : out std_logic;
	FinalPosX : out signed (10 downto 0);
	FinalPosY : out signed(9 downto 0);
	Win : out std_logic
);
end component;
component mypll is
    port(
        ref_clk_i: in std_logic;
        rst_n_i: in std_logic;
        outcore_o: out std_logic;
        outglobal_o: out std_logic
    );
	end component;
	
component pattern_gen is
port(
clk : in std_logic;
row : in unsigned(9 downto 0);
col : in unsigned(9 downto 0);
colors : out std_logic_vector(5 downto 0);
valid : in std_logic;
P1x : in signed(10 downto 0);
P1y : in signed(9 downto 0)
);
end component;
component vga is
port(
clk : in std_logic;
valid : out std_logic;
row : out unsigned(9 downto 0);
col : out unsigned(9 downto 0);
HSYNC : out std_logic;
VSYNC : out std_logic
);
end component;
signal Px : signed (10 downto 0);
signal Py : signed(9 downto 0);
begin
game : GameLogic port map(
	clk => clk_out,
	GoUp=> UpP1,
	GoDown=> DownP1,
	GoLeft => LeftP1,
	GoRight => RightP1,
	Reset => Reset,
	Collision => collision,
	FinalPosX => Px,
	FinalPosY => Py,
	Win => win
);
cgen : pattern_gen port map(
clk => clk_out,
col => currCol,
row => currRow,
colors=>colors,
valid => currValid,
P1x => Px,
P1y => Py
);
pl: mypll port map (
ref_clk_i => clk,
rst_n_i => '1',
outcore_o => clk_out,
outglobal_o => open
);
vga_unit : vga port map (
clk => clk_out,
valid  => currValid,
row  => currRow,
col  => currCol,
HSYNC => hsyncOut,
VSYNC => vsyncOut
);


end;
