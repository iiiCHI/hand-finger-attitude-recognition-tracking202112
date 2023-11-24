function [DataFeature] = Func_GetFeature(RowData,FS)
%FUNC_GETFEATURE 这个函数是为了获取这个波形的各项特征。
%   输入：
%       RowData：原始数据
%       FS：采样率
%   输出：
%       DataFeature 数据的特征，包括偏度m3、峰度m4
    

    %% 使用函数拟合数据到正态分布
    data = RowData;
    m3 = skewness(data);% 计算数据的偏度、m3
    m4 = kurtosis(data);% 计算数据的峰度、m4
    %% 计算时间反演
    Rj = 0;% 这是计算差异立方体的值
    %% 涉及点和滞后点之间的差异立方体
    for j = 1:size(data,1)-1
        fz = 0;
        fm = 0;
        for i = j+1:size(data,1)
            fz = fz + (data(i)-data(i-j))^3;
            fm = fm + data(i)^2;
        end
        Rj = max(Rj,fz/(fm^(2/3)));
    end
end



%% 绘制直方图
% data = After_Tar;
% % 使用fitdist函数拟合数据到正态分布
% pd = fitdist(data, 'Normal');
% 
% % 绘制原始数据的直方图
% histogram(data, 'Normalization', 'pdf');
% hold on;
% 
% % 绘制拟合的正态分布曲线
% x = linspace(min(data), max(data), 100);
% y = pdf(pd, x);
% plot(x, y, 'LineWidth', 2);
% 
% title('拟合高斯分布示例');
% xlabel('数据值');
% ylabel('概率密度');
% 
% legend('原始数据直方图', '拟合的正态分布');
% hold off;
