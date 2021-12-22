options sasautos=("S:\Global macros") ;

libname adam "xxxxxxxxx\adam";
libname sdtm "xxxxxxxxx\sdtm";

%global protocol outdir txtfile; 
%let protocol=SHRUS1001;
%let outdir=xxxxxxxxxxxxxxx\efficacy; 
%let txtfile=xxxxxxxxxxxxxxx\efficacy\title1.txt;

 data _null_;
      set sashelp.vextfl;
      if (substr(fileref,1,3)='_LN' or substr
         (fileref,1,3)='#LN' or substr(fileref,1,3)='SYS') and
         index(upcase(xpath),'.SAS')>0 then do;
         call symput("pgmname",trim(scan(xpath,-1,'\')));
         call symput('pgm',scan(trim(scan(xpath,-1,'\')),1, '.'));
         stop;
      end;
run;
