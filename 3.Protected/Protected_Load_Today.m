function Protected_Load_Today
global dRealTimeVix

if exist('dHighFrequencyVixIndex', 'file')
    load('dHighFrequencyVixIndex')
    dLocated = dHighFrequencyVixIndex(:, 1) == cSetupPlatform.Date.NumStandard;
    dDataTemp = dHighFrequencyVixIndex(dLocated, 2 : end);
    
    for iIndex = 2 : 4
        dLocated = ~isnan(dDataTemp(:, iIndex));
        dTemp = dDataTemp(dLocated, [1, iIndex]);
        [~, dLocation_In, dLocation_Out] = intersect(dRealTimeVix(:, 1), dTemp(:, 1));
        dRealTimeVix(dLocation_In, iIndex) = dTemp(dLocation_Out, 2);
    end
else
end
end