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
%let lib=SASHELP;

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
options nosymbolge

/*Displaying Macro Variables*/
%put _user_;
/*Automatic Macro Variables*/


data Avg_MPG;
    set sashelp.cars;
    MPG_Average=mean(MPG_City, MPG_Highway);
run;

%put _automatic_; /* helps to check the automatic data variable*/

title1 "Distribution of Average Miles Per Gallon";
title2 "Data Source: &syslast";
footnote "Created on <&sysdate9>";  /*awesome, we can put the data the graph was developed*/
proc sgplot;
    histogram MPG_Average;
    density MPG_Average;
run;
title;footnote;


/*Storing and Processing Text

SAS Macro Functions
Name	       Description
%UPCASE	       Converts values to uppercase.
%SUBSTR	       Extracts a substring from a character string.
%SCAN	       Extracts a word from a character string.
%SYSFUNC	   Executes SAS functions.
%SYSEVALF	   Performs arithmetic and evaluates logical expressions*/

/*using %upcase usually used while used in the title and the title should be in uppercase*/

%let text=class list;
title "%upcase(&text)";
proc print data=sashelp.class;
run;
title;

/*Processing Text with Macro Functions


Macro Function Call Examples
Macro Funciton Call	      Value
%upcase(front)	              FRONT

%let dt=front;
%upcase(&dt)	              FRONT
%scan(sashelp.cars, 2, .)     cars
%substr(CA123, 1, 2)	       CA
%substr("CA123", 1, 2)	       "C */


/*Evaluating Arithmetic Expressions*/


/*Using Special Characters*/
/*%str (character=string)*/

%let location=%str(Buenos Aires, Argentina);
%let city=%scan(&location, 1,%str(,));
%put &=city;

/*demonstrating of macrovariable use*/
/* Step 1 */

%let year=2015;
%let windm=150;

title1 "&year Storms";
title2 "Winds Exceeding &windm M/H ";
footnote "Report Created on &sysdate9 at &systime";
proc print data=storm_final noobs;
   where Season=&year and MaxWindMPH>=&windm;
run;
title;footnote;

/* Step 2 */

%let year=2015;
%let windm=150;

title1 "&year Storms";
title2 "Winds Exceeding &windm M/H or %sysevalf(&WindM*1.61) KM/H";
footnote "Report Created on &sysdate9 at &systime";
proc print data=storm_final noobs;
   where Season=&year and MaxWindMPH>=&windm;
run;
title;footnote;

/* Step 3 */

%let year=2015;
%let windm=150;

title1 "&year Storms";
title2 "Winds Exceeding &WindM M/H or %sysevalf(&WindM*1.61) KM/H"; /*use the %sysevalf() to do the calculations*/
footnote "Report Created on %sysfunc(today(), date9.) at %sysfunc(time(), timeampm.)"; /*for curent data, use %sysfunc(today(), date9.) at %sysfunc(time(), timeampm.)";*/
proc print data=mc1.storm_final noobs;
   where Season=&year and MaxWindMPH>=&windm;
run;
title;footnote;

/* Steps 4-6 */

%let year=2015;
%let windm=150;
%let dtfoot=%str(footnote "Report Created on %sysfunc(today(), date9.) at %sysfunc(time(), timeampm.)";);
title1 "&year Storms";
title2 "Winds Exceeding &windm M/H or %sysevalf(&windm*1.61) KM/H";
&dtfoot
proc print data=storm_final noobs;
   where MaxWindMPH>=&windm and Season=&year;
run;
title;footnote;


/*Creating Macro Variables in PROC SQL*/

proc sql; 
select * from 
storm_damage;
run;

proc sql;
select mean(cost) 
    into :avgcost
    from storm_damage;
quit;

%put &=avgcost;
%put &=sqlobs;

/* Step 3 */

proc sql noprint;
select mean(cost) format=dollar20. 
    into :avgcost trimmed
    from storm_damage;
quit;

%put &=avgcost;
%put &=sqlobs;

/* Step 4 */

proc sql noprint;
select mean(cost) format=dollar20.,
       median(cost) format=dollar20. 
    into :avgcost trimmed,
         :medcost trimmed
    from mc1.storm_damage;
quit;

%put &=avgcost;
%put &=medcost;
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
select StormType
	into :Type1-
	from storm_type_codes;
quit;

%put &=type1 &=type2 &=type3 &=type4 &=type5; 
%put &=sqlobs;

/* Steps 8-9 */

proc sql noprint;
select StormType
	into :typelist separated by ", "
	from mc1.storm_type_codes;
quit;

%put &=typelist; 
%put &=sqlobs;



/*Create Macro Variables in a DATA Step*/


%let make=Honda;

proc means data=sashelp.cars noprint maxdec=0;
	where Make="&make";
	var MSRP;
	output out=CarsStat Mean=Mean;
run;

/* Complete the CALL SYMPUTX statement */
data _null_;
	set CarsStat;
	call symputx("avgmsrp",Mean);
run;
/*The PUT function can be used to format the value of Mean before it is stored in the macro variable.*/
data _null_;
	set CarsStat;
	call symputx("avgmsrp",put(Mean, dollar8.));
run;

title "&make Cars";
title2 "Average MSRP: &avgmsrp";
proc print data=sashelp.cars noobs;
	where Make="&make";
run;
title;

/* Step 1 */

proc means data=storm_damage noprint;
    var Cost;
    output out=work.sumdata mean= median= /autoname;
run;

/* Step 2 */

proc means data=storm_damage noprint;
    var Cost;
    output out=work.sumdata mean= median= /autoname;
run;

data _null_;
    set sumdata;
	call symputx("avgcost", cost_mean);
	call symputx("medcost", cost_median);
run;
%put &=avgcost &=medcost;

/* Step 3 */

proc means data=mc1.storm_damage noprint;
    var Cost;
    output out=work.sumdata mean= median= /autoname;
run;

data _null_;
    set sumdata;
	call symputx("avgcost", put(cost_mean, dollar20.));
	call symputx("medcost", put(cost_median, dollar20.));
run;

%put &=avgcost &=medcost;

/* Steps 4-5 */

proc print data=mc1.storm_type_codes;
run;

data _null_;
	set mc1.storm_type_codes;
	call symputx("type", StormType);
run;

%put &=type;
*%put &=type1 &=type2 &=type3 &=type4 &=type5;


/* Steps 6-7 */

proc print data=mc1.storm_type_codes;
run;

data _null_;
	set mc1.storm_type_codes;
	call symputx(cats("type", _n_), StormType);
run;

%put &=type1 &=type2 &=type3 &=type4 &=type5;

/* Steps 8-9 */

data _null_;
	set mc1.storm_type_codes;
	call symputx(Type, StormType);
run;

%put &=DS &=ET &=NR &=SS &=TS;

/* Step 10 */

data _null_;
    set mc1.Storm_Type_Codes end=last;
    call symputx(Type,StormType);
    if last then call symputx('dsobs',_n_);
run;

%put &=DS &=ET &=NR &=SS &=TS &=dsobs;

/*Scenario: Using Indirect References*/
proc sql noprint;
select MinWind
    into :wind1-
    from storm_cat;
quit;

%let cat=4;
%put NOTE: Category &cat storms >= &wind&cat MPH;



/* Steps 1-2 */
%let year=2016;
%let cat=2;
%let basin=SI;

proc sql noprint;
select MinWind
    into :wind1-
    from mc1.storm_cat;
quit;

data _null_;
    set mc1.storm_basin_codes;
    call symputx(Basin, BasinName);
run;

title1 "&basin &year Category &cat+ Storms";
proc print data=mc1.storm_final noobs;
	where Basin="&basin" and
		  MaxWindMPH>=&&wind&cat and
		  Season=&year;
run;
title;

/* Step 3 */
%let year=2016;
%let cat=2;
%let basin=SI;

proc sql noprint;
select MinWind
    into :wind1-
    from mc1.storm_cat;
quit;

data _null_;
    set mc1.storm_basin_codes;
    call symputx(Basin, BasinName);
run;

title1 "&&&basin &year Category &cat+ Storms";
proc print data=mc1.storm_final noobs;
	where Basin="&basin" and
		  MaxWindMPH>=&&wind&cat and
		  Season=&year;
run;
title;

/* Step 4 */
%let year=2014;
%let cat=3;
%let basin=NA;

proc sql noprint;
select MinWind
    into :wind1-
    from mc1.storm_cat;
quit;

data _null_;
    set mc1.storm_basin_codes;
    call symputx(Basin, BasinName);
run;

title1 "&&&basin &year Category &cat+ Storms";
proc print data=mc1.storm_final noobs;
	where Basin="&basin" and
		  MaxWindMPH>=&&wind&cat and
		  Season=&year;
run;
title;

/* Steps 5-8 */
%let year=2014;
%let cat=3;
%let basin=NA;

proc sql noprint;
select MinWind, Damage
    into :wind1-, :damage1-
    from mc1.storm_cat;
quit;

data _null_;
    set mc1.storm_basin_codes;
    call symputx(Basin, BasinName);
run;

title1 "&&&basin &year Category &cat+ Storms";
footnote "Category &cat storms typically cause %lowcase(&&damage&cat)";
proc print data=mc1.storm_final noobs;
	where Basin="&basin" and
		  MaxWindMPH>=&&wind&cat and
		  Season=&year;
run;
title;footnote;


