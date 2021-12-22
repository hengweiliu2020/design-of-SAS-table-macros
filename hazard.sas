
 

%macro hazard(tagn=, tag=, strata=, indata=, outdata=, classvar=, catlabel=p-value [a]#Hazard ratio (95% CI) [b], indent=N);

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

ods output parameterestimates=work.parmest;
proc phreg data=&indata;
class &classvar;
strata &strata;
model aval*cnsr(1)=&classvar/rl=pl;
run;

data parmest; set parmest;
ratioci=put(hazardratio,5.1) ||' ('||put(hrlowerplcl,5.1)||','||put(hrupperplcl,5.1)||')';
pvalue=put(probchisq, 6.4);
run;

proc transpose data=parmest out=hazard1; 
var pvalue;
id classval0;
run;

proc transpose data=parmest out=hazard2; 
var ratioci;
id classval0;
run;

data &outdata;
length %do k=1 %to %eval(&tot-1); &&val&k %end; $30. catlabel tag $100.;
set hazard1(in=a) hazard2(in=b);
if a then catlabel="&catlab1";
if b then catlabel="&catlab2";
tagn=&tagn;
tag="&tag";
indent="&indent";
run;


%mend;


