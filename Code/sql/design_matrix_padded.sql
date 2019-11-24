DROP TABLE IF EXISTS rnn_design_matrix_padded;
CREATE TABLE rnn_design_matrix_padded AS
SELECT van_pad.hadm_id
  , van_pad.day
  , van_pad.van_flag
  , COALESCE(dem.is_male, 0) AS is_male
  , COALESCE(dem.is_black, 0) AS is_black
  , COALESCE(dem.age, 0) AS age
  , COALESCE(vital.heartrate, 0) AS heartrate
  , COALESCE(vital.sysbp, 0) AS sysbp
  , COALESCE(vital.diasbp, 0) AS diasbp
  , COALESCE(vital.meanbp, 0) AS meanbp
  , COALESCE(vital.resprate, 0) AS resprate
  , COALESCE(vital.tempc, 0) AS tempc
  , COALESCE(vital.spo2, 0) AS spo2
  , COALESCE(lab.aniongap, 0) AS aniongap
  , COALESCE(lab.albumin, 0) AS albumin
  , COALESCE(lab.bands, 0) AS bands
  , COALESCE(lab.bicarbonate, 0) AS bicarbonate
  , COALESCE(lab.bilirubin, 0) AS bilirubin
  , COALESCE(lab.creatinine, 0) AS creatinine
  , COALESCE(lab.chloride, 0) AS chloride
  , COALESCE(lab.glucose, 0) AS glucose
  , COALESCE(lab.hematocrit, 0) AS hematocrit
  , COALESCE(lab.hemoglobin, 0) AS hemoglobin
  , COALESCE(lab.lactate, 0) AS lactate
  , COALESCE(lab.platelet, 0) AS platelet
  , COALESCE(lab.potassium, 0) AS patassium
  , COALESCE(lab.ptt, 0) AS ptt
  , COALESCE(lab.inr, 0) AS inr
  , COALESCE(lab.pt, 0) AS pt
  , COALESCE(lab.sodium, 0) AS sodium
  , COALESCE(lab.bun, 0) AS bun
  , COALESCE(lab.wbc, 0) AS wbc
FROM rnn_van_label_padded van_pad
LEFT JOIN
  (
    SELECT van.hadm_id
      , van.day
      , co.is_male
      , co.is_black
      , co.age
    FROM rnn_van_label van
    LEFT JOIN rnn_cohort co
      ON van.hadm_id = co.hadm_id
  ) dem
  ON van_pad.hadm_id = dem.hadm_id AND van_pad.day = dem.day
LEFT JOIN rnn_vitals vital
  ON van_pad.hadm_id = vital.hadm_id AND van_pad.day = vital.day
LEFT JOIN rnn_labs lab
  ON van_pad.hadm_id = lab.hadm_id AND van_pad.day = lab.day
ORDER BY van_pad.hadm_id, van_pad.day;