%macro ple(tagn=, tag=, indata=, outdata=, classvar=, timepoint=, catlabel=, indent=N); 

data get_cat(keep=timelist catlabel); 
length catlabel $100.;
catlab="&catlabel";
timepoint="&timepoint";
numcat=countw(catlab,'#') ;
do k=1 to numcat;
timelist=input(scan(timepoint,k,' '), best.);
catlabel=scan(catlab, k, '#');
output;
end;
run;

proc sort data=&indata out=_&indata;
by &classvar;
run;

ods output Quartiles=quartiles (keep=&classvar percent estimate lowerlimit upperlimit);
ods output ProductLimitEstimates=ple (keep=&classvar survival stderr timelist);
proc lifetest data=_&indata timelist=&timepoint conftype=loglog outsurv=surv;
by &classvar;
time aval*cnsr(1);
run;

** Survival Rate (percent) (95% CI) **;  
proc sort data=ple; by &classvar descending survival; 
data survpct;
   length  surv survlow survhi $10 result $25;;  
   merge ple(in=a) surv(in=b where=(sdf_lcl^=. or sdf_ucl^=.)); 
   by &classvar descending survival; 
   if a; 
 
   if survival=. then surv    = 'NE';  else surv    = put(survival*100, 5.1);
   if sdf_lcl=.  then survlow = 'NE';  else survlow = put(sdf_lcl*100, 5.1);
   if sdf_ucl=.  then survhi  = 'NE';  else survhi  = put(sdf_ucl*100, 5.1); 
   result = strip(surv)||" ("||strip(survlow)||", "||strip(survhi)||")"; 
run;

data survpct; set survpct;
ci=compbl('('||survlow||', '||survhi||')');

proc sort data=survpct; by timelist;

proc transpose data=survpct out=_tt1_ prefix=s_;
var surv; 
id &classvar;
by timelist;

proc transpose data=survpct out=_tt2_ prefix=c_;
var ci; 
id &classvar;
by timelist;

data &outdata; 
length %do k=1 %to &tot; &&val&k %end; $30. tag $100.;
merge _tt1_ _tt2_ get_cat;
by timelist; 
%do k=1 %to &tot;
&&val&k=strip(s_&&val&k)|| " "||strip(c_&&val&k);
%end;
tagn=%eval(&tagn);
tag="&tag";
indent="&indent"; 
run;

proc sort data=&outdata; by timelist;
run;


%mend;



