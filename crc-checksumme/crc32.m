function [result, hex] = crc32(data)
% This function calculates the CRC-32 checksum
%
% copyright by:
% Steffen Mauch (C) 2014
% email: steffen.mauch (at) gmail.com
%
% You can redistribute it and/or modify it under the terms of the GNU General Public
% License as published by the Free Software Foundation, version 2.
%
% This program is distributed in the hope that it will be useful, but WITHOUT
% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
% FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
% details.
%
% You should have received a copy of the GNU General Public License along with
% this program; if not, write to the Free Software Foundation, Inc., 51
% Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 
gx = zeros(1, 32);
gx( [27 24 23 17 13 12 11 9 8 6 5 3 2 1] ) = 1;
 
data_len = length(data);
 
result = dec2bin(0 , 32 ) - '0';
for k=1:data_len
temp = dec2bin( data(k),32 ) - '0';
for m = 1:32
if result(32) ~= temp(m)
result(1:32) = [ 0 result(1:31) ];
result = xor(result,gx);
else
result(1:32) = [0 result(1:31)];
end
end
end
 
str = num2str(fliplr(result));
hex = dec2hex( bin2dec(str),8 );