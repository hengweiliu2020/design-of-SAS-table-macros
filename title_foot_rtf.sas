*read the title footnote file in txt format and create macro variables;
*call this macro if the user is using ODS RTF to create the TLFs;

%macro title_foot_rtf(txtfile=, tabno=);

%global numtle tle1 tle2 tle3 tle3 tle4 tle5; 
options FORMCHAR='|_---|+|---+=|-/\<>*' nodate nonumber nocenter mprint mlogic symbolgen orientation=landscape;

ods escapechar='~';
   
   data _null_;
      set sashelp.vextfl;
      if (substr(fileref,1,3)='_LN' or substr
         (fileref,1,3)='#LN' or substr(fileref,1,3)='SYS') and
         index(upcase(xpath),'.SAS')>0 then do;
         call symput("pgmname",trim(scan(xpath,-1,'\')));
         call symput('pgm',scan(trim(scan(xpath,-1,'\')),1, '.'));
         stop;
      end;

data spec;
company="Hengrui USA";
pgmname="Program Name: &pgmname";
protocol="Protocol: &protocol";
sdatec="&sysdate";
sdate=input(sdatec, date9.);
datec=put(sdate, yymmdd10.);
rundtm="Run datetime: <"||datec||" &systime>";

call symput('rundtm', trim(left(rundtm)));
call symput('company', trim(left(company)));
call symput('pgmname', trim(left(pgmname)));

run;



data titlef;
      infile "&txtfile" print lrecl=50000 pad missover end=eof;
      input text $ 1-175;
     y=index(upcase(substr(text,1,5)),'TABLE') + index(upcase(substr(text,1,7)),'LISTING') + index(upcase(substr(text,1,6)),'FIGURE');
      if substr(upcase(text),1,4)='NOTE' then foot=2;
      if y>0 then num=compress(scan(text,2,' '),':');
      
      data titlef; set titlef;
      retain temp1 ;
      if num>' '  then temp1= num;
      else num=temp1;
      if text=' ' then delete;
      
      proc sort data=titlef; by num;
      
      data titlef; set titlef;
      by num;
      retain temp2;
      if first.num then temp2=.;
      if foot>0 then temp2=foot;
      else foot=temp2;
      if foot<.z then foot=1;
     
      
      data titlef; set titlef;
      where num="&tabno";
      run;
      
      data _null_;
      set titlef end=eof;
      where foot=1;
      i+1;
      call symput(compress("tle"||put(i,best.)), text);
      if eof then call symput('numtle', trim(left(put(_n_,best.))));
      run;
      
      
      title1 font='Arial' height=0.7 j=left "&company" j=right "Page ~{pageof}";
      title2 font='Arial' height=0.7 j=left "&protocol";
      
      
      %do k=1 %to &numtle;
      title%eval(2+&k) font='Arial' height=0.7 j=center "&&tle&k";
      %end;
     
      run;
      
      
      proc sql noprint;
      select count(*) into :footobs from titlef where foot=2;
      
      %if &footobs=0 %then %do;
      footnote1 justify=l "~R'\brdrt\brdrs\brdrw5'";
      %end;
      
      %else %do;
      
      data _null_;
      set titlef end=eof;
      where foot=2;
      i+1;
      call symput(compress("fot"||put(i,best.)), trim(left(text)));
      if eof then call symput('numfot', trim(left(put(_n_,best.))));
      run;
      
      
      footnote1 justify=l "~R'\brdrt\brdrs\brdrw5'";
      %do i=1 %to &numfot;
      footnote%eval(1+&i) font='Arial' height=0.7 j=left "&&fot&i";
      %end;
      %end;
      
      
      



%mend;

