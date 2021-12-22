options sasautos=("S:\Global macros") ;

libname adam "S:\DEV\Pyrotinib\SHRUS1001\CSR\data\adam";
libname sdtm "S:\DEV\Pyrotinib\SHRUS1001\CSR\data\sdtm";

%global protocol outdir txtfile; 
%let protocol=SHRUS1001;
%let outdir=S:\DEV\Pyrotinib\SHRUS1001\CSR\programs\efficacy; 
%let txtfile=S:\DEV\Pyrotinib\SHRUS1001\CSR\programs\efficacy\title1.txt;

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
