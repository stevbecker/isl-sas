/* Chapter 4 Classification */

%let datapath=/folders/myshortcuts/dc/data;
%put "&datapath/Smarket.csv";

filename csvfile "&datapath/Default.csv";
proc import datafile=csvfile dbms=csv out=default replace;

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

/* Table 4.1 */
proc genmod data=default;
   model default = balance
   			/link=logit dist=binomial;
run;   			

/* Score using the model */
proc genmod data=default outest=est1;
   model default = balance
   			/link=logit dist=binomial;
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