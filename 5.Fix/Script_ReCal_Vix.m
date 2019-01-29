clc
clear all
addpath('E:\3.工作与实习\兴业证券\6.指数编制\0.iVix\3.Protected')

%% Clean Data
[~, ~, cRawData] = xlsread('OPUDLData.xlsx');

% Time
dRawTime = datenum(cRawData(2 : end, 2), 'yyyy.mm.dd hh:MM:ss');

% Code
cRawCode = cRawData(2 : end, 3);
cRawCode = regexp(cRawCode, '\d*', 'match');
dRawCode = cellfun(@(x) str2double(x{:}), cRawCode);

% Price
dOpenPrice = cRawData(2 : end, 5);
dLocated = cell2mat(cellfun(@(x) isa(x, 'char'), dOpenPrice, 'UniformOutput', 0));
[dOpenPrice(dLocated)] = deal({0});
dOpenPrice = cell2mat(dOpenPrice);

dClosePrice = cRawData(2 : end, 6);
dLocated = cell2mat(cellfun(@(x) isa(x, 'char'), dClosePrice, 'UniformOutput', 0));
[dClosePrice(dLocated)] = deal({0});
dClosePrice = cell2mat(dClosePrice);

% Call or Put
cRawType = cRawData(2 : end, 11);
dType = strcmp(cRawType, '认购');

% Date2Expire
dMatureDate = datenum(cRawData(2 : end, 15), 'yyyy.mm.dd');
dDate2Expire = dMatureDate - fix(dRawTime);

% Time
dTimeNow = str2num(datestr(dRawTime - dMatureDate, 'hhMMss'));

% TGT Price
dOpenPrice_TGT = cRawData(2 : end, 19);
dOpenPrice_TGT = cell2mat(dOpenPrice_TGT);
dClosePrice_TGT = cRawData(2 : end, 20);
dClosePrice_TGT = cell2mat(dClosePrice_TGT);

% Rf
dRiskFree = cRawData(2 : end, 25);
dLocated = cell2mat(cellfun(@(x) isa(x, 'char'), dRiskFree, 'UniformOutput', 0));
[dRiskFree(dLocated)] = deal({0.03});
dRiskFree = cell2mat(dRiskFree);

% Execute Price
dExPrice = cRawData(2 : end, 13);
dExPrice = cell2mat(dExPrice);

% Combine the Data
dOptionInfo = [dRawCode, dExPrice, dType, dDate2Expire, dTimeNow, dClosePrice, dRiskFree, dRawTime, dClosePrice_TGT];

% Add 0930 & 1300
dLocated = dOptionInfo(:, 5) == 100000 | dOptionInfo(:, 5) == 133000;
dOption2Add = dOptionInfo(dLocated, :);
dOption2Add(dOption2Add(:, 5) == 100000, 5) = 93000;
dOption2Add(dOption2Add(:, 5) == 133000, 5) = 130000;
dOption2Add(:, 6) = dOpenPrice(dLocated);
dOption2Add(:, 9) = dOpenPrice_TGT(dLocated);
dOption2Add(dOption2Add(:, 5) == 93000, 8) = fix(dOption2Add(dOption2Add(:, 5) == 93000, 8)) + ...
    datenum([0, 0, 0, 9, 30, 0]);
dOption2Add(dOption2Add(:, 5) == 130000, 8) = fix(dOption2Add(dOption2Add(:, 5) == 130000, 8)) + ...
    datenum([0, 0, 0, 13, 00, 0]);

dOptionInfo = [dOptionInfo; dOption2Add];

%% Cal VXO
dTimeLine = unique(dOptionInfo(:, 8));
dVix = dTimeLine;
dVix(:, 2 : 4) = 0;
parfor iTime = 1 : length(dTimeLine)
    nNow = dTimeLine(iTime);
    dLocated = dOptionInfo(:, 8) == nNow;
    dOptionTemp = dOptionInfo(dLocated, :);
    
    % Reorgnize
    dLocated = dOptionTemp(:, 3) == 1;
    dTemp_1 = sortrows(dOptionTemp(dLocated, :), [4, 2, 1]);
    dTemp_0 = sortrows(dOptionTemp(~dLocated, :), [4, 2, 1]);
    dOptionTemp = [dTemp_1; dTemp_0];
    
    dTimeMin = (dOptionTemp(:, 4) .* 1440 + ...
        ((fix(nNow) + 1) - nNow) * 1440 + ...
        510) ./ 525600;
    
    % IV
    dOptionTemp(:, 10) = Kit_blsimpv(dOptionTemp(:, 9),...
        dOptionTemp(:, 2), ...
        dOptionTemp(:, 7), ...
        dTimeMin, ...
        dOptionTemp(:, 6), ...
        dOptionTemp(:, 3));
    
    % Cal VXO
    dLocated = dOptionTemp(:, 4) > 5;
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
        
        % Call BS Vix
        nVxo_Call_Near = Fun_Cal_VXO(nOptionDuration_Near, 1, dOptionTemp);
        nVxo_Call_SubNear = Fun_Cal_VXO(nOptionDuration_SubNear, 1, dOptionTemp);
        nVxo_Call = nVxo_Call_Near * ((nOptionDuration_SubNear - 30) / (nOptionDuration_SubNear - nOptionDuration_Near))...
            + nVxo_Call_SubNear * ((30 - nOptionDuration_Near) / (nOptionDuration_SubNear - nOptionDuration_Near));
        
        % Put BS Vix
        nVxo_Put_Near = Fun_Cal_VXO(nOptionDuration_Near, 0, dOptionTemp);
        nVxo_Put_SubNear = Fun_Cal_VXO(nOptionDuration_SubNear, 0, dOptionTemp);
        nVxo_Put = nVxo_Put_Near * ((nOptionDuration_SubNear - 30) / (nOptionDuration_SubNear - nOptionDuration_Near))...
            + nVxo_Put_SubNear * ((30 - nOptionDuration_Near) / (nOptionDuration_SubNear - nOptionDuration_Near));
        
    else

        nVxo_Call_Near = Fun_Cal_VXO(nOptionDuration_Near, 1, dOptionTemp);
        nVxo_Call = nVxo_Call_Near;
        nVxo_Put_Near = Fun_Cal_VXO(nOptionDuration_Near, 0, dOptionTemp);
        nVxo_Put = nVxo_Put_Near;
    end
    
    dResult = [nNow, nVxo_Call * 100, nVxo_Put * 100, (nVxo_Call + nVxo_Put) * 50];
    dVix(iTime, :) = dResult;
    disp(datestr(nNow, 'yyyy.mm.dd'))
end

cDate = cellstr(datestr(dVix(:, 1), 'yyyy.mm.dd hh:MM:ss'));
cFields = {'时间', '认购Vix', '认沽Vix', 'Vix'};
cData = num2cell(dVix(:, 2 : end));
cResult = [cDate, cData];
cResult = [cFields; cResult];
xlswrite('VxoResult.xlsx', cResult);


function nVxo = Fun_Cal_VXO(nOptionDuration, nDirection, dOptionTemp)

% 抽取临时数据阵
dOptionInfo = dOptionTemp(dOptionTemp(:, 4) == nOptionDuration & dOptionTemp(:, 3) == nDirection, :);
dTemp_Up = dOptionInfo(dOptionInfo(:, 2) >= dOptionInfo(:, 9), :);
dTemp_Down = dOptionInfo(dOptionInfo(:, 2) < dOptionInfo(:, 9), :);

if ~isempty(dTemp_Up)
    nVxo_Up = dTemp_Up(1, 10);
    nExPrice_Up = dTemp_Up(1, 2);
    nTGTPrice = dTemp_Up(1, 9);
else
    nVxo_Up = 0;
    nExPrice_Up = 0;
end

if ~isempty(dTemp_Down)
    nVxo_Down = dTemp_Down(1, 10);
    nExPrice_Down = dTemp_Down(1, 2);
    nTGTPrice = dTemp_Down(1, 9);
else
    nVxo_Down = 0;
    nExPrice_Down = 0;
end

nVxo = nVxo_Down * ((nExPrice_Up - nTGTPrice) / (nExPrice_Up - nExPrice_Down))...
    + nVxo_Up * ((nTGTPrice - nExPrice_Down) / (nExPrice_Up - nExPrice_Down));

end
