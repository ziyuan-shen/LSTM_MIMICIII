DROP TABLE IF EXISTS rnn_labs;
CREATE TABLE rnn_labs AS
WITH processed_lab AS
(
    SELECT lab.hadm_id
        , lab.day
        , avg(CASE WHEN lab.lab_name = 'ANION GAP' THEN valuenum ELSE null END) as ANIONGAP
        , avg(CASE WHEN lab.lab_name = 'ALBUMIN' THEN valuenum ELSE null END) as ALBUMIN
        , avg(CASE WHEN lab.lab_name = 'BANDS' THEN valuenum ELSE null END) as BANDS
        , avg(CASE WHEN lab.lab_name = 'BICARBONATE' THEN valuenum ELSE null END) as BICARBONATE
        , avg(CASE WHEN lab.lab_name = 'BILIRUBIN' THEN valuenum ELSE null END) as BILIRUBIN
        , avg(CASE WHEN lab.lab_name = 'CREATININE' THEN valuenum ELSE null END) as CREATININE
        , avg(CASE WHEN lab.lab_name = 'CHLORIDE' THEN valuenum ELSE null END) as CHLORIDE
        , avg(CASE WHEN lab.lab_name = 'GLUCOSE' THEN valuenum ELSE null END) as GLUCOSE
        , avg(CASE WHEN lab.lab_name = 'HEMATOCRIT' THEN valuenum ELSE null END) as HEMATOCRIT
        , avg(CASE WHEN lab.lab_name = 'HEMOGLOBIN' THEN valuenum ELSE null END) as HEMOGLOBIN
        , avg(CASE WHEN lab.lab_name = 'LACTATE' THEN valuenum ELSE null END) as LACTATE
        , avg(CASE WHEN lab.lab_name = 'PLATELET' THEN valuenum ELSE null END) as PLATELET
        , avg(CASE WHEN lab.lab_name = 'POTASSIUM' THEN valuenum ELSE null END) as POTASSIUM
        , avg(CASE WHEN lab.lab_name = 'PTT' THEN valuenum ELSE null END) as PTT
        , avg(CASE WHEN lab.lab_name = 'INR' THEN valuenum ELSE null END) as INR
        , avg(CASE WHEN lab.lab_name = 'PT' THEN valuenum ELSE null END) as PT
        , avg(CASE WHEN lab.lab_name = 'SODIUM' THEN valuenum ELSE null end) as SODIUM
        , avg(CASE WHEN lab.lab_name = 'BUN' THEN valuenum ELSE null end) as BUN
        , avg(CASE WHEN lab.lab_name = 'WBC' THEN valuenum ELSE null end) as WBC
    FROM
      (
        SELECT le.hadm_id
            , ceil(extract(EPOCH from le.charttime-co.intime)/60.0/60.0/24.0)::smallint AS day
        -- here we assign labels to ITEMIDs
        -- this also fuses together multiple ITEMIDs containing the same data
            , CASE
                WHEN itemid = 50868 THEN 'ANION GAP'
                WHEN itemid = 50862 THEN 'ALBUMIN'
                WHEN itemid = 51144 THEN 'BANDS'
                WHEN itemid = 50882 THEN 'BICARBONATE'
                WHEN itemid = 50885 THEN 'BILIRUBIN'
                WHEN itemid = 50912 THEN 'CREATININE'
                -- exclude blood gas
                -- WHEN itemid = 50806 THEN 'CHLORIDE'
                WHEN itemid = 50902 THEN 'CHLORIDE'
                -- exclude blood gas
                -- WHEN itemid = 50809 THEN 'GLUCOSE'
                WHEN itemid = 50931 THEN 'GLUCOSE'
                -- exclude blood gas
                --WHEN itemid = 50810 THEN 'HEMATOCRIT'
                WHEN itemid = 51221 THEN 'HEMATOCRIT'
                -- exclude blood gas
                --WHEN itemid = 50811 THEN 'HEMOGLOBIN'
                WHEN itemid = 51222 THEN 'HEMOGLOBIN'
                WHEN itemid = 50813 THEN 'LACTATE'
                WHEN itemid = 51265 THEN 'PLATELET'
                -- exclude blood gas
                -- WHEN itemid = 50822 THEN 'POTASSIUM'
                WHEN itemid = 50971 THEN 'POTASSIUM'
                WHEN itemid = 51275 THEN 'PTT'
                WHEN itemid = 51237 THEN 'INR'
                WHEN itemid = 51274 THEN 'PT'
                -- exclude blood gas
                -- WHEN itemid = 50824 THEN 'SODIUM'
                WHEN itemid = 50983 THEN 'SODIUM'
                WHEN itemid = 51006 THEN 'BUN'
                WHEN itemid = 51300 THEN 'WBC'
                WHEN itemid = 51301 THEN 'WBC'
            ELSE null END AS lab_name
            , -- add in some sanity checks on the values
            -- the where clause below requires all valuenum to be > 0, so these are only upper limit checks
            CASE
                WHEN itemid = 50862 and valuenum >    10 THEN null -- g/dL 'ALBUMIN'
                WHEN itemid = 50868 and valuenum > 10000 THEN null -- mEq/L 'ANION GAP'
                WHEN itemid = 51144 and valuenum <     0 THEN null -- immature band forms, %
                WHEN itemid = 51144 and valuenum >   100 THEN null -- immature band forms, %
                WHEN itemid = 50882 and valuenum > 10000 THEN null -- mEq/L 'BICARBONATE'
                WHEN itemid = 50885 and valuenum >   150 THEN null -- mg/dL 'BILIRUBIN'
                WHEN itemid = 50806 and valuenum > 10000 THEN null -- mEq/L 'CHLORIDE'
                WHEN itemid = 50902 and valuenum > 10000 THEN null -- mEq/L 'CHLORIDE'
                WHEN itemid = 50912 and valuenum >   150 THEN null -- mg/dL 'CREATININE'
                WHEN itemid = 50809 and valuenum > 10000 THEN null -- mg/dL 'GLUCOSE'
                WHEN itemid = 50931 and valuenum > 10000 THEN null -- mg/dL 'GLUCOSE'
                WHEN itemid = 50810 and valuenum >   100 THEN null -- % 'HEMATOCRIT'
                WHEN itemid = 51221 and valuenum >   100 THEN null -- % 'HEMATOCRIT'
                WHEN itemid = 50811 and valuenum >    50 THEN null -- g/dL 'HEMOGLOBIN'
                WHEN itemid = 51222 and valuenum >    50 THEN null -- g/dL 'HEMOGLOBIN'
                WHEN itemid = 50813 and valuenum >    50 THEN null -- mmol/L 'LACTATE'
                WHEN itemid = 51265 and valuenum > 10000 THEN null -- K/uL 'PLATELET'
                WHEN itemid = 50822 and valuenum >    30 THEN null -- mEq/L 'POTASSIUM'
                WHEN itemid = 50971 and valuenum >    30 THEN null -- mEq/L 'POTASSIUM'
                WHEN itemid = 51275 and valuenum >   150 THEN null -- sec 'PTT'
                WHEN itemid = 51237 and valuenum >    50 THEN null -- 'INR'
                WHEN itemid = 51274 and valuenum >   150 THEN null -- sec 'PT'
                WHEN itemid = 50824 and valuenum >   200 THEN null -- mEq/L == mmol/L 'SODIUM'
                WHEN itemid = 50983 and valuenum >   200 THEN null -- mEq/L == mmol/L 'SODIUM'
                WHEN itemid = 51006 and valuenum >   300 THEN null -- 'BUN'
                WHEN itemid = 51300 and valuenum >  1000 THEN null -- 'WBC'
                WHEN itemid = 51301 and valuenum >  1000 THEN null -- 'WBC'
            ELSE le.valuenum END AS valuenum
        FROM rnn_cohort co
        INNER JOIN labevents le
            ON co.hadm_id = le.hadm_id
        WHERE le.ITEMID in
          (
            -- comment is: LABEL | CATEGORY | FLUID | NUMBER OF ROWS IN LABEVENTS
            50868, -- ANION GAP | CHEMISTRY | BLOOD | 769895
            50862, -- ALBUMIN | CHEMISTRY | BLOOD | 146697
            51144, -- BANDS - hematology
            50882, -- BICARBONATE | CHEMISTRY | BLOOD | 780733
            50885, -- BILIRUBIN, TOTAL | CHEMISTRY | BLOOD | 238277
            50912, -- CREATININE | CHEMISTRY | BLOOD | 797476
            50902, -- CHLORIDE | CHEMISTRY | BLOOD | 795568
            -- 50806, -- CHLORIDE, WHOLE BLOOD | BLOOD GAS | BLOOD | 48187
            50931, -- GLUCOSE | CHEMISTRY | BLOOD | 748981
            -- 50809, -- GLUCOSE | BLOOD GAS | BLOOD | 196734
            51221, -- HEMATOCRIT | HEMATOLOGY | BLOOD | 881846
            -- 50810, -- HEMATOCRIT, CALCULATED | BLOOD GAS | BLOOD | 89715
            51222, -- HEMOGLOBIN | HEMATOLOGY | BLOOD | 752523
            -- 50811, -- HEMOGLOBIN | BLOOD GAS | BLOOD | 89712
            50813, -- LACTATE | BLOOD GAS | BLOOD | 187124
            51265, -- PLATELET COUNT | HEMATOLOGY | BLOOD | 778444
            50971, -- POTASSIUM | CHEMISTRY | BLOOD | 845825
            -- 50822, -- POTASSIUM, WHOLE BLOOD | BLOOD GAS | BLOOD | 192946
            51275, -- PTT | HEMATOLOGY | BLOOD | 474937
            51237, -- INR(PT) | HEMATOLOGY | BLOOD | 471183
            51274, -- PT | HEMATOLOGY | BLOOD | 469090
            50983, -- SODIUM | CHEMISTRY | BLOOD | 808489
            -- 50824, -- SODIUM, WHOLE BLOOD | BLOOD GAS | BLOOD | 71503
            51006, -- UREA NITROGEN | CHEMISTRY | BLOOD | 791925
            51301, -- WHITE BLOOD CELLS | HEMATOLOGY | BLOOD | 753301
            51300  -- WBC COUNT | HEMATOLOGY | BLOOD | 2371
          )
        AND valuenum IS NOT null
        AND valuenum > 0 -- lab values cannot be 0 and cannot be negative
        AND le.charttime >= co.intime
        AND le.charttime <= co.outtime  
      ) lab
    GROUP BY lab.hadm_id, lab.day
    ORDER BY lab.hadm_id, lab.day
)
SELECT van.hadm_id
  , van.day
  -- fill missing values with normal values
  , CASE WHEN pro.aniongap IS NOT NULL THEN pro.aniongap
      ELSE 10 END AS aniongap
  , CASE WHEN pro.albumin IS NOT NULL THEN pro.albumin
      ELSE 4.4 END AS albumin
  , CASE WHEN pro.bands IS NOT NULL THEN pro.bands
      ELSE 10 END AS bands
  , CASE WHEN pro.bicarbonate IS NOT NULL THEN pro.bicarbonate
      ELSE 26.5 END AS bicarbonate
  , CASE WHEN pro.bilirubin IS NOT NULL THEN pro.bilirubin
      ELSE 0.65 END AS bilirubin
  , CASE WHEN pro.creatinine IS NOT NULL THEN pro.creatinine
      ELSE 0.9 END AS creatinine
  , CASE WHEN pro.chloride IS NOT NULL THEN pro.chloride
      ELSE 101 END AS chloride
  , CASE WHEN pro.glucose IS NOT NULL THEN pro.glucose
      ELSE 85.5 END AS glucose
  , CASE WHEN pro.hematocrit IS NOT NULL THEN pro.hematocrit
      ELSE 42.5 END AS hematocrit
  , CASE WHEN pro.hemoglobin IS NOT NULL THEN pro.hemoglobin
      ELSE 13.75 END AS hemoglobin
  , CASE WHEN pro.lactate IS NOT NULL THEN pro.lactate
      ELSE 0.75 END AS lactate
  , CASE WHEN pro.platelet IS NOT NULL THEN pro.platelet
      ELSE 300 END AS platelet
  , CASE WHEN pro.potassium IS NOT NULL THEN pro.potassium
      ELSE 4.25 END AS potassium
  , CASE WHEN pro.ptt IS NOT NULL THEN pro.ptt
      ELSE 65 END AS ptt
  , CASE WHEN pro.inr IS NOT NULL THEN pro.inr
      ELSE 1.1 END AS inr
  , CASE WHEN pro.pt IS NOT NULL THEN pro.pt
      ELSE 12.25 END AS pt
  , CASE WHEN pro.sodium IS NOT NULL THEN pro.sodium
      ELSE 140 END AS sodium
  , CASE WHEN pro.bun IS NOT NULL THEN pro.bun
      ELSE 13.5 END AS bun
  , CASE WHEN pro.wbc IS NOT NULL THEN pro.wbc
      ELSE 7.5 END AS wbc
FROM rnn_van_label van
LEFT JOIN processed_lab pro
  ON van.hadm_id = pro.hadm_id AND van.day = pro.day;