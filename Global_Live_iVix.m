%% 0. 准备设定
clc
clear all
addpath('0.Data\')
addpath('1.GUI\')
addpath('2.Pic\')
addpath('3.Protected\')
addpath('4.Temp\')
Protected_Config;
global cSetupPlatform

%% 1. 获取期权列表
Protected_Fetch_OptionList;

%% 2. 断点续传
Protected_Load_Today;

%% 2. 主循环
disp('Main Loop Start')
while true
    dNow = datevec(now);
    nNow = dNow(4) * 100 + dNow(5);
    if (nNow >= 0930 && nNow<= 1130) || (nNow >= 1300 && nNow <= 1500)
        % 2.1 获取实时期权数据
        Protected_Fetch_OptionMarketData;
        
        % 2.2 计算实时ivix
        Protected_Cal_Vix;

        % 2.3 GUI呈现
        try
            GUI_Fig;
        catch
            if cSetupPlatform.GUI.IsOpen
            else
                Protected_Save_Data;
            end
        end
        
    elseif nNow > 1500
        %% 3 收盘后进行日级数据结算
        Protected_Save_Data;
        break
        
    else
        %% 4 盘中以及早盘休息
        if nNow ~= 1135
        else
            Protected_Save_Data;
            Protected_Send_Mail;
            pause(60)
        end
        
    end
end

%% 4. 收盘后计算当日vix指数
Protected_Send_Mail;
