/** MACROS **/

/* Macros: macros is nothing but we do not need to write a program repetitively. */

/* how many ways to create a macro variables:- */


/* %let ; */
/* %macro parameters; */
/* %do; */
/* call symput in data step; */
/* proc sql; into: clause; */

/* %local; */
/* %global; */

/** systen defined macro options(macro debugging options) **/


/* Symbolgen :  */
/* ptints the values of the resolving a macro variables in the sas log */

/* Mlogic: */
/* prints in the sas log when the execution started and ended for each macro program */

/* mprint: */

/* prints the sas macro program to the sas log window */

/* merror: */
/* prints the error line number when any error occusrs during execution */

options symbolgen mlogic mprint merror serror;
%let x=16; /** global macro variable **/
%put &x.;

data new;
set sashelp.class;
where age=&x.;
run;

%let path=C:\Users\Sudha\Desktop\New folder\sas data sets\Banking\product.xls;
libname sas excel "&path";
data new;
set sas.product;
run;

%let path1=C:\Users\Sudha\Desktop\New folder\sas data sets\Banking\geography.xls;

proc import datafile="&path1." out=ds
dbms=xls replace;
run;


data empsalary;
input empid empname $ empdept $ salary;
cards;
101 sudhakar A  75000
102 prit B 50000
103 vishal C 55000
104 surat D 60000
105 tango E 65000
106 alpha A 75000
107 suresh B 50000
108 rima C 55000
109 pooja D 60000
110 tulshi E 65000
111 chailtali A 80000
112 hina A 45000
113 tina B 55000
114 jina B 35000
115 mina C 65000
116 kina C 38000
117 kamina D 65000
118 kutta D 25000
119 riddhi E 89000
120 dharti E 15000
;
run;




%macro bonusrep;
%local y;
%let y=15; /** local macro variable **/
data new;
set empsalary;
bonus=salary*&y./100;
proc print;
run;
%mend;

%put &y.;
%bonusrep;


%macro sudhakar;
data class1;
set sashelp.class;
where age=&y.;
proc print;
run;
%mend;

%sudhakar;


%let z=12; /** global macro variable **/

%macro sudhakar;
%let z=15; /** local macro varibale **/
data new;
set sashelp.class;
where age=&z.;
run;
proc print data=new;
run;
%put &z.;
%mend;

%put &z.;

%sudhakar;



/** macro parameters **/
/*1. keyword parameters*/
/*2. positional parameters*/
/*3. mixed parameters*/
 
/*1. keyword parameters*/
%macro shri(x=,y=,z=);
data &y.;
set &x.;
where age=&z.;
proc print;
run;
%mend;
%shri(x=sashelp.class,y=class_new,z=14);
%shri(x=sashelp.class,y=class_new1,z=15);
%shri(x=sashelp.class,y=class_new2,z=13);
%shri(y=class_new3,z=11,x=sashelp.class);


/** POSITIONAL PARAMETERS **/

%macro parameters(input,output,var);
data &output.;
set &input.;
where age=&var.;
run ;
%mend;
%parameters(sashelp.class,class_new,14);
%parameters(sashelp.class,class_new1,15);
%parameters(sashelp.class,class_new2,13);
%parameters(sashelp.class,class_new3,11);


/** MIXED PARAMETERS **/

%macro parameters(input,var,output=);
data &output.;
set &input.;
where age=&var.;
run;
%mend;
%parameters(sashelp.class,14,output=class_new);
%parameters(sashelp.class,13,output=class_new1);
%parameters(sashelp.class,12,output=class_new2);
%parameters(sashelp.class,15,output=class_new3);


%let a=40;
%let b=30;
%let c=50;

%let d=%eval(&a.+&b.+&c.);
%put &d.;

%let a=40.58;
%let b=30.26;
%let c=50;

%let d=%sysevalf(&a.+&b.+&c.);
%put &d.;


%let a=h;
%let h=g;
%let g=k;

/* &&=& */
/* &&&&=& */
/*2,4,8,16,32,64,128,256*/

%put &&&&&&&&a.;



%macro cityday(input=,output=);
data &output. ;
set &input.;
if DATE="&date."d then output;
run;
%mend;
%let x=32;

%macro macroname;
%let begin_date=%sysfunc(intnx(year,%sysfunc(today()),-&x.,B),date9.);
%let ending_date=%sysfunc(intnx(year,%sysfunc(today()),-&x.,E),date9.);
%let diff=%sysfunc(intck(month,"&begin_date."d,"&ending_date."d));
%put &begin_date. &ending_date. &diff.;

%do i=1 %to &diff.;
%let date=%sysfunc(intnx(month,"&begin_date."d,&i.,B),date9.);
%put &date.;
%cityday(input=sashelp.citiday,output=city_day_&date.); /** nested macro program**/
%end;
%mend macroname;

%macroname;

/** it will create a macro variable for the begining value of the varible **/
proc sql;
select name into: class_name from sashelp.class;
quit;

%put &class_name.;

/** it will create a macro variable for the all values of the varible **/
proc sql;
select name into: class_macro separated by "," from sashelp.class;
quit;

%put &class_macro.;

data _null_;
set sashelp.class;
call symput('latha',name);
run;

%put &latha.;

data _null_;
set sashelp.class;
call symputx('n',_n_);
run;

%put &n.;

/** call symputx is creating a macro variable also it will remove leading and trailing blank spaces **/

 proc sql; 
 select (count(*)) into: counts from sashelp.class; 
 quit; 
 %put &counts.; 

proc print data=sashelp.class;
run;

proc sql;
select name,sex, age into: name_mac1- :name_mac&n., :sex_mac1- : sex_mac&n.  ,
:age_mac1- :age_mac&n.   from sashelp.class;
quit;

%put &name_mac7. &sex_mac10. &age_mac17.;

/** it will create a macro variable for the ending value of the varible **/
data _null_;
set sashelp.class;
call symput('studname',name);
run;

data _null_;
set sashelp.class;
call symput('n',_n_);
run;

%put &n.;
%put &studname.;

%macro name_macros(input=,output=);
data &output.;
set &input.;
if name="&studname.";
run;
%mend;
%name_macros(input=sashelp.class,output=ds_cls);


/** Automatic macro variable **/
%let a=40;
%let b=30;
%let c=50


/** prints the values of user defined global macro variables onto the log window **/
%put _user_; 
/** prints the values of user defined global macro variables and system defined global macro variables **/ 
%put _global_;

/** prints the values of local macro variable on to the log window **/
%put _local_;
/** prints the values of system defined macro variables which gets created during sas invocation **/
/** SYSTEM DEFINED MACRO VARIABLES STORED IN GLOBAL SYMBOL TABLE **/
%put _automatic_;
/** prints both global and automatic macro variables **/
%put _all_;

%put &sysuserid.;
%put &sysdate.;
%put &systime.;
%put &syslast.;
%put &sysday.;
 
data empsalary;
input empid empname $ empdept $ salary;
cards;
101 sudhakar A  75000
102 prit B 50000
103 vishal C 55000
104 surat D 60000
105 tango E 65000
106 alpha A 75000
107 suresh B 50000
108 rima C 55000
109 pooja D 60000
110 tulshi E 65000
111 chailtali A 80000
112 hina A 45000
113 tina B 55000
114 jina B 35000
115 mina C 65000
116 kina C 38000
117 kamina D 65000
118 kutta D 25000
119 riddhi E 89000
120 dharti E 15000
;
run;

%macro empsalarybonus(input=,output=);

data &output.;
set &input.;
bonus_emp=salary*.10;
run;

%if &sysday.=Wednesday %then %do;
proc means data=&syslast.;
title " Generated by Sudhakar konduru";
title1 "Report on &syslast.";
title2 "created by &sysuserid. &systime.";
footnote "thank you";
run;
%end;
%else %put "data is not available";

%mend;
%empsalarybonus(input=empsalary,output=empsalbonus);



options symbolgen mlogic mprint merror serror;
%macro values(input=,output=,output1=,var=);
data &output. &output1.;
set &input.;
if sex="&var." then output &output.;
else  output &output1.;
run;
%mend;

%values(input=sashelp.class,output=male,output1=female,var=M);

/** macro quoting functions(masking the special characters) **/

%str;
%nrstr;
%sysfunc;

%let begin_date=%sysfunc(intnx(year,%sysfunc(today()),-&x.,B),date9.);
%let ending_date=%sysfunc(intnx(year,%sysfunc(today()),-&x.,E),date9.);
%let diff=%sysfunc(intck(month,"&begin_date."d,"&ending_date."d));
%put &begin_date. &ending_date. &diff.;

%let new_var=%substr(&var.,5,6);
%put &new_var.;

%let new_scan=%scan(&var.,2);
%put &new_scan.;

%let var=data new %str(;) set sashelp%str(.)class;
%let &var.;

%let statement=%nrstr(title "S&P 500";); 
%put &statement.;

%let fname=%scan(&data.,1);
%let lname=%scan(&data.,2);

%put &fname.;
%put  &lname.;


/** call execute **/

%macro dailyreport(input=);
proc print data=&input.;
run;
%mend;

%macro weeklyreport(input=);
proc means data=&input.;
run;
%mend;

data _null_;
if "&sysday." eq "Friday" then call execute ('%weeklyreport(input=sashelp.class)');/*always put the macro in double quotes*/
else call execute ('%dailyreport(input=sashelp.class)');
run;

data _null_;
if "&sysday." eq "Wednesday" then call execute ('%weeklyreport(input=sashelp.class)');
else call execute ('%dailyreport(input=sashelp.class)');
run;

data _null_;
set sashelp.class;
call symputx('names',name);
run;


%put &names.;

data _null_;
set sashelp.class;
if name eq "&names." then call execute ('%weeklyreport(input=sashelp.class)');
else call execute ('%dailyreport(input=sashelp.class)');
run;

%macro macros_nn;
%if &sysday. eq Friday %then %do;
%weeklyreport(input=sashelp.class);
%end;
%else %dailyreport(input=sashelp.class);
%mend;

%macros_nn;


/** macro variable attribute functions **/
/* the macro variable is created or not we need to check by using these functions */
/* %symexist(x); */
/* %symglobl(x); */
/* %symlocal(x); */

/* if it's exist it will give the value 1 otherwise 0; */
%let x=a;
%macro namesss();
%let y=b;
%mend;
%namesss();

%put &x.;

%put %symexist(x);/*1 for exist and o for non existence*/
%put %symglobl(x);
%put %symlocal(y);

options symbolgen mlogic mprint;
data _null_;
if %symexist(x) = 0  then call execute ('%weeklyreport(input=sashelp.class)');
else call execute ('%dailyreport(input=sashelp.class)');
run;

%symdel x;
%put &x.;

data _null_;
if %symexist(x) eq 1  then call execute ('%weeklyreport(input=sashelp.class)');
else call execute ('%dailyreport(input=sashelp.class)');
run;

%put &x.;


/*Notes from the class*/



%macro splitdata(input=,output=);
%let begining_date=%sysfunc(intnx(year,%sysfunc(today()),-32,B),date9.);
%let ending_date=%sysfunc(intnx(year,%sysfunc(today()),-28,B),date9.);
%let diff=%sysfunc(intck(month,"&begining_date."d,"&ending_date."d));

%put &begining_date. &ending_date. &diff.;


%do i=1 %to &diff.;

%let date=%sysfunc(intnx(month,"&begining_date."d,&i.,B),date9.);
%put &date.;
data &output._&date.;
set &input.;
if date="&date."d;
run;

%end;
%mend;


%splitdata(input=sashelp.citiday,output=data);

/*lets create to perm library to store a macro */
libname sanjay1 "C:\sanjaysas
options mautosource sasautos=(sudha)symbolgel mlogic mprint merror serror;