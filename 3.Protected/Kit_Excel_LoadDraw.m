function Kit_Excel_LoadDraw

[dRawData, ~, ~] = xlsread('A股50ETF期权波动率指数_20180228.xlsm');

nDateLag = 693962;

dVixData = dRawData(:, [15, 16 : 18]);
dVixData(:, 1) = dVixData(:, 1) + nDateLag;
dLocated = isnan(dVixData(:, 1));
dVixData(dLocated, :) = [];
dVixData = [str2num(datestr(dVixData(:, 1), 'yyyymmdd')), ...
    str2num(datestr(dVixData(:, 1), 'hhMMss')),...
    dVixData(:, 2 : end)];

nFrequency = datenum([0, 0, 0, 0, 0, 1]);
dRealTimeVix(:, 1) = str2num(datestr([datenum([0 0 0 9 30 0]) : nFrequency : datenum([0 0 0 11 29 59]), ...
        datenum([0 0 0 13 00 0]) : nFrequency : datenum([0 0 0 14 59 59])], 'hhMMss'));
dRealTimeVix(:, 2 : 5) = nan;
dRealTimeVix(:, 6) = 1 : length(dRealTimeVix);

[~, dLocation_In, dLocation_Out] = intersect(dRealTimeVix(:, 1), dVixData(:, 2));
dRealTimeVix(dLocation_In, 2 : 4) = dVixData(dLocation_Out, 3 : 5);

% Plot
dLocated = ~isnan(dRealTimeVix(:, 2));
plot(dRealTimeVix(dLocated, 6), dRealTimeVix(dLocated, 2), 'Black', ...
    dRealTimeVix(dLocated, 6), dRealTimeVix(dLocated, 3), 'Red', ...
    dRealTimeVix(dLocated, 6), dRealTimeVix(dLocated, 4), 'Blue', ...
    'LineWidth', 1)
set(gca, 'XLim', [0, 14400])
set(gca, 'XTick', 0 : 1800 : 14400)
set(gca, 'XTickLabel', {'9:30:00','10:00:00','10:30:00','11:00:00','11:30:00','13:30:00','14:00:00','14:30:00','15:00:00'})
cLegend = {'Vix', 'Vxo_Call', 'Vxo_Put'};
legend(cLegend)
title('RealTime Vix Indexs')
saveas(gca, ['.\', 'RealTime Vix Indexs_', datestr(dVixData(1, 1), 'yyyy-mm-dd'), '.jpg'])
close

% Daily
load('dHistVixIndex')

dLocated = dHistVixIndex(:, 1) == datestr(dVixData(1, 1);
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

end
