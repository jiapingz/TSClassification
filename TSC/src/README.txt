Time series classification pipeline

The code is tested under Linux, therefore it is directly runnable for Linux users. For windows users, first go to folders 'src – wavekit' and 'src – libsvm-3.18', and compile 'wavekit' and 'svm' packages separately.

Procedure to run the code:
1. change the current working directory to folder '../TSC/src';
2. download UCR time series datasets from “http://www.cs.ucr.edu/~eamonn/time_series_data/”, and place them into folder '../src/datasets';
3. run 'configPath.m' first to set path and global variables;
4. run our demo examples: 'demo_classification.m', 'demo_findFeaturePts.m', 'demo_hybridvsFeaturePts.m' and 'demo_HOG1Dscales.m';


