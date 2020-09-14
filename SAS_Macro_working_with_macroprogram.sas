


/*Working with Macro Programs, macro program to write SAS codes*/
/*start with the validation of the SAS program*/
/* Generalize with macro variables*/
/*creat a macro definition with the parameters*/


/*Calling a micro*/

%MACRO macro-name </ DES="description">; /*,macro name should follow the SAS name conventions*/
    macro-text /*include macro language statements,expressions,SAS program steps,complete or partial SAS program statements*/
%MEND <macro-name>;


/*for example*/
%let shc=sashelp.cars;
%let obs=100;

%macro printcars;
proc print data=&shc(obs=&obs);
run; 
%mend printcars;

%printcars /*we created a macro "printcars' and we call this macro by using %macroname printcars and donot need semicolon*/

/*By default, the macro-generated code isn't displayed in the log*/
/*OPTIONS MPRINT|NOMPRINT; /* the generated code is displayed in the log*/



/*creat a macro definition with the parameters*/

%macro printsashelp(shc,obs);
proc print data=&shc(obs=&obs);
run; 
%mend printsashelp;

/*this is awesome*/

/*do you you can print 50 obsaervation from the SAShelp shoe data*/
%printsashelp(sashelp.shoes,50)

/*do you you can print 100 obsaervation from the SAShelp class data*/
%printsashelp(sashelp.class,10)


/*do you you can print 75 obsaervation from the SAShelp stock data*/
options mprint;  /*this options helps to print the macro variable */
%printsashelp(sashelp.stocks,10)
options nomprint;




proc print data=sashelp.cars;
run;

/**/
/*this is the sgplot generated and we are going to call this sgplot in macro*/

title1 "engine size by make and type";
proc sgplot data=sashelp.cars;
    vbar origin / dataskin=pressed;
    where type="SUV" and msrp>20000 and EngineSize>2; 
run;
title;

options mcompilenote=all; /*this helps to write the code in log book as SAS doenot have system to write for macro execution*/
%macro sashelpcars(type,msrp,enginesize);
title1 "type msrp and enginesize based on the origin";
title2 "&type type, &msrp msrp, &enginesize Enginesize"; 
proc sgplot data=sashelp.cars;
    vbar origin / dataskin=pressed;
    where type="&type" and msrp>&msrp and EngineSize>&enginesize; 
run;
title;
%mend;


options mprint;
%Sashelpcars(type=SUV,msrp=20000,enginesize=2)
options nomprint;

/*After a macro is generated we can use this macro for multiple purposes*/


options mprint;
%Sashelpcars(type=Sedan,msrp=25000,enginesize=2.5)
options nomprint;



/*Macro Variable Scope can be global or local in scoop */


/*global */
/*global macro variables: stored in the global symbol table, created when SAS is started,remains in memory until the session ends*/
/*macro.s that are generated outside the macro definition using*/
/*% let  
Call symputx routine  /*create global macro variables using the CALL SYMPUTX routine
sql INTO clause   generate macros in sql 
global statement  explicitly creates macro variables in the global symbol table without assigning a value
%global name x;*/


/*local*/
/*valid only inside a macro defintion*/
/*creates macro variable in the local symbol table*/
/*doesnot assign or modify values*/
/*if the variable exits, the value doenot change*/
/*CALL SYMPUTX(macro-variable-name, value, 'L')/* can be used to call macrovariable*/



/*Lets see this example*/

data sports         /*notice the missing semicolon*/      
    set sashelp.cars;
    where Type="Sports";
    AvgMPG=mean(MPG_City, MPG_Highway);
run;

/*this is macro so if then do put end else, everything needs %*/

%if &syserr ne 0 %then %do;/*syserr is the global macro and can be used*/
    %put ERROR: The rest of the program will not execute;
%end;
%else %do;
	title "Sports Cars";
	proc print data=sports noobs;	
	    var Make Model AvgMPG MSRP EngineSize;
	run;
	title;
	proc sgplot data=sports;
	    scatter x=MSRP y=EngineSize;
	run;
%end;
title;

/*what if we correct the data step you will get proc step being executed*/


data sports;     
    set sashelp.cars;
    where Type="Sports";
    AvgMPG=mean(MPG_City, MPG_Highway);
run;

%if &syserr ne 0 %then %do;
    %put ERROR: The rest of the program will not execute;
%end;
%else %do;
	title "Sports Cars";
	proc print data=sports noobs;	
	    var Make Model AvgMPG MSRP EngineSize;
	run;
	title;
	proc sgplot data=sports;
	    scatter x=MSRP y=EngineSize;
	run;
%end;
title;


/*Additionaly we can use the macros to select the partcular value in the variable*/

proc print data=sashelp.cars;
run;

%macro avgfuel(loc);/* macro named avgfuel that accepts one parameters: Basin,*/
%if &loc= %then %do;
    %put ERROR: Provide a value for Origin.;
    %put ERROR- Valid values: Asia, Europe, USA;
    %return;
%end;

%else %if &loc=USA %then %do;
	data fuel_&loc;
		set sashelp.cars;
		where Origin="&loc";
		AvgMPG=mean(MPG_City, MPG_Highway);
		keep Make Model Type AvgMPG;
	run;
%end;

%else %if &loc=Europe %then %do;
	data fuel_&loc;
		set sashelp.cars;
		where Origin="&loc";
		AvgKmL=mean(MPG_City, MPG_Highway)*.425;
		keep Make Model Type AvgKmL;
	run;
%end;

%else %do;
	data fuel_&loc;
		set sashelp.cars;
		where Origin="&loc";
		AvgKmL=mean(MPG_City, MPG_Highway)*.10;
		keep Make Model Type AvgKmL;
	run;
%end;

title1 "Fuel Efficiency";
title2 "Origin: &loc";
proc print data=fuel_&loc;
run;
title;
%mend avgfuel;

options mprint mlogic;
%avgfuel(Europe)
options nomprint nomlogic;

options mprint mlogic;
%avgfuel(USA)
options nomprint nomlogic;


/*Generating Repetitive Code*/
%macro allcylinders(start,stop);
    %do num=&start %to &stop;
        title "&num-Cylinder Cars";
        proc print data=sashelp.cars noobs;
            where Cylinders=&num;
            var Make Model Type Origin 
                MSRP MPG_City MPG_Highway;
        run;
    %end;
%mend allcylinders;

%allcylinders(3,6)


proc sql noprint;
select distinct Cylinders
    into :list separated by ', '/*in sql we can develop the macros by using INTO:*/
    from sashelp.cars
    where Cylinders ne .;
quit;

%put &=list;

%cyllist(&list)

/*Demo: %DO Loops with Indirect References*/

/*Below is the code that we geenrated earlier we will use %do loop to produce graph for each origin*/

options mcompilenote=all mlogic mprint; 
%macro sashelpcars(type,msrp,enginesize);
title1 "type msrp and enginesize based on the origin";
title2 "&type type, &msrp msrp, &enginesize Enginesize"; 
proc sgplot data=sashelp.cars;
    vbar origin / dataskin=pressed;
    where type="&type" and msrp>&msrp and EngineSize>&enginesize; 
run;
title;
%mend;


options mprint;
%Sashelpcars(type=SUV,msrp=20000,enginesize=2)
options nomprint;

/*We know there are many types of cars in the sashelp.cars table
Now we want to do is to use the Proc sql to determine the distinct types 
and use all the types in do loop to make graphs for all types with other two macro variables*/

/*first we have to use sql to determine the distinct types*/

options mcompilenote=all mlogic mprint; 
%macro sashelpcars(type,msrp);
title1 "type msrp based on the origin";
title2 "&type type, &msrp msrp"; 
proc sgplot data=sashelp.cars;
    vbar origin / dataskin=pressed;
    where type="&type" and msrp>&msrp; 
run;
title;
%mend;

options mprint;
%Sashelpcars(type=SUV,msrp=20000)
options nomprint;

proc sql noprint;
select type
	into : type1-
	from sashelp.cars;
quit;


/*After findign the distinct types now we can call a new macrovaraible and use this distinct types */

%macro alltypes(cartypes);
%local i;
proc sql noprint;
select distinct type
	into :type1-
	from sashelp.cars;
quit;

%do i=1 %to &sqlobs;
	%sashelpcars(&&type&i, &cartypes)
%end;
%mend alltypes;

options mlogic mprint;
%alltypes(20000)

/**/
/*got it this is just awesome*/


options nomlogic nomprint;
%allbasins(30000,3)