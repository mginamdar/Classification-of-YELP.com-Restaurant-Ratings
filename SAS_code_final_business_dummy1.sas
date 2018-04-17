LIBNAME yelp "C:\Users\pradeepgowda\Documents\My SAS Files\9.4\SAS_DATA\Yelp";

DATA  yelpdata_business;
LENGTH
 business_id $ 22
 city $ 36
 state $ 3
 postal_code $ 8
;

INFILE  "C:\Users\pradeepgowda\Documents\My SAS Files\9.4\RAW_DATA\Yelp\Business_Clean.txt" 
     DSD 
     LRECL= 135 ;
INPUT
 business_id
 city
 state
 postal_code
 latitude
 longitude
 stars
 review_count
 is_open
 Alcohol
 Ambience
 Parking
 BusinessAcceptsCreditCards
 GoodForkids
 NoiseLevel
 OutdoorSeating
 RestaurantsDelivery
 PriceRange
 RestaurantsReservations
 RestaurantsTableService
;
RUN;

data yelpdata_business;
  set 'C:\Users\M\Downloads\yelpdata_business.sas7bdat';
run;


PROC FORMAT;
	value is_open
      0 = 'Restaurant closed'  
      1 = 'Restaurant open';
	value Alcohol
      1 = 'No drinks'  
      2 = 'Beer and Wine'
	  3 = 'Full bar';
	value Ambience
      0 = 'Normal'  
      1 = 'Romantic'
	  2 = 'Intimate'
	  3 = 'Classy'
	  4 = 'Hipster'
	  5 = 'Touristy'
	  6 = 'Trendy'
	  7 = 'Upscale'
	  8 = 'Casual';
	value Parking
      0 = 'None'  
      1 = 'Garage'
	  2 = 'Street'
	  3 = 'Validated'
	  4 = 'Lot'
	  5 = 'Valet';
	value BusinessAcceptsCreditCards
      1 = 'False'  
      2 = 'True';
	value GoodForkids
      1 = 'False'  
      2 = 'True';
	value NoiseLevel
      1 = 'Quiet'  
      2 = 'Loud'
	  3 = 'Average'
	  4 = 'Very loud';
	value OutdoorSeating
      1 = 'False'  
      2 = 'True';
	value RestaurantsDelivery
      1 = 'False'  
      2 = 'True';
	value PriceRange
      1 = 'Inexpensive'  
      2 = 'Moderate'
	  3 = 'Pricey'
	  4 = 'Ultra High-End';
	value RestaurantsReservations
      1 = 'False'  
      2 = 'True';
	value RestaurantsTableService
      1 = 'False'  
      2 = 'True';
RUN;


** Examine the variables for outliner **;
proc freq data=yelpdata_business;
	tables review_count is_open Alcohol Ambience Parking BusinessAcceptsCreditCards GoodForkids NoiseLevel OutdoorSeating 
		RestaurantsDelivery PriceRange RestaurantsReservations RestaurantsTableService;
	format is_open is_open.; 
	format Alcohol Alcohol.; 
	format Ambience Ambience.; 
	format Parking Parking.; 
	format BusinessAcceptsCreditCards BusinessAcceptsCreditCards.; 
	format GoodForkids GoodForkids.; 
	format NoiseLevel NoiseLevel.; 
	format OutdoorSeating OutdoorSeating.; 
	format RestaurantsDelivery RestaurantsDelivery.; 
	format PriceRange PriceRange.; 
	format RestaurantsReservations RestaurantsReservations.; 
	format RestaurantsTableService RestaurantsTableService.; 
run;

* Review_count data is having significant difference in mean, median and mode values: possibility of outliners;
proc univariate data=yelpdata_business;
  var review_count;
  histogram / cfill=gray;
run;

proc capability data=yelpdata_business noprint;
  ppplot review_count ;
run;

** Apply transformation to review_count, divide stars rating into binary variable for classification, remove the outliners from
	review_count by selecting only review_count lessthan 500;
DATA yelpdata_business1;
	SET yelpdata_business;
	
	logreview = log10(review_count);
	IF stars<=2.5 THEN star=0;
	ELSE IF stars>2.5 THEN star=1;

	if review_count <= 500 then output yelpdata_business1;
	
RUN;

** Check the review_count distrubution ;
proc univariate data=yelpdata_business1;
  var review_count logreview;
  histogram / cfill=gray normal kernel;
  qqplot / normal;
run;

proc capability data=yelpdata_business1 noprint;
  ppplot logreview ;
run;

** Create dummy variable for categorical data;
DATA yelpdata_business2;
	SET yelpdata_business1;

	IF is_open = 0 THEN Rest_Closed = 1;
	ELSE Rest_Closed = 0;
	IF is_open = 1 THEN Rest_Open = 1;
	ELSE Rest_Open = 0;

	IF Alcohol = 1 THEN No_Alcohol = 1;
	ELSE No_Alcohol = 0;
	IF Alcohol = 2 THEN Beer_Wine = 1;
	ELSE Beer_Wine = 0;
	IF Alcohol = 3 THEN Full_bar = 1;
	ELSE Full_bar = 0;

	IF Ambience = 0 THEN Basic_Ambience = 1;
	ELSE Basic_Ambience = 0;
	IF Ambience = 1 THEN Romantic_Ambience = 1;
	ELSE Romantic_Ambience = 0;
	IF Ambience = 2 THEN Intimate_Ambience = 1;
	ELSE Intimate_Ambience = 0;
	IF Ambience = 3 THEN Classy_Ambience = 1;
	ELSE Classy_Ambience = 0;
	IF Ambience = 4 THEN Hipster_Ambience = 1;
	ELSE Hipster_Ambience = 0;
	IF Ambience = 5 THEN Touristy_Ambience = 1;
	ELSE Touristy_Ambience = 0;
	IF Ambience = 6 THEN Trendy_Ambience = 1;
	ELSE Trendy_Ambience = 0;
	IF Ambience = 7 THEN Upscale_Ambience = 1;
	ELSE Upscale_Ambience = 0;
	IF Ambience = 8 THEN Casual_Ambience = 1;
	ELSE Casual_Ambience = 0;

	IF Parking = 0 THEN No_Parking = 1;
	ELSE No_Parking = 0;
	IF Parking = 1 THEN Garage_Parking = 1;
	ELSE Garage_Parking = 0;
	IF Parking = 2 THEN Street_Parking = 1;
	ELSE Street_Parking = 0;
	IF Parking = 3 THEN Validated_Parking = 1;
	ELSE Validated_Parking = 0;
	IF Parking = 4 THEN Lot_Parking = 1;
	ELSE Lot_Parking = 0;
	IF Parking = 5 THEN Valet_Parking = 1;
	ELSE Valet_Parking = 0;
	
	IF BusinessAcceptsCreditCards = 1 THEN NoCreditCard = 1;
	ELSE NoCreditCard = 0;
	IF BusinessAcceptsCreditCards = 2 THEN AcceptCreditCard = 1;
	ELSE AcceptCreditCard = 0;
	
	IF GoodForkids = 1 THEN Bad_ForKids = 1;
	ELSE Bad_ForKids = 0;
	IF GoodForkids = 2 THEN Good_ForKids = 1;
	ELSE Good_ForKids = 0;

	IF NoiseLevel = 1 THEN Quiet_NoiseLevel = 1;
	ELSE Quiet_NoiseLevel = 0;
	IF NoiseLevel = 2 THEN Loud_NoiseLevel = 1;
	ELSE Loud_NoiseLevel = 0;
	IF NoiseLevel = 3 THEN Average_NoiseLevel = 1;
	ELSE Average_NoiseLevel = 0;
	IF NoiseLevel = 4 THEN VeryLoud_NoiseLevel = 1;
	ELSE VeryLoud_NoiseLevel = 0;

	IF OutdoorSeating = 1 THEN OutdoorSeating_NotAvailable = 1;
	ELSE OutdoorSeating_NotAvailable = 0;
	IF OutdoorSeating = 2 THEN OutdoorSeating__Available  = 1;
	ELSE OutdoorSeating__Available = 0;

	IF RestaurantsDelivery = 1 THEN Delivery__NotAvailable  = 1;
	ELSE Delivery__NotAvailable = 0;
	IF RestaurantsDelivery = 2 THEN Delivery__Available  = 1;
	ELSE Delivery__Available = 0;

	IF PriceRange = 1 THEN Inexpensive_PriceRange = 1;
	ELSE Inexpensive_PriceRange = 0;
	IF PriceRange = 2 THEN Moderate_PriceRange = 1;
	ELSE Moderate_PriceRange = 0;
	IF PriceRange = 3 THEN Pricey_PriceRange = 1;
	ELSE Pricey_PriceRange = 0;
	IF PriceRange = 4 THEN UltraHighEnd_PriceRange = 1;
	ELSE UltraHighEnd_PriceRange = 0;

	IF RestaurantsReservations = 1 THEN Reservations__NotAvailable  = 1;
	ELSE Reservations__NotAvailable = 0;
	IF RestaurantsReservations = 2 THEN Reservations__Available  = 1;
	ELSE Reservations__Available = 0;

	IF RestaurantsTableService = 1 THEN TableService__NotAvailable  = 1;
	ELSE TableService__NotAvailable = 0;
	IF RestaurantsTableService = 2 THEN TableService__Available  = 1;
	ELSE TableService__Available = 0;

	
	DROP 
	is_open
	Alcohol
	Ambience
	BusinessAcceptsCreditCards
	Parking
	GoodForkids
	NoiseLevel
	OutdoorSeating
	RestaurantsDelivery
	PriceRange
	RestaurantsReservations
	RestaurantsTableService;


RUN;


ODS GRAPHICS ON;
ODS RTF FILE="C:\Users\pradeepgowda\Documents\My SAS Files\9.4\SAS_output\yelp.rtf";


Title "Classification: Logistic regression";

PROC LOGISTIC DATA=yelpdata_business1 PLOTS=ALL OUTMODEL=LogisticModel;
	CLASS is_open (ref='0') Alcohol (ref='1') Ambience (ref='0') Parking (ref='0') BusinessAcceptsCreditCards (ref='1')
			GoodForkids (ref='1') NoiseLevel (ref='1') OutdoorSeating (ref='1') RestaurantsDelivery (ref='1') 
			PriceRange (ref='1') RestaurantsReservations (ref='1') RestaurantsTableService (ref='1') / PARAM= ref ;
					 
	MODEL star = logreview is_open Alcohol Ambience Parking BusinessAcceptsCreditCards GoodForkids NoiseLevel 
					OutdoorSeating RestaurantsDelivery PriceRange RestaurantsReservations 
					RestaurantsTableService / SELECTION=STEPWISE;
	SCORE OUT=Score1;		
RUN;

proc surveyselect data= yelpdata_business1 method=srs N=100 out= samp;

proc logistic inmodel=LogisticModel;
   score data=samp out=Score3;
run;

proc print data=score3;
var f_star i_star;run;

proc contents data=score3;
run;

Title "Clustering Analysis: K-means clustering";

/* run HPCLUS to auto-select best k value */

proc hpclus data= yelpdata_business1 maxclusters= 8 maxiter= 100 seed= 54321  
     NOC= ABC(B= 1 minclusters= 3 align= PCA);   /* select best k between 3 and 8 using ABC */                           
     input logreview: stars;;                             
run;


/* now run FASTCLUS to find k nice clusters from non-random seeds */

proc fastclus data= yelpdata_business1 out= fcOut1 outtree= maxiter= 100  
      maxclusters= 6    /* k found by hpclus */
      summary;
	  VAR logreview stars;
run;

PROC FREQ DATA=fcout1; 
	tables cluster*state; 
RUN;

Title "Classification: Naive Bayesan";

proc hpbnet data=yelpdata_business2 numbin=3 structure=Naive
         prescreening=0 varselect=0;
     target star;
     input Rest_Closed  Rest_Open No_Alcohol Beer_Wine Full_bar Basic_Ambience Romantic_Ambience 
			Intimate_Ambience Classy_Ambience Hipster_Ambience Touristy_Ambience Trendy_Ambience Upscale_Ambience 
			Casual_Ambience No_Parking Garage_Parking Street_Parking Validated_Parking Lot_Parking Valet_Parking 
			NoCreditCard AcceptCreditCard Bad_ForKids Good_ForKids Quiet_NoiseLevel Loud_NoiseLevel Average_NoiseLevel 
			VeryLoud_NoiseLevel OutdoorSeating_NotAvailable OutdoorSeating__Available Delivery__NotAvailable 
			Delivery__Available Inexpensive_PriceRange Moderate_PriceRange Pricey_PriceRange UltraHighEnd_PriceRange 
			Reservations__NotAvailable Reservations__Available TableService__NotAvailable 
			TableService__Available / LEVEL=NOM;
     output network=network;
 run;


proc print data=network noobs label;
     var _parentnode_ _childnode_;
     where _type_="STRUCTURE";
 run;

Title "Classification: Random Forest";

proc hpforest data=yelpdata_business1 maxtrees= 500 vars_to_try=4 seed=600 trainfraction=0.6  maxdepth=50 leafsize=6 alpha= 0.05;
	target star;
     input  is_open Alcohol Ambience Parking BusinessAcceptsCreditCards GoodForkids NoiseLevel 
					OutdoorSeating RestaurantsDelivery PriceRange RestaurantsReservations 
					RestaurantsTableService / LEVEL=NOMINAL;
			ods    output fitstatistics = fitstats; 
	input logreview;
	save file = "C:\Users\pradeepgowda\Documents\model_fit.bin";

RUN;

proc hpforest data=yelpdata_business1 maxtrees= 500 vars_to_try=4 seed=600 trainfraction=0.6  maxdepth=50 leafsize=6 alpha= 0.05;
target star/level=nominal;
input  is_open Alcohol Ambience Parking BusinessAcceptsCreditCards GoodForkids NoiseLevel 
					OutdoorSeating RestaurantsDelivery PriceRange RestaurantsReservations 
					RestaurantsTableService / LEVEL=NOMINAL;
input logreview/level=interval ;
save file = "C:\Users\M\Desktop\Yelp\model_fit.bin";
run;


proc surveyselect data= yelpdata_business1 method=srs N=100 out= samp; run;

proc hp4score data=samp; 
	id   star; 
	score file= "C:\Users\M\Desktop\Yelp\model_fit.bin" out=scored; 
run;  

TITLE 'Dimension Reduction Technique: Multiple Correspondence Analysis';
   
   * Perform Multiple Correspondence Analysis;
PROC CORRESP MCA OBSERVED DATA=yelpData_business2 OUT=MCA_Var;
      TABLES No_Alcohol Beer_Wine Full_bar Basic_Ambience Romantic_Ambience Intimate_Ambience Classy_Ambience Hipster_Ambience 
			Touristy_Ambience Trendy_Ambience Upscale_Ambience Casual_Ambience No_Parking Garage_Parking Street_Parking 
			Validated_Parking Lot_Parking Valet_Parking NoCreditCard AcceptCreditCard Bad_ForKids Good_ForKids Quiet_NoiseLevel 
			Loud_NoiseLevel Average_NoiseLevel VeryLoud_NoiseLevel OutdoorSeating_NotAvailable OutdoorSeating__Available 
			Delivery__NotAvailable Delivery__Available Inexpensive_PriceRange Moderate_PriceRange Pricey_PriceRange 
			UltraHighEnd_PriceRange Reservations__NotAvailable Reservations__Available TableService__NotAvailable 
			TableService__Available;
	
RUN;


PROC LOGISTIC DATA= Coor PLOTS=ALL;
	MODEL star = logreview Rest_Closed  Rest_Open No_Alcohol Beer_Wine Full_bar Basic_Ambience Romantic_Ambience Intimate_Ambience Classy_Ambience Hipster_Ambience Touristy_Ambience Trendy_Ambience Upscale_Ambience Casual_Ambience No_Parking Garage_Parking Street_Parking Validated_Parking Lot_Parking Valet_Parking NoCreditCard AcceptCreditCard Bad_ForKids Good_ForKids Quiet_NoiseLevel Loud_NoiseLevel Average_NoiseLevel VeryLoud_NoiseLevel OutdoorSeating_NotAvailable OutdoorSeating__Available Delivery__NotAvailable Delivery__Available Inexpensive_PriceRange Moderate_PriceRange Pricey_PriceRange UltraHighEnd_PriceRange Reservations__NotAvailable Reservations__Available TableService__NotAvailable TableService__Available / SELECTION=STEPWISE;
	output out= result p = prob;
RUN;

PROC PRINCOMP data=yelpdata_business2 out=PRINC;
	var Rest_Closed  Rest_Open No_Alcohol Beer_Wine Full_bar Basic_Ambience Romantic_Ambience 
			Intimate_Ambience Classy_Ambience Hipster_Ambience Touristy_Ambience Trendy_Ambience Upscale_Ambience 
			Casual_Ambience No_Parking Garage_Parking Street_Parking Validated_Parking Lot_Parking Valet_Parking 
			NoCreditCard AcceptCreditCard Bad_ForKids Good_ForKids Quiet_NoiseLevel Loud_NoiseLevel Average_NoiseLevel 
			VeryLoud_NoiseLevel OutdoorSeating_NotAvailable OutdoorSeating__Available Delivery__NotAvailable 
			Delivery__Available Inexpensive_PriceRange Moderate_PriceRange Pricey_PriceRange UltraHighEnd_PriceRange 
			Reservations__NotAvailable Reservations__Available TableService__NotAvailable 
			TableService__Available;
 run;

PROC LOGISTIC DATA= PRINC PLOTS=ALL OUTMODEL=LogisticModel_1;
	MODEL star = logreview Prin1 Prin2 Prin3 Prin4 Prin5 Prin6 Prin7 Prin8 Prin9 Prin10 Prin11
					Prin12 Prin13 Prin14 Prin15 Prin16 Prin17 Prin18 / SELECTION=STEPWISE;
	output out= result p = prob; SCORE OUT=Score5;
RUN;


proc surveyselect data= PRINC method=srs N=100 out= samp;
RUN;

proc logistic inmodel=LogisticModel_1;
   score data=samp out=Score6;
run;


QUIT;
  
