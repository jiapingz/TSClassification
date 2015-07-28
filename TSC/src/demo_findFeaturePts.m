%% ========================================================
% findFeaturePoints(sensordata, sel);
% INPUTS: 
%          sensordata -- a row or column time series 
%          sel        -- a numeric values (>1)
%                     -- the larger it is, the more selective it is
%% ========================================================
configPath;
load('sampleTimeSeries.mat');

% case one: fewer feature points
findFeaturePoints(t1, 2);

% case two: more feature points
findFeaturePoints(t1, 5);
   

 