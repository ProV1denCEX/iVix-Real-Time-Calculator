function Protected_Fetch_OptionList
global cSetupPlatform
global dOptionTemp
global dOptionMarketInfo

disp('Start Fetching Options List')

for iTimes = 1 : 5
    [cData, ~, ~, ~, nErrorID_0]...
        = cSetupPlatform.Wind.API.wset('optionchain',['date=', cSetupPlatform.Date.StrStandard, ';us_code=510050.SH;option_var=全部;call_put=全部;field=us_code,us_name,option_var,option_code,option_name,exe_type,strike_price,call_put,expiredate']);
    [nUSPrice,~,~,~,nErrorID_1] ...
        = cSetupPlatform.Wind.API.wsd('510050.SH','pre_close',cSetupPlatform.Date.StrStandard, cSetupPlatform.Date.StrStandard);
    nErrorID = nErrorID_0 + nErrorID_1;
    [nIsError, sErrorMesg] = Protected_Check_WindError(nErrorID);
    
    if ~nIsError
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
        dOptionMarketInfo = [nUSPrice, 510050, dOptionTemp(:, 1)'];
        
        cCode = arrayfun(@(x) [num2str(x), '.SH,'], dTemp(:, 1), 'UniformOutput', 0);
        sCode = [cCode{:}];
        sCode(end) = [];
        cSetupPlatform.Option.sCode = sCode;
        break
    else
        disp(sErrorMesg)
        disp(['Retry Fetching ... ', num2str(iTimes)])
    end
    
    if iTimes == 5
        error('Please Check API Connection !!!')
    else
    end
end
end