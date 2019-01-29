function Protected_Cal_Vix
global cSetupPlatform
global dOptionTemp
global dVixIndex
global dRealTimeVix
global dOptionMarketInfo

%% Cal Option's iV
% Cal Options' IV
dTimeMin = (dOptionTemp(:, 4) .* 1440 + ...
    ((today + 1) - cSetupPlatform.Date.Now_Matlab) * 1440 + ...
    510) ./ 525600;

dOptionTemp(:, 10) = Kit_blsimpv(dOptionTemp(:, 9),...
    dOptionTemp(:, 2), ...
    cSetupPlatform.RiskFree, ...
    dTimeMin, ...
    dOptionTemp(:, 6), ...
    dOptionTemp(:, 3));

%% Cal iVix
%% F
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
    
    nVix_Near = Fun_Cal_Vix(nOptionDuration_Near);
    nVix_SubNear = Fun_Cal_Vix(nOptionDuration_SubNear);
    
    nVix = (((nVix_Near * nTimeMin_Near * ((nTimeMin_SubNear * 525600 - 43200) / ((nTimeMin_SubNear - nTimeMin_Near) * 525600))...
        + nVix_SubNear * nTimeMin_SubNear * ((43200 - nTimeMin_Near * 525600) / ((nTimeMin_SubNear - nTimeMin_Near) * 525600)))...
        * (365 / 30)) ^ 0.5) * 100;
    
    % Call BS Vix
    nVxo_Call_Near = Fun_Cal_VXO(nOptionDuration_Near, 1);
    nVxo_Call_SubNear = Fun_Cal_VXO(nOptionDuration_SubNear, 1);
    nVxo_Call = nVxo_Call_Near * ((nOptionDuration_SubNear - 22) / (nOptionDuration_SubNear - nOptionDuration_Near))...
        + nVxo_Call_SubNear * ((22 - nOptionDuration_Near) / (nOptionDuration_SubNear - nOptionDuration_Near));
    
    % Put BS Vix
    nVxo_Put_Near = Fun_Cal_VXO(nOptionDuration_Near, 0);
    nVxo_Put_SubNear = Fun_Cal_VXO(nOptionDuration_SubNear, 0);
    nVxo_Put = nVxo_Put_Near * ((nOptionDuration_SubNear - 22) / (nOptionDuration_SubNear - nOptionDuration_Near))...
        + nVxo_Put_SubNear * ((22 - nOptionDuration_Near) / (nOptionDuration_SubNear - nOptionDuration_Near));
    
else
    nVix_Near = Fun_Cal_Vix(nOptionDuration_Near);
    nVix = nVix_Near * 100;
    
    nVxo_Call_Near = Fun_Cal_VXO(nOptionDuration_Near, 1);
    nVxo_Call = nVxo_Call_Near;
    nVxo_Put_Near = Fun_Cal_VXO(nOptionDuration_Near, 0);
    nVxo_Put = nVxo_Put_Near;
end

dVixIndex(end + 1, 1) = cSetupPlatform.Date.Now;
dVixIndex(end, 2) = nVix;
dVixIndex(end, 3) = nVxo_Call * 100;
dVixIndex(end, 4) = nVxo_Put * 100;

%% 写入GUI矩阵
[~, dLocation_In, ~] = intersect(dRealTimeVix(:, 1), dVixIndex(end, 1));
if ~isempty(dLocation_In)
    dRealTimeVix(dLocation_In, 2 : 4) = dVixIndex(end, 2 : 4);
    dRealTimeVix(dLocation_In, 5) = ((dOptionTemp(1, 9) / dOptionMarketInfo(1)) - 1) * 100;
else
end

end

function nVxo = Fun_Cal_VXO(nOptionDuration, nDirection)
global dOptionTemp

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

function nVix = Fun_Cal_Vix(nOptionDuration)
global cSetupPlatform
global dOptionTemp

nTimeMin = (nOptionDuration * 1440 + ...
    ((today + 1) - cSetupPlatform.Date.Now_Matlab) * 1440 + ...
    510) ./ 525600;

% 抽取临时数据阵
dOptionInfo = dOptionTemp(dOptionTemp(:, 4) == nOptionDuration, :);

% 计算合成远期价格 和 无风险收益
dCalPrice = dOptionInfo(dOptionInfo(:, 3) == 1, :);
dPutPrice = dOptionInfo(dOptionInfo(:, 3) == 0, :);
[~, dLocation] = min(abs(dCalPrice(:, 6) - dPutPrice(:, 6)));
neRT = exp(cSetupPlatform.RiskFree * nTimeMin);
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