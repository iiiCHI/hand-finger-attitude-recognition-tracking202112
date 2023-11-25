function aver = Func_cacluAver(data,numGroups)
    % 将数据平均分成numGroups组
    groupSize = size(data, 1) / numGroups;
    
    % 初始化一个存储平均值的矩阵
    averageData = zeros(numGroups, size(data, 2));
    
    % 计算每组的均值
    for i = 1:numGroups
        startIdx = round((i - 1) * groupSize) + 1;
        endIdx = round(i * groupSize);
        averageData(i, :) = mean(data(startIdx:endIdx, :));
    end
    aver = averageData;
end