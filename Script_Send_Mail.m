%% 0. 全局变量
sMailAdress = 'quantcta@sina.com';
sMailPassword = 'quantcta';
sMail2Sent = {sMailAdress};

%% 1. SMTP_Server Get
nInd = find(sMailAdress == '@', 1);
sSMTP_Server = ['smtp.', sMailAdress(nInd+1 : end)];

%% 2. 发送邮件
try
    setpref('Internet','SMTP_Server',sSMTP_Server);
    setpref('Internet','E_mail', sMailAdress);
    setpref('Internet','SMTP_Username', sMailAdress);
    setpref('Internet','SMTP_Password', sMailPassword);
    
    props = java.lang.System.getProperties;
    props.setProperty('mail.smtp.auth','true');
    
    cAttachments = {['.\A股50ETF期权波动率指数.xlsm']};
    sSubject = ['Vix Index Push ', datestr(now, 'yyyy-mm-dd')];
    sContent = [];
    
    for iAdress = 1 : length(sMail2Sent)
        sendmail(sMail2Sent{iAdress}, sSubject, sContent, cAttachments);
    end
    
catch err
    disp('发生异常');
    for i = 1:size(err.stack,1)
        StrTemp = ['FunName：',err.stack(i).name,' Line：',num2str(err.stack(i).line)];
        disp(StrTemp);
    end
end

% exit
