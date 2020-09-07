
/*SAS Macro storign and processing text*/
/*% to specify macro and & to link to the armstand*/

options symbolgen;
%let type=Truck;
%let hp=250;
title1 "Car Type: &type";
title2 "Horsepower > &hp"; /*always use double quotation marks*/
proc print data=sashelp.cars;
    var Make Model MSRP Horsepower;
    where Type="&type" and Horsepower>&hp;
run;
title;
options nosymbolgen;


/*Delimiting Macro Variable References*/
options symbolgen;
%let type=Truck;
%let hp=250;

title "&type.s with Horsepower > &hp"; /* adding . after types acts as delimiter, it will be truckS in the table*/
footnote "Data Source: SASHELP.CARS";
proc print data=sashelp.cars;
    var Make Model MSRP Horsepower;
    where Type="&type" and Horsepower>&hp;
run;
title;footnote;
options nosymbolgen;


/*libname microvariable use*/
options symbolgen;
%let type=Truck;
%let hp=250;
%let lib=SASHELP;

title "&type.s with Horsepower > &hp"; /* adding . after types acts as delimiter, it will be truckS in the table*/
footnote "Data Source: &lib..CARS"; /* single period was intercepted as macrodelimiter, use ..*/ 
proc print data=&lib..cars;
    var Make Model MSRP Horsepower;
    where Type="&type" and Horsepower>&hp;
run;
title;footnote;
options nosymbolgen;

/*Displaying Macro Variables*/
%put _user_;
/*Automatic Macro Variables*/



data Avg_MPG;
    set sashelp.cars;
    MPG_Average=mean(MPG_City, MPG_Highway);
run;

%put _automatic_; /* helps to check the automatic data variable*/

title1 "Distribution of Average Miles Per Gallon";
title2 "Data Source: &syslast"; /*syslast helps to use the table that was last used*/
footnote "Created on <&sysdate9>";  /*awesome, we can put the data the graph was developed*/
proc sgplot;
    histogram MPG_Average;
    density MPG_Average;
run;
title;footnote;


/*Storing and Processing Text upcase, substr, scan, synfunc, sysevalf*/

SAS Macro           Functions
Name	       Description
%UPCASE	       Converts values to uppercase
%SUBSTR	       Extracts a substring from a character string
%SCAN	       Extracts a word from a character string
%SYSFUNC	   Executes SAS functions
%SYSEVALF	   Performs arithmetic and evaluates logical expressions



/*1: using %upcase usually used while used in the title and the title should be in uppercase*/
/*we can upcase the macrovaiable to upcase in some while keeping the small text in some*/

%let text=universtiy of nebraska class list for 2020;
title "%upcase(&text)";
%let libb= sashelp.class;
proc print data=&lib;
run;
title;


/*2. using %SUBSTR to extracts a substring from a character string*/

%let text= universtiy of nebraska class list for 2020;
%let cla= %substr(&text,1, 22);
title1 "%upcase(&text)";
title2 "&cla with Sanjay";
proc print data=sashelp.class;
run;
title;


/*3. using %SUBSTR to extracts a substring from a character string*/

%let text= universtiy of nebraska class list for 2020;
%let cla= %scan(&text,3);
title1 "%upcase(&text)";
title2 "&cla with Sanjay";
proc print data=sashelp.class;
run;
title;

/*4. using %SYSFUNC to extracts a substring from a character string*/

%let dt=front;
data cars_subset;
    set sashelp.cars;
    where upcase(DriveTrain)="%upcase(&dt)";
run;
 
title "%sysfunc(propcase(&dt)) Wheel Drive Cars";
footnote "Listing from %scan(&syslast,2) Table";
proc print data=&syslast;
run;
title;
footnote;


/*Evaluating Arithmetic Expressions*/

/*we have used the sashelp stock date and used the %syseval to determine the athematic expression of the macros*/
data macro1;
set sashelp.stocks;
year=year (date);
drop date;
run;

%let year=2004;
%let nextyear=%sysevalf(&year+1);/*we can use addition, substraction, multiplication and the division expression*/
proc print data=macro1;
where year=&year;
run;

%let year=2005;
%let nextyear=%sysevalf(&year-5);
proc print data=macro1;
where year=&nextyear;
run;

/*Using Special Characters*/
/*%str (character=string)*/

%let location=%str(Buenos Aires, Argentina);
%let city=%scan(&location, 1,%str(,)); /*the demilitor is the ,*/
%put &=city;

/*another example*/

%let location=%str(winston-salem, NC);
%let city=%scan(&location, 1,%str());
%put &=city;

/*demonstrating of macrovariable use*/
/* Step 1 */

data macro1;
set sashelp.stocks;
year=year (date);
drop date;
run;

%let year=2000;
%let open=90;
title1 "&year";
title2 "stock Exceeding &open ";
footnote "Report Created on &sysdate9 at &systime";
proc print data=macro1 noobs;
   where year=&year and open>&open;
run;
title;footnote;




/*using macrovaraible in the SAS SQl*/
/*if you want to create macro variables using values available only during execution, you can use SAS sql*/

proc sql; 
select * from sashelp.stocks;
quit;



proc sql; 
select * from sashelp.stocks
where open>70
order by open;
quit;


proc sql;
select mean(open) 
    into :avgopen
    from sashelp.stocks;
quit;

%put &=avgopen;
%put &=sqlobs;

/* Step 3 */

proc sql noprint; /*we have noprint as we donot want to print the observation*/
select mean(open)
    into :avgopen trimmed
    from sashelp.stocks;
quit;

%put &=avgopen;
%put &=sqlobs;

/* Step 4 */

proc sql noprint;
select mean(open) format=dollar20.,
       median(open) format=dollar20. 
    into :avgopen trimmed,:medopen trimmed
    from sashelp.stocks;
quit;

%put &=avgopen;
%put &=medopen;
%put &=sqlobs;

/* Step 5 */
proc sql;
select *
	from storm_type_codes;
quit;

*%put &=type1 &=type2 &=type3 &=type4 &=type5;
*%put &=sqlobs;

/* Steps 6-7 */

proc sql noprint;
select Stock
	into :Type1-
	from sashelp.stocks;
quit;

%put &=type1 &=type2 &=type3; 
%put &=sqlobs;

/* Steps 8-9 */

proc sql noprint;
select Stock
	into :typelist separated by " "
	from sashelp.stocks;
quit;

%put &=typelist; 
%put &=sqlobs;


/*Creating Macro Variables in a DATA Step*/
/*CALL SYMPUTX routine creates a macro variable with the fixed name foot and assigns the literal string inside the double quotation marks*/

/* Complete the CALL SYMPUTX statement */
%let make=Honda;

data &make;
    set sashelp.cars end=lastrow;
    where upcase(Make)="%upcase(&make)";
    retain HybridFlag;
    if Type="Hybrid" then HybridFlag=1;
    if lastrow then do;
        if HybridFlag=1 then do;
            %let foot=&make Offers Hybrid Cars;
        end;
        else do;
            %let foot=&make Does Not Have a Hybrid Car;
        end;
    end;
run;
proc print data=&make;
run;

/*why this is not executed,this is because macro is not the data step thing*/

/*You create and update macro variables in the DATA step with the CALL SYMPUTX routine. Because CALL SYMPUTX is a DATA step CALL routine and not a macro statement, it is processed during the execution phase.*/
%let make=Honda;
data &make;
    set sashelp.cars end=lastrow;
    where upcase(Make)="%upcase(&make)";
    if Type="Hybrid" then HybridCount+1;
    if lastrow=1 then do;
        call symputx("hybridnum", HybridCount);
    end;
run;


/*The PUT function can be used to format the value of Mean before it is stored in the macro variable.*/


/* Step 1 */
proc print data=sashelp.stocks;
run;


proc means data=sashelp.stocks noprint;
    var high;
    output out=work.sumstock mean= median= /autoname;
run;

/* Step 2 */


data _null_;
    set sumstock;
	call symputx("avghigh", high_mean);
	call symputx("medhigh", high_median);
run;
%put &=avghigh &=medhigh;


data _null_;
    set sumstock;
	call symputx("avghigh", high_mean);
	call symputx("medhigh", Put (high_median, dollar5.));
run;
%put &=avghigh &=medhigh;




/*Scenario: Using Indirect References*/
/*When multiple ampersands are found, SAS uses the Forward Rescan Rule
Two ampersands resolve to one ampersand, and a single ampersand followed by a name token resolves to the macro variable value.
The macro processor then rescans the text and resolves any additional macro triggers until they are all resolved*/

data macro1;
set sashelp.stocks;
year=year (date);
drop date;
run;


%let stock=intel;
%let year =2000;
%let high= 60.00;

title "&&stock &year &high and values"; /*we have to use && to solve this issue*/
proc print data=macro1 noobs;
 where upcase(stock)="%upcase(&stock)";
run;
