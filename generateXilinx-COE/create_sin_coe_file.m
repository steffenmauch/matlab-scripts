nb_steps = 128;

frequ_start = 10;
frequ_dist = 50;

data = zeros(128,8);

k = 1;
for freq = frequ_start:frequ_dist:frequ_start+frequ_dist*7
   temp = floor( sin( 2*pi*freq*(0:1/nb_steps:1-1/nb_steps) ).*(2^15-1)+2^15 );
   data(:,k) = temp';
   k = k + 1;
end

write_coe_file(data,'test.coe')
