
--
--! @file        mbrot_pkg.vhd
--! @brief       
--! @author      RWH
-- VHDL Source
-- Device      : 
-- Project     : 
-- Project No. : 
-- PCB         : 
-- PCB No.     : 
-- Date        : unreleased
-- Release     : unreleased
-- Compiler    : 
-- Synthesiser : 

LIBRARY ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

LIBRARY ieee_proposed;
use ieee_proposed.fixed_float_types.all;
use ieee_proposed.fixed_pkg.all;


package mbrot_pkg is


constant INT_PART           : integer := (4 -1);    -- 4 bits for integer part (3 downto 0)
constant FRAC_PART          : integer := -32;       -- 32 bits for fractional part (1 to 32)


type complex_t is
    record
        re : sfixed(INT_PART downto FRAC_PART);
        im : sfixed(INT_PART downto FRAC_PART);
    end record complex_t;
    
type xypos_t is
    record
        xpos : integer range 0 to 2047;
        ypos : integer range 0 to 2047;
    end record xypos_t;


end package mbrot_pkg;



