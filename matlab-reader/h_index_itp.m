%% helper function: ITP index
function [index] = h_index_itp(latbounds,lonbounds,timebounds,numObs)
global ITP;

index1 = [ITP.lat] > min(latbounds) & [ITP.lat] < max(latbounds);
index2 = [ITP.lon] > min(lonbounds) & [ITP.lon] < max(lonbounds);
index3 = [ITP.time] > min(timebounds) & [ITP.time] < max(timebounds);
index4 = [ITP.numObs] > numObs;

index = logical(index1 .* index2 .* index3 .* index4);
end