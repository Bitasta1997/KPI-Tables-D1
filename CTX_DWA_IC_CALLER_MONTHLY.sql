SET SQL_SAFE_UPDATES = 0;
delete from aepdev.`aep_context_t3` where ctxjob='DWA_IC_CALLER_MONTHLY' and ctxarea='KPI';


insert into aepdev.`aep_context_t3` ( `region` , `ctxarea` , `ctxjob` , `ctxkey` , `ctxval` , `remarks` )
values
(
'BKK',
'KPI',
'DWA_IC_CALLER_MONTHLY',
'stepcnt',
'6',
'step count'
);


insert into aepdev.`aep_context_t3` ( `region` , `ctxarea` , `ctxjob` , `ctxkey` , `ctxval` , `remarks` )
values
(
'BKK',
'KPI',
'DWA_IC_CALLER_MONTHLY',
'stgqry1',
'
TRUNCATE TABLE ~SCHEMAVA~.DWA_IC_CALLER_MONTHLY_STG1
',
'step 1'
);


insert into aepdev.`aep_context_t3` ( `region` , `ctxarea` , `ctxjob` , `ctxkey` , `ctxval` , `remarks` )
values
(
'BKK',
'KPI',
'DWA_IC_CALLER_MONTHLY',
'stgqry2',
'
INSERT INTO ~SCHEMAVA~.DWA_IC_CALLER_MONTHLY_STG1
(
 NO_OF_IC_CALLER
,IC_OPERATOR
,MOST_USED_AMPHUR_CODE
,MOST_USED_TUMBON_CODE
,MOST_USED_PROVINCE_CODE
,PROCESS_NAME
,EXECUTION_ID
,REPORT_DATE
,REPORT_MONTH
,REPORT_YEAR
,LOAD_USER
,LOAD_DATE 
,DW_LAST_UPDATE_TIME
)
SELECT 
SUM(IC.NO_OF_DTAC_SUBSCRIBER)   AS NO_OF_IC_CALLER,
\'Dtac\'   AS IC_OPERATOR,
VCM.AMPHUR_CD AS MOST_USED_AMPHUR_CODE,
VCM.TAMBON_CD AS MOST_USED_TUMBON_CODE,
VCM.PROVINCE_CD AS MOST_USED_PROVINCE_CODE,
null AS PROCESS_NAME,
~EXECUTIONID~               AS EXECUTION_ID,
IC.WEEK_ID AS REPORT_DATE,
DATE_PART(\'MONTH\', IC.WEEK_ID) AS REPORT_MONTH,
DATE_PART(\'YEAR\', IC.WEEK_ID) AS REPORT_YEAR,
null AS LOAD_USER,
null as LOAD_DATE,
null as DW_LAST_UPDATE_TIME
null as DW_LAST_UPDATE_TIME
FROM
(SELECT     
WEEK_ID ,
TAMBON_NAME,
AMPHUR_NAME,
PROVINCE_NAME,
\'Dtac\' AS OPERATOR_NAME,     
SUM(NO_OF_DTAC_SUBSCRIBER) as NO_OF_IC_CALLER
FROM ~SCHEMAVA~.USAGE_INTERCONNECT_CALLER_TAMBON_WEEKLY
WHERE  WEEK_ID  between <first week of the month> and <last week of the month>
AND upper(PROVINCE_NAME)  NOT IN (\'NATIONWIDE\')
AND NO_OF_DTAC_SUBSCRIBER > 0 
GROUP BY 
ROLLUP(WEEK_ID ,TAMBON_NAME,AMPHUR_NAME,PROVINCE_NAME)
UNION
SELECT     
WEEK_ID ,
TAMBON_NAME,
AMPHUR_NAME,
PROVINCE_NAME,
\'Dtac\' AS OPERATOR_NAME,     
SUM(NO_OF_DTAC_SUBSCRIBER) as NO_OF_IC_CALLER
FROM ~SCHEMAVA~.USAGE_INTERCONNECT_CALLER_TAMBON_WEEKLY
WHERE  WEEK_ID  between <first week of the month> and <last week of the month>
AND upper(PROVINCE_NAME) IN (\'NATIONWIDE\')
AND NO_OF_DTAC_SUBSCRIBER > 0 
GROUP BY 
ROLLUP(WEEK_ID ,TAMBON_NAME,AMPHUR_NAME,PROVINCE_NAME))IC
INNER JOIN ~SCHEMAVA~.USAGE_IC_TEMPLATE_RATIO_WEEKLY AS RATIO
ON IC.WEEK_ID = RATIO.WEEK_ID 
LEFT OUTER JOIN ~SCHEMAVA~.DIM_CLUSTER AS VCM
ON IC.PROVINCE_NAME = VCM.PROVINCE_EN
AND IC.AMPHUR_NAME  = VCM.AMPHUR_EN
AND IC.TAMBON_CD = VCM.TAMBON_EN
WHERE VCM.REC_END_DT = \'9999-12-31\'
AND VCM.ACCOUNT_TYPE_CD = 0
group by IC.WEEK_ID,VCM.AMPHUR_CD,VCM.TAMBON_CD,VCM.PROVINCE_CD

',
'step 2'
);


insert into aepdev.`aep_context_t3` ( `region` , `ctxarea` , `ctxjob` , `ctxkey` , `ctxval` , `remarks` )
values
(
'BKK',
'KPI',
'DWA_IC_CALLER_MONTHLY',
'stgqry3',
'
INSERT INTO ~SCHEMAVA~.DWA_IC_CALLER_MONTHLY_STG1
(
 NO_OF_IC_CALLER
,IC_OPERATOR
,MOST_USED_AMPHUR_CODE
,MOST_USED_TUMBON_CODE
,MOST_USED_PROVINCE_CODE
,PROCESS_NAME
,EXECUTION_ID
,REPORT_DATE
,REPORT_MONTH
,REPORT_YEAR
,LOAD_USER
,LOAD_DATE 
,DW_LAST_UPDATE_TIME
)
SELECT 
SUM(IC.NO_OF_AIS_SUBSCRIBER*RATIO.AIS_RATIO) AS NO_OF_IC_CALLER
\'AIS\' AS IC_OPERATOR
VCM.AMPHUR_CD AS MOST_USED_AMPHUR_CODE,
VCM.TAMBON_CD AS MOST_USED_TUMBON_CODE,
VCM.PROVINCE_CD AS MOST_USED_PROVINCE_CODE,
null AS PROCESS_NAME,
~EXECUTIONID~               AS EXECUTION_ID,
IC.WEEK_ID AS REPORT_DATE,
DATE_PART(\'MONTH\', IC.WEEK_ID) AS REPORT_MONTH,
DATE_PART(\'YEAR\', IC.WEEK_ID) AS REPORT_YEAR,
null AS LOAD_USER,
null as LOAD_DATE,
null as DW_LAST_UPDATE_TIME
FROM
(SELECT     
WEEK_ID ,
TAMBON_NAME,
AMPHUR_NAME,
PROVINCE_NAME,
\'AIS\' AS OPERATOR_NAME,     
NO_OF_AIS_SUBSCRIBER
FROM ~SCHEMAVA~.USAGE_INTERCONNECT_CALLER_TAMBON_WEEKLY
WHERE  WEEK_ID  between <first week of the month> and <last week of the month>
AND PROVINCE_NAME NOT IN (\'NATIONWIDE\')
AND  NO_OF_AIS_SUBSCRIBER > 0
GROUP BY 
ROLLUP( WEEK_ID ,TAMBON_NAME,AMPHUR_NAME,PROVINCE_NAME,NO_OF_AIS_SUBSCRIBER)
union
SELECT     
WEEK_ID ,
TAMBON_NAME,
AMPHUR_NAME,
PROVINCE_NAME,
\'AIS\' AS OPERATOR_NAME,     
NO_OF_AIS_SUBSCRIBER
FROM ~SCHEMAVA~.USAGE_INTERCONNECT_CALLER_TAMBON_WEEKLY
WHERE  WEEK_ID  between <first week of the month> and <last week of the month>
AND PROVINCE_NAME IN (\'NATIONWIDE\')
AND  NO_OF_AIS_SUBSCRIBER > 0
GROUP BY 
ROLLUP( WEEK_ID ,TAMBON_NAME,AMPHUR_NAME,PROVINCE_NAME,NO_OF_AIS_SUBSCRIBER))IC
INNER JOIN ~SCHEMAVA~.USAGE_IC_TEMPLATE_RATIO_WEEKLY AS RATIO
ON IC.WEEK_ID = RATIO.WEEK_ID 
LEFT OUTER JOIN ~SCHEMAVA~.DIM_CLUSTER AS VCM
ON IC.PROVINCE_NAME = VCM.PROVINCE_EN
AND IC.AMPHUR_NAME  = VCM.AMPHUR_EN
AND IC.TAMBON_CD = VCM.TAMBON_EN
WHERE VCM.REC_END_DT = \'9999-12-31\'
AND VCM.ACCOUNT_TYPE_CD = 0
group by IC.WEEK_ID,VCM.AMPHUR_CD,VCM.TAMBON_CD,VCM.PROVINCE_CD
',
'step 3'
);


insert into aepdev.`aep_context_t3` ( `region` , `ctxarea` , `ctxjob` , `ctxkey` , `ctxval` , `remarks` )
values
(
'BKK',
'KPI',
'DWA_IC_CALLER_MONTHLY',
'stgqry4',
'
INSERT INTO ~SCHEMAVA~.DWA_IC_CALLER_MONTHLY_STG1
(
 NO_OF_IC_CALLER
,IC_OPERATOR
,MOST_USED_AMPHUR_CODE
,MOST_USED_TUMBON_CODE
,MOST_USED_PROVINCE_CODE
,PROCESS_NAME
,EXECUTION_ID
,REPORT_DATE
,REPORT_MONTH
,REPORT_YEAR
,LOAD_USER
,LOAD_DATE 
,DW_LAST_UPDATE_TIME
)
SELECT 
SUM(IC.NO_OF_TRUEMOVE_SUBSCRIBER*RATIO.TRUEMOVE_RATIO) AS NO_OF_IC_CALLER,
\'TRUE\' AS IC_OPERATOR,
VCM.AMPHUR_CD AS MOST_USED_AMPHUR_CODE,
VCM.TAMBON_CD AS MOST_USED_TUMBON_CODE,
VCM.PROVINCE_CD AS MOST_USED_PROVINCE_CODE,
null AS PROCESS_NAME,
~EXECUTIONID~               AS EXECUTION_ID,
IC.WEEK_ID AS REPORT_DATE,
DATE_PART(\'MONTH\', IC.WEEK_ID) AS REPORT_MONTH,
DATE_PART(\'YEAR\', IC.WEEK_ID) AS REPORT_YEAR,
null AS LOAD_USER,
null as LOAD_DATE,
null as DW_LAST_UPDATE_TIME
FROM
(SELECT     
WEEK_ID ,
TAMBON_NAME,
AMPHUR_NAME,
PROVINCE_NAME,
\'AIS\' AS OPERATOR_NAME,     
NO_OF_AIS_SUBSCRIBER
FROM ~SCHEMAVA~.USAGE_INTERCONNECT_CALLER_TAMBON_WEEKLY
WHERE  WEEK_ID  between <first week of the month> and <last week of the month>
AND PROVINCE_NAME NOT IN (\'NATIONWIDE\')
AND  NO_OF_AIS_SUBSCRIBER > 0
GROUP BY 
ROLLUP( WEEK_ID ,TAMBON_NAME,AMPHUR_NAME,PROVINCE_NAME,NO_OF_AIS_SUBSCRIBER)
union
SELECT     
WEEK_ID ,
TAMBON_NAME,
AMPHUR_NAME,
PROVINCE_NAME,
\'AIS\' AS OPERATOR_NAME,     
NO_OF_AIS_SUBSCRIBER
FROM ~SCHEMAVA~.USAGE_INTERCONNECT_CALLER_TAMBON_WEEKLY
WHERE  WEEK_ID  between <first week of the month> and <last week of the month>
AND PROVINCE_NAME IN (\'NATIONWIDE\')
AND  NO_OF_AIS_SUBSCRIBER > 0
GROUP BY 
ROLLUP( WEEK_ID ,TAMBON_NAME,AMPHUR_NAME,PROVINCE_NAME,NO_OF_AIS_SUBSCRIBER))IC
INNER JOIN ~SCHEMAVA~.USAGE_IC_TEMPLATE_RATIO_WEEKLY AS RATIO
ON IC.WEEK_ID = RATIO.WEEK_ID 
LEFT OUTER JOIN ~SCHEMAVA~.DIM_CLUSTER AS VCM
ON IC.PROVINCE_NAME = VCM.PROVINCE_EN
AND IC.AMPHUR_NAME  = VCM.AMPHUR_EN
AND IC.TAMBON_CD = VCM.TAMBON_EN
WHERE VCM.REC_END_DT = \'9999-12-31\'
AND VCM.ACCOUNT_TYPE_CD = 0
group by IC.WEEK_ID,VCM.AMPHUR_CD,VCM.TAMBON_CD,VCM.PROVINCE_CD
',
'step 4'
);


insert into aepdev.`aep_context_t3` ( `region` , `ctxarea` , `ctxjob` , `ctxkey` , `ctxval` , `remarks` )
values
(
'BKK',
'KPI',
'DWA_IC_CALLER_MONTHLY',
'stgqry5',
'
INSERT INTO ~SCHEMAVA~.DWA_IC_CALLER_MONTHLY_STG1
(
 NO_OF_IC_CALLER
,IC_OPERATOR
,MOST_USED_AMPHUR_CODE
,MOST_USED_TUMBON_CODE
,MOST_USED_PROVINCE_CODE
,PROCESS_NAME
,EXECUTION_ID
,REPORT_DATE
,REPORT_MONTH
,REPORT_YEAR
,LOAD_USER
,LOAD_DATE 
,DW_LAST_UPDATE_TIME
)
SELECT 
(SUM(IC.NO_OF_DTAC_SUBSCRIBER)  + SUM(IC.NO_OF_AIS_SUBSCRIBER*RATIO.AIS_RATIO) + SUM(IC.NO_OF_TRUEMOVE_SUBSCRIBER*RATIO.TRUEMOVE_RATIO)) AS NO_OF_IC_CALLER,
\'ALL\' AS IC_OPERATOR,
VCM.AMPHUR_CD AS MOST_USED_AMPHUR_CODE,
VCM.TAMBON_CD AS MOST_USED_TUMBON_CODE,
VCM.PROVINCE_CD AS MOST_USED_PROVINCE_CODE,
null AS PROCESS_NAME,
~EXECUTIONID~               AS EXECUTION_ID,
IC.WEEK_ID AS REPORT_DATE,
DATE_PART(\'MONTH\', IC.WEEK_ID) AS REPORT_MONTH,
DATE_PART(\'YEAR\', IC.WEEK_ID) AS REPORT_YEAR,
\'~LOADUSER~\'              AS LOAD_USER,
\'~LOADDATE~\'              AS LOAD_DATE,
\'~DWLASTUPDATETIME~\'      AS DW_LAST_UPDATE_TIME
FROM
(SELECT     
WEEK_ID ,
TAMBON_NAME,
AMPHUR_NAME,
PROVINCE_NAME,
\'AIS\' AS OPERATOR_NAME,     
NO_OF_AIS_SUBSCRIBER
FROM ~SCHEMAVA~.USAGE_INTERCONNECT_CALLER_TAMBON_WEEKLY
WHERE  WEEK_ID  between <first week of the month> and <last week of the month>
AND PROVINCE_NAME NOT IN (\'NATIONWIDE\')
AND  NO_OF_AIS_SUBSCRIBER > 0
GROUP BY 
ROLLUP( WEEK_ID ,TAMBON_NAME,AMPHUR_NAME,PROVINCE_NAME,NO_OF_AIS_SUBSCRIBER)
union
SELECT     
WEEK_ID ,
TAMBON_NAME,
AMPHUR_NAME,
PROVINCE_NAME,
\'AIS\' AS OPERATOR_NAME,     
NO_OF_AIS_SUBSCRIBER
FROM ~SCHEMAVA~.USAGE_INTERCONNECT_CALLER_TAMBON_WEEKLY
WHERE  WEEK_ID  between <first week of the month> and <last week of the month>
AND PROVINCE_NAME IN (\'NATIONWIDE\')
AND  NO_OF_AIS_SUBSCRIBER > 0
GROUP BY 
ROLLUP( WEEK_ID ,TAMBON_NAME,AMPHUR_NAME,PROVINCE_NAME,NO_OF_AIS_SUBSCRIBER))IC
INNER JOIN ~SCHEMAVA~.USAGE_IC_TEMPLATE_RATIO_WEEKLY AS RATIO
ON IC.WEEK_ID = RATIO.WEEK_ID 
LEFT OUTER JOIN ~SCHEMAVA~.DIM_CLUSTER AS VCM
ON IC.PROVINCE_NAME = VCM.PROVINCE_EN
AND IC.AMPHUR_NAME  = VCM.AMPHUR_EN
AND IC.TAMBON_CD = VCM.TAMBON_EN
WHERE VCM.REC_END_DT = \'9999-12-31\'
AND VCM.ACCOUNT_TYPE_CD = 0
group by IC.WEEK_ID,VCM.AMPHUR_CD,VCM.TAMBON_CD,VCM.PROVINCE_CD
',
'step 5'
);

insert into aepdev.`aep_context_t3` ( `region` , `ctxarea` , `ctxjob` , `ctxkey` , `ctxval` , `remarks` )
values
(
'BKK',
'KPI',
'DWA_IC_CALLER_MONTHLY',
'stgqry6',
'
INSERT INTO ~SCHEMAVA~.DWA_IC_CALLER_MONTHLY
SELECT
 NO_OF_IC_CALLER
,IC_OPERATOR
,MOST_USED_AMPHUR_CODE
,MOST_USED_TUMBON_CODE
,MOST_USED_PROVINCE_CODE
,PROCESS_NAME
,EXECUTION_ID
,REPORT_DATE
,REPORT_MONTH
,REPORT_YEAR
,LOAD_USER
,LOAD_DATE 
,DW_LAST_UPDATE_TIME
FROM ~SCHEMAVA~.DWA_IC_CALLER_MONTHLY_STG1
',
'step 6'
);


insert into aepdev.`aep_context_t3` ( `region` , `ctxarea` , `ctxjob` , `ctxkey` , `ctxval` , `remarks` )
values
(
'BKK',
'KPI',
'DWA_IC_CALLER_MONTHLY',
'stgtable1',
'~SCHEMAVA~.DWA_IC_CALLER_MONTHLY_stg1',
null
);


insert into aepdev.`aep_context_t3` ( `region` , `ctxarea` , `ctxjob` , `ctxkey` , `ctxval` , `remarks` )
values
(
'BKK',
'KPI',
'DWA_IC_CALLER_MONTHLY',
'stgtable2',
'~SCHEMAVA~.DWA_IC_CALLER_MONTHLY_stg1',
null
);


insert into aepdev.`aep_context_t3` ( `region` , `ctxarea` , `ctxjob` , `ctxkey` , `ctxval` , `remarks` )
values
(
'BKK',
'KPI',
'DWA_IC_CALLER_MONTHLY',
'stgtable3',
'~SCHEMAVA~.DWA_IC_CALLER_MONTHLY_stg1',
null
);


insert into aepdev.`aep_context_t3` ( `region` , `ctxarea` , `ctxjob` , `ctxkey` , `ctxval` , `remarks` )
values
(
'BKK',
'KPI',
'DWA_IC_CALLER_MONTHLY',
'stgtable4',
'~SCHEMAVA~.DWA_IC_CALLER_MONTHLY_stg1',
null
);


insert into aepdev.`aep_context_t3` ( `region` , `ctxarea` , `ctxjob` , `ctxkey` , `ctxval` , `remarks` )
values
(
'BKK',
'KPI',
'DWA_IC_CALLER_MONTHLY',
'stgtable5',
'~SCHEMAVA~.DWA_IC_CALLER_MONTHLY_stg1',
null
);

insert into aepdev.`aep_context_t3` ( `region` , `ctxarea` , `ctxjob` , `ctxkey` , `ctxval` , `remarks` )
values
(
'BKK',
'KPI',
'DWA_IC_CALLER_MONTHLY',
'stgtable6',
'~SCHEMAVA~.DWA_IC_CALLER_MONTHLY',
null
);

