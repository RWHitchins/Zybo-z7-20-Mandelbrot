-------------------------------------------------------------
-- my_axi_slave.vhd
--
-- Author: Mike Field <hamster@snap.net.nz>
--
-- My own AXI slave implementation, to see what is involved.
-- connects the AXI bus to a register file of 16 registers.
-------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity my_axi_slave is
  port (
    ------------------------
    -- Incoming system clock
    ------------------------
    clk         : in  STD_LOGIC;    
    ------------------------
    -- Write address channel    
    ------------------------
    AXI_awvalid : in  STD_LOGIC;    
    AXI_awid    : in  STD_LOGIC_VECTOR (11 downto 0 );
    AXI_awburst : in  STD_LOGIC_VECTOR ( 1 downto 0 );
    AXI_awlock  : in  STD_LOGIC_VECTOR ( 1 downto 0 );
    AXI_awsize  : in  STD_LOGIC_VECTOR ( 2 downto 0 );
    AXI_awprot  : in  STD_LOGIC_VECTOR ( 2 downto 0 );
    AXI_awaddr  : in  STD_LOGIC_VECTOR (31 downto 0 );
    AXI_awcache : in  STD_LOGIC_VECTOR ( 3 downto 0 );
    AXI_awlen   : in  STD_LOGIC_VECTOR ( 3 downto 0 );
    AXI_awqos   : in  STD_LOGIC_VECTOR ( 3 downto 0 );
    AXI_awready : out STD_LOGIC := '0';

    ------------------------
    -- Write Data channel    
    ------------------------
    AXI_wdata   : in  STD_LOGIC_VECTOR (31 downto 0 );
    AXI_wstrb   : in  STD_LOGIC_VECTOR ( 3 downto 0 );
    AXI_wready  : out STD_LOGIC := '0';
    AXI_wlast   : in  STD_LOGIC;
    AXI_wvalid  : in  STD_LOGIC;
    AXI_wid     : in  STD_LOGIC_VECTOR (11 downto 0 );

    ------------------------
    -- Read address channel
    ------------------------
    AXI_arvalid : in  STD_LOGIC;
    AXI_arready : out STD_LOGIC := '0';
    AXI_arid    : in  STD_LOGIC_VECTOR ( 11 downto 0 );
    AXI_arburst : in  STD_LOGIC_VECTOR ( 1 downto 0 );
    AXI_arlock  : in  STD_LOGIC_VECTOR ( 1 downto 0 );
    AXI_arsize  : in  STD_LOGIC_VECTOR ( 2 downto 0 );
    AXI_arprot  : in  STD_LOGIC_VECTOR ( 2 downto 0 );
    AXI_araddr  : in  STD_LOGIC_VECTOR (31 downto 0 );
    AXI_arcache : in  STD_LOGIC_VECTOR ( 3 downto 0 );
    AXI_arlen   : in  STD_LOGIC_VECTOR ( 3 downto 0 );
    AXI_arqos   : in  STD_LOGIC_VECTOR ( 3 downto 0 );

    ------------------------
    -- Read data channel
    ------------------------
    AXI_rready  : in  STD_LOGIC;
    AXI_rlast   : out STD_LOGIC := '0';
    AXI_rvalid  : out STD_LOGIC := '0';
    AXI_rid     : out STD_LOGIC_VECTOR (11 downto 0 ) := (others => '0');
    AXI_rresp   : out STD_LOGIC_VECTOR ( 1 downto 0 ) := (others => '0');
    AXI_rdata   : out STD_LOGIC_VECTOR (31 downto 0 ) := (others => '0');

    ------------------------
    -- Write status channel 
    ------------------------
    AXI_bready  : in  STD_LOGIC;
    AXI_bvalid  : out STD_LOGIC := '0';
    AXI_bid     : out STD_LOGIC_VECTOR (11 downto 0 ) := (others => '0');
    AXI_bresp   : out STD_LOGIC_VECTOR ( 1 downto 0 ) := (others => '0');

    ---------------------------------
    -- Register file interface
    ---------------------------------
    reg_address      : out std_logic_vector ( 3 downto 0 ) := (others => '0');
    reg_write_data   : out std_logic_vector (31 downto 0 ) := (others => '0');
    reg_write_strobe : out std_logic_vector ( 3 downto 0 ) := (others => '0');
    reg_read_data    : in  std_logic_vector (31 downto 0 ) := (others => '0')
    );
end my_axi_slave;

architecture Behavioral of my_axi_slave is
    type t_state is (s_idle, s_read, s_write, s_write_wait);
    signal state                   : t_state := s_idle;

    signal words_to_go        : unsigned(3 downto 0) := (others => '0');
    signal write_id           : STD_LOGIC_VECTOR (11 downto 0 );
    signal address_start      : STD_LOGIC_VECTOR (31 downto 0 ) := (others => '0');
    signal address_incr       : STD_LOGIC_VECTOR (31 downto 0 ) := (others => '0');
    signal address_mask       : STD_LOGIC_VECTOR ( 7 downto 0 ) := (others => '1');
    signal address            : STD_LOGIC_VECTOR (31 downto 0 ) := (others => '0');
begin   

calc_addr_proc: process(address_mask, address_start, address_incr)
    begin
        -- Bit 7 and up are selected based on bit 7 of addreess_mask
        -- If set, it uses bits from the the start address, 
        -- If not, it uses the incrementing address
        address <= address_start;
        if address_start(7) = '1' then
            address(address'high downto 7) <= address_start(address'high downto 7);
        else
            address(address'high downto 7) <= address_incr(address'high downto 7);
        end if;

        -- Bit 0 to six are selected based on the low 7 bits of addreess_mask
        -- If set, it uses bits from the the start address, 
        -- If not, it uses the incrementing address        
        address(6 downto 0) <= (address_start(6 downto 0) AND     address_mask(6 downto 0))
                            OR (address_incr (6 downto 0) AND NOT address_mask(6 downto 0));
    end process;

map_through_writes_proc: process(state, AXI_wvalid)
    begin
        if state = s_write and AXI_wvalid = '1' then
            reg_write_strobe <= AXI_wstrb;
        else
            reg_write_strobe <= (others => '0');
        end if;
    end process;
    reg_address      <= address(5 downto 2);
    reg_write_data   <= AXI_wdata; 
    AXI_rdata        <= reg_read_data;
    
assert_aXready_proc: process(AXI_awvalid, AXI_arvalid, state)
    begin
        AXI_awready <= '0';
        AXI_arready <= '0';
        if state = s_idle then
            AXI_awready <= AXI_awvalid;
            AXI_arready <= AXI_arvalid AND NOT AXI_awvalid;
        end if;
    end process;
     
clk_proc: process(clk)
    begin
        if rising_edge(clk) then     
            case state is 
                when s_idle =>
                    AXI_rvalid  <= '0';
                    AXI_wready  <= '0';
                    if AXI_awvalid = '1' then
                        state       <= s_write;
                        -- Receive write transaction, 
                        address_start <= AXI_awaddr; 
                        address_incr  <= AXI_awaddr; 
                        case AXI_awburst is
                           when "00"   => -- Fixed
                                address_mask    <= x"FF"; 
                           when "01"   => -- Incr
                                address_mask    <= x"00"; 
                           when "10"   =>  -- Wrap 
                                case AXI_awsize is
                                    when "000"  => address_mask    <= x"FF";
                                    when "001"  => address_mask    <= x"FE"; 
                                    when "010"  => address_mask    <= x"FC"; 
                                    when "011"  => address_mask    <= x"F8"; 
                                    when "100"  => address_mask    <= x"F0"; 
                                    when "101"  => address_mask    <= x"E0"; 
                                    when "110"  => address_mask    <= x"C0"; 
                                    when others => address_mask    <= x"80"; 
                                end case;
                           when others => -- Fixed
                                address_mask    <= x"FF"; 
                        end case;

                        -- NOTE: We ignore AXI_awlen, and use the last flag on the data transfer                        
                        -- Remember Transaction Id and set the response code for the write ack 
                         AXI_bid     <= AXI_awid;
                         if AXI_awlock = "01" then
                             AXI_bresp <= "01";  -- EXOKAY response code
                         else
                             AXI_bresp <= "00";  -- OKAY response code
                         end if;
                         
                         -- Set up to receive data                         
                         AXI_wready  <= '1';
                         
                    elsif AXI_arvalid = '1' then
                         -- Service read transaction
                         -- remember how large the transfer will be
                         address_start <= AXI_araddr; 
                         address_incr  <= AXI_araddr;
                          
                         case AXI_arburst is
                            when "00"   => -- Fixed
                                 address_mask    <= x"FF"; 
                            when "01"   => -- Incr
                                 address_mask    <= x"00"; 
                            when "10"   =>  -- Wrap 
                                 case AXI_arsize is
                                     when "000"  => address_mask    <= x"FF";
                                     when "001"  => address_mask    <= x"FE"; 
                                     when "010"  => address_mask    <= x"FC"; 
                                     when "011"  => address_mask    <= x"F8"; 
                                     when "100"  => address_mask    <= x"F0"; 
                                     when "101"  => address_mask    <= x"E0"; 
                                     when "110"  => address_mask    <= x"C0"; 
                                     when others => address_mask    <= x"80"; 
                                 end case;
                            when others => -- Fixed
                                 address_mask    <= x"FF"; 
                         end case;
                         words_to_go <= unsigned(AXI_arlen);
                        
                        -- remember Transaction Id for the response 
                         AXI_rid     <= AXI_arid;

                         -- Set the response code             
                         IF AXI_arlock = "01" then
                             AXI_rresp   <= "01"; -- EXOKAY
                         else
                             AXI_rresp   <= "00"; -- OKAY
                         end if;  
                                             
                         AXI_rvalid  <= '1';
                         state <= s_read;                    
                         if unsigned(AXI_arlen) = 0 then
                            AXI_rlast <= '1';
                         end if;
                    end if;
                when s_write =>
                    ------------------------------------------
                    -- Is the Master transmitting a data word?
                    ------------------------------------------
                    if AXI_wvalid = '1' then
                        ---------------------------------------------------
                        -- Is this the last word of the burst? 
                        -- If so, send the response in the AXI_b channel 
                       --------------------------------------------
                        if AXI_wlast = '1' then
                            -- AXI_bresp is already set!
                            AXI_bvalid <= '1';
                            AXI_wready  <= '0';
                            state     <= s_write_wait;
                        end if;
                        address_incr <= std_logic_vector(unsigned(address_incr) + 1);                                                 
                   end if;
                    
                when s_write_wait => 
                    -------------------------------------------------------
                    -- Wait for AXI_bready to be asserted before going idle
                    -- (we have already asserted 'AXI_bvalid')
                    -------------------------------------------------------
                    if AXI_bready = '1' then
                        AXI_bvalid <= '0';
                        state <= s_idle;
                    end if;

                when s_read =>
                    -------------------------------------------------------------
                    -- Service the read until we get to the last word to transfer
                    -- (AXI_rvalid is already asserted)
                    -------------------------------------------------------------
                    if AXI_rready = '1' then
                        AXI_rlast <= '0';
                        if words_to_go = 0 then
                            AXI_rvalid  <= '0';
                            state     <= s_idle;
                        elsif words_to_go = 1 then
                            AXI_rlast <= '1';
                        end if;
                        words_to_go <= words_to_go - 1;
                        address_incr <= std_logic_vector(unsigned(address_incr) + 1);                                                 
                    end if;
                when others =>
                    state <= s_idle;                 
            end case;
        end if;
    end process;
end Behavioral;
