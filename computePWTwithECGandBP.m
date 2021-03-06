function [ pwtPeak, pwtValley, pwtKey, pwtRise, hr, fig, hasError ] = computePWTwithECGandBP( ecg, bp, ifplot, titleOfSignals )
%COMPUTEPWTWITHECGANDRAEND Summary of this function goes here
%   Detailed explanation goes here


%% 步骤1：滤波
bp = sigfilter(bp);
ecg = sigfilter(ecg);

%% 步骤2：检测R波波峰，计算心率
[ecg_peak, hr]=HR_detection(ecg);

%% 步骤3：提取脉搏波关键点
[bp_peak, bp_valley, bp_key, bp_rise]= detectPeaksInPulseWave(bp);

%% 步骤4：计算pwt,并验证是否排除了太多点
[pwtPeak, ~, bp_peak_used] = compute_pwtt(ecg_peak, bp_peak, 100, 400);
[pwtValley, ~, bp_valley_used] = compute_pwtt(ecg_peak, bp_valley, 50, 400);
[pwtKey, ecg_peak_used, bp_key_used] = compute_pwtt(ecg_peak, bp_key, 50, 400);
[pwtRise, bp_valley_used1, bp_peak_used1] = compute_pwtt(bp_valley, bp_peak, 10, 200);

%% 步骤5：验证步骤4是否排除了太多点
isTrue = 0;
isTrue = isTrue || isTooManyPeaksRemoved({ecg_peak, bp_peak}, {ecg_peak_used, bp_peak_used});
isTrue = isTrue || isTooManyPeaksRemoved({ecg_peak, pwtValley}, {ecg_peak_used, bp_valley_used});
isTrue = isTrue || isTooManyPeaksRemoved({ecg_peak, bp_key}, {ecg_peak_used, bp_key_used});
isTrue = isTrue || isTooManyPeaksRemoved({bp_valley, bp_peak}, {bp_valley_used1, bp_peak_used1});
hasError = isTrue;

%% 步骤6：根据需要画图
if ifplot || isTrue
    fig = figure('Name', titleOfSignals);
    subplot(211), drawSignalPeaksAndPeaksUsed(ecg, {ecg_peak}, {ecg_peak_used}, 'r');
    subplot(212), drawSignalPeaksAndPeaksUsed(bp, {bp_peak, bp_valley, bp_key}, ...
        {bp_peak_used, bp_valley_used, bp_key_used}, 'b');
else
    fig = 0;
end

%% 步骤7：去除统计异常点
pwtPeak = removeOutlier(pwtPeak, 2, 10);
pwtValley = removeOutlier(pwtValley, 2, 10);
pwtKey = removeOutlier(pwtKey, 2, 10);
pwtRise = removeOutlier(pwtRise, 2, 10);



end

