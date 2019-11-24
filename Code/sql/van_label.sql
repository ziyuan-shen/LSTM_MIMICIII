DROP TABLE IF EXISTS rnn_van_label;
CREATE TABLE rnn_van_label AS
SELECT co_day.hadm_id
  , co_day.icustay_id
  , co_day.day
  , CASE WHEN van.van_day IS NULL THEN 0
      ELSE 1 END AS van_flag
FROM
(
  SELECT hadm_id
    , icustay_id
    , length_of_stay
    , generate_series(1, length_of_stay::INTEGER) AS day
  FROM rnn_cohort
) co_day
LEFT JOIN
(
  SELECT DISTINCT co.icustay_id
    , generate_series(
        ceil(extract(epoch from (pr.startdate - co.intime))/60.0/60.0/24.0)::INTEGER, 
        ceil(extract(epoch from (pr.enddate - co.intime))/60.0/60.0/24.0)::INTEGER) AS van_day
  FROM rnn_cohort co
  LEFT JOIN prescriptions pr
    ON co.icustay_id = pr.icustay_id
  WHERE pr.drug = 'Vancomycin'
    AND pr.startdate >= co.intime
    AND pr.startdate < co.outtime
) van
  ON co_day.icustay_id = van.icustay_id AND co_day.day = van.van_day
WHERE (van.van_day <= co_day.length_of_stay OR van.van_day IS NULL)
-- trunctate ICU stay after 14th day
  AND co_day.day <= 14
ORDER BY co_day.hadm_id;