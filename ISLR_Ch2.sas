
/* 2.3 Lab */

/* 2.3.1 Basic Commands */
proc iml;
x = {1,3,2,5};
print x;
x = {1,6,2};
print x;
y = {1,4,3};
print y;

nr = nrow(x);
nc = ncol(x);
print nr nc;

nr = nrow(y);
nc = ncol(y);
print nr nc;

xy = x + y;
print xy;

/* http://blogs.sas.com/content/iml/2011/05/23/listing-sasiml-variables.html */
show names;
show allnames;

/* free nr nc; */
free nr nc;
show names;
show allnames;

/* compare REMOVE with FREE statement */
/* REMOVE is for removing something from a data set, so first there is a data set */
store x y xy;
show storage;
remove y;
show storage;
show names;

proc iml;
x = shapecol(1:4, 2, 2);
print x;

y = shape(1:4, 2, 2);
print y;

xr = sqrt(x);
print xr[format=5.2];

xx = x##2;
print xx;

proc iml;
x = j(50,1); /* allocate (50 x 1) vector */
call randgen(x, "Normal"); /* fill it */
print (x[1:10]);

x1 = j(50,1);
call randgen(x1, "Normal", 50, 0.1);
y = x + x1;
print (y[1:10]);

z = x || y;
print (z[1:10,]);
corr = corr(z);
print corr;

proc iml;
call randseed(1303); /* set random number seed. */
x = j(50,1);
call randgen(x,"Normal");
print (x[1:10]);

proc iml;
call randseed(3);
y = j(100,1);
call randgen(y, "Normal");

mean = mean(y);
var = var(y);
sqrtvar = sqrt(var);
std = std(y);
print mean var sqrtvar std;


/* 2.3.2 Graphics */
/* Produce a scatterplot of the numbers in x versus the numbers in y */
proc iml;
x = j(100,1); /* allocate */
y = j(100,1);
call randgen(x, "Normal");
call randgen(y, "Normal");

title "Plot of X vs Y";
run Scatter(x, y) label={"this is x-axis", "this is y-axis"};


ods pdf file="/folders/myshortcuts/mySAS/Figure.pdf";
proc iml;
x = j(100,1); /* allocate */
y = j(100,1);
call randgen(x, "Normal");
call randgen(y, "Normal");

title "Plot of X vs Y";
run Scatter(x, y) label={"this is x-axis", "this is y-axis"}
                  option="markerattrs=(color=green)";
ods pdf close;

proc iml;
x = do(1,10,1);
print x;

x2 = 1:10;
print x2;

proc iml;
/** generate n evenly spaced points between (and including) a and b **/
/* http://blogs.sas.com/content/iml/2012/01/23/constants-in-sas.html */
start Linspace(a, b, n);
   if n<2 then return( b );
   incr = (b-a) / (n-1);
   return( do(a, b, incr) );
finish;

/* http://blogs.sas.com/content/iml/2012/01/23/constants-in-sas.html */
pi = constant('pi');
t = Linspace(-pi, pi, 50);
print pi t;


/* To-do: contour plot */
/* see SAS/STAT 13.2 User's Guide Chapter 54 The KDE Procedure */

/* To-do: image() produces heatmap */
/* To-do: persp() produces a three-dimensional plot */


/* 2.3.3 Indexing Data */
proc iml;
A = shapecol(1:16,4,4);
print A;

a1 = A[2,3];
print a1;

a2 = A[{1 3},{2 4}];
print a2;

a3 = A[1:3, 2:4];
print a3;

a4 = A[1:2,];
a5 = A[,1:2];
a6 = A[1,];
print a4, a5, a6;

proc iml;
A = shapecol(1:16,4,4);
print A;

vr = {1 3};
idxr = setdif(1:nrow(A), vr);
a7 = A[idxr, ];
print idxr, a7;

vc = {1 3 4};
idxc = setdif(1:ncol(A), vc);
a8 = A[idxr, idxc];
print idxc, a8;

anr = nrow(A);
anc = ncol(A);
print anr anc;


/* 2.3.4 Loading Data */
/* First use Excel to load Auto.data, then save as Auto.csv */

/* Import from Auto.csv. There are error warning though getting data into dataset. */
proc import out=work.auto
            datafile='/folders/myshortcuts/dc/data/Auto.csv'
            dbms=csv replace;
            getnames=yes;
            datarow=2;
run;            

/* Remove observations with missing values */
data autoNoMiss;
   set auto;
   if cmiss(of _all_) then delete;
run;  

/* Check data set info */
proc contents data=autoNoMiss;
run;


/* 2.3.5 Additional Graphical and Numerical Summaries */

/* scatterplot */
proc sgplot data=autoNoMiss;
   scatter x=cylinders y=mpg;
run;

/* boxplot */
proc sgplot data=autoNoMiss;
   vbox mpg / category=cylinders;
run;   

/* histogram */
proc sgplot data=autoNoMiss;
   histogram mpg;
run;   

/* scatterplot matrix */
proc sgscatter data=autoNoMiss;
   matrix _numeric_;
run;
   
proc sgscatter data=autoNoMiss;
   matrix mpg displacement horsepower weight acceleration;
run;   

/* summary */
proc univariate data=autoNoMiss;
   var _numeric_;
run;
   
proc univariate data=autoNoMiss;
   var mpg;
run;   


/* Exercise 8 */

/* 8 (a) (b) Read data*/
filename csvfile "/folders/myshortcuts/dc/data/College.csv" termstr=CRLF;
proc import datafile=csvfile
            dbms=csv
            out=college
            replace;
run;

proc iml;
use college;
/*    read all into mcl; */
   read all var _NUM_ into X[colname=NumerNames];
   read all var _CHAR_ into C[colname=CharNames];
close college;

x1= X[1:10,];
c1 = C[1:10,];
print x1, c1;
print NumerNames, CharNames;

names = C[,1];
mattrib X rowname=names
          colname=NumerNames;
print X;          

/* show names; */
/* print mcl; */
/* m1 = mcl[,setdif(1:ncol(mcl),1)]; */
/* print m1; */


/* 8(c)i */
proc iml;
use college;
summary class {private} var _NUM_;

/* 8(c)ii */
proc iml;
use college;
   read all var _NUM_ into X[colname=NumerNames];
   read all var _CHAR_ into C[colname=CharNames];
close college;

c1 = C[,2];
c1name = CharNames[2];

x1 = X[,1:9];
x1name = NumerNames[1:9];

/* create data sets from matrices */
create dc1 from c1[colname=c1name];
append from c1;
close dc1;
create dx1 from x1[colname=x1name];
append from x1;
close dx1;

/* Combine two data sets by One-to-One Reading */
data dxc;
   set dc1;
   set dx1;
run;

proc sgscatter data=dxc;
   matrix _numeric_ / group=private;
run;

/* 8(c)iii */
proc sgplot data=dxc;
   vbox outstate / group=private;
run;   

/* 8(c)iv */
/* In IML, you can't mix character and numeric in a matrix. */
/* You can finish the exerice with DATA STEP, but I will try it with IML here. */
/* I will use numeric 0 for character "No", 1 for "Yes" */
/* Avoid loop in IML */
proc iml;
use college;
/*    read all var _NUM_ into X[colname=NumerNames]; */
   read all var {Outstate Top10perc};
   read all var {private};
summary class {private};
close college;
/* print X; */

call Bar(private);
private = (private="Yes");
/* print private; */
/* call Bar(private); */

/* create a new vector Elite by binning Top10perc */
/* EliteX = X[,"Top10perc"]; */
/* print EliteX; */
Elite = j(nrow(Top10perc),1,0);
Elite = (Top10perc>50);
call Bar(Elite);

/* Outstate and Elite are column vectors. Theya aren't in a matrix.*/
title "Boxplots of Outstate vs Elite";
call Box(Outstate) Category=elite;


/* 8(c)v */
/* proc sgpanel data=college; */
/*    panelby Private; */
/*    histogram Top10perc; */
/*    density Top10perc; */
/* run;    */

proc sgscatter data=college;
/*    matrix _NUMERIC_ / diagonal = (histogram kernel); */
   matrix Apps Accept Outstate Top10perc 
      / diagonal=(histogram kernel)
        group=Private;
run;


/* Exercise 9 */
filename csvfile "/folders/myshortcuts/dc/data/Auto.csv";
proc import datafile=csvfile dbms=csv out=auto replace;
run;

/* Remove observations with missing values */
data autoNoMiss;
   set auto;
   if cmiss(of _all_) then delete;
run;

/* 9(a) */
proc contents data=autoNoMiss(keep=_numeric_);
run;

proc contents data=autoNoMiss(keep=_char_);
run;

/* 9(b)(c) */
proc means data=autoNoMiss min max range mean std;
   var _numeric_;
run;   

/* 9(d) */
data subAutoNoMiss;
   set autoNoMiss;
   if _n_ >= 10 and _n_ <= 85 then delete;
run;   

proc means data=subAutoNoMiss range mean std;
   var _numeric_;
run;

proc univariate data=autoNoMiss;
   histogram / normal;
/*    by origin notsorted; */
run;   


proc sgscatter data=autoNoMiss;
   matrix _numeric_ 
   / diagonal=(kernel histogram)
     group=origin;
run;   
         

/* Exercise 10 */

/* 10(a) */
/* Boston.csv exported in R has an added column. */
/* Using Google Refine, remove this column, save it as Boston2.csv */
filename csvfile "/folders/myshortcuts/dc/data/Boston2.csv";
proc import datafile=csvfile dbms=csv out=Boston replace;

/* data boston(drop=var1); */
/*    set bostonraw; */
/* run;    */

proc contents data=Boston;
run;         
   
/* 10(b) */
proc sgscatter data=Boston;
   matrix _numeric_ / diagonal=(kernel histogram);
/*    matrix crim zn age dis rad tax ptratio black medv */
/*    / diagonal=(kernel histogram); */
run;

/* 10(c) */
proc sgplot data=Boston;
   scatter x=age y=crim;  
run;   

proc sgplot data=Boston;
   scatter x=dis y=crim;   
run;  

proc sgplot data=Boston;
   scatter x=rad y=crim;   
run;  

proc sgplot data=Boston;
   scatter x=tax y=crim;   
run;  

proc sgplot data=Boston;
   scatter x=ptratio y=crim;   
run;     

/* 10(d) */
proc univariate data=Boston;
   histogram;
   var crim tax ptratio;
run;   

/* 10(e) */
proc sgplot data=Boston;
   vbar chas;
run;   

proc freq data=Boston;
   table chas;
run;


/* 10(f) */
proc means data=Boston Q1 Median Q3 QRange;
   var ptratio;
run;
   
/* 10(g) */
proc sql;
select * from Boston having medv=min(medv);
quit;

/* 10(h) */
proc sql number;
select * from Boston where rm > 7;


proc sql number;
select * from Boston where rm > 8;
quit;

proc sql;
create table BostonRm8 as
   select * from Boston where rm > 8;
quit;   


proc means data=Boston;
run;
proc means data=BostonRm8;
run;



