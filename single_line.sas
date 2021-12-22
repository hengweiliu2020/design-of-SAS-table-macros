




%macro single_line(tagn=, tag=, catlabel=, outdata=);

data &outdata; 
tagn=&tagn;
tag="&tag";
catlabel="&catlabel"; 
run;

%mend;

