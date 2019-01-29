function option_list=download_option_v2(wind,start_time,end_time,period_days,theory_vol)
%% 功能：下载指定区间内的所有期权合约，并且期权合约按照期权方向和到期月份分为8类
% step1: 初始化结果矩阵
option_list=struct; 
option_list.call_a=struct;
option_list.call_b=struct;
option_list.call_c=struct;
option_list.call_d=struct;
option_list.put_a=struct;
option_list.put_b=struct;
option_list.put_c=struct;
option_list.put_d=struct;

% step2: 下载计算隐含波动率的必要数据
us_close=wind.wsd('510050.SH','close',start_time,end_time,'Fill=Previous');
rt_start_time=wind.tdaysoffset(-20,start_time);
rate=wind.wsd('FR007.IR','close3',rt_start_time,end_time,'Fill=Previous');

% step3：逐日下载期权数据，并添加隐含波动率、delta、理论价格和价内外程度的数据
for loop=1:length(period_days)
    unique_day=datestr(datenum(period_days(loop)),'yyyymmdd');
    temp_option_list=wind.wset('OptionChain',['date=' unique_day ';us_code=510050.SH;option_var=;month=全部;call_put=全部']);
    temp_option_price=wind.wss(temp_option_list(:,4),'close',['tradeDate=' unique_day],'priceAdj=U','cycle=D');
    
    us_price=us_close(loop);
    temp_rate=mean(rate(loop:(loop+20)))/100;
    
    impv_vec=zeros(length(temp_option_price),1);
    delta_vec=zeros(length(temp_option_price),1);
    theory_price_vec=zeros(length(temp_option_price),1);
    
    for sub_loop=1:length(temp_option_price)
        temp_time=(double(temp_option_list{sub_loop,12})+1)/365;
        % 计算隐含波动率数据和理论价格数据
        [temp_call,temp_put]=blsprice(us_price, temp_option_list{sub_loop,7}, temp_rate, temp_time, theory_vol(loop));
        if strcmp(temp_option_list{sub_loop,9},'认购')
            if us_price<0 || temp_option_list{sub_loop,7}<0 || temp_rate<0 || temp_time<0 || temp_option_price(sub_loop)<0
                disp()
            end
            impv_vec(sub_loop)=blsimpv(us_price,temp_option_list{sub_loop,7},temp_rate,temp_time,temp_option_price(sub_loop));
            theory_price_vec(sub_loop)=temp_call;
        else
            impv_vec(sub_loop)=blsimpv(us_price,temp_option_list{sub_loop,7},temp_rate,temp_time,temp_option_price(sub_loop),2,0,[],false);
            theory_price_vec(sub_loop)=temp_put;
        end
        % 计算delta
        if (impv_vec(sub_loop)>0 && impv_vec(sub_loop)<2)
            [temp_call,temp_put]=blsdelta(us_price,temp_option_list{sub_loop,7},temp_rate,temp_time,impv_vec(sub_loop));
            if strcmp(temp_option_list{sub_loop,9},'认购')
                delta_vec(sub_loop)=temp_call;
            else
                delta_vec(sub_loop)=temp_put;
            end
        else
            delta_vec(sub_loop)=nan;
            disp('无法正确计算Delta!')
        end
    end
    moneyness_vec=cell2mat(temp_option_list(:,7))/us_price;
    
    list_date=sort(unique(cell2mat(temp_option_list(:,12))));
    
    name=['date' unique_day];
    temp_option_list(:,14)=num2cell(impv_vec);
    temp_option_list(:,15)=num2cell(delta_vec);
    temp_option_list(:,16)=num2cell(temp_option_price);
    temp_option_list(:,17)=num2cell(moneyness_vec);
    temp_option_list(:,18)=num2cell(wind.wss(temp_option_list(:,4),'volume',['tradeDate=' unique_day],'cycle=D'));
    
    option_list.call_a.(name)=temp_option_list(strcmp(temp_option_list(:,9),'认购')&cell2mat(temp_option_list(:,12))==list_date(1),:);
    option_list.call_a.(name)(:,19)=num2cell(double(wind.tdayscount(datestr(datenum(unique_day,'yyyymmdd'),'yyyy-mm-dd'),option_list.call_a.(name){1,11}))*ones(size(option_list.call_a.(name),1),1));
    option_list.call_b.(name)=temp_option_list(strcmp(temp_option_list(:,9),'认购')&cell2mat(temp_option_list(:,12))==list_date(2),:);
    option_list.call_b.(name)(:,19)=num2cell(double(wind.tdayscount(datestr(datenum(unique_day,'yyyymmdd'),'yyyy-mm-dd'),option_list.call_b.(name){1,11}))*ones(size(option_list.call_b.(name),1),1));
    option_list.call_c.(name)=temp_option_list(strcmp(temp_option_list(:,9),'认购')&cell2mat(temp_option_list(:,12))==list_date(3),:);
    option_list.call_c.(name)(:,19)=num2cell(double(wind.tdayscount(datestr(datenum(unique_day,'yyyymmdd'),'yyyy-mm-dd'),option_list.call_c.(name){1,11}))*ones(size(option_list.call_c.(name),1),1));
    option_list.call_d.(name)=temp_option_list(strcmp(temp_option_list(:,9),'认购')&cell2mat(temp_option_list(:,12))==list_date(4),:);
    option_list.call_d.(name)(:,19)=num2cell(double(wind.tdayscount(datestr(datenum(unique_day,'yyyymmdd'),'yyyy-mm-dd'),option_list.call_d.(name){1,11}))*ones(size(option_list.call_d.(name),1),1));
    option_list.put_a.(name)=temp_option_list(strcmp(temp_option_list(:,9),'认沽')&cell2mat(temp_option_list(:,12))==list_date(1),:);
    option_list.put_a.(name)(:,19)=option_list.call_a.(name)(:,19);
    option_list.put_b.(name)=temp_option_list(strcmp(temp_option_list(:,9),'认沽')&cell2mat(temp_option_list(:,12))==list_date(2),:);
    option_list.put_b.(name)(:,19)=option_list.call_b.(name)(:,19);
    option_list.put_c.(name)=temp_option_list(strcmp(temp_option_list(:,9),'认沽')&cell2mat(temp_option_list(:,12))==list_date(3),:);
    option_list.put_c.(name)(:,19)=option_list.call_c.(name)(:,19);
    option_list.put_d.(name)=temp_option_list(strcmp(temp_option_list(:,9),'认沽')&cell2mat(temp_option_list(:,12))==list_date(4),:);
    option_list.put_d.(name)(:,19)=option_list.call_d.(name)(:,19);
    
    disp(loop)
end