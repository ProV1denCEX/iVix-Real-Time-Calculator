% _Author : Frontal Xiang
%_Version: V 1.0.0
%_Describe: 进行发件，将完整数据 / 更新数据 发送给目标邮箱
%_Update: 20171109 完成与Excel对接代码
%_Input: null
%_Output:null
%***********************************************
function Protected_Send_Mail
%% 0. 全局变量
global cSetupPlatform

%% 1. SMTP_Server Get
nInd = find(cSetupPlatform.Mail.MailAdress == '@', 1);
sSMTP_Server = ['smtp.', cSetupPlatform.Mail.MailAdress(nInd+1 : end)];

%% 2. 发送邮件
try
    setpref('Internet','SMTP_Server',sSMTP_Server);
    setpref('Internet','E_mail', cSetupPlatform.Mail.MailAdress);
    setpref('Internet','SMTP_Username', cSetupPlatform.Mail.MailAdress);
    setpref('Internet','SMTP_Password', cSetupPlatform.Mail.MailPassword);
    
    props = java.lang.System.getProperties;
    props.setProperty('mail.smtp.auth','true');
    
    cAttachments = {[cSetupPlatform.Dir.Pic, '\RealTime Vix Indexs_', cSetupPlatform.Date.StrStandard, '.jpg'], ...
        [cSetupPlatform.Dir.Pic, '\', 'Daily Vix Indexs.jpg']};
    sSubject = ['Vix Index Push ', datestr(now, 'yyyy-mm-dd')];
    sContent = [];
    
    for iAdress = 1 : length(cSetupPlatform.Mail.Mail2Sent)
        sendmail(cSetupPlatform.Mail.Mail2Sent{iAdress}, sSubject, sContent, cAttachments);
    end
    
catch err
    disp('发生异常');
    for i = 1:size(err.stack,1)
        StrTemp = ['FunName：',err.stack(i).name,' Line：',num2str(err.stack(i).line)];
        disp(StrTemp);
    end
end
end