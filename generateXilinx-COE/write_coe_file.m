function write_coe_file(data, filename)
% This function generates a 'coe' file which suits for
% Xilinx ISE FPGA-tool (initialization value for BRAM)
%   'data'
%       could be a matrix or a vector and each line is written
%       sequentially in the BRAM
%   'filename'
%       is a string containing the filename of the coe-file
%
%   copyright by:
%       Steffen Mauch, (c) 09/2013
%       email: steffen.mauch (at) gmail.com
%
%  You can redistribute it and/or modify it under the terms of the GNU General Public
%  License as published by the Free Software Foundation, version 2.
% 
%  This program is distributed in the hope that it will be useful, but WITHOUT
%  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
%  FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
%  details.
% 
%  You should have received a copy of the GNU General Public License along with
%  this program; if not, write to the Free Software Foundation, Inc., 51
%  Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
    
fd = fopen(filename,'w');  %#ok<MFAMB>

fprintf(fd,'; This .COE file specifies initialization values for a block\n');  %#ok<MFAMB>
fprintf(fd,'; memory of depth=16, and width=8. In this case, values are\n');
fprintf(fd,'; specified in hexadecimal format.\n');
fprintf(fd,'; script by Steffen Mauch, (c) 09/2013\n');
fprintf(fd,'memory_initialization_radix=16;\n');
fprintf(fd,'memory_initialization_vector=\n');

[a b] = size(data); %#ok<MFAMB>

for l=1:a
    for k=1:b
        fprintf(fd,'%04x', data(l,k) );
    end
    if( l == a )
        fprintf(fd,';\n');
    else
        fprintf(fd,',\n');
    end
end
fclose(fd);  %#ok<MFAMB>
