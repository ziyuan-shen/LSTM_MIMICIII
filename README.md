# LSTM_MIMICIII
> The project aims to employ LSTM to predict medical outcomes using MIMICIII dataset. Most work is based on [An attention based deep learning model of clinical events in the intensive care unit](https://doi.org/10.1371/journal.pone.0211057) and functions to produce similar results. Selection of features and model specifics may vary, though.

## Architecture

Repo architecture:

<details><summary>Code</summary><blockquote>
&nbsp;&nbsp;&nbsp;&nbsp;run_lstm_mimic.ipynb&nbsp;&nbsp;&nbsp;&nbsp;//LSTM model training
<details><summary>sql</summary>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;cohort.sql&nbsp;&nbsp;&nbsp;&nbsp;//extract cohort from icustays</br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;design_matrix_padded.sql&nbsp;&nbsp;&nbsp;&nbsp;//combine all features and labels to a design matrix that is padded to 14-day ICU stay</br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;labs.sql&nbsp;&nbsp;&nbsp;&nbsp;//extract laboratory features from labevents</br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;van_label_padded.sql&nbsp;&nbsp;&nbsp;&nbsp;//pad vancomycin receipt label to 14 days for each ICU stay</br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;van_label.sql&nbsp;&nbsp;&nbsp;&nbsp;//generate daily vancomycin receipt label</br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;vitals.sql&nbsp;&nbsp;&nbsp;&nbsp;//extract vital features from chartevents</br>
</details>
</blockquote></details>
<details><summary>Data</summary><blockquote>
rnn_cohort.csv<br/>
rnn_design_matrix_padded.csv<br/>
rnn_labs.csv<br/>
rnn_van_label_padded.csv<br/>
rnn_van_label.csv<br/>
rnn_vitals.csv<br/>
</blockquote></details>
.gitignore<br/>
README.md

## Getting Started

### Prerequisites

Dependencies required for the project:
<ul>
<li>Python 3.7.3</li>
<li>PostgreSQL 11.3</li>
</ul>

Python packages required:
<ul>
<li>psycopg2 2.8.4</li>
<li>NumPy 1.17.2</li>
<li>pandas 0.25.3</li>
<li>TensorFlow 2.0.0-rc10</li>
<li>Keras 2.2.4</li>
<li>scikit-learn 0.21.3</li>
<li>Matplotlib 3.1.1</li>
</ul>

### Setup

1. Set up MIMICIII dataset on a postgresql server. (Instruction is available at [https://github.com/MIT-LCP/mimic-code/tree/master/buildmimic/postgres](https://github.com/MIT-LCP/mimic-code/tree/master/buildmimic/postgres))

2. Clone the repo

```sh
git clone https://github.com/ziyuan-shen/LSTM_MIMICIII
```

3. Execute sql queries under `./Code/sql` to generate training data (Pay attention to execution order by table dependencies)

4. Run notebook `./Code/run_lstm_mimic.ipynb` to train the LSTM model

## Data

All the source data comes from the public MIMICIII dataset ([https://mimic.physionet.org/](https://mimic.physionet.org/)).

## Model

### Label

Vancomycin administration: daily receipt of any dose of vancomycin

### Preprocessing

* Individual patient ICU admissions 2 days or longer
    * First ICU stay is kept for each encounter (over 18 years old)
    * ICU stays more than 14 days are truncated to 14 days
    * ICU stays fewer than 14 days are padded with 0 (these days are masked out in LSTM model)
* Missing value imputation
    * Vital and lab missing values are filled out with corresponding normal value
* Numeric values are coded as daily average values
* Categorical variables are coded as indicators

### Feature Engineering

&nbsp;| No. | Info.
--- | --- | ---
Encounter | 27129 | individual ICU stay
Demographics | 3 | is_male, is_black, age
Vitals | 7 | heart rate, bp, resp rate, temperature, etc
Labs | 19 | albumin, bands, creatinine, glucose, etc

## Contact

Ziyuan Shen - ziyuan.shen@duke.edu

## Reference

Part of the sql queries to extract laboratory and vital data references the repo [here](https://github.com/alistairewj/mortality-prediction). Attention layer function references the repo [here](https://github.com/deepak-kaji/mimic-lstm).