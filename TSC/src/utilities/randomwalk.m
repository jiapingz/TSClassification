function r = randomwalk(n)
% r = random_walk(n)
% n: length of random walk time series
% 
% This is the continuous analog of symmetric random walk, each increment y(s+t)-y(s) is 
% Gaussian with distribution N(0,t^2) and increments over disjoint intervals are independent. 
% It is typically simulated as an approximating random walk in discrete time. 

sigma=1;
r=[0 cumsum(sigma.*randn(1,n-1))]; % standard Brownian motion 