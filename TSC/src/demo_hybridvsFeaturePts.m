%% ========================================================
% this demo shows difference between feature-point-based sampling
% and hybrid sampling
%   feature-point-based sampling -- sample ONLY from feature points
%   hybrid sampling -- sampling from both feature-rich and feature-less
%                      (flag) regions
%% ========================================================
configPath;
load('sampleTimeSeries.mat');

%% case one: feature-point-based sampling
findFeaturePoints(t2, 4);

%% case two: hybrid sampling
% [idx, marker] = findHybridPoints(sensordata, sel, stride);
[subsequencesIdx, markers] = findHybridPoints(t2, 4, 30);
plotHybridPts(t2, subsequencesIdx, markers);
   

 