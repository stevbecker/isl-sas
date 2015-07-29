/* Chapter 3 Linear Regression */

%let datapath=/folders/myshortcuts/dc/data;
%put "&datapath/Advertising.csv";

filename csvfile "&datapath/Advertising.csv";
proc import datafile=csvfile dbms=csv out=advertising replace;


ods graphics off;
proc reg data=advertising;
   model sales = tv;
   ods output ParameterEstimates=PE;
run;


data _null_;
   set PE;
   if _n_ = 1 then call symput('Int', put(estimate, BEST6.));    
   else            call symput('Slope', put(estimate, BEST6.));  
run;

%put &Int;
%put &Slope;

proc sgplot data=advertising noautolegend;
   title "Regression Line with Slope and Intercept";
   scatter x=tv y=sales;
   reg x=tv y=sales;
   inset "Intercept = &Int" "Slope = &Slope" / 
         border title="Parameter Estimates" position=topleft;
run;   

proc sgplot data=advertising;
   scatter x=radio y=sales;  
   reg x=radio y=sales;  
run;  

proc sgplot data=advertising;
   scatter x=newspaper y=sales;
   reg x=newspaper y=sales;
run;  


/* Reproduce Figure 3.3 */
/* To-do: plot y=2+3x and regression line together on the scatter plot */
proc iml;
call randseed(2015);
x = j(100,1);
call randgen(x, "Normal", 0, 1);
/* print x; */
call Histogram(x);

call randseed(20155);
ee = j(100,1);
call randgen(ee, "Normal", 0, 1.2);

y = 2 + 3*x + ee;
call Scatter(x,y);
/* print (y[1:10]); */


/* Table 3.4 */
proc reg data=advertising;
   model sales = tv radio newspaper;
run;   

/* Table 3.5 */
proc corr data=advertising;
   var tv radio newspaper;
run;   

/* Credit */
filename csvfile "&datapath/Credit.csv";
proc import datafile=csvfile dbms=csv out=credit replace;

data credit;
   set credit;
   if gender='Male' then gender1=0;
   else if gender='Female' then gender1=1;
   else gender1=100;
run;   

proc univariate data=credit noprint;
   histogram gender1;
/*    histogram ethnicity; */
run;   

proc reg data=credit;
   model balance =  gender1;
run;    

/* Interaction term: Table 3.9 */
data advertising2;
   set advertising;
   tv_radio = tv * radio;
run;

proc reg data=advertising2;
   model sales = tv radio tv_radio;
run;      


