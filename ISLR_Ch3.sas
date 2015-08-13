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

proc sgscatter data=advertising;
   matrix _numeric_ 
   / diagonal=(histogram kernel);
run;   

/* Reproduce Figure 3.3 */
/* To-do: plot y=2+3x and regression line together on the scatter plot */
/* use SERIES statement in PROC SGPLOT */

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

/* Table 3.6 */
proc reg data=advertising;
   model sales = tv radio newspaper
         / vif;
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

/* Table 3.10 Polynomial Regression */
filename csvfile "&datapath/Auto.csv";
proc import datafile=csvfile dbms=csv out=auto replace;

data autoNoMiss;
   set auto;
   if cmiss(of _all_) then delete;
run;   

proc glm data=autoNoMiss;
   model mpg=horsepower horsepower*horsepower;
run;   

/* Collinearity Figure 3.14 */
proc sgscatter data=credit;
   matrix age limit rating;
run;   

/* Table 3.11 */
proc reg data=credit;
   model balance=age limit;
run;

proc reg data=credit;
   model balance=rating limit;
run;   

/* p102, VIF (Variance Inflation Factors): Collinearity Diagonistics */
proc reg data=credit;
   model balance=age limit rating 
      / vif;
run;      


/* 3.6 Lab: Linear Regression */

filename csvfile "&datapath/Boston.csv";
proc import datafile=csvfile out=boston dbms=csv replace;

proc contents data=boston;
run;

proc reg data=boston outest=bostonest;
   modle medv = lstat;
/*    model medv = lstat / r clm cli; */
   /* clm -- option p plus 95% CI for estimated mean */
   /* cli -- option p plus 95% CI for predicted value */
run;   


/* Check residuals */
/* http://www.ats.ucla.edu/stat/sas/webbooks/reg/chapter2/sasreg2.htm */
/* https://www.stat.wisc.edu/~yandell/software/sas/linmod.html */
proc reg data=boston;
   model medv = lstat;
   output out=bostonres (keep=r) residual=r; 
run;   

proc univariate data=bostonres plots;
   var r;
run;   


/* Score a new data set (p111-112, R predict() */
/* http://support.sas.com/kb/33/307.html */

data need_prediction;
   input lstat @@;
datalines;
5 10 15
;

data combined;
   set boston need_prediction;
run;   

/* Scoring by augumenting the training data set */
proc reg data=combined;
   model medv = lstat / p cli clm;
   id lstat;
run;

/* Scoring by PROC SCORE */
to-do: show CLM CLI
proc reg data=boston noprint outest=est1;
   model medv = lstat;
run;

proc score data=need_prediction score=est1 out=prediciton type=parms;
   var lstat;
run;   

/* Scoring by PROC PLM */
proc reg data=boston noprint outest=est1;
   model medv = lstat;
   store RegModel;
run;

proc plm restore=RegModel;
   score data=need_prediction out=plm_prediction predicted;
run;

/* plot regression line */
proc sgplot data=boston;
   scatter x=lstat y=medv /
      markerattrs=(symbol=star size=1pct);
   reg x=lstat y=medv /
      lineattrs=(color=red pattern=1 thickness=1pct) ;
run;   

proc reg data=boston;
   model medv = lstat;
run;   

/* 3.6.3 Multiple Linear Regression */
proc reg data=boston;
   model medv = lstat age;
run;   

/* to-do: shorthand for all predictors */
proc reg data=boston;
   model medv = age black chas crim dis indus 
               lstat nox ptratio rad rm tax zn / vif;
run;

/* 3.6.4 Interaction Terms */
proc glm data=boston;
   model medv = lstat age lstat*age;
run;   

/* 3.6.5 Non-linear Transformations of the Predictors */
proc glm data=boston plots=(diagnostics residuals);
   model medv = lstat lstat*lstat;
run;

/* to-do: big difference of results between R and SAS */
proc glm data=boston plots=(diagnostics residuals);
   model medv = lstat
                lstat*lstat 
                lstat*lstat*lstat 
                lstat*lstat*lstat*lstat
                lstat*lstat*lstat*lstat*lstat;
run;



/* Exercise 8 */
filename csvfile "&datapath/Auto.csv";
proc import datafile=csvfile out=AutoRaw dbms=csv replace;

data auto;
   set AutoRaw;
   if cmiss(of _all_) then delete;
run;

proc reg data=auto outest=est;
   model mpg = horsepower;
   store RegModel;
run;

/* 8(a)iv */
/* Scoring by augmenting the training data */
data need_pred;
   input horsepower;
datalines;
98
;

data auto2;
   set auto need_pred;
run;   

proc print data=auto2;
   where mpg is missing;
run;   

proc reg data=auto2;
   model mpg = horsepower;
   output out=out1 r=resid p=pred ucl=pihigh lcl=pilow 
         uclm=cihigh lclm=cilow stdp=stdmean;
run;   
   
data res_pred;
   set out1;
   if mpg=.;
run;         

proc print data=res_pred;
run;
   

/* Exercise 9 */
/* 9(a) */
proc sgscatter data=auto;
   matrix _numeric_;
run;   

/* 9(b) correlatio matrix */
proc corr data=auto;
   var _numeric_;
run;

/* 9(c) multiple linear regression */
proc reg data=auto;
   model mpg = cylinders displacement horsepower 
               weight acceleration year origin;
run;   

/* 9(e)(f) */
/* Data analysis is as much an art as a science */


/* Exercise 10 */
filename csvfile "&datapath/Carseats.csv";
proc import datafile=csvfile dbms=csv out=carseats replace;


/* 10(a) */
proc freq data=carseats;
   table shelveloc urban us;
run;

data carseats2 (drop=urban us);
   set carseats;
   if urban='Yes' then urban2=1;
   else urban2=0;
   if us='Yes' then us2=1;
   else us2=0;
run;   

proc means data=carseats2;
run;

proc glm data=carseats;
   class urban us;
   model sales = price urban us;
run;   

proc reg data=carseats2;
   model sales = price urban2 us2;
run;   

/* 10(e) */
proc reg data=carseats2;
   model sales = price us2;
run;


/* Exercise 11 */
/* http://blogs.sas.com/content/iml/2011/08/24/how-to-generate-random-numbers-in-sas.html */
data xy;
call streaminit(1);
do i = 1 to 100;
   x = rand("Normal");
   y = 2*x + rand("Normal");
   output;
end;
run;      

proc univariate data=xy;
var x y;
histogram x/ endpoints=-3 to 3 by 0.5;
histogram y/ endpoints=-5 to 5 by 0.5;
run;
 
/* 11(a) */
proc reg data=xy;
   model y = x / noint;
run;   

/* 11(b) */
proc reg data=xy;
   model x = y / noint;
run;   


/* Exercise 13 */
data xy13;
call streaminit(1);
do i = 1 to 100;
   x = rand("Normal");
   eps = rand('Normal',0,0.25);
   y = -1 + 0.5*x + eps;
   output;
end;
run;   

proc univariate data=xy13;
   var x y eps;
   histogram x;
   histogram y;
   histogram eps;
run;   

/* 13(c) */
proc reg data=xy13;
   model y = x;
run;      

/* 13(d) */
proc sgplot data=xy13;
   scatter x=x y=y;
run;   

/* 13(f) */
/* to-do */

/* 13(g) */
proc glm data=xy13;
   model y = x x*x;
run;


/* Exercise 14 */
/* 14(a) */
data xy14 (drop=i);
call streaminit(1);
do i = 1 to 100;
   x1 = rand('Uniform');
   x2 = 0.5*x1 + rand('Normal')/10;
   y = 2 + 2*x1 + 0.3*x2 + rand('Normal');
   output;
end;
run;   

proc univariate data=xy14;
   var x1 x2 y;
   histogram x1;
   histogram x2;
   histogram y;
run;   
   
proc reg data=xy14;
   model y = x1 x2;
run;      

/* 14(b) */
proc corr data=xy14;
   var x1 x2;
run;   

proc sgplot data=xy14;
   scatter x=x1 y=x2;
run;   

/* 14(d) */
proc reg data=xy14;
   model y = x1;
run;

/* 14(e) */
proc reg data=xy14;
   model y = x2;
run;
   
/* 14(g) */
data temp;
   input x1 x2 y;
   datalines;
0.1 0.8 6
;   

data xy14g;
   set xy14 temp;
run;   

proc reg data=xy14g;
   model y = x1 x2;
run;   


/* Exercise 3#15 */
filename csvfile "&datapath/Boston2.csv";
proc import datafile=csvfile dbms=csv out=boston replace;

proc contents data=boston;
run;

proc means data=boston;
run;

proc reg data=boston;
   model crim = zn indus chas nox rm age dis rad tax ptratio black lstat medv;
run;


