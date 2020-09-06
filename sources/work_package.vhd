library ieee;
use ieee.std_logic_1164.all;

package work_package is
 type state_type is (idle, capture_image, y0_first, y1_first, px1, x_first, x_second, py2, y0_second, y1_second, init_res, init_l_res, res, l_res, l_res2, dist, dm);
end work_package;

package body work_package is
end work_package;