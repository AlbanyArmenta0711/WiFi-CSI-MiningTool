
 ## Subjects Directory
Subjects directory contains what I like to call RAW CSI, i.e., how data is directly obtained from the Linux 802.11n CSI Tool, CSI amplitude values, and accelerometer data per subject. 
CSV files containing timestamp, amplitude and phase can be found in the directories named S#_AMP_PHASE (1st field is a timestamp, followed by 90 amplitude values and 90 phase values). Amplitude only files are in directories S#_CSI, and acc data in S#_GT. 

## WithFeatures Directory 
WithFeatures dataset its already processed as described in the paper (Bandpass, hampel and SG filters) Each sample consists of the features exposed in the Github page under the Feature Extraction and Classification Model. Its important to highlight that it contains all of subjects information, which leads to have a dataset of dimensions 21596x162 (last column is the label). 
