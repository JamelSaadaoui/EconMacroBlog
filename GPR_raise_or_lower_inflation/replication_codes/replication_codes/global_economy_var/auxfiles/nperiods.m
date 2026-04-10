function [ y ] = nperiods( str_sample_init,str_sample_end,Tdelta,p)

t1 = str2num(str_sample_init(1:4)) + (str2num(str_sample_init(6:7)))*Tdelta + p*Tdelta ;
t2 = str2num(str_sample_end(1:4)) + (str2num(str_sample_end(6:7)))*Tdelta  ;

y = round((t2 - t1)/Tdelta) + 1 ;



end

