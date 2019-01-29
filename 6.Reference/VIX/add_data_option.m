function option_list_new=add_data_option(option_list,wind,start_time,end_time,peroid_days,theory_vol)
%% 描述：在原有数据基础上添加期权数据
option_list_add=download_option_v2(wind,start_time,end_time,peroid_days,theory_vol);
option_list_new=option_list;
for loop=1:length(peroid_days)
    unique_day=datestr(datenum(peroid_days(loop)),'yyyymmdd');
    name=['date' unique_day];
    option_list_new.call_a.(name)=option_list_add.call_a.(name);
    option_list_new.call_b.(name)=option_list_add.call_b.(name);
    option_list_new.call_c.(name)=option_list_add.call_c.(name);
    option_list_new.call_d.(name)=option_list_add.call_d.(name);
    option_list_new.put_a.(name)=option_list_add.put_a.(name);
    option_list_new.put_b.(name)=option_list_add.put_b.(name);
    option_list_new.put_c.(name)=option_list_add.put_c.(name);
    option_list_new.put_d.(name)=option_list_add.put_d.(name);
    disp(loop)
end