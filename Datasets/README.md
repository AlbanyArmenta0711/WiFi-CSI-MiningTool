
 ## Subjects Directory
Subjects directory contains what I like to call RAW CSI, i.e., how data is directly obtained from the Linux 802.11n CSI Tool, CSI amplitude values, and accelerometer data per subject. 
Raw CSI files are in the directories named S#_RAW, amplitudes are in directories S#_CSI, and acc data in S#_GT. To obtain amplitude and phase values from Raw CSI you can use Daniel Halperin tools. 

## WithFeatures Directory 
WithFeatures dataset its already processed as described in the paper (Bandpass, hampel and SG filters) Each sample consists of the features exposed in the Github page under the Feature Extraction and Classification Model. Its important to highlight that it contains all of subjects information, which leads to have a dataset of dimensions 21596x162 (last column is the label). 
