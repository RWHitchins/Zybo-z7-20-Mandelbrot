
--------------------------------------------------------------------------------
-- Project Name : <project name>
--! @file mandelbrot_tpg_top.vhd
--! @brief <add short description here>
--! @author RWH
--! @date 29th January 2019
--
-- Change History ...
-- <date> <modified by> <change description>
--
--------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--                  Definition of Ports
-------------------------------------------------------------------------------
-- S_AXI_ACLK            -- AXI Clock
-- S_AXI_ARESETN         -- AXI Reset
-- S_AXI_AWADDR          -- AXI Write address
-- S_AXI_AWVALID         -- Write address valid
-- S_AXI_AWREADY         -- Write address ready
-- S_AXI_WDATA           -- Write data
-- S_AXI_WSTRB           -- Write strobes
-- S_AXI_WVALID          -- Write valid
-- S_AXI_WREADY          -- Write ready
-- S_AXI_BRESP           -- Write response
-- S_AXI_BVALID          -- Write response valid
-- S_AXI_BREADY          -- Response ready
-- S_AXI_ARADDR          -- Read address
-- S_AXI_ARVALID         -- Read address valid
-- S_AXI_ARREADY         -- Read address ready
-- S_AXI_RDATA           -- Read data
-- S_AXI_RRESP           -- Read response
-- S_AXI_RVALID          -- Read valid
-- S_AXI_RREADY          -- Read ready
-- Bus2IP_Clk            -- Synchronization clock provided to User IP
-- Bus2IP_Reset          -- Active high reset for use by the User IP
-- Bus2IP_Addr           -- Desired address of read or write operation
-- Bus2IP_RNW            -- Read or write indicator for the transaction
-- Bus2IP_BE             -- Byte enables for the data bus
-- Bus2IP_CS             -- Chip select for the transcations
-- Bus2IP_RdCE           -- Chip enables for the read
-- Bus2IP_WrCE           -- Chip enables for the write
-- Bus2IP_Data           -- Write data bus to the User IP
-- IP2Bus_Data           -- Input Read Data bus from the User IP
-- IP2Bus_WrAck          -- Active high Write Data qualifier from the IP
-- IP2Bus_RdAck          -- Active high Read Data qualifier from the IP
-- IP2Bus_Error          -- Error signal from the IP



LIBRARY ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

LIBRARY ieee_proposed;
use ieee_proposed.fixed_pkg.all;

library work;
use work.mbrot_pkg.all;

library axi_lite_ipif_v3_0;
use axi_lite_ipif_v3_0.ipif_pkg.all;


entity mandelbrot_tpg_top is
 generic (
         C_S_AXI_DATA_WIDTH    : integer  range 32 to 32   := 32;
         C_S_AXI_ADDR_WIDTH    : integer                   := 32
         );
port
(
    reset               : in std_logic;
    clk                 : in std_logic;
    
    -- AXI STREAM interface (VIDEO)
    m0_axis_tready      : in std_logic;
    m0_axis_tdata       : out std_logic_vector(23 downto 0);
    m0_axis_tvalid      : out std_logic;
    m0_axis_tuser       : out std_logic_vector(0 downto 0);
    m0_axis_tlast       : out std_logic;
    m0_axis_tkeep       : out std_logic_vector(2 downto 0);


    --AXI4 interface (control)
    S_AXI_ACLK          : in  std_logic;
    S_AXI_ARESETN       : in  std_logic;
    S_AXI_AWADDR        : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    S_AXI_AWVALID       : in  std_logic;
    S_AXI_AWREADY       : out std_logic;
    S_AXI_WDATA         : in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    S_AXI_WSTRB         : in  std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
    S_AXI_WVALID        : in  std_logic;
    S_AXI_WREADY        : out std_logic;
    S_AXI_BRESP         : out std_logic_vector(1 downto 0);
    S_AXI_BVALID        : out std_logic;
    S_AXI_BREADY        : in  std_logic;
    S_AXI_ARADDR        : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    S_AXI_ARVALID       : in  std_logic;
    S_AXI_ARREADY       : out std_logic;
    S_AXI_RDATA         : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    S_AXI_RRESP         : out std_logic_vector(1 downto 0);
    S_AXI_RVALID        : out std_logic;
    S_AXI_RREADY        : in  std_logic;

    eol                 : out std_logic;
    sof                 : out std_logic
);
end entity mandelbrot_tpg_top;


architecture  mandelbrot_top_rtl of mandelbrot_tpg_top is

-- Components here:

component mandelbrot_tile is
port(
    reset           : in std_logic;
    pix_clk         : in std_logic;
    start           : in std_logic;                         -- start calculating the results 
    ready           : out std_logic;
    max_its         : in std_logic_vector(15 downto 0);     -- sets the max. no of iterations
    cmpx_tl         : in complex_t;                         -- specify the top left/bottom right locations to map to the 1920x1080 picture
    cmpx_br         : in complex_t;
    pixpos_tl       : in xypos_t;
    pixpos_br       : in xypos_t;
    valid           : out std_logic;
    data_out        : out std_logic_vector(15 downto 0);  
    x_pos           : out std_logic_vector(10 downto 0);
    y_pos           : out std_logic_vector(10 downto 0);   
    end_of_line     : out std_logic;
    start_of_frame  : out std_logic                         -- asserted when all values have been generated for this tile
    );
end component;


component axi_lite_ipif is
    generic (
         C_S_AXI_DATA_WIDTH    : integer  range 32 to 32   := 32;
         C_S_AXI_ADDR_WIDTH    : integer                   := 32;
         C_S_AXI_MIN_SIZE      : std_logic_vector(31 downto 0):= X"000003FF";
         C_USE_WSTRB           : integer := 0;
         C_DPHASE_TIMEOUT      : integer range 0 to 512 := 8;
         C_ARD_ADDR_RANGE_ARRAY: SLV64_ARRAY_TYPE :=  -- not used
            (
              X"0000_0000_0000_0000", -- IP user0 base address
              X"0000_0000_0000_1000" -- IP user0 high address  
            );
         C_ARD_NUM_CE_ARRAY    : INTEGER_ARRAY_TYPE :=  (0 => 1);--not used
         C_FAMILY              : string  := "virtex6"
           );
    port (

        --System signals
      S_AXI_ACLK            : in  std_logic;
      S_AXI_ARESETN         : in  std_logic;
      S_AXI_AWADDR          : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
      S_AXI_AWVALID         : in  std_logic;
      S_AXI_AWREADY         : out std_logic;
      S_AXI_WDATA           : in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
      S_AXI_WSTRB           : in  std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
      S_AXI_WVALID          : in  std_logic;
      S_AXI_WREADY          : out std_logic;
      S_AXI_BRESP           : out std_logic_vector(1 downto 0);
      S_AXI_BVALID          : out std_logic;
      S_AXI_BREADY          : in  std_logic;
      S_AXI_ARADDR          : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
      S_AXI_ARVALID         : in  std_logic;
      S_AXI_ARREADY         : out std_logic;
      S_AXI_RDATA           : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
      S_AXI_RRESP           : out std_logic_vector(1 downto 0);
      S_AXI_RVALID          : out std_logic;
      S_AXI_RREADY          : in  std_logic;
      -- Controls to the IP/IPIF modules
      Bus2IP_Clk            : out std_logic;
      Bus2IP_Resetn         : out std_logic;
      Bus2IP_Addr           : out std_logic_vector((C_S_AXI_ADDR_WIDTH-1) downto 0);
      Bus2IP_RNW            : out std_logic;
      Bus2IP_BE             : out std_logic_vector(((C_S_AXI_DATA_WIDTH/8)-1) downto 0);
      Bus2IP_CS             : out std_logic_vector(0 downto 0);
      Bus2IP_RdCE           : out std_logic_vector(0 downto 0);
      Bus2IP_WrCE           : out std_logic_vector(0 downto 0);
      Bus2IP_Data           : out std_logic_vector((C_S_AXI_DATA_WIDTH-1) downto 0);
      IP2Bus_Data           : in  std_logic_vector((C_S_AXI_DATA_WIDTH-1) downto 0);
      IP2Bus_WrAck          : in  std_logic;
      IP2Bus_RdAck          : in  std_logic;
      IP2Bus_Error          : in  std_logic
       );
end component;


component blk_mem_gen_0 is
  port ( 
    clka    : in std_logic;
    wea     : in std_logic_vector ( 0 to 0 );
    addra   : in std_logic_vector ( 7 downto 0 );
    dina    : in std_logic_vector ( 31 downto 0 );
    clkb    : in std_logic;
    addrb   : in std_logic_vector ( 7 downto 0 );
    doutb   : out std_logic_vector ( 31 downto 0 )
  );
end component;


--constants
-- type defs
constant num_ctrl_regs      : integer := 10;
constant num_status_regs    : integer := 2;

type t_reg      is array (0 to 15) of std_logic_vector(31 downto 0);
type ctrl_reg_t is array (0 to (num_ctrl_regs-1))  of std_logic_vector(31 downto 0);  
type status_reg_t is array (0 to (num_status_regs-1))  of std_logic_vector(31 downto 0); 
-- Registers are split into bytes for byte-masked writes.
signal reg : t_reg := (others => (others => '0')); 

-- signals
signal end_of_line_tbd      : std_logic;
signal start_of_frame_tbd   : std_logic;
signal end_of_line          : std_logic;
signal start_of_frame       : std_logic;
signal pix_clk              : std_logic := '0';
signal pixpos_tl            : xypos_t;
signal pixpos_br            : xypos_t;
signal data_out             : std_logic_vector(15 downto 0);
signal valid                : std_logic;
signal valid_tbd            : std_logic;
signal start_of_frame_slv   : std_logic_vector(0 downto 0);

signal Bus2IP_Clk           : std_logic;
signal Bus2IP_Resetn        : std_logic;
signal Bus2IP_Addr          : std_logic_vector((C_S_AXI_ADDR_WIDTH-1) downto 0);
signal Bus2IP_RNW           : std_logic;
signal Bus2IP_BE            : std_logic_vector(((C_S_AXI_DATA_WIDTH/8)-1) downto 0);
signal Bus2IP_CS            : std_logic_vector(0 downto 0);
signal Bus2IP_RdCE          : std_logic_vector(0 downto 0);
signal Bus2IP_WrCE          : std_logic_vector(0 downto 0);
signal Bus2IP_Data          : std_logic_vector((C_S_AXI_DATA_WIDTH-1) downto 0);
signal IP2Bus_Data          : std_logic_vector((C_S_AXI_DATA_WIDTH-1) downto 0);
signal IP2Bus_WrAck         : std_logic;
signal IP2Bus_RdAck         : std_logic;
signal IP2Bus_Error         : std_logic;

signal lut_wr               : std_logic_vector(0 downto 0);
signal lut_rdata            : std_logic_vector(31 downto 0);
signal lut_waddr            : std_logic_vector(7 downto 0);
signal lut_raddr            : std_logic_vector(7 downto 0);
signal IP2Bus_RdAck_dly     : std_logic;
signal ctrl_reg_wr          : std_logic;
signal ctrl_reg             : ctrl_reg_t := (others => (others => '0'));
signal x_pos                : std_logic_vector(10 downto 0);
signal y_pos                : std_logic_vector(10 downto 0);
signal stat_reg             : status_reg_t;
signal cmpx_tl              : complex_t;
signal cmpx_br              : complex_t;

signal tlre                 : std_logic_vector(35 downto 0);
signal tlim                 : std_logic_vector(35 downto 0);
signal brre                 : std_logic_vector(35 downto 0);
signal brim                 : std_logic_vector(35 downto 0);
signal ready                : std_logic;

begin
-- Set up some defaults: These will be controlled via the CPU eventually

-- initially choose to use full HD res
pixpos_tl.xpos <= 0;
pixpos_tl.ypos <= 0;


    
tlre <= (ctrl_reg(2)(3 downto 0)) & (ctrl_reg(1)(31 downto 0));    --  -1.7 (for full mandelbrot set)
tlim <= (ctrl_reg(4)(3 downto 0)) & (ctrl_reg(3)(31 downto 0));    --  +1
brre <= (ctrl_reg(6)(3 downto 0)) & (ctrl_reg(5)(31 downto 0));    --  +1.7
brim <= (ctrl_reg(8)(3 downto 0)) & (ctrl_reg(7)(31 downto 0));    --  -1

cmpx_tl.re <= to_SFix(tlre,36,32); 
cmpx_tl.im <= to_SFix(tlim,36,32);

cmpx_br.re <= to_SFix(brre,36,32);      
cmpx_br.im <= to_SFix(brim,36,32); 

pixpos_br.xpos <= to_integer(unsigned(ctrl_reg(9)(10 downto 0)));     --1919;
pixpos_br.ypos <= to_integer(unsigned(ctrl_reg(9)(26 downto 16)));    --1079;


UUT: mandelbrot_tile
    port map(
    reset           => reset,
    pix_clk         => clk,
    start           => ctrl_reg(0)(31),         -- start calculating the results 
    ready           => ready,
    max_its         => ctrl_reg(0)(15 downto 0),-- sets the max. no of iterations
    cmpx_tl         => cmpx_tl,  
    cmpx_br         => cmpx_br,                
    pixpos_tl       => pixpos_tl,
    pixpos_br       => pixpos_br,
    valid           => valid_tbd,
    data_out        => data_out,
    x_pos           => x_pos,
    y_pos           => y_pos,  
    end_of_line     => end_of_line_tbd,   
    start_of_frame  => start_of_frame_tbd
    );
   
    start_of_frame_slv(0) <= start_of_frame;
    
    m0_axis_tdata    <= lut_rdata(23 downto 0); 
    m0_axis_tvalid   <= valid;
    m0_axis_tlast    <= end_of_line;
    m0_axis_tuser    <= start_of_frame_slv;
    m0_axis_tkeep    <= "111";
    
    eol <= end_of_line;
    sof <= start_of_frame;
    
-- delay other signals to match the delay through the LUT
delay_proc: process(clk)
begin
    if rising_edge(clk) then
        valid           <= valid_tbd;
        start_of_frame  <= start_of_frame_tbd;
        end_of_line     <= end_of_line_tbd;
    end if;
end process;


axi_slave_inst: axi_lite_ipif 
    generic map
    (

        C_S_AXI_DATA_WIDTH  => 32,                      --: integer  range 32 to 32   := 32;
        C_S_AXI_ADDR_WIDTH  => 32,                      --: integer                   := 32;
        C_S_AXI_MIN_SIZE    => X"00001000",             --: std_logic_vector(31 downto 0):= X"000001FF";
        C_USE_WSTRB         => 0,                       --: integer := 0;
        C_ARD_ADDR_RANGE_ARRAY => 
            (
              X"0000_0000_0000_0000", -- IP user0 base address
              X"0000_0000_0001_0000" -- IP user0 high address      -- 16 4-byte registers
            ),
        C_ARD_NUM_CE_ARRAY  => (0 => 1),
        C_DPHASE_TIMEOUT    => 8                        --: integer range 0 to 512 := 8
    )
    port map
    (
      --System signals
    S_AXI_ACLK            => S_AXI_ACLK   ,                --: in  std_logic;
    S_AXI_ARESETN         => S_AXI_ARESETN,                --: in  std_logic;
    S_AXI_AWADDR          => S_AXI_AWADDR ,                --: in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    S_AXI_AWVALID         => S_AXI_AWVALID,                --: in  std_logic;
    S_AXI_AWREADY         => S_AXI_AWREADY,                --: out std_logic;
    S_AXI_WDATA           => S_AXI_WDATA  ,                --: in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    S_AXI_WSTRB           => S_AXI_WSTRB  ,                --: in  std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
    S_AXI_WVALID          => S_AXI_WVALID ,                --: in  std_logic;
    S_AXI_WREADY          => S_AXI_WREADY ,                --: out std_logic;
    S_AXI_BRESP           => S_AXI_BRESP  ,                --: out std_logic_vector(1 downto 0);
    S_AXI_BVALID          => S_AXI_BVALID ,                --: out std_logic;
    S_AXI_BREADY          => S_AXI_BREADY ,                --: in  std_logic;
    S_AXI_ARADDR          => S_AXI_ARADDR ,                --: in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    S_AXI_ARVALID         => S_AXI_ARVALID,                --: in  std_logic;
    S_AXI_ARREADY         => S_AXI_ARREADY,                --: out std_logic;
    S_AXI_RDATA           => S_AXI_RDATA  ,                --: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    S_AXI_RRESP           => S_AXI_RRESP  ,                --: out std_logic_vector(1 downto 0);
    S_AXI_RVALID          => S_AXI_RVALID ,                --: out std_logic;
    S_AXI_RREADY          => S_AXI_RREADY ,                --: in  std_logic;
    -- Controls to the IP/IPIF modules
    Bus2IP_Clk            => Bus2IP_Clk   ,                --: out std_logic;
    Bus2IP_Resetn         => Bus2IP_Resetn,                --: out std_logic;
    Bus2IP_Addr           => Bus2IP_Addr  ,                --: out std_logic_vector((C_S_AXI_ADDR_WIDTH-1) downto 0);
    Bus2IP_RNW            => Bus2IP_RNW   ,                --: out std_logic;
    Bus2IP_BE             => Bus2IP_BE    ,                --: out std_logic_vector(((C_S_AXI_DATA_WIDTH/8)-1) downto 0);
    Bus2IP_CS             => Bus2IP_CS    ,                --: out std_logic_vector(((C_ARD_ADDR_RANGE_ARRAY'LENGTH)/2-1) downto 0);
    Bus2IP_RdCE           => Bus2IP_RdCE  ,                --: out std_logic_vector((calc_num_ce(C_ARD_NUM_CE_ARRAY)-1) downto 0);
    Bus2IP_WrCE           => Bus2IP_WrCE  ,                --: out std_logic_vector((calc_num_ce(C_ARD_NUM_CE_ARRAY)-1) downto 0);
    Bus2IP_Data           => Bus2IP_Data  ,                --: out std_logic_vector((C_S_AXI_DATA_WIDTH-1) downto 0);
    IP2Bus_Data           => IP2Bus_Data  ,                --: in  std_logic_vector((C_S_AXI_DATA_WIDTH-1) downto 0);
    IP2Bus_WrAck          => IP2Bus_WrAck ,                --: in  std_logic;
    IP2Bus_RdAck          => IP2Bus_RdAck ,                --: in  std_logic;
    IP2Bus_Error          => IP2Bus_Error                  --: in  std_logic
    );


LUT: blk_mem_gen_0 
  port map
  ( 
    clka            => clk,                                 --: in STD_LOGIC;
    wea             => lut_wr,                              --: in STD_LOGIC_VECTOR ( 0 to 0 );
    addra           => lut_waddr,                           --: in STD_LOGIC_VECTOR ( 7 downto 0 );
    dina            => Bus2IP_Data,                         --: in STD_LOGIC_VECTOR ( 31 downto 0 );
    clkb            => clk,                                 --: in STD_LOGIC;
    addrb           => data_out(7 downto 0),                --: in STD_LOGIC_VECTOR ( 7 downto 0 );
    doutb           => lut_rdata                            --: out STD_LOGIC_VECTOR ( 31 downto 0 )
  );


IPIF_control: process(clk)
begin
    if rising_edge(clk) then

        if (reset = '1') then
            ctrl_reg    <= (others => (others => '0'));
            stat_reg    <= (others => (others => '0'));
            lut_waddr   <= (others => '0');
        else

            stat_reg(0)(0) <= ready;
            stat_reg(1)(10 downto 0)    <= x_pos;
            stat_reg(1)(26 downto 16)   <= y_pos;
            
            IP2Bus_WrAck <= '0'; 
            -- LUT write control
            lut_wr(0) <= '0';
            ctrl_reg_wr <= '0';
            if (Bus2IP_WrCE(0) = '1' and Bus2IP_RNW = '0') and (Bus2IP_Addr(10) = '0') then -- offset from 0
                lut_wr(0)      <= '1';
                lut_waddr   <= Bus2IP_Addr(9 downto 2);
            end if;

            if (Bus2IP_WrCE(0) = '1' and Bus2IP_RNW = '0') and (Bus2IP_Addr(10) = '1') then -- offset from 0x400
                ctrl_reg_wr      <= '1';
                case Bus2IP_Addr(7 downto 2)is
                   when "000000"    => ctrl_reg(0) <= Bus2IP_Data;   -- (15 downto 0) = max_its
                   when "000001"    => ctrl_reg(1) <= Bus2IP_Data;   -- tl re 
                   when "000010"    => ctrl_reg(2) <= Bus2IP_Data;   -- tl re (ms)
                   when "000011"    => ctrl_reg(3) <= Bus2IP_Data;   -- tl im
                   when "000100"    => ctrl_reg(4) <= Bus2IP_Data;   -- tl im (ms)
                   when "000101"    => ctrl_reg(5) <= Bus2IP_Data;   -- br re  
                   when "000110"    => ctrl_reg(6) <= Bus2IP_Data;   -- br re (ms)
                   when "000111"    => ctrl_reg(7) <= Bus2IP_Data;   -- br im 
                   when "001000"    => ctrl_reg(8) <= Bus2IP_Data;   -- br im (ms)
                   when "001001"    => ctrl_reg(9) <= Bus2IP_Data;
                   when others      =>  null;
               end case;
            end if;

            --provide ACK after write
            if (lut_wr(0) = '1') or (ctrl_reg_wr = '1') then
               IP2Bus_WrAck <= '1';
            end if;
            
            --read side
            IP2Bus_RdAck_dly <= '0';
            if (Bus2IP_RdCE(0) = '1' and Bus2IP_RNW = '1') and (Bus2IP_Addr(10) = '1')then -- offset from 0x400
                case Bus2IP_Addr(7 downto 2)is
                    --control registers
                    when "000000"   => IP2Bus_Data <=  ctrl_reg(0); --00
                    when "000001"   => IP2Bus_Data <=  ctrl_reg(1); --04
                    when "000010"   => IP2Bus_Data <=  ctrl_reg(2); --08
                    when "000011"   => IP2Bus_Data <=  ctrl_reg(3); --0c
                    when "000100"   => IP2Bus_Data <=  ctrl_reg(4); --10
                    when "000101"   => IP2Bus_Data <=  ctrl_reg(5); --14
                    when "000110"   => IP2Bus_Data <=  ctrl_reg(6); --18
                    when "000111"   => IP2Bus_Data <=  ctrl_reg(7); --1c
                    when "001000"   => IP2Bus_Data <=  ctrl_reg(8); --20
                    when "001001"   => IP2Bus_Data <=  ctrl_reg(9); --24
                    -- status registers
                    when "100000"   => IP2Bus_Data <=  stat_reg(0); --80
                    when "100001"   => IP2Bus_Data <=  stat_reg(1); --84
                    when others     => IP2Bus_Data <= x"DEADBEEF";
                end case;
                --provide ACK after read
                IP2Bus_RdAck_dly <= '1';
            end if;         
            IP2Bus_RdAck <= IP2Bus_RdAck_dly;

        end if;
    end if;
end process;

end architecture mandelbrot_top_rtl;