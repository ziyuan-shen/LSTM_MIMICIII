DROP TABLE IF EXISTS rnn_van_label_padded;
CREATE TABLE rnn_van_label_padded AS
SELECT pad.hadm_id
  , pad.day
  , CASE WHEN van.van_flag IS NOT NULL THEN van.van_flag
      ELSE 0 END AS van_flag
FROM
(
  SELECT hadm_id
    , generate_series(1, 14) AS day
  FROM rnn_cohort
) pad
LEFT JOIN rnn_van_label van
  ON pad.hadm_id = van.hadm_id AND pad.day = van.day
ORDER BY pad.hadm_id, pad.day;