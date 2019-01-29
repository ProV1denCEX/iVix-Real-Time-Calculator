function [vix,call_vix,put_vix]=vxo_cal(option_list,temp_date,current_close,wind)
    %% 描述：使用美股VXO算法计算隐含波动率指数
    %  创建日期：2016.5.26
    min_date=option_list.call_a.(temp_date){1,12};
    sec_date=option_list.call_b.(temp_date){1,12};
    K_call_a=cell2mat(option_list.call_a.(temp_date)(:,7));
    K_call_b=cell2mat(option_list.call_b.(temp_date)(:,7));
    K_call_c=cell2mat(option_list.call_c.(temp_date)(:,7));
    if (min_date>30) || (min_date<=5 && sec_date>=30)
        disp('本期入选4个样本！')
        if min_date>30
            unique_K=K_call_a;
            temp_call_a=option_list.call_a.(temp_date);
            temp_put_a=option_list.put_a.(temp_date);
        else
            unique_K=K_call_b;
            temp_call_a=option_list.call_b.(temp_date);
            temp_put_a=option_list.put_b.(temp_date);
        end
        real_K_loc=(unique_K<current_close); %#ok<*NODEF>
        if sum(real_K_loc)>0
            real_K=max(unique_K(real_K_loc));
        else
            real_K=min(unique_K);
        end
        vain_K_loc=(unique_K>=current_close);
        if sum(vain_K_loc)>0
            vain_K=min(unique_K(vain_K_loc));
        else
            vain_K=max(unique_K);
        end
        if real_K==vain_K
            sorted_K=sort(unique_K);
            if real_K==max(sorted_K)
                real_K=sorted_K(end-1);
            else
                vain_K=sorted_K(2);
            end
        end
        x_low_call=temp_call_a(cell2mat(temp_call_a(:,7))==real_K,:);x_low_call=filter_info(x_low_call);
        x_low_put=temp_put_a(cell2mat(temp_put_a(:,7))==real_K,:);x_low_put=filter_info(x_low_put);
        x_high_call=temp_call_a(cell2mat(temp_call_a(:,7))==vain_K,:);x_high_call=filter_info(x_high_call);
        x_high_put=temp_put_a(cell2mat(temp_put_a(:,7))==vain_K,:);x_high_put=filter_info(x_high_put);

        VXO_info=[x_low_call;x_low_put;x_high_call;x_high_put];
        vix=VXO_index(VXO_info,current_close,2,'all',temp_date,wind);
        call_vix=VXO_index(VXO_info,current_close,2,'call',temp_date,wind);
        put_vix=VXO_index(VXO_info,current_close,2,'put',temp_date,wind);
    else
        disp('本期入选8个样本！')
        if min_date>5
            unique_K_a=K_call_a;
            unique_K_b=K_call_b;
            temp_call_a=option_list.call_a.(temp_date);
            temp_put_a=option_list.put_a.(temp_date);
            temp_call_b=option_list.call_b.(temp_date);
            temp_put_b=option_list.put_b.(temp_date);
        else
            unique_K_a=K_call_b;
            unique_K_b=K_call_c;
            temp_call_a=option_list.call_b.(temp_date);
            temp_put_a=option_list.put_b.(temp_date);
            temp_call_b=option_list.call_c.(temp_date);
            temp_put_b=option_list.put_c.(temp_date);
        end

        near_real_K_loc=(unique_K_a<current_close); %#ok<*NODEF>
        if sum(near_real_K_loc)>0
            near_real_K=max(unique_K_a(near_real_K_loc));
        else
            near_real_K=min(unique_K_a);
        end
        near_vain_K_loc=(unique_K_a>=current_close);
        if sum(near_vain_K_loc)>0
            near_vain_K=min(unique_K_a(near_vain_K_loc));
        else
            near_vain_K=max(unique_K_a);
        end
        if near_vain_K==near_real_K
            sorted_K=sort(unique_K_a);
            if near_real_K==max(sorted_K)
                near_real_K=sorted_K(end-1);
            else
                near_vain_K=sorted_K(2);
            end
        end

        sub_real_K_loc=(unique_K_b<current_close); %#ok<*NODEF>
        if sum(sub_real_K_loc)>0
            sub_real_K=max(unique_K_b(sub_real_K_loc));
        else
            sub_real_K=min(unique_K_b);
        end
        sub_vain_K_loc=(unique_K_b>=current_close);
        if sum(sub_vain_K_loc)>0
            sub_vain_K=min(unique_K_b(sub_vain_K_loc));
        else
            sub_vain_K=max(unique_K_b);
        end
        if sub_vain_K==sub_real_K
            sorted_K=sort(unique_K_b);
            if sub_real_K==max(sorted_K)
                sub_real_K=sorted_K(end-1);
            else
                sub_vain_K=sorted_K(2);
            end
        end

        x_near_low_call=temp_call_a(cell2mat(temp_call_a(:,7))==near_real_K,:);x_near_low_call=filter_info(x_near_low_call);
        x_near_low_put=temp_put_a(cell2mat(temp_put_a(:,7))==near_real_K,:);x_near_low_put=filter_info(x_near_low_put);
        x_near_high_call=temp_call_a(cell2mat(temp_call_a(:,7))==near_vain_K,:);x_near_high_call=filter_info(x_near_high_call);
        x_near_high_put=temp_put_a(cell2mat(temp_put_a(:,7))==near_vain_K,:);x_near_high_put=filter_info(x_near_high_put);
        x_sub_low_call=temp_call_b(cell2mat(temp_call_b(:,7))==sub_real_K,:);x_sub_low_call=filter_info(x_sub_low_call);
        x_sub_low_put=temp_put_b(cell2mat(temp_put_b(:,7))==sub_real_K,:);x_sub_low_put=filter_info(x_sub_low_put);
        x_sub_high_call=temp_call_b(cell2mat(temp_call_b(:,7))==sub_vain_K,:);x_sub_high_call=filter_info(x_sub_high_call);
        x_sub_high_put=temp_put_b(cell2mat(temp_put_b(:,7))==sub_vain_K,:);x_sub_high_put=filter_info(x_sub_high_put);

        VXO_info=[x_near_low_call;x_near_low_put;x_near_high_call;x_near_high_put;x_sub_low_call;x_sub_low_put;x_sub_high_call;x_sub_high_put];
        vix=VXO_index(VXO_info,current_close,1,'all',temp_date,wind);
        call_vix=VXO_index(VXO_info,current_close,1,'call',temp_date,wind);
        put_vix=VXO_index(VXO_info,current_close,1,'put',temp_date,wind);
    end
end
function new_option_info=filter_info(old_option_info)
    if size(old_option_info,1)>1
        for iloop=1:size(old_option_info,1)
            if strcmp(old_option_info{iloop,5}(end),'A')
                loc=iloop;
            end
        end
        new_option_info=old_option_info(loc,:);
    else
        new_option_info=old_option_info;
    end
end
function VXO_impv=VXO_index(VXO_info,us_close,op_type,scope,temp_date,wind)
    if op_type==2
        sigma_low_call=VXO_info{1,14};sigma_low_call(isnan(sigma_low_call))=0;
        sigma_low_put=VXO_info{2,14};sigma_low_put(isnan(sigma_low_put))=0;
        sigma_up_call=VXO_info{3,14};sigma_up_call(isnan(sigma_up_call))=0;
        sigma_up_put=VXO_info{4,14};sigma_up_put(isnan(sigma_up_put))=0;
        
        if strcmp(scope,'call')
            sigma_low_put=sigma_low_call;
            sigma_up_put=sigma_up_call;
        elseif strcmp(scope,'put')
            sigma_low_call=sigma_low_put;
            sigma_up_call=sigma_up_put;
        end
        
        sigma_low=(sigma_low_call+sigma_low_put)/2;
        sigma_up=(sigma_up_call+sigma_up_put)/2;
        
        strike_low=min(cell2mat(VXO_info(:,7)));
        strike_up=max(cell2mat(VXO_info(:,7)));
        VXO_impv=sigma_low*(strike_up-us_close)/(strike_up-strike_low)+...
            sigma_up*(us_close-strike_low)/(strike_up-strike_low);
    elseif op_type==1
        sigma_near_low_call=VXO_info{1,14};sigma_near_low_call(isnan(sigma_near_low_call))=0;
        sigma_near_low_put=VXO_info{2,14};sigma_near_low_put(isnan(sigma_near_low_put))=0;
        sigma_near_up_call=VXO_info{3,14};sigma_near_up_call(isnan(sigma_near_up_call))=0;
        sigma_near_up_put=VXO_info{4,14};sigma_near_up_put(isnan(sigma_near_up_put))=0;
        sigma_sub_low_call=VXO_info{5,14};sigma_sub_low_call(isnan(sigma_sub_low_call))=0;
        sigma_sub_low_put=VXO_info{6,14};sigma_sub_low_put(isnan(sigma_sub_low_put))=0;
        sigma_sub_up_call=VXO_info{7,14};sigma_sub_up_call(isnan(sigma_sub_up_call))=0;
        sigma_sub_up_put=VXO_info{8,14};sigma_sub_up_put(isnan(sigma_sub_up_put))=0;
        
        if strcmp(scope,'call')
            sigma_near_low_put=sigma_near_low_call;
            sigma_near_up_put=sigma_near_up_call;
            sigma_sub_low_put=sigma_sub_low_call;
            sigma_sub_up_put=sigma_sub_up_call;
        elseif strcmp(scope,'put')
            sigma_near_low_call=sigma_near_low_put;
            sigma_near_up_call=sigma_near_up_put;
            sigma_sub_low_call=sigma_sub_low_put;
            sigma_sub_up_call=sigma_sub_up_put;
        end
        
        current_trade_date=datestr(datenum(temp_date(5:end),'yyyymmdd'),'yyyy-mm-dd');
        remain_trade_days_near=VXO_info{1,19};
        remain_trade_days_sub=VXO_info{5,19};
        
        sigma_near_low=(sigma_near_low_call+sigma_near_low_put)/2;
        sigma_near_up=(sigma_near_up_call+sigma_near_up_put)/2;
        sigma_sub_low=(sigma_sub_low_call+sigma_sub_low_put)/2;
        sigma_sub_up=(sigma_sub_up_call+sigma_sub_up_put)/2;  
        
        strike_low=min(cell2mat(VXO_info(1:4,7)));
        strike_up=max(cell2mat(VXO_info(1:4,7)));
        sigma_near=sigma_near_low*(strike_up-us_close)/(strike_up-strike_low)+...
            sigma_near_up*(us_close-strike_low)/(strike_up-strike_low);
        strike_low=min(cell2mat(VXO_info(5:8,7)));
        strike_up=max(cell2mat(VXO_info(5:8,7)));
        sigma_sub=sigma_sub_low*(strike_up-us_close)/(strike_up-strike_low)+...
            sigma_sub_up*(us_close-strike_low)/(strike_up-strike_low);
        
        if iscell(sigma_near) || iscell(sigma_sub)
            disp('警告！')
        end
        VXO_impv=sigma_near*(remain_trade_days_sub-22)/(remain_trade_days_sub-remain_trade_days_near)+...
            sigma_sub*(22-remain_trade_days_near)/(remain_trade_days_sub-remain_trade_days_near);
    end
end