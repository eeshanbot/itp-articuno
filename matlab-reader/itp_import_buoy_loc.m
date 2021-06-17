function [timestamp,lon,lat] = itp_import_buoy_loc(filename)

B = load(filename);

%% Allocate imported array to column variable names
year = B(:,1);
day = B(:,2);
lon = B(:,3);
lat = B(:,4);
buffer = zeros(size(year));
timestamp = datenum([year buffer day buffer buffer buffer]);
end



