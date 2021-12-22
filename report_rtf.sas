%macro report_rtf(indata=, outdir=, trtwidth=1.5);
libname outd "&outdir";

%custom;

** take care of the variable INDENT ** ; 

%varexist(&indata, indent);

%if &result=1 %then %do;
data _&indata; set &indata;
%end;
%else %do;
data _&indata; set &indata;
indent='N';
%end;
run;

** take care of the variable INDENT2 ** ; 

%varexist(_&indata, indent2);

%if &result=1 %then %do;
data _&indata; set _&indata;
%end;
%else %do;
data _&indata; set _&indata;
indent2='N';
%end;
run;

ods document name=outd.&pgm.(write);
ods rtf file="&outdir\&pgm..rtf" style=custom ; 

proc report data=_&indata headline headskip 
                 missing split='^';
columns tagn tag indent indent2 catlabel %do k=1 %to &tot; &&val&k %end;;
define tagn/group noprint order; 
define tag/ group noprint;
define indent/display noprint; 
define indent2/display noprint; 
define catlabel/display style(column)={ cellwidth=%sysevalf(8.8-&tot*&trtwidth) in} 
                style(header)={just=left cellwidth=%sysevalf(8.8-&tot*&trtwidth) in} 
                "&trt0" flow order=data;
%do k=1 %to &tot; 
define &&val&k/style(column)={just=right cellwidth=&trtwidth in} 
               style(header)={just=right cellwidth=&trtwidth in}  "&&trt&k" flow;
%end;

compute before tag; 
line @1 tag $200.;
endcomp;

compute catlabel;
if indent='Y' then call define(_col_, "style", "style={leftmargin=.15in}");
if indent2='Y' then call define(_col_, "style", "style={leftmargin=.30in}");
endcomp;
run;

ods rtf close; 
ods document close; 

run;

%mend;
