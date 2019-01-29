function Protected_Config
global cSetupPlatform
global dOptionMarketInfo
global dOptionTemp
global dVixIndex
global dRealTimeVix

%% ErrorList
load('cErrorList');
cSetupPlatform.Wind.ErrorList = cErrorList;

%% API
cSetupPlatform.Wind.API = windmatlab;

%% Date
dTemp = datevec(now);
cSetupPlatform.Date.NumStandard = dTemp(1) * 10000 + dTemp(2) * 100 + dTemp(3);
cSetupPlatform.Date.StrStandard = datestr(now, 'yyyy-mm-dd');

%% Rf
cSetupPlatform.RiskFree = 0.03;

%% RealTime Double
nFrequency = datenum([0, 0, 0, 0, 0, 1]);
dRealTimeVix(:, 1) = str2num(datestr([datenum([0 0 0 9 30 0]) : nFrequency : datenum([0 0 0 11 29 59]), ...
        datenum([0 0 0 13 00 0]) : nFrequency : datenum([0 0 0 14 59 59])], 'hhMMss'));
dRealTimeVix(:, 2 : 5) = nan;
dRealTimeVix(:, 6) = 1 : length(dRealTimeVix);

%% GUI
cSetupPlatform.GUI.IsOpen = true;

%% Dir
cSetupPlatform.Dir.Home = cd;
cSetupPlatform.Dir.Data = [cd, '\0.Data'];
cSetupPlatform.Dir.Pic = [cd, '\2.Pic'];
cSetupPlatform.Dir.Temp = [cd, '\4.Temp'];

%% Mail
cSetupPlatform.Mail.MailAdress = 'xyquantcta@sina.com';
cSetupPlatform.Mail.Mail2Sent = '475937844@qq.com';
cSetupPlatform.Mail.MailPassword = 'xyquantcta';

end