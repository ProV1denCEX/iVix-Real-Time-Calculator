%% 0. 全局变量
sMailAdress = 'xyquantcta@sina.com';
sMailPassword = 'xyquantcta';
sMail2Sent = {'475937844@qq.com', ...
    'yumingming0918@126.com', ...
    'dongj@yhfund.com.cn', ...
    'ganmx@yhfund.com.cn', ...
    'zhouyou@yhfund.com.cn', ...
    'liup@yhfund.com.cn'};

%% 1. SMTP_Server Get
nInd = find(sMailAdress == '@', 1);
sSMTP_Server = ['smtp.', sMailAdress(nInd+1 : end)];

%% 2. 发送邮件
try
    setpref('Internet','SMTP_Server',sSMTP_Server);
    setpref('Internet','E_mail', sMailAdress);
    setpref('Internet','SMTP_Username', sMailAdress);
    setpref('Internet','SMTP_Password', sMailPassword);
    setpref('Internet','E_mail_Charset','UTF-8'); 
    
    props = java.lang.System.getProperties;
    props.setProperty('mail.smtp.auth','true');
    
%     props.setProperty('mail.smtp.socketFactory.class','javax.net.ssl.SSLSocketFactory');
%     props.setProperty('mail.smtp.socketFactory.port','465');
    
    cAttachments = ['Industry_Security_iVix_Push.xlsm'];
    sSubject = ['Vix Index Push ', datestr(now, 'yyyy-mm-dd')];
    
    if str2double(datestr(now, 'hhMM')) > 1300
        sContent = '下午';
    else
        sContent = '上午';
    end
    sContent = ['兴业证券iVix指数实时计算结果 于明明 ', datestr(now, 'yyyy-mm-dd'), ' ', sContent];
    
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

exit