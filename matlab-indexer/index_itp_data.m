%% index_itp
% creates a mat file of relevant ITP properties for easier, searchable
% access later on

%% set path to ITP directory
itpFolders = dir('~/Code/itp-articuno/itp-data');
dirFlag = [itpFolders.isdir];
dirFlag(1:2) = 0; % removes . and .. as entries

% isolate folders only
itpFolders = itpFolders(dirFlag);
NF = numel(itpFolders);

%% loop through N files to make final list between *final and *grddata
for nf = 1:NF
    itpNum{nf} = erase(itpFolders(nf).name,["final","grddata"]);
end

% empty count
count = 0;

for nf = 1:NF
    
    % check to see how many copies there are
    listBool = strcmpi(itpNum{nf},itpNum);
    fCount = sum(listBool);
    
    % only grddata exists
    if fCount == 1
        count = count + 1;
        itpList{count} = [itpNum{nf} 'grddata'];
    elseif fCount == 2
        count = count + 1;
        itpList{count} = [itpNum{nf} 'final'];
    end
end

itpList = unique(itpList);

%% make ITP struct

% overall structure - will be large
ITP = [];
N = numel(itpList);
k = 0;

for n = 1:N
    
    datFiles = dir([itpFolders(n).folder '/' itpList{n} '/*grd*.dat']);
    
    if isempty(datFiles)
        fprintf('\n');
        warning('%s is empty',itpList{n});
        
        % try other thing for funsies
        temp = itpList{n};
        cc = contains(temp,'f');
        if cc
            temp2 = split(temp,'f');
            check = [temp2{1} 'grddata'];
        else
            temp2 = split(temp,'g');
            check = [temp2{1} 'final'];
        end
        
        datFiles = dir([itpFolders(n).folder '/' check '/*grd*.dat']);

        if isempty(datFiles)
            warning('%s is also empty!',check);
        end
    end
    
    tic
    M = numel(datFiles);
    for m = 1:M
        mCheck = ceil([0.1 0.3 0.5 0.7 0.9]*M);
        k = k+1;
        
        % assign ITP machine number
        eraseStr1 = ["final","grddata","itp"];
        itpNumStr = erase(itpList{n},eraseStr1);
        ITP(k).machine = itpNumStr;
        if m == 1
           fprintf('\n ITP %4s',itpNumStr);
        end
        
        % assign data "status" = final (tier3 data), grddata (tier2 data or tier1, but either way, not tier3)
        eraseStr2 = ["itp",itpNumStr];
        itpStatusStr = erase(itpList{n},eraseStr2);
        if strcmp(itpStatusStr,"final")
            ITP(k).status = 3;
        elseif strcmp(itpStatusStr,"grddata")
            ITP(k).status = 2;
        else
            ITP(k).status = 0;
            warning('ITP status = 0 @ %s', itpList{n});
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