function Protected_Save_Data
global cSetupPlatform
global dRealTimeVix

% Full Package Backup
cd(cSetupPlatform.Dir.Data)
save(['VixData_Backup_', cSetupPlatform.Date.StrStandard, '_', num2str(cSetupPlatform.Date.Now)])

% HF Vix Index
if exist('dHighFrequencyVixIndex', 'file')
    load('dHighFrequencyVixIndex')
    
    if dHighFrequencyVixIndex(end, 1) ~= cSetupPlatform.Date.NumStandard
        dDataTemp(:, 2) = dRealTimeVix(:, 1);
        dDataTemp(:, 1) = cSetupPlatform.Date.NumStandard;
        dDataTemp(:, 3 : 5) = Fun_Screen_Data(dRealTimeVix(:, 2 : 4));
        dHighFrequencyVixIndex = [dHighFrequencyVixIndex; dDataTemp];
        
    else
        dDataTemp(:, 2) = dRealTimeVix(:, 1);
        dDataTemp(:, 1) = cSetupPlatform.Date.NumStandard;
        dDataTemp(:, 3 : 5) = dRealTimeVix(:, 2 : 4);
        
        for iIndex = 3 : 5
            dLocated = ~isnan(dDataTemp(:, iIndex));
            dTemp = dDataTemp(dLocated, [2, iIndex]);
            [~, dLocation_In, dLocation_Out] = intersect(dHighFrequencyVixIndex(:, 2), dTemp(:, 1));
            dHighFrequencyVixIndex(dLocation_In, iIndex) = dTemp(dLocation_Out, 2);
        end
    end

else
    dHighFrequencyVixIndex(:, 2) = dRealTimeVix(:, 1);
    dHighFrequencyVixIndex(:, 1) = cSetupPlatform.Date.NumStandard;
    dHighFrequencyVixIndex(:, 3 : 5) = Fun_Screen_Data(dRealTimeVix(:, 2 : 4));

end
save('dHighFrequencyVixIndex', 'dHighFrequencyVixIndex')

% Plot
dLocated = ~isnan(dRealTimeVix(:, 2));
plot(dRealTimeVix(dLocated, 6), dRealTimeVix(dLocated, 2), 'Black', ...
    dRealTimeVix(dLocated, 6), dRealTimeVix(dLocated, 3), 'Red', ...
    dRealTimeVix(dLocated, 6), dRealTimeVix(dLocated, 4), 'Blue', ...
    'LineWidth', 1.5)
set(gca, 'XLim', [0, 14400])
set(gca, 'XTick', 0 : 1800 : 14400)
set(gca, 'XTickLabel', {'9:30:00','10:00:00','10:30:00','11:00:00','11:30:00','13:30:00','14:00:00','14:30:00','15:00:00'})
cLegend = {'Vix', 'Vxo_Call', 'Vxo_Put'};
legend(cLegend)
title('RealTime Vix Indexs')
saveas(gca, [cSetupPlatform.Dir.Pic, '\', 'RealTime Vix Indexs_', cSetupPlatform.Date.StrStandard, '.jpg'])
close

% Daily
load('dHistVixIndex')

dLocated = dHistVixIndex(:, 1) == cSetupPlatform.Date.NumStandard;
if sum(dLocated)
    dHistVixIndex(dLocated, 2) = dRealTimeVix(1, 2);
    dHistVixIndex(dLocated, 3) = max(dRealTimeVix(:, 2));
    dHistVixIndex(dLocated, 4) = min(dRealTimeVix(:, 2));
    dHistVixIndex(dLocated, 5) = dRealTimeVix(end, 2);
else
    dHistVixIndex(end + 1, 2) = dRealTimeVix(1, 2);
    dHistVixIndex(end, 3) = max(dRealTimeVix(:, 2));
    dHistVixIndex(end, 4) = min(dRealTimeVix(:, 2));
    dHistVixIndex(end, 5) = dRealTimeVix(end, 2);

end

dDate = datenum(num2str(dHistVixIndex(:, 1)), 'yyyymmdd');
candle(dHistVixIndex(:, 3), dHistVixIndex(:, 4), dHistVixIndex(:, 2), dHistVixIndex(:, 5), 'r')
dXTick = get(gca, 'XTick');
dXTick = dXTick(2 : end - 1);
cDate = cellstr(datestr(dDate(dXTick), 'yyyy-mm-dd'));
cDate = {[], cDate{:}, []};
set(gca, 'XTickLabel', cDate)
title('Daily Vix Indexs')
saveas(gca, [cSetupPlatform.Dir.Pic, '\', 'Daily Vix Indexs.jpg'])
close

cd(cSetupPlatform.Dir.Home)
end

function dData2Screen = Fun_Screen_Data(dData2Screen)

for iIndex = 1 : size(dData2Screen, 2)
    dLocation_Start = find(~isnan(dData2Screen(:, iIndex)), 1, 'first');
    dLocation_End = find(~isnan(dData2Screen(:, iIndex)), 1, 'last');
    for iMinute = dLocation_Start : dLocation_End
        if ~isnan(dData2Screen(iMinute, iIndex))
        else
            dData2Screen(iMinute, iIndex) = dData2Screen(iMinute - 1, iIndex);
        end
    end
end
end


