
%macro combine(prefix=, count=, outdata=);

data &outdata; 
set %do k=1 %to &count; &prefix&k %end;;  
run;

%mend;


