%% 描述：计算CBOE index脚本
%   时间：2017.11.27
clc;clear 

%% Part I 数据更新

load('option_list_all_v2.mat')
wind=windmatlab;

target_index='510050.SH';
start_time='2015-02-09';
end_time='2018-02-28';
period_days=wind.tdays(start_time,end_time);
theory_vol=zeros(length(period_days),1);
[us_close,~,~,date]=wind.wsd(target_index,'close',start_time,end_time,'Fill=Previous');
us_close=[m2xdate(date) us_close];
for loop=1:length(us_close)
    if loop+21<=length(us_close)
        temp_price=us_close(loop:loop+21);
    else
        temp_price=us_close(end-21:end);
    end
    theory_vol(loop)=std(price2ret(temp_price))*sqrt(252);
end

last_updated=fieldnames(option_list.call_a);
start_time=datestr(datenum(last_updated{end,1}(5:end),'yyyymmdd')+1,'yyyy-mm-dd');
if datenum(start_time)<datenum(end_time)
    add_period_days=wind.tdays(start_time,end_time);
    theory_vol=theory_vol(end-length(add_period_days)+1:end);
    option_list=add_data_option(option_list,wind,start_time,end_time,add_period_days,theory_vol);
    save('option_list_all_v2.mat','option_list')
    load('option_list_all_v2.mat')
end

%% Part II 指数计算
cboe_index=zeros(length(period_days),5);
cboe_index(:,1)=datenum(period_days);

for iloop=1:length(datenum(period_days))
    iloop_date=['date' datestr(datenum(period_days{iloop}),'yyyymmdd')];
    iloop_vix_data=cboe_vix_cal(option_list,iloop_date);
    cboe_index(iloop,2)=iloop_vix_data;
    [vix,call_vix,put_vix]=vxo_cal(option_list,iloop_date,us_close(iloop,2),wind);
    cboe_index(iloop,3:5)=[vix,call_vix,put_vix];
    disp([iloop_vix_data vix])
end

plot(datetime(cboe_index(:,1),'ConvertFrom','datenum'),cboe_index(:,3))
cboe_index(:,1)=m2xdate(cboe_index(:,1));