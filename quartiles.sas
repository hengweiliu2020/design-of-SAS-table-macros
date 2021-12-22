%macro quartiles(tagn=, tag=, indata=, outdata=, classvar=, 
                 catlabel=25th Percentile (95% CI)#Median (95% CI)#75th Percentile (95% CI)#Range, indent=N); 

data get_cat; 
length catlabel $100.;
catlab="&catlabel";
numcat=countw(catlab,'#') ;
do k=1 to numcat;
catn=k;
catlabel=scan(catlab, k, '#');
output;
end;
run;

data _null_; 
set get_cat end=eof;
i+1;
call symput(compress("catlab"||put(i, best.)), trim(left(catlabel)));
run;

proc sort data=&indata out=_&indata;
by &classvar;
run;

ods output Quartiles=quartiles (keep=&classvar percent estimate lowerlimit upperlimit);
ods output ProductLimitEstimates=ple; * (keep=&classvar survival stderr timelist);
proc lifetest data=_&indata timelist=6 12 18 24 conftype=loglog outsurv=surv;
by &classvar;
time aval*cnsr(1);  
run;

data quartiles; 
length lowerc upperc estc $20. value $50.;
set quartiles; 

if lowerlimit<.z then lowerc='NE';
else lowerc=put(lowerlimit,5.1);

if upperlimit<.z then upperc='NE';
else upperc=put(upperlimit,5.1);

value='('||lowerc||', '||upperc||')';
value=compbl(value);

if estimate>.z then estc=put(estimate,5.1);
else estc='NE';

proc sort data=quartiles; by percent;

proc transpose data=quartiles out=_tt1_ prefix=e_;
var estc; 
id &classvar;
by percent;

proc transpose data=quartiles out=_tt2_ prefix=v_;
var value; 
id &classvar;
by percent;


data &outdata; 
length %do k=1 %to &tot; &&val&k %end; $30. catlabel $100.;
merge _tt1_ _tt2_;
by percent;
%do k=1 %to &tot;
&&val&k=strip(e_&&val&k) || " "|| strip(v_&&val&k);
%end;

if percent=25 then catlabel="&catlab1";
if percent=50 then catlabel="&catlab2";
if percent=75 then catlabel="&catlab3";
run;

** get the range ** ;
data _&indata; 
length avalplus $6.;
set _&indata; 
if cnsr=1 then avalplus=put(aval,5.1)||"+";
else avalplus=put(aval, 5.1); 
run;

proc sort data=_&indata; 
by &classvar aval;
run;

data get_min(keep=&classvar avalplus rename=avalplus=min); 
set _&indata;
by &classvar aval;
if first.&classvar;

data get_max(keep=&classvar avalplus rename=avalplus=max);
set _&indata;
by &classvar aval;
if last.&classvar; 

data min_max;
merge get_min get_max;
by &classvar;
minmax=strip(min)||", "||strip(max);
run;

proc transpose data=min_max out=range;
var minmax;
id &classvar;
run;

data range; set range; 
catlabel="&catlab4";
percent=100.1;
run;

data &outdata; 
length tag $100.;
set &outdata range;
tagn=%eval(&tagn);
tag="&tag";
indent="&indent";
run;

proc sort data=&outdata; by percent;
run;

%mend;

