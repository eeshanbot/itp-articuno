%% index_itp
% creates a mat file of relevant ITP properties for easier, searchable
% access later on

%% set path to ITP directory
itpFolders = dir('../data-local');
dirFlag = [itpFolders.isdir];
dirFlag(1:2) = 0; % removes . and .. as entries

% isolate folders only
itpFolders = itpFolders(dirFlag);
N = numel(itpFolders);

% overall structure - will be large
ITP = [];
k = 0;
for n = 1:N
    
    datFiles = dir([itpFolders(n).folder '/' itpFolders(n).name '/*grd*.dat']);
    M = numel(datFiles);
    
    if isempty(datFiles)
        fprintf('\n');
        warning('%s is empty',itpFolders(n).name);
    end
    
    tic
    for m = 1:M
        mCheck = ceil([0.1 0.3 0.5 0.7 0.9]*M);
        k = k+1;
        
        % assign ITP machine number
        eraseStr1 = ["final","grddata","itp"];
        itpNumStr = erase(itpFolders(n).name,eraseStr1);
        ITP(k).machine = itpNumStr;
        if m == 1
           fprintf('\n ITP %4s',itpNumStr);
        end
        
        % assign data "status" = final (tier3 data), grddata (tier2 data or tier1, but either way, not tier3)
        eraseStr2 = ["itp",itpNumStr];
        itpStatusStr = erase(itpFolders(n).name,eraseStr2);
        if strcmp(itpStatusStr,"final")
            ITP(k).status = 3;
        elseif strcmp(itpStatusStr,"grddata")
            ITP(k).status = 2;
        else
            ITP(k).status = 0;
            warning('ITP status = 0 @ %s', itpFolders(n).name);
        end
        
        % info extract from *profile*, not buoy
        info = itp_import_profiler_loc([datFiles(m).folder '/' datFiles(m).name]);
        
        % time
        ITP(k).time = datenum([info.year 0 info.day 0 0 0]);
        ITP(k).timestr = datestr(datenum([info.year 0 info.day 0 0 0]));
        
        % lat/lon
        ITP(k).lat = info.lat;
        ITP(k).lon = info.lon;
        
        % num observations
        ITP(k).numObs = info.obs;
        
        % print statement for progress
        if ismember(m,mCheck)
            fprintf(' .');
        end
        if m == M
            fprintf(' . . %d profiles', M)
        end
        
        % assign file
        ITP(k).file = [datFiles(m).folder '/' datFiles(m).name];
        
    end
    t = toc;
    fprintf(' in %2.2f s', t);
end

fprintf('\n');

% save usefully
clearvars -except ITP
save itp-indexed.mat