clc
clear all
w = windmatlab;
% w.menu;
% 


cOptionDate = w_wset_data;

cOptionDate(:, 2 : 3) = num2cell(cellfun(@(x) str2double(datestr(datenum(x, 'yyyy.mm.dd'), 'yyyymmdd')), cOptionDate(:, 2 : 3)));
cOptionDate(:, 1) = num2cell(cellfun(@(x) str2double(x), cOptionDate(:, 1)));
dOptionDate = cell2mat(cOptionDate);
dLocated = dOptionDate(:, 3) >= 20180214;
dOptionDate = dOptionDate(dLocated, :);

cOptionCode = arrayfun(@(x) [num2str(x), '.SH'], dOptionDate(:, 1), 'UniformOutput', 0);
sCode = [cOptionCode{:}];
sCode(end) = [];
sCode = ['510050.SH,', sCode];
cOptionCode = [{'510050.SH'}; cOptionCode];
for iCode = 1 : length(cOptionCode)
    sCode = cOptionCode{iCode};
    [dData,~,~,dDate,~,~]=w.wsi(sCode,'open,high,low,close','2018-02-14 09:30:00','2018-03-07 17:12:29');
    dData = [dDate, dData];
    cOptionCode{iCode, 2} = dData;
    disp(num2str(iCode))
end
cOptionData = cOptionCode;
% save('cOptionData', 'cOptionData')

load('cOptionData')
%% 1 获取日期
[cDate,w_tdays_codes,w_tdays_fields,w_tdays_times,w_tdays_errorid,w_tdays_reqid]=...
    w.tdays('2018-02-14','2018-03-07');

for iCode = 1 : length(cOptionData)
    dData = cOptionData{iCode, 2};
    dDateTemp = str2num(datestr(dData(:, 1), 'yyyymmdd'));
    dDateTemp(:, 2) = str2num(datestr(dData(:, 1), 'hhMMss'));
    
    dData = [dDateTemp, dData(:, 2 : end), dData(:, 1)];
    for iData = 2 : length(dData)
        dLocated = isnan(dData(iData, :));
        dData(iData, dLocated) = dData(iData - 1, dLocated);
    end
    
    
    cOptionData{iCode, 2} = dData;
end
dOptionCode = cellfun(@(x) str2double(x(1 : end - 3)), cOptionData(:, 1));
disp('Data Done')

%% 2 对每日生成dOptionTemp
cVixData = cell(length(cDate), 1);
dVixPrice = zeros(length(cDate), 5);
for iDate = 1 : length(cDate)
    sDate = cDate{iDate};
    dLocation = strfind(sDate, '.');
    sDate(dLocation) = '-';
    nDate = str2double(cell2mat(regexp(sDate, '\d*', 'match')));
    
    disp(sDate)
    
    for iTimes = 1 : 5
        [cData, ~, ~, ~, nErrorID_0]...
            = w.wset('optionchain',['date=', sDate, ';us_code=510050.SH;option_var=全部;call_put=全部;field=us_code,us_name,option_var,option_code,option_name,exe_type,strike_price,call_put,expiredate']);
        
        if nErrorID_0 == 0
            break
        else
            % retry
        end
    end
    
    cTemp = regexp(cData(:, 4), '\d*', 'match');
    dTemp = cellfun(@(x) str2double(x{1}), cTemp);
    dTemp(:, 2) = cell2mat(cData(:, 7));
    dLocated = strcmp(cData(:, 8), '认购');
    dTemp(dLocated, 3) = 1;
    dTemp(:, 4) = cell2mat(cData(:, end));
    
    dLocated = dTemp(:, 3) == 1;
    dTemp_1 = sortrows(dTemp(dLocated, :), [4, 2, 1]);
    dTemp_0 = sortrows(dTemp(~dLocated, :), [4, 2, 1]);
    dTemp = [dTemp_1; dTemp_0];
    
    dOptionTemp = dTemp;
    dOptionTemp(:, 5 : 6) = 0;
    
    nFrequency = datenum([0, 0, 0, 0, 1, 0]);
    dRealTimeVix(:, 1) = str2num(datestr([datenum([0 0 0 9 30 0]) : nFrequency : datenum([0 0 0 11 29 0]), ...
        datenum([0 0 0 13 00 0]) : nFrequency : datenum([0 0 0 14 59 0])], 'hhMMss'));
    dRealTimeVix(:, 2 : 5) = nan;
    dRealTimeVix(:, 6) = 1 : length(dRealTimeVix);
    
    for iMinute = 1 : length(dRealTimeVix)
        nMinute = dRealTimeVix(iMinute, 1);
        disp(num2str(nMinute))
        % 找data
        for iCode = 1 : length(dOptionTemp)
            nCode = dOptionTemp(iCode, 1);
            dLocated = dOptionCode == nCode;
            dData = cOptionData{dLocated, 2};
            dLocated = dData(:, 1) == nDate & dData(:, 2) == nMinute;
            
            dOptionTemp(iCode, 5) = nMinute;
            dOptionTemp(iCode, 6 : 8) = dData(dLocated, 6);
            
            dData = cOptionData{1, 2};
            dLocated = dData(:, 1) == nDate & dData(:, 2) == nMinute;
            dOptionTemp(iCode, 9) = dData(dLocated, 6);
            
        end
        dOptionTemp(isnan(dOptionTemp)) = 0;
        
        % 写入矩阵
%         dOptionMarketInfo(end + 1, :) = [dData(2, 1), dData(:, 2)'];
        
        nTimeGap = dData(dLocated, 7);
        
        
        % 计算
        % Cal Options' IV
        dTimeMin = (dOptionTemp(:, 4) .* 1440 + ...
            ((today + 1) - nTimeGap) * 1440 + ...
            510) ./ 525600;
        
        dOptionTemp(:, 10) = Kit_blsimpv(dOptionTemp(:, 9),...
            dOptionTemp(:, 2), ...
            0.03, ...
            dTimeMin, ...
            dOptionTemp(:, 6), ...
            dOptionTemp(:, 3));
        
        % F
        % 计算近月次近月分钟
        dLocated = dOptionTemp(:, 4) > 8;
        dTimeMin = dTimeMin(dLocated, :);
        dFTemp = dOptionTemp(dLocated, :);
        [nOptionDuration_Near, dLocation] = min(dFTemp(:, 4));
        nTimeMin_Near = dTimeMin(dLocation);
        
        if nOptionDuration_Near <= 30
            % CBOE Vix
            dLocated = dFTemp(:, 4) > nOptionDuration_Near;
            dTimeMin = dTimeMin(dLocated, :);
            dFTemp = dFTemp(dLocated, :);
            [nOptionDuration_SubNear, dLocation] = min(dFTemp(:, 4));
            nTimeMin_SubNear = dTimeMin(dLocation);
            
            nVix_Near = Fun_Cal_Vix(nOptionDuration_Near, dOptionTemp, nTimeGap);
            nVix_SubNear = Fun_Cal_Vix(nOptionDuration_SubNear, dOptionTemp, nTimeGap);
            
            nVix = (((nVix_Near * nTimeMin_Near * ((nTimeMin_SubNear * 525600 - 43200) / ((nTimeMin_SubNear - nTimeMin_Near) * 525600))...
                + nVix_SubNear * nTimeMin_SubNear * ((43200 - nTimeMin_Near * 525600) / ((nTimeMin_SubNear - nTimeMin_Near) * 525600)))...
                * (365 / 30)) ^ 0.5) * 100;
            
            % Call BS Vix
            nVxo_Call_Near = Fun_Cal_VXO(nOptionDuration_Near, 1, dOptionTemp);
            nVxo_Call_SubNear = Fun_Cal_VXO(nOptionDuration_SubNear, 1, dOptionTemp);
            nVxo_Call = nVxo_Call_Near * ((nOptionDuration_SubNear - 22) / (nOptionDuration_SubNear - nOptionDuration_Near))...
                + nVxo_Call_SubNear * ((22 - nOptionDuration_Near) / (nOptionDuration_SubNear - nOptionDuration_Near));
            
            % Put BS Vix
            nVxo_Put_Near = Fun_Cal_VXO(nOptionDuration_Near, 0, dOptionTemp);
            nVxo_Put_SubNear = Fun_Cal_VXO(nOptionDuration_SubNear, 0, dOptionTemp);
            nVxo_Put = nVxo_Put_Near * ((nOptionDuration_SubNear - 22) / (nOptionDuration_SubNear - nOptionDuration_Near))...
                + nVxo_Put_SubNear * ((22 - nOptionDuration_Near) / (nOptionDuration_SubNear - nOptionDuration_Near));
            
        else
            nVix_Near = Fun_Cal_Vix(nOptionDuration_Near, dOptionTemp, nTimeGap);
            nVix = nVix_Near * 100;
            
            nVxo_Call_Near = Fun_Cal_VXO(nOptionDuration_Near, 1, dOptionTemp);
            nVxo_Call = nVxo_Call_Near;
            nVxo_Put_Near = Fun_Cal_VXO(nOptionDuration_Near, 0, dOptionTemp);
            nVxo_Put = nVxo_Put_Near;
        end
        
        dRealTimeVix(iMinute, 1) = nDate;
        dRealTimeVix(iMinute, 2) = nVix;
        dRealTimeVix(iMinute, 3) = nVxo_Call * 100;
        dRealTimeVix(iMinute, 4) = nVxo_Put * 100;
        dRealTimeVix(iMinute, 5) = nMinute;
    end
    
    % 记录结果
    cVixData{iDate} = dRealTimeVix;
    
    % 生成当日开高低收
    dVixPrice(iDate, 1) = nDate;
    dVixPrice(iDate, 2) = (dRealTimeVix(1, 2));
    dVixPrice(iDate, 3) = max(dRealTimeVix(:, 2));
    dVixPrice(iDate, 4) = min(dRealTimeVix(:, 2));
    dVixPrice(iDate, 5) = (dRealTimeVix(end, 2));
    
end

%% 5 保存历史数据，通用化画bar数据

save('dVixPrice', 'dVixPrice')
save('cVixData', 'cVixData')






function nVxo = Fun_Cal_VXO(nOptionDuration, nDirection, dOptionTemp)

% 抽取临时数据阵
dOptionInfo = dOptionTemp(dOptionTemp(:, 4) == nOptionDuration & dOptionTemp(:, 3) == nDirection, :);
dTemp = dOptionInfo(dOptionInfo(:, 2) >= dOptionInfo(:, 9), :);
nVxo_Up = dTemp(1, 10);
nExPrice_Up = dTemp(1, 2);

dTemp = dOptionInfo(dOptionInfo(:, 2) < dOptionInfo(:, 9), :);
nVxo_Down = dTemp(end, 10);
nExPrice_Down = dTemp(end, 2);

nVxo = nVxo_Down * ((nExPrice_Up - dTemp(1, 9)) / (nExPrice_Up - nExPrice_Down))...
    + nVxo_Up * ((dTemp(1, 9) - nExPrice_Down) / (nExPrice_Up - nExPrice_Down));

end

function nVix = Fun_Cal_Vix(nOptionDuration, dOptionTemp, nNow)

nTimeMin = (nOptionDuration * 1440 + ...
    ((today + 1) - nNow) * 1440 + ...
    510) ./ 525600;

% 抽取临时数据阵
dOptionInfo = dOptionTemp(dOptionTemp(:, 4) == nOptionDuration & dOptionTemp(:, 6) ~= 0, :);

% 计算合成远期价格 和 无风险收益
dCalPrice = dOptionInfo(dOptionInfo(:, 3) == 1, :);
dPutPrice = dOptionInfo(dOptionInfo(:, 3) == 0, :);
[~, dLocation] = min(abs(dCalPrice(:, 6) - dPutPrice(:, 6)));
neRT = exp(0.03 * nTimeMin);
nF = dCalPrice(dLocation, 2) + neRT * (dCalPrice(dLocation, 6) - dPutPrice(dLocation, 6));

%% Ks
% 计算最接近的执行价格K0
dTemp = dOptionInfo(dOptionInfo(:, 2) <= nF, 2);
nExPrice_0 = dTemp(end);

% 计算买一卖一价格中值 Q(Ki)
dOptionInfo(:, 11) = (dOptionInfo(:, 7) + dOptionInfo(:, 8)) * 0.5;

% 决定采用看跌期权or看涨期权
dOptionInfo(dOptionInfo(:, 2) > nExPrice_0, 12) = 1;
dOptionInfo(:, 13) = dOptionInfo(:, 12) == dOptionInfo(:, 3);
dOptionInfo(dOptionInfo(:, 2) == nExPrice_0, 13) = 1;
dOptionInfo = dOptionInfo(dOptionInfo(:, 13) == 1, :);

% 计算相邻上下执行价格差值的1/2
[dTemp, ~, dLocation_Output] = unique(dOptionInfo(:, 2), 'sorted');
if length(dTemp) >= 3
    dTemp = [dTemp(2) - dTemp(1); dTemp(3 : end) - dTemp(1 : end - 2); dTemp(end) - dTemp(end - 1)];
else
    dTemp = [dTemp(2) - dTemp(1); dTemp(end) - dTemp(end - 1)];
end
dOptionInfo(:, 14) = dTemp(dLocation_Output);

%% Cal Vix
nVix = 2 / nTimeMin *...
    sum(dOptionInfo(:, 14) ./ (dOptionInfo(:, 2) .^ 2) .* neRT .* dOptionInfo(:, 11)) - ...
    (1 / nTimeMin) * (((nF / nExPrice_0) - 1) ^ 2);

end