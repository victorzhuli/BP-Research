% 10/03/2017
%%%% CNN on sample data (from ppt)
addpath('/Users/lizhu/Dropbox/projects/Blood_Pressure/');
[ECG_seg, PPG_seg] = lz_segment_continuous;
%% filtering and down sample
new_srate = 100;
raw_srate = 10000;
locutoff = 0;    hicutoff = 50;
PPG_filt = eegfilt( PPG_seg', raw_srate, locutoff, hicutoff, size(PPG_seg,1), 500 ); PPG_filt = PPG_filt';
PPGd = resample(PPG_filt, new_srate, raw_srate);
%% check point - seg
tr2plot = 11;
figure(3); clf; subplot(211); plot(PPG_seg(:,tr2plot), 'b'); hold on; plot(PPG_filt(:,tr2plot), 'r') 
subplot(212); plot(PPGd(:,tr2plot)); xlim([1 size(PPGd,1)])
%% sliding window
w_ln = 9 * new_srate; w_st = .1 * new_srate; 
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
csvwrite('/Users/lizhu/Dropbox/projects/Blood_Pressure/PPGvg_9s.csv', PPGvg);
save('/Users/lizhu/Dropbox/projects/Blood_Pressure/PPGvg_9s.mat', 'PPGvg');

%%%%%% convert VG to .jpg and save
% load('/Users/lizhu/Dropbox/projects/Blood_Pressure/PPGvg_1p5s.mat')
load('/Users/lizhu/Dropbox/projects/Blood_Pressure/measure_BP'); % ground truth
SBP = measure_BP.SBP; DBP = measure_BP.DBP;
cd /Users/lizhu/Dropbox/projects/Blood_Pressure/VG_CNN/transfer_learning_inceptionv3/New-Simple-Inception-Transfer-Learning/VG_PPG_9s_train/
for iCat = 1: size(PPGvg, 4)
    
    for iWn = 1: size(PPGvg, 3)
        % naming convention: indWin_SBP_DBP
        imwrite(PPGvg(:,:,iWn,iCat), sprintf('VG_9s_%02d_%02d_%02d.jpg', iWn, SBP(iCat), DBP(iCat)),'jpg')
    end
end
%% check point - windowed seg
tr2plot = 11; win2plot = 101;
figure(5); clf; 
for iWin = 1:5
    subplot(4,5,iWin); imagesc(PPGvg(:,:,iWin,1)); colormap(gray);
    subplot(4,5,iWin+5); imagesc(PPGvg(:,:,iWin,20));
    subplot(4,5,iWin+10); imagesc(PPGvg(:,:,iWin,6));
    subplot(4,5,iWin+15); imagesc(PPGvg(:,:,iWin,12));
end

