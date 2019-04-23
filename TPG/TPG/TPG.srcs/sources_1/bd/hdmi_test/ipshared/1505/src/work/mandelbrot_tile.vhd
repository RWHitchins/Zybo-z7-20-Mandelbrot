
--------------------------------------------------------------------------------
-- Project Name : <project name>
--! @file mandelbrot_tile.vhd

--! @author Roger Hitchins
--! @date 11th February 2019
--
-- Change History ...
-- <date> <modified by> <change description>
--
--------------------------------------------------------------------------------


-- Mandelbrot set - a description. 

-- For some values of complex value C the iteration Z --> Z*Z + C escapes to infinity. 
-- For other values the iteration remains within a disc of some finite radius. The values within this disc are referred to as the members of the mandelbrot set.
-- The interesting values for C are chosen so that they map to an image area, where the X-axis (real) boundary ranges from -2 to +1, and y-axis (imag) ranges from -1 to + 1. For example, for a 640x480 image, you could choose
-- to map pixel(0,0) to (-2 + j) and pixel(639,0) to (2 + j), pixel(0,479) to (-2 - j) and pixel(639,479) to (2 - j). This way you would exercise all the values in and around the set if you were to follow a raster scan of values.
-- The members of the set are typically rendered in black, while the rate at which values outside the set escape to infinity determines the colour they are rendered with.
-- In software, this is usually performed pixel by pixel following a typical raster scan. In firmware it may be possible to distribute the problem to speed things up. 
-- Resource usage is key here - careful thought will be required to attempt to optimize the process (actually for both resource usage and speed of operation)

-- if z= (x + jy) then z*z = (x*x - y*y + 2*x*y*j)
-- The real part of this, re = x*x - y*y
-- The imaginary part of this, im = 2*x*y
-- The iteration adds the real part of imaginary number C to the real part of Z-squared, and the imaginary part of C to the imaginary part of Z-squared.
-- If the modulus of the resulting complex number is not greater than two, it assigns the result back to Z and the iteration continues.
-- If it is, it is not part of the set, so the iteration escapes and we move on to assessing the next location.
-- Note that within the set the iteration will not grow and so an iteration loop-count escape mechanism is usually employed.

-- Alternatively, It is possible to determine if the value in question lies within the main cardioid or the period-2 bulb before passing the value through the escape time algorithm. 
-- This may help to speed up rendering of an entire image, but will increase the resources required to do so.
-- Exactly how the resources are utilised to perform the maths required has yet to be determined - this is a starting point to allow that to be determined.

-- Optimization information :

-- Point (x(real),y(imag)) lies within main cardioid :-
-- p = sqrt( (sqr(x-1/4) + y*y) )
-- x < p - 2*p*p + 1/4

-- Point (x(real),y(imag)) lies within the period-2 bulb :-
-- sqr(x+1) + y*y < 1/16

-- Note: The data generated by this routine needs to be written into a memory so that an entire picture can be rendered.
-- The nature of the calculations means that some pixels take longer to determine their associated value (which will be used to colour the pixel)
-- Smaller areas will take less time to calculate.
-- Exactly how the data generated from this code is used to create an image has yet to be decided!!

-- R.W.Hitchins 11th February 2019

LIBRARY ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

LIBRARY ieee_proposed;
use ieee_proposed.fixed_pkg.all;

LIBRARY work; 
USE work.mbrot_pkg.all;             -- defines complex_t and xypos_t


entity mandelbrot_tile is
port(
    reset           : in std_logic;
    pix_clk         : in std_logic;
    start           : in std_logic;                         -- start calculating the results 
    ready           : out std_logic;
    max_its         : in std_logic_vector(15 downto 0);     -- sets the max. no of iterations
    cmpx_tl         : in complex_t;
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
end mandelbrot_tile;


architecture rtl of mandelbrot_tile is



constant lim            : sfixed(3 downto 0) := x"4";       -- Value used to indicate the iteration is growing ... above this, bomb out.
type mbrot_states is (idle, setup_values, get_next_coord, xypos_to_complex, calc_x2y2, calc_xy, calc_modz, perform_iteration, update_pos);

signal mbrot_state      : mbrot_states;
signal start_d          : std_logic;
signal icount           : integer range 0 to 65535;
signal iter_no          : integer range 0 to 65535;
signal xstart           : integer range 0 to 2047;
signal ystart           : integer range 0 to 2047;
signal xfinish          : integer range 0 to 2047;
signal yfinish          : integer range 0 to 2047;
signal curr_xpos        : integer range 0 to 2047;
signal curr_ypos        : integer range 0 to 2047;
signal cx_re_start      : sfixed(3 downto -32);
signal cx_im_start      : sfixed(3 downto -32);
signal cx_re_finish     : sfixed(3 downto -32);
signal cx_im_finish     : sfixed(3 downto -32);
signal act_re           : sfixed(3 downto -32);
signal act_im           : sfixed(3 downto -32);
signal x2               : sfixed(3 downto -32);
signal y2               : sfixed(3 downto -32);
signal xy               : sfixed(3 downto -32);
    
signal recip_xsize      : sfixed(3 downto -32);
signal recip_ysize      : sfixed(3 downto -32); 
    
signal cal              : complex_t;
signal iter_val         : std_logic;
signal xsize            : integer range 0 to 2047;
signal ysize            : integer range 0 to 2047;
    
signal modz             : sfixed(3 downto -32);
signal im_range_recip_y : sfixed(3 downto -32);
signal re_range_recip_x : sfixed(3 downto -32); 

begin -- main

--recip_xsize <= to_sfixed(0.0005208333, 3,-32);      -- reciprocal of 1920 (0000.00000000001000100010001000100001 (3,-32) = (3 downto 0)..then decimal place then 32 decimal bits (36 bits in total)
--recip_ysize <= to_sfixed(0.0009259259, 3,-32);      -- reciprocal of 1080 (0000.00000000001111001010111001110101 (3,-32)

-- Note: this is pre-calculated to save having to perform an additional division.
recip_xsize <= "000000000000001000100010001000100001"; -- (3,-32) = (3 downto 0)..then decimal place then 32 decimal bits (36 bits in total)
recip_ysize <= "000000000000001111001010111001110101"; -- (3,-32)


process(pix_clk)

variable im_range     : sfixed(3 downto -32);
variable re_range     : sfixed(3 downto -32);                           

begin
    if rising_edge(pix_clk) then
        if (reset = '1') then       -- synchronous reset
            mbrot_state <= idle;
            icount      <= 0;
            cal.re  <= (others => '0');
            cal.im  <= (others => '0');
            xsize   <= 0;
            ysize   <= 0;
        else  
        
        start_of_frame  <= '0';                                          -- default values
        end_of_line     <= '0';
        iter_val        <= '0';
        start_d         <= start;
        ready           <= '0';

        case mbrot_state is   
            when idle =>
                ready <= '1';
                if (start_d = '0' and start = '1') then                 -- Look for rising edge of start signal
                    xstart          <= pixpos_tl.xpos;                  -- take a snapshot of the TLHC 
                    ystart          <= pixpos_tl.ypos;
                    xfinish         <= pixpos_br.xpos;                  -- take a snapshot of the BRHC             
                    yfinish         <= pixpos_br.ypos;
                    cx_re_start     <= cmpx_tl.re;
                    cx_im_start     <= cmpx_tl.im;
                    cx_re_finish    <= cmpx_br.re;
                    cx_im_finish    <= cmpx_br.im;
                    mbrot_state     <= setup_values;                            
                end if;
            
            when setup_values =>
                -- compute ranges...
                im_range  := resize( (cx_im_start  - cx_im_finish), im_range);
                re_range  := resize( (cx_re_finish - cx_re_start) , re_range);
                mbrot_state     <= get_next_coord; 
            
            when get_next_coord     => 
                xsize <= (xfinish - xstart) + 1;                        --integer range
                ysize <= (yfinish - ystart) + 1;

                re_range_recip_x <= resize(re_range * recip_xsize, re_range_recip_x);
                im_range_recip_y <= resize(im_range * recip_ysize, im_range_recip_y);
                
                curr_xpos   <= xstart;
                curr_ypos   <= ystart;                
                mbrot_state <= xypos_to_complex;                 
            
            when xypos_to_complex =>                                    -- use curr_xpos, curr_ypos and cmpx_ range to calculate complex number equivalent to position     
                act_re <= resize( ( cx_re_start + (re_range_recip_x * to_sfixed(curr_xpos, 11, 0)) ) , act_re );
                act_im <= resize( ( cx_im_start - (im_range_recip_y * to_sfixed(curr_ypos, 11, 0)) ) , act_im );                                        
                mbrot_state <= calc_x2y2;
            
            when calc_x2y2 =>                                             -- iteration loop-back point
                x2   <= resize(cal.re * cal.re, x2);  
                y2   <= resize(cal.im * cal.im, y2); 
                xy   <= resize(cal.re * cal.im, xy);
                mbrot_state <= calc_modz;
                       
            when calc_modz =>
                modz <= resize((x2 + y2), modz);                        -- strictly speaking the modulus is the square root of this number, 
                mbrot_state <= perform_iteration;                       -- so escape when the result is bigger than 4 rather than 2            
            
            when perform_iteration =>       
                if (modz > lim) or (icount > (to_integer(unsigned(max_its))) - 1) then
                    if (curr_xpos = xfinish ) then
                        end_of_line <= '1';
                    end if;
                    if (curr_xpos = 0 and curr_ypos = 0) then
                        start_of_frame <= '1';
                    end if;
                    iter_val    <= '1';
                    iter_no     <= icount;
                    icount      <= 0;
                    cal.re      <= (others => '0');                              -- Clear before another iteration
                    cal.im      <= (others => '0');  
                    mbrot_state <= update_pos;
                else
                    iter_no     <= icount;
                    icount <= icount + 1;
                    -- calculate the complex values and add in the re+im values related to the current pixel
                    cal.re <= resize( ( x2 - y2 )  + act_re , x2);
                    cal.im <= resize( ( xy + xy )  + act_im , xy);          -- or (sll 1) shift xy left by one bit to double it
                    mbrot_state <= calc_x2y2;
                end if; 

            
            
            
            when update_pos =>   
            
                -- needs to step through the picture tile we're interested in pixel by pixel (raster) and spit out an equivalent complex number
                if (curr_xpos = xfinish ) and (curr_ypos = yfinish) then    -- must be at the end of the tile
                    mbrot_state <= idle;
                else
                    if (curr_xpos = xfinish) then
                        curr_xpos <= xstart;
                        curr_ypos <= curr_ypos + 1;
                    else
                        curr_xpos <= curr_xpos + 1;
                    end if; 
                    mbrot_state <= xypos_to_complex;
                end if;    
                                          
            when others => mbrot_state <= idle;
        end case;

        end if;
    end if;
end process;



data_out    <= std_logic_vector(to_unsigned(iter_no, 16));
valid       <= iter_val;
x_pos       <= std_logic_vector(to_unsigned(curr_xpos, 11));
y_pos       <= std_logic_vector(to_unsigned(curr_ypos, 11));

end rtl;
