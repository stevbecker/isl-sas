/* Chapter 4 Classification */

%let datapath=/folders/myshortcuts/dc/data;
%put "&datapath/Smarket.csv";

filename csvfile "&datapath/Default.csv";
proc import datafile=csvfile dbms=csv out=default replace;

proc summary data=default;
   class student default;
   var balance income;
   output out=sum_default;
run;   

data default2 (drop=var1 student);
   set default;
   if student='Yes' then student2=1;
   else if student='No' then student2=0;
   else student2=-1;
run;
   

/* Figure 4.1 */
proc sgplot data=default;
   scatter x=balance y=income / group=default;
run;  

proc sgplot data=default;
   vbox balance / category=default;
run;   

proc sgplot data=default;
   vbox income/ category=default;
run;

/* Table 4.1 use PROC LOGISTIC */
/* p134 4.3.3 Making Predictions */
data valid;
   input balance default $;
   datalines;
1000 .
2000 .
;   

proc logistic data=default;
/*    model default = balance; */
   model default (desc) = balance;
   score data=valid out=validscore; /* making prediction */
   run;

/* Table 4.1 use PROC GENMOD */
/* p134 4.3.3 Making Predictions */
proc genmod data=default;
/*    model default = balance / link=logit dist=binomial; */
   model default (desc) = balance / link=logit dist=binomial;
   store out=logmod;
   run;           

proc plm source=logmod;
/*    score data=valid out=validscore2; */
   score data=valid out=validscore2 / ilink;
/*    score data=valid out=validscore2 lclm=lower uclm=upper / ilink; */
/*    The ILINK option in the SCORE statement requests that predicted values  */
/*    be inversely transformed to the response scale */
   run;


data valid2;
   input student2 default $;
   datalines;
1 .
0 .
;

/* Table 4.2 */
/* Use PROC LOGISTIC */
proc logistic data=default2;
   model default (desc) = student2;
   score data=valid2 out=validscore3; /* making prediction */
   run;

/* Table 4.2 */
/* Use PROC GENMOD */   
proc genmod data=default2;
   model default (desc) = student2 / link=logit dist=binomial;
   store out=logmod;
   run;           

proc plm source=logmod;
   score data=valid2 out=validscore4 / ilink;
   run;

/* Table 4.3 using PROC LOGISTIC */
proc logistic data=default2;
   model default (desc) = balance income student2;
   run;

/* Table 4.3 using PROC GENMOD */
proc genmod data=default2;
   model default (desc) = balance income student2 / link=logit dist=binomial;
   run; 

/* Figure 4.3 */
/* to-do: the left panel of Figure 4.3 */
/* http://blogs.sas.com/content/graphicallyspeaking/2013/08/11/customizing-plot-appearance/ */
/* how to define this problem */
proc sgplot data=default2;
   series x=balance y=income / group=student2;
   run;

proc sgplot data=default2;
   histogram balance / group=default;
   run;

proc sgplot data=default2;
   vbox balance / category=student2;
run;   


/* Chapter 4 Lab */

filename csvfile "&datapath/Smarket.csv";
proc import datafile=csvfile dbms=csv out=Smarket replace;

proc corr data=Smarket;
   var _numeric_;
run;

proc sgplot data=Smarket;
   scatter x=year y=volume;
   reg x=year y=volume;
run;

proc genmod data=Smarket;
   model direction=lag1 lag2 lag3 lag4 lag5 volume
         /link=logit dist=binomial;
run;



/* 4.6.6 An Application to Caravan Insurance Data */
filename csvfile "&datapath/Caravan.csv";
proc import datafile=csvfile dbms=csv out=Caravan1 replace;

data Caravan (drop=Var1);
   set Caravan1;
run;

/* standardize variables in Caravan */
proc standard data=Caravan mean=0 std=1 out=zcaravan;
  var _numeric_;
run;

proc means data=zcaravan;
run;

data testCvan trainCvan;
   set Caravan;
   if _n_ <= 1000 then output testCvan;
   else output trainCvan;
run;   

proc discrim data=trainCvan 
          method=npar k=3
          testdata=testCvan
          testout=testScore;
   class purchase;
   var _numeric_;
run;            



