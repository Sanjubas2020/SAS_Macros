/*Generating Data-Dependent Listing Reports*/
/*Here we are generating a macro to print report with the data set we want and select the specific varible */


proc print data=sashelp.cars;
run;

%macro grouplist(tab,col);
proc sql noprint;
select distinct upcase(&col)
    into :val1-
    from &tab;
quit;

%do i=1 %to &sqlobs;
title "Group: &&val&i";
proc print data=&tab out=sanjay1;
    where upcase(&col)="&&val&i";
run;
%end;
%mend grouplist;


/*Call the GroupList macro with sashelp.cars and DriveTrain as the parameter values.*/
%grouplist(sashelp.cars, DriveTrain)

/*Call the GroupList macro for origin from sashelp.com */
%grouplist(sashelp.cars, Origin)


%grouplist(sashelp.stocks,stock)


/*Export into separate excel sheets*/

  %macro grouplist(tab,col);
proc sql noprint;
select distinct upcase(&col)
    into :val1-
    from &tab;
quit;

%do i=1 %to &sqlobs;
title "Group: &&val&i";

     data sanjay1;
       set &tab;
    where upcase(&col)="&&val&i";
	run;
proc export data=sanjay1 dbms=xlsx outfile="C:\Users\Owner\Desktop\sas\classic.xlsx" replace;
run;
%end;
%mend grouplist;

%grouplist(sashelp.cars, DriveTrain)



/* I am able to export the data but the above codes need to corretion*/

/*coding chalelgne*/
/*Exporting Data to Separate Worksheets in Microsoft Excel*/
/*for example we have the sashelp.class data and export the distinct name variable into the each excel sheet*/
 


%macro classxls;
libname class xlsx "C:\Users\Owner\Desktop\sas\classic.xlsx";
%if &syslibrc ne 0 %then %do;
    %put ERROR: class.xlsx was not successfully assigned. Check the path and filename.;
%end;

%else %do;
    proc sql noprint;
    select name
        into :name1-
	   from sashelp.class;
    quit;
	
    %do i=1 %to &sqlobs;
    data class.&&name&i.._name;
        set sashelp.class;
		where age>10;
    run;
    %end;
%end;
libname storm clear;
%mend classxls;

%classxls


