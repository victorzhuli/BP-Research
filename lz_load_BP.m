function PPG_seg = lz_load_BP(file_idx)

%%%% load raw data
%%%% input  - file_idx: 1 or 2, index of the dataset
%%%% output - raw PPG signals, number_time_points x number_trials

% sampling rate
srate = 10000;
len_trial = 12*srate; % length of trial (12 seconds)

if file_idx == 1
    num_sess = 2; % number of sessions
    % time of cuff inflation (s)
    timing_cuff{1} = [155 215 275 335 395 1280 1325 1370 1420 1470];
    timing_cuff{2} = [235 280 325 370 410 460 500 545 590 650];
elseif file_idx == 2
    num_sess = 4;
    % time of cuff inflation (s)
    timing_cuff{1} = [20 110 210 310 532 655 1270 1515 1580 1645 1710];
    timing_cuff{2} = [70 150 215 715 1325];
    timing_cuff{3} = [55 135 220];
    timing_cuff{4} = [145 210 255 350 1026 1110 1255 1330 1700];
end

sessFolder = sprintf('BP Files%d', file_idx);

% initiate
PPG_seg_stack_over_sess = cell(1, num_sess);
for iSess = 1 : num_sess
    sessName = sprintf('PPG%d', iSess);
    
    % load raw data
    if ispc
        
    elseif ismac
        load(['/Users/lizhu/Dropbox/Li-2017/BP Research/Data-082017/',sessFolder,'/mat_files/',sessName,'.mat']);
    elseif isunix
        load(['/home/lz206/Dropbox/Li-2017/BP Research/Data-082017/',sessFolder,'/mat_files/',sessName,'.mat']);
    end
    eval(['PPG = ',sessName,';']);
    
    % segment according to timing of cuff inflation
    num_tr = length(timing_cuff{iSess});
    
    % initiate
    PPG_seg_stack_over_sess{iSess} = nan(len_trial, num_tr); % 12 second for each trial
    
    for itr = 1: num_tr
        % index of cuff inflation
        ind = find( PPG(:,1) == timing_cuff{iSess}(itr) );
        PPG_seg_stack_over_sess{iSess}(:, itr) = PPG( ind-len_trial : ind-1   ,2);
    end
end

PPG_seg = cell2mat(PPG_seg_stack_over_sess);
