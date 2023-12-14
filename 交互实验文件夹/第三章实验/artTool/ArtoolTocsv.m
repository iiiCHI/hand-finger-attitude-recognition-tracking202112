%% 这个文件用于生成artool的对齐秩变换的值的
load('../data.mat')

for i = 1:24

    % 创建示例字符串数组
    stringCon = repmat({'Con'}, 34, 1);
    stringUnc = repmat({'Unc'}, 34, 1);
    Id = 1:68;
    
    % 将字符串和数据矩阵合并成一个表格
    dataTable = table(Id',[stringCon;stringUnc], [round(data(:,i),4);round(data(:,i+24),4)], 'VariableNames', {'Id','Group', 'Value'});
    
    % 指定要保存的CSV文件名
    csvFileName = sprintf(".\\Data%d.csv",i);
    
    % 使用writetable函数将表格写入CSV文件
    writetable(dataTable, csvFileName);
    
    fprintf('CSV文件已创建：%s\n', csvFileName);

end