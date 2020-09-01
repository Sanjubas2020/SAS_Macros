/*soi

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


/*Working with Macro Programs, macro program to write SAS codes*/
 

%let Basin=NA;
%let Season=2016;
%let MaxWind=80;

title1 "Storm Frequency by Type";
title2 "&Basin Basin, &Season Season, Max Wind > &MaxWind MPH"; 
proc sgplot data=storm_final;
    vbar StormType / dataskin=pressed;
    where Basin="&Basin" and Season=&Season and MaxWindMPH>&MaxWind; 
run;
title;

/* Step 3 */

%let Basin=EP;
%let Season=2015;
%let MaxWind=125;

title1 "Storm Frequency by Type";
title2 "&Basin Basin, &Season Season, Max Wind > &MaxWind MPH"; 
proc sgplot data=storm_final;
    vbar StormType / dataskin=pressed;
    where Basin="&Basin" and Season=&Season and MaxWindMPH>&MaxWind; 
run;
title;

/* Step 4 */

options mcompilenote=all;
%macro StormChart(Basin, Season, MaxWind);
title1 "Storm Frequency by Type";
title2 "&Basin Basin, &Season Season, Max Wind > &MaxWind MPH"; 
proc sgplot data=storm_final;
    vbar StormType / dataskin=pressed;
    where Basin="&Basin" and Season=&Season and MaxWindMPH>&MaxWind; 
run;
title;
%mend;

/* Step 5 */
options mprint;
%StormChart(EP,2015,125)
options nomprint;


options mcompilenote=all;
%macro stormchart(basin=NA, season=2016, maxwind=20);
title1 "Storm Frequency by Type";
title2 "&basin Basin, &season Season, Max Wind > &maxwind MPH"; 
proc sgplot data=storm_final;
    vbar StormType / dataskin=pressed;
    where Basin="&basin" and Season=&season and MaxWindMPH>&maxwind; 
run;
title;
%mend stormchart;

options mprint;
%stormchart(season=2015, basin=EP)
options nomprint;

/*Global Macro Variables*/


/*conditional processing*/
data sports
    set sashelp.cars;
    where Type="Sports";
    AvgMPG=mean(MPG_City, MPG_Highway);
run;

%if &syserr ne 0 then %do;
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

%macro stormchart(basin, season, maxwind);
title1 "Storm Frequency by Type";
title2 "&basin Basin, &season Season";
footnote "Max Wind > &maxwind MPH";
proc sgplot data=mc1.storm_final;
    vbar StormType / dataskin=pressed;
    where Basin="&basin" and Season=&season and MaxWindMPH>&maxwind; 
run;
title;footnote;
%mend stormchart;

options mcompilenote=all;
%stormchart(NA,2016,80)

/* Step 2 */
 
%macro stormchart(basin, season, cat);
%local maxwind;
%if &cat=5 %then %let maxwind=157;
%else %if &cat=4 %then %let maxwind=130;
%else %if &cat=3 %then %let maxwind=111;
%else %if &cat=2 %then %let maxwind=96;
%else %if &cat=1 %then %let maxwind=74;

title1 "Storm Frequency by Type";
title2 "&basin Basin, &season Season";
footnote "Max Wind > &maxwind MPH";
proc sgplot data=mc1.storm_final;
    vbar StormType / dataskin=pressed;
    where Basin="&basin" and Season=&season and MaxWindMPH>&maxwind; 
run;
title;footnote;
%mend stormchart;

options mcompilenote=all mlogic mprint;
%stormchart(NA,2016,3)
%stormchart(EP,2015)

/* Step 3 */

%macro stormchart(basin, season, cat);
%local maxwind;
%if &cat=5 %then %let maxwind=157;
%else %if &cat=4 %then %let maxwind=130;
%else %if &cat=3 %then %let maxwind=111;
%else %if &cat=2 %then %let maxwind=96;
%else %if &cat=1 %then %let maxwind=74;

title1 "Storm Frequency by Type";
title2 "&basin Basin, &season Season";
%if &cat ne  %then %do;
   	footnote "Max Wind > &maxwind MPH"; 
%end;
%else %do;
   	footnote "All Storms Included";
%end;
proc sgplot data=mc1.storm_final;
    vbar StormType / dataskin=pressed;
    where Basin="&basin" and Season=&season 
    %if &cat ne %then %do;
         and MaxWindMPH>&maxwind
    %end;
    ;
run;
title;footnote;
%mend stormchart;

options mcompilenote=all mlogic mprint;
%stormchart(EP,2015)
%stormchart(SI,2014,2)

/* Step 4 */

options nomprint nomlogic

/*Generating repetitive code*/

options mlogic mprint;
%macro allcylinders(start,stop);
%do num=&start %to &stop;
    title "&num-Cylinder Cars";
    proc print data=sashelp.cars noobs;
        where Cylinders=&num;
        var Make Model Type Origin 
            MSRP MPG_City MPG_Highway;
    run;
	%end;
title;
%mend allcylinders;

options nomlogic nomprint;

/* Steps 1-2 */

options mcompilenote=all mlogic mprint;

%macro stormchart(basin, season);
title1 "Storm Frequency by Type";
title2 "&basin Basin, &season Season";
proc sgplot data=mc1.storm_final;
	vbar StormType / dataskin=pressed;
    where Basin="&basin" and Season=&season;
run;
title;
%mend stormchart;

%stormchart(NA,2015)

/* Steps 3-5 */

%macro allbasins(year);
%local i;
proc sql noprint;
select basin
	into :basin1-
	from mc1.storm_basin_codes;
quit;

%do i=1 %to &sqlobs;
	%stormchart(&&basin&i, &year)
%end;
%mend allbasins;

/* Steps 6-8 */

%allbasins(2015)
%allbasins(2009)

options nomlogic nomprint;
