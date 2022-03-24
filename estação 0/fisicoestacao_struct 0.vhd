-- VHDL Entity DNP3_802_11_lib.Station80211.interface
--
-- Created:
--          by - Lucas.UNKNOWN (LUCAS-ACER64)
--          at - 16:44:05 19/07/2013
--
-- Generated by Mentor Graphics' HDL Designer(TM) 2012.1 (Build 6)
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.STD_LOGIC_UNSIGNED.all;
USE IEEE.numeric_std.all;

ENTITY fisicoestacao080211 IS
   PORT( 
        clk_80211          : IN     std_logic;
        clk_10mhz          : in     std_logic;        
        rst_80211          : IN     std_logic; 
        sta_send_frame_len0: IN     std_logic_vector (15 DOWNTO 0);
        sta_send_frame0    : IN     std_logic_vector (3007 DOWNTO 0);
        tx_fromsta10       : IN     std_logic_vector (3199 DOWNTO 0);
        endtx00            : IN     std_logic;
        endtx000            : out     std_logic;
        endtx01            : OUT     std_logic;
        endtx0             : OUT     std_logic;
        channel_idle0      : out     std_logic;
        sta_rec_frame0     : OUT    std_logic_vector (3007 DOWNTO 0);
        sta_rec_frame_len0 : OUT    std_logic_vector (15 DOWNTO 0);
        sta_phy_tx0        : OUT    std_logic_vector (3199 DOWNTO 0)
   
   );

-- Declarations

END fisicoestacao080211 ;

--
-- VHDL Architecture DNP3_802_11_lib.Station80211.struct
--
-- Created:
--          by - Lucas.UNKNOWN (LUCAS-ACER64)
--          at - 16:44:06 19/07/2013
--
-- Generated by Mentor Graphics' HDL Designer(TM) 2012.1 (Build 6)
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.STD_LOGIC_UNSIGNED.all;
USE IEEE.numeric_std.all;

--LIBRARY DNP3_802_11_lib;

ARCHITECTURE struct OF fisicoestacao080211 IS

   -- Architecture declarations

   -- Internal signal declarations
    


   -- Component Declarations
   COMPONENT tx_rx_physical0
   PORT (
      clk_80211          : IN     std_logic;
      clk_10mhz          : in     std_logic;
      rst_80211          : IN     std_logic;
  
     sta_send_frame_len0 : IN     std_logic_vector (15 DOWNTO 0);
     sta_send_frame0     : IN     std_logic_vector (3007 DOWNTO 0);
     sta_rec_frame0      : OUT    std_logic_vector (3007 DOWNTO 0);
     sta_rec_frame_len0  : OUT    std_logic_vector (15 DOWNTO 0);
     tx_fromsta10        : IN     std_logic_vector (3199 DOWNTO 0);
     sta_phy_tx0         : OUT    std_logic_vector (3199 DOWNTO 0);
     endtx0              : OUT     std_logic;
     endtx00             : IN     std_logic;
     endtx000             : out     std_logic;
     endtx01             : OUT     std_logic;
     channel_idle0       : out     std_logic
   );
   END COMPONENT;
   

   -- Optional embedded configurations
   -- pragma synthesis_off
--   FOR ALL : SAR_Backoff USE ENTITY DNP3_802_11_lib.SAR_Backoff;
--   FOR ALL : SAR_MAC USE ENTITY DNP3_802_11_lib.SAR_MAC;
--   FOR ALL : SAR_PHY USE ENTITY DNP3_802_11_lib.SAR_PHY;
--   FOR ALL : SSM_MAC USE ENTITY DNP3_802_11_lib.SSM_MAC;
--   FOR ALL : SSM_PHY USE ENTITY DNP3_802_11_lib.SSM_PHY;
--   -- pragma synthesis_on


BEGIN

   -- Instance port mappings.
   B_1 : tx_rx_physical0
      PORT MAP (
          clk_80211 => clk_80211,
          clk_10Mhz => clk_10Mhz,
          rst_80211 => rst_80211,
          
          -- time management interface
      
          sta_send_frame_len0 => sta_send_frame_len0,
          sta_send_frame0     => sta_send_frame0,
          sta_rec_frame0      => sta_rec_frame0, 
          sta_rec_frame_len0  => sta_rec_frame_len0,
          tx_fromsta10        => tx_fromsta10,
          sta_phy_tx0         => sta_phy_tx0,
          endtx0              => endtx0,
          endtx00              => endtx00,
          endtx000              => endtx000,
          endtx01              => endtx01,
          channel_idle0       => channel_idle0
 );
  

END struct;