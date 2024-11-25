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

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
entity GameLogic is
	port(
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
end GameLogic;
architecture synth of GameLogic is
signal start : unsigned(5 downto 0);
signal Px : signed(10 downto 0) :=  "00101000000";
signal Py : signed(9 downto 0) := "0011110000";
signal Vx : signed(4 downto 0):=  "00100";
signal Vy : signed(4 downto 0):=  "00100";
signal u : std_logic;
signal d : std_logic;
signal l : std_logic;
signal r : std_logic;
signal up : std_logic;
signal do : std_logic;
signal le : std_logic;
signal ri : std_logic;
signal UpButton : std_logic;
signal DownButton : std_logic;
signal LeftButton : std_logic;
signal RightButton : std_logic;
signal turnover : unsigned(18 downto 0);
begin
process(clk) is
begin
if rising_edge(clk) then
turnover <= turnover + 1;
end if;
if rising_edge(turnover(18)) then
u <= GoUp;
d <= GoDown;
l <= GoLeft;
r <= GoRight;
up <= u;
do <= d;
le <= l;
ri <= r;
if(u='0' and up = '1')then
UpButton <= u;
else
UpButton <= '1';
end if;
if(d = '0' and do = '1')then
DownButton <= d;
else
DownButton <= '1';
end if;
if(l = '0' and le = '1')then
LeftButton <= l;
else
LeftButton <= '1';
end if;
if(r = '0' and ri = '1')then
RightButton <= r;
else
RightButton <= '1';
end if;
if(start < 10) then
Px <=  "00111100000";
Py <= "0011111100";
Vy <= "00100";
Vx <= "10100";
start <= start + 1;
Win <= '0';
Collision <= '0';
elsif(Reset = '1') then
start <= "000000";
elsif (Px <= "00000000010" and Py <= "0000000010")then
Win <= '1';
elsif (Px >= "01001011110" and Py >= "0111001010") then
Win <='1';
elsif (Px <= "00000000010" and Py >= "0111001010")then
Win <= '1';
elsif (Px >= "01001011110" and Py <= "0000000010")then
Win <='1';

elsif(Px + Vx <= "00000000000") then
Px <= "00000000000";

Collision <= '1';
Vx <= (not Vx)+1;
elsif(Px + Vx >= "01001100000")then
Collision <= '1';
Px <= "01001100000";
Vx <= (not Vx)+1;
elsif(Py +Vy <= "0000000000")then
Collision <= '1';
Py <= "0000000000";
Vy <= (not Vy)+1;
elsif(Py + Vy >= "0111001100")then
Collision <= '1';
Py <= "0111001100";
Vy <= (not Vy)+1;
elsif (UpButton = '0' and Vy /= "01111") then
Vy <= Vy + 1;

Collision <= '0';
Px <= Px + Vx;
Py <= Py + Vy;
elsif(DownButton = '0' and Vy /= "10001") then
Vy <= Vy - 1;

Collision <= '0';
Px <= Px + Vx;
Py <= Py + Vy;
elsif(RightButton = '0' and Vx /= "01111") then
Vx <= Vx + 1;

Collision <= '0';
Px <= Px + Vx;
Py <= Py + Vy;

elsif(LeftButton = '0' and Vx /= "10001") then
Vx <= Vx - 1;

Collision <= '0';
Px <= Px + Vx;
Py <= Py + Vy;
else
Collision <= '0';
Px <= Px + Vx;
Py <= Py + Vy;
end if;
end if;
end process;
FinalPosX <= Px;
FinalPosY <= Py;
end;



library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
entity vga is
port(
clk : in std_logic;
valid : out std_logic;
row : out unsigned(9 downto 0);
col : out unsigned(9 downto 0);
HSYNC : out std_logic;
VSYNC : out std_logic
);
end vga;
architecture synth of vga is
signal rowCounter : unsigned(9 downto 0) := to_unsigned(0,10);
signal colCounter : unsigned(9 downto 0) := to_unsigned(0,10);
begin
row <= rowCounter;
col <= colCounter;
process(clk) is
begin
if rising_edge(clk) then
	if colCounter < 640 then
		HSYNC <= '1';
		valid <= '1';
		colCounter <= colCounter +1;
	elsif colCounter < 656 then
		HSYNC <= '1';
		valid <= '0';
		colCounter <= colCounter +1;
	elsif colCounter < 752 then
		HSYNC <='0';
			valid <= '0';
		colCounter <= colCounter +1;
	elsif colCounter < 800 then
		HSYNC <='1';
			valid <= '0';
		colCounter <= colCounter +1;
	else 
	colCounter <= to_unsigned(0,10);
	if rowCounter < 480 then
	rowCounter <= rowCounter + 1;
	VSYNC <= '1';
	valid <= '1';
	elsif rowCounter < 490 then
		rowCounter <= rowCounter + 1;
	VSYNC <= '1';
	valid <= '0';
	elsif rowCounter < 492 then
			rowCounter <= rowCounter + 1;
	VSYNC <= '0';
	valid <= '0';
	elsif rowCounter < 525 then
				rowCounter <= rowCounter + 1;
	VSYNC <= '1';
	valid <= '0';
	else
	rowCounter <= to_unsigned(0,10);
	end if;
	end if;
		
end if;
end process;
end;



library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
entity pattern_gen is
port(
clk : in std_logic;
row : in unsigned(9 downto 0);
col : in unsigned(9 downto 0);
colors : out std_logic_vector(5 downto 0);
valid : in std_logic;
P1x : in signed(10 downto 0);
P1y : in signed(9 downto 0)
);
end pattern_gen;
architecture synth of pattern_gen is
signal temp : std_logic_vector(9 downto 0);
signal temp2 : std_logic_vector(9 downto 0);

begin
process(clk) is
begin
if rising_edge(clk) then
if ((col) < (unsigned(P1x) + 32)) then
	if ((col) > unsigned(P1x)) then
		if  (row) < (unsigned(P1y) + 20) then
			if (row) > unsigned(P1y) then
			colors <= "000000";
			else colors <= "111111";
				end if;
		else colors <= "111111";
			end if;
	else colors <= "111111";
	end if;
	
--bgr
else 
colors <= "111111";
end if;
if valid = '0' then
colors <= "000000";
end if;
end if;
end process;
end;


