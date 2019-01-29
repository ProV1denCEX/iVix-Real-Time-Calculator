% _Author : Frontal Xiang
%_Version: V 1.0.0
%_Describe: 判断wind是否报错并抛出错误提示
%_Update: 20171120 完成基本程序代码
%               20171228 修改warning为disp
%_Input: null
%_Output:null
%*******************************************************************
function [nIsError, sErrorMesg] = Protected_Check_WindError(nErrorID)
%% 0.全局变量
global cSetupPlatform

%% 1. 比对是否出现数据错误
cErrorList = cSetupPlatform.Wind.ErrorList;
dLocated = [cErrorList{:, 1}] == nErrorID;

if ~sum(dLocated)
    cSetupPlatform.Wind.Status = '正常';
    nIsError = false;
    sErrorMesg = [];
else
    sError = cErrorList{dLocated, 2};
    nIsError = true;
    cSetupPlatform.Wind.Status = ['Wind API Error, Error Code : ', num2str(nErrorID), ' ; ', sError];
    sErrorMesg = cSetupPlatform.Wind.Status;
end
end