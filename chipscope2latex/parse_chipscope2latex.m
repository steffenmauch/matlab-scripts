% This script parse a ASCII exported chipscope chart to 
% use with TikZ inside a LaTeX document
%
% Chipscope is a product form Xilinx and used for debugging the
% internal FPGA signals
%
%   copyright by:
%       Steffen Mauch (C) 2014
%       email: steffen.mauch (at) gmail.com
% 
%
%  Due to TikZ limiations, only signals with less then 256 could
%  be rendered with LaTeX/TikZ/PGF, so adjust the window parameter as whished
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


filename = 'testchipscope.ascii';
nbSamples = 4096;
window = 160:280;

delim = '\t';
clc;


% Get Filename
if ~ischar(filename)
    error('csvreadh:FileNameMustBeString', ...
        'Filename must be a string.'); 
end

% Make sure file exists
if exist(filename,'file') ~= 2 
    error('csvreadh:FileNotFound',...
    'File not found.');
end
    
% open input file
file = fopen( filename );
line = fgetl( file );
h = regexp( line, delim, 'split' );

nbSignals = size(h,2);

data = zeros(nbSamples,nbSignals);
for k=1:nbSamples
    line = fgetl( file );
    temp = str2double( regexp( line, delim, 'split' ) );
    temp(end) = [];
    data(k,:) = temp;
end

fclose(file);



fprintf(['\n\\begin{tikztimingtable}[ \n' ...
    '\ttiming/slope=0,         %% no slope \n' ...
    '\ttiming/coldist=2em,     %% column distance \n' ...
    '\txscale=0.3,yscale=1, %% scale diagrams \n' ...
    '\tsemithick               %% set line width \n' ...
  '] \n']);
fprintf( 'clk & %i{c} \\\\\n', length(window)*2 );
for k = 3:nbSignals
   str = run_length_chipscope( data( window, k )' );
   title = strrep(h{k},'_','\_');
   fprintf('%s & %s \\\\\n', title, str)
end
fprintf('%%\n\\end{tikztimingtable}\n\n');
