%% demo_ts_diagram.m
% demo script for the itp-articuno library
% @eeshanbot

%% prep workspace
clear; clc; close all;

%% load ITP object
% note: since ITP can take a while to load, it is useful to check if it is
% already loaded at the beginning of a script that you may run often:
% 
% change "clear" to "clearvars -except ITP"
if ~exist('ITP','var')
    A = load('~/Code/itp-articuno/matlab-indexer/itp-indexed.mat');
    global ITP;
    ITP = A.ITP; clear A;
end

%% set time and spatial bounds

itp_latbox = [65 80];
itp_lonbox = [-150 -110];

t0 = datenum([2012 12 1 0 0 0]);
tf = datenum([2013 3 31 23 59 59]);

index = h_index_itp(itp_latbox,itp_lonbox,[t0 tf],20);
itpDomain = find(index == 1);


%% prep nicely if you want to do anything else
domainLat = [ITP(itpDomain).lat];
domainLon = [ITP(itpDomain).lon];
domainTimes = [ITP(itpDomain).time];

%% loop and plot
figure(1);
plot(NaN,NaN,'w');
hold on

for k = itpDomain
    
    % load ITP profiler
    [pressure,temperature,salinity,numObs] = itp_import_profiler_data(ITP(k).file,ITP(k).status);

    % simple TS curve
    scatter(salinity,temperature,25,pressure,'filled','MarkerFaceAlpha',0.05)
end
hold off

% visuals
colormap(parula(20));
cb = colorbar;
grid on

% labels
ylabel(cb,'depth [m]');
xlabel('salinity [psu]');
ylabel('temperature [degC]');