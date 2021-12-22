
data adtte; set adam.adtte; 
where  ittfl='Y' and paramcd='PFS' and tr01pg3 in ('Group B','Group C');
if tr01pg3='Group B' then trt='trta'; 
else if tr01pg3='Group C' then trt='trtb'; 

data adsl; set adam.adsl;
where ittfl='Y' and tr01pg3 in ('Group B','Group C');
if tr01pg3='Group B' then trt='trta'; 
else if tr01pg3='Group C' then trt='trtb'; 

data adtte; 
length cnsr_c $8.;
set adtte; 
if cnsr=0 then cnsr_c='Event';
else if cnsr=1 then cnsr_c='Censored';
aval=aval/4; * change week to month; 
run;

%bign(classvar=trt);

%category_stat(tagn=1, tag=, category=Event#Censored, indata=adtte, invar=cnsr_c, 
classvar=trt, outdata=p1, catlabel=Event#Censored);

%single_line(tagn=2, tag=, catlabel=PFS (months), outdata=p2);
%quartiles(tagn=2, tag=, indata=adtte, outdata=p3, classvar=trt, indent=Y);

%ple(tagn=3, tag=, indata=adtte, outdata=p4, classvar=trt, timepoint=%str(3 6 9 12), 
catlabel=3-month event-free rate (95% CI)#6-month event-free rate (95% CI)#9-month event-free rate (95% CI)#12-month event-free rate (95% CI)  );

%hazard(tagn=4, tag=, strata=sex race, indata=adtte, outdata=p5, classvar=trt);

%combine(prefix=p, count=5, outdata=final); 

%title_foot_rtf(txtfile=&txtfile, tabno=1.1);


%let trt0=; 
%let trt1=Treatment A ^ (N=&bign1); 
%let trt2=Treatment B ^ (N=&bign2);
%report_rtf(indata=final, outdir=&outdir);

