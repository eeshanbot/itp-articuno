%% index_itp_rawlocs
% creates a look up table for ITP raw locations that can be easily accessed

%% set path to ITP directory
clear; clc;

itpRawLocs = dir('~/Code/itp-articuno/itp-data/*rawlocs.dat');
N = numel(itpRawLocs);

%% loop through itpFolders
for n = 1:N
    
    str = itpRawLocs(n).name;
    erasestr = ["rawlocs.dat","itp"];
    strKey{n} = erase(str,erasestr);
    
    strFilePath{n} = [itpRawLocs(n).folder '/' itpRawLocs(n).name];
    
end

%% make map

mapRawLocs = containers.Map(strKey,strFilePath);
clearvars -except mapRawLocs
save itp-mapRawLocs