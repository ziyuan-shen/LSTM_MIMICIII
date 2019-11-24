DROP TABLE IF EXISTS rnn_vitals;
CREATE TABLE rnn_vitals AS
WITH processed_vital AS
(
    SELECT vital.icustay_id
      , vital.day
      , avg(HeartRate) as HeartRate
      , avg(SysBP) as SysBP
      , avg(DiasBP) as DiasBP
      , avg(MeanBP) as MeanBP
      , avg(RespRate) as RespRate
      , avg(TempC) as TempC
      , avg(SpO2) as SpO2
    FROM
    (
    SELECT co.icustay_id
        , ceil(extract(EPOCH from ce.charttime-co.intime)/60.0/60.0/24.0)::smallint AS day
        , (CASE WHEN itemid IN (211,220045) AND valuenum > 0 AND valuenum < 300 THEN valuenum ELSE NULL END) AS HeartRate
        , (CASE WHEN itemid IN (51,442,455,6701,220179,220050) AND valuenum > 0 AND valuenum < 400 THEN valuenum ELSE NULL END) AS SysBP
        , (CASE WHEN itemid IN (8368,8440,8441,8555,220180,220051) AND valuenum > 0 AND valuenum < 300 THEN valuenum ELSE NULL END) AS DiasBP
        , (CASE WHEN itemid IN (456,52,6702,443,220052,220181,225312) AND valuenum > 0 AND valuenum < 300 THEN valuenum ELSE NULL END) AS MeanBP
        , (CASE WHEN itemid IN (615,618,220210,224690) AND valuenum > 0 AND valuenum < 70 THEN valuenum ELSE NULL END) AS RespRate
        , (CASE WHEN itemid IN (223761,678) AND valuenum > 70 AND valuenum < 120 THEN (valuenum-32)/1.8 -- converted to degC in valuenum call
                WHEN itemid IN (223762,676) AND valuenum > 10 AND valuenum < 50 THEN valuenum ELSE NULL END) AS TempC
        , (CASE WHEN itemid IN (646,220277) AND valuenum > 0 AND valuenum <= 100 THEN valuenum ELSE NULL END) AS SpO2
    FROM rnn_cohort co
    INNER JOIN chartevents ce
        ON co.icustay_id = ce.icustay_id
    WHERE ce.error IS DISTINCT FROM 1
        AND ce.itemid IN
          (
            -- HEART RATE
            211, --"Heart Rate"
            220045, --"Heart Rate"

            -- Systolic/diastolic

            51, --	Arterial BP [Systolic]
            442, --	Manual BP [Systolic]
            455, --	NBP [Systolic]
            6701, --	Arterial BP #2 [Systolic]
            220179, --	Non Invasive Blood Pressure systolic
            220050, --	Arterial Blood Pressure systolic

            8368, --	Arterial BP [Diastolic]
            8440, --	Manual BP [Diastolic]
            8441, --	NBP [Diastolic]
            8555, --	Arterial BP #2 [Diastolic]
            220180, --	Non Invasive Blood Pressure diastolic
            220051, --	Arterial Blood Pressure diastolic

            -- MEAN ARTERIAL PRESSURE
            456, --"NBP Mean"
            52, --"Arterial BP Mean"
            6702, --	Arterial BP Mean #2
            443, --	Manual BP Mean(calc)
            220052, --"Arterial Blood Pressure mean"
            220181, --"Non Invasive Blood Pressure mean"
            225312, --"ART BP mean"

            -- RESPIRATORY RATE
            618,--	Respiratory Rate
            615,--	Resp Rate (Total)
            220210,--	Respiratory Rate
            224690, --	Respiratory Rate (Total)

            -- SPO2, peripheral
            646, 220277,

            -- GLUCOSE, both lab and fingerstick
            --807,--	Fingerstick Glucose
            --811,--	Glucose (70-105)
            --1529,--	Glucose
            --3745,--	BloodGlucose
            --3744,--	Blood Glucose
            --225664,--	Glucose finger stick
            --220621,--	Glucose (serum)
            --226537,--	Glucose (whole blood)

            -- TEMPERATURE
            223762, -- "Temperature Celsius"
            676,	-- "Temperature C"
            223761, -- "Temperature Fahrenheit"
            678 --	"Temperature F"
          )
        AND ce.charttime >= co.intime
        AND ce.charttime <= co.outtime
    ) vital
    GROUP BY vital.icustay_id, vital.day
)
SELECT van.hadm_id
  , van.day
  , CASE WHEN pro.HeartRate IS NOT NULL THEN pro.HeartRate
      ELSE 80 END AS heartrate
  , CASE WHEN pro.SysBP IS NOT NULL THEN pro.SysBP
      ELSE 115 END AS sysbp
  , CASE WHEN pro.DiasBP IS NOT NULL THEN pro.DiasBP
      ELSE 70 END AS diasbp
  , CASE WHEN pro.MeanBP IS NOT NULL THEN pro.MeanBP
      ELSE 85 END AS meanbp
  , CASE WHEN pro.RespRate IS NOT NULL THEN pro.RespRate
      ELSE 16 END AS resprate
  , CASE WHEN pro.TempC IS NOT NULL THEN pro.TempC
      ELSE 37 END AS tempc
  , CASE WHEN pro.SpO2 IS NOT NULL THEN pro.SpO2
      ELSE 97.5 END AS spo2
FROM rnn_van_label van
LEFT JOIN processed_vital pro
  ON van.icustay_id = pro.icustay_id AND van.day = pro.day
ORDER BY van.hadm_id, van.day;