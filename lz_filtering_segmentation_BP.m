function [train_data_x,train_data_y, test_data_x, test_data_y] = lz_filtering_segmentation_BP(file_idx)

% 11/10/2017
% filtering, downsampling, training, testing  
%
%%%% file_idx: file index, 1 or 2

addpath(genpath('/Users/lizhu/Dropbox/projects/Blood_Pressure/'));
addpath('/Users/lizhu/Dropbox/projects/calcium/Figs4Paper');
%% load data
[PPG_seg, measure_BP] = lz_load_BP(file_idx);

%% filtering and down sample
new_srate = 100;
raw_srate = 10000;
locutoff = 0;    hicutoff = 50;
PPG_filt = eegfilt( PPG_seg', raw_srate, locutoff, hicutoff, size(PPG_seg,1), 500 ); PPG_filt = PPG_filt';
PPGd = resample(PPG_filt, new_srate, raw_srate);
clear raw_srate locutoff hicutoff 

%% segmentation
w_ln = 7 * new_srate; w_st = .1 * new_srate; 
num_win = (size(PPGd,1) - w_ln) / w_st + 1;
% initiate
PPGds = nan( w_ln, num_win, size(PPGd,2) ); % #win len x num of win x num of category
PPGvg = nan( w_ln, w_ln, num_win, size(PPGd,2) ); % #win len x #win len x num of win x num of category
for iCat = 1: size(PPGd, 2)
    parfor iWin = 1 : num_win
        PPGds(:, iWin, iCat) = PPGd( (iWin-1) * w_st + 1 : (iWin-1) * w_st + w_ln, iCat);
    end
    % vg building
    fprintf('Building VG for categary %01d ......\n', iCat);
    PPGvg(:, :, :, iCat) = lz_VG_build_2(PPGds(:, :, iCat));
end
csvwrite('/Users/lizhu/Dropbox/projects/Blood_Pressure/PPGvg_file2_7s.csv', PPGvg);
save('/Users/lizhu/Dropbox/projects/Blood_Pressure/PPGvg_file2_7s.mat', 'PPGvg');

%%%%%% convert VG to .jpg and save
% load('/Users/lizhu/Dropbox/projects/Blood_Pressure/PPGvg_1p5s.mat')
SBP = measure_BP.SBP; DBP = measure_BP.DBP;
cd /Users/lizhu/Dropbox/projects/Blood_Pressure/VG_CNN/transfer_learning_inceptionv3/New-Simple-Inception-Transfer-Learning/VG_PPG_file2_7s_train/
for iCat = 1: size(PPGvg, 4)
    
    for iWn = 1: size(PPGvg, 3)
        % naming convention: indWin_SBP_DBP
        imwrite(PPGvg(:,:,iWn,iCat), sprintf('VG_file2_7s_%02d_%02d_%02d.jpg', iWn, SBP(iCat), DBP(iCat)),'jpg')
    end
end

























