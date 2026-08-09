/*==========================================================================
  STAT395 PROJECT — Comparing Probability Sampling Designs
  Data source: Survey of Activities of Young People (SAYP) 2019, Stats SA
  Group Seed: 202502
==========================================================================*/

libname Project xlsx "/home/u63431575/SAYP.xlsx";
run;

/*==========================================================================
  1. SIMPLE RANDOM SAMPLING (SRS)
==========================================================================*/
proc surveyselect data=project.sayp
    sampsize=3334          /* 25% of the 13,336-record frame            */
    method=srs
    seed=202502
    out=project.srs_data
    stats;
run;

proc surveymeans data=project.srs_data total=13336
    mean clm sum clsum varsum var;
    var  Q13Age Totalhours;
    weight samplingweight;
run;

proc surveyfreq data=project.srs_data;
    tables Q22Attend Q12Gender;
run;

/*==========================================================================
  2. SIMPLE RANDOM SAMPLING WITH REPLACEMENT (SRS WR / Unrestricted Random)
==========================================================================*/
proc surveyselect data=project.sayp
    sampsize=3334
    method=urs
    seed=202502
    out=project.urs_data
    stats;
run;

proc surveymeans data=project.urs_data total=13336
    mean clm sum clsum varsum var;
    var  Q13Age Totalhours;
    weight samplingweight;
run;

proc surveyfreq data=project.urs_data;
    tables Q22Attend Q12Gender;
run;

/*==========================================================================
  3. STRATIFIED SAMPLING (proportional allocation by Q12Gender)
==========================================================================*/
data work.sayp;
    set project.sayp;
run;

proc sort data=work.sayp;
    by Q12Gender;
run;

proc surveyselect data=work.sayp
    sampsize=(879 862)      /* proportional allocation across 2 strata,
                                totalling n=1,741 as reported            */
    out=strata_sample
    method=srs
    seed=202502
    stats;
    strata Q12Gender;
run;

proc surveymeans data=strata_sample mean clm sum clsum var;
    strata Q12Gender;
    var Totalhours Q13Age;
run;

proc surveymeans data=strata_sample mean clm sum clsum;
    strata Q12Gender;
    var TotalHrs;
    weight Weight;
run;

/*==========================================================================
  4. CLUSTER SAMPLING (Province as the cluster / sampling unit)
==========================================================================*/
proc surveyselect data=project.sayp
    method=srs              /* SRS of primary sampling units (provinces) */
    sampsize=2
    seed=202502
    out=cluster_srs
    samplingunit=Province
    stats;
run;

proc surveymeans data=cluster_srs;
    cluster Province;
    var Q13Age TotalHours;
run;

proc surveyfreq data=cluster_srs;
    tables Q22Attend Child_Labour;
run;
