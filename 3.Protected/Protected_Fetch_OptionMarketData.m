function Protected_Fetch_OptionMarketData
global cSetupPlatform
global dOptionMarketInfo
global dOptionTemp

[dData,~,~,nTime,nErrorID,~]...
    = cSetupPlatform.Wind.API.wsq(['510050.SH,', cSetupPlatform.Option.sCode],'rt_time,rt_latest,rt_bid1,rt_ask1');

[nIsError, sErrorMesg] = Protected_Check_WindError(nErrorID);

if ~nIsError
    dOptionTemp(:, 5 : 8) = dData(2 : end, :);
    dOptionTemp(:, 9) = dData(1, 2);
    dOptionMarketInfo(end + 1, :) = [dData(2, 1), dData(:, 2)'];
    cSetupPlatform.Date.Now = str2double(datestr(nTime, 'hhMMss'));
    cSetupPlatform.Date.Now_Matlab = nTime;
else
    disp(sErrorMesg)
end
end