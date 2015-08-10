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



   
