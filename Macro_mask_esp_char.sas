
*masking the special characters: constant text %STR %NRSTR;
%let clear = title; footnote;
title 'Tesla stock';
footnote "Go and buy tesla stock";
proc print data=sashelp.cars;
run;
options mprint symbolgen;
&clear.;
*here macro variable doesnot resolve to the clear;*this is why we need the %str*/;

%let clear = %str(title; footnote;);
title 'Tesla stock';
footnote "Go and buy tesla stock";
proc print data=sashelp.cars;
run;
options mprint symbolgen;
&clear.;


*%NRSTR doesnot mast the &%;
%let company =%nrstr(AT&%T);
options mprint symbolgen;
%put &company;
 
*Thus company macro is resolved;


*USING THE %SUPERQ,%BQUOTE, %NRBQUOTE TO MASK RESOLVED VALUES;
*SUPERQ MASKS  The %SUPERQ function masks all special 
characters and mnemonics, including macro triggers, during macro execution;
%macro where (state);
%if %superq(state)=NC %then %put Southeast;
%else %if %superq(State) = %str(OR) %then %put Northeast;
%else %put unknown;
%mend where;

options mprint symbolgen;
%where(OR);

/*SOMETIMES YOU DONOT HAVE TO MAST THE RESOLVED VALUE, %BQUOTE*/

%MACRO CARS(mk1,mk2);
%let make=%bquote("&mk1", "&mk2");
title "Cars: &make";
proc print data=sashelp.cars;
var make model type;
where make in (%unquote(&make));
run;
%mend cars;

options mprint symbolgen;
%cars (Honda,Audi)


/*acessing and printing all data sets in a library using macros*/

libname ldata "C:\Users\sbasnet\Dropbox (MRI-Biometrics)\Biometrics\NATRIUM-HF\Data\08Feb2021\SAS Data";

/*write a macro to print specified observation from all the data sets in the library*/
%macro printlib (libname);
proc sql noprint;          /*creates a macros dsn1 to dsn n... for all data sets*/
  select cats("&libname..",memname)
     into : dsn1-
   from dictionary.tables
   where libname="%upcase(&libname.)";
quit;
%do i=1 %to &sqlobs;
data &&dsn&i.;
   set &&dsn&i.;
   run;
/*if you want to print everything*/
/*proc print data=&&dsn&i.;*/
/*run;*/
%end;
%mend printlib;

%printlib (ldata);

libname lldata "C:\Users\sbasnet\Dropbox (MRI-Biometrics)\Biometrics\NATRIUM-HF\Data\25jan2021\SAS Data";
%printlib (lldata);


