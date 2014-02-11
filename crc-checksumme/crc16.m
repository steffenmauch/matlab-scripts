

    function [result, hex] = crc16(data)
    % This function calculates the CRC-16 checksum
    %
    % copyright by:
    % Steffen Mauch (C) 2013
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
     
    gx = zeros(1, 16);
    gx( [13 6 1] ) = 1;
     
    data_len = length(data);
     
    result = dec2bin( 0 , 16 ) - '0';
    for k=1:data_len
    temp = dec2bin( data(k),8 ) - '0';
    for m = 1:8
    if result(16) ~= temp(m)
    result(1:16) = [ 0 result(1:15) ];
    result = xor(result,gx);
    else
    result(1:16) = [0 result(1:15)];
    end
    end
    end
     
    str = num2str(fliplr(result));
    hex = dec2hex( bin2dec(str), 4 );
