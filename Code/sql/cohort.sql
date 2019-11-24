DROP TABLE IF EXISTS rnn_cohort;
CREATE TABLE rnn_cohort AS
WITH cohort AS
(
  SELECT DISTINCT icu.hadm_id
    , icu.subject_id
    , icu.icustay_id
    , CASE WHEN pat.gender='M' THEN 1
        ELSE 0 END as is_male
    , CASE WHEN adm.ethnicity LIKE '%BLACK%' THEN 1
        ELSE 0 END AS is_black
    , round((CAST(adm.admittime AS DATE) - CAST(pat.dob AS DATE)) / 365.242, 4) AS age
    , icu.intime
    , icu.outtime
    , floor(extract(epoch from (icu.outtime - icu.intime))/60.0/60.0/24.0) AS length_of_stay
  FROM icustays icu
  INNER JOIN patients pat
    ON icu.subject_id = pat.subject_id
  INNER JOIN admissions adm
    ON icu.hadm_id = adm.hadm_id
  WHERE (icu.outtime - icu.intime) >= interval '2 day'
    AND adm.has_chartevents_data=1 
)
SELECT cohort.hadm_id
  , cohort.subject_id
  , cohort.icustay_id
  , cohort.is_male
  , cohort.is_black
  , cohort.age
  , cohort.intime
  , cohort.outtime
  , cohort.length_of_stay
FROM
  (
    SELECT hadm_id
      , MIN(intime) AS intime
    FROM cohort
    GROUP BY hadm_id
  ) hadm
LEFT JOIN cohort
  ON hadm.hadm_id = cohort.hadm_id AND hadm.intime = cohort.intime
WHERE cohort.age>=18
ORDER BY cohort.hadm_id;