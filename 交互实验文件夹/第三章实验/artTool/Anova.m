%% 这个主要是为了进行Anova检验的
p_value = zeros(24,1);
F_value = zeros(24,1);
eta_squared = zeros(24,1);

for i = 1:24
    csvFileName = sprintf(".\\Data%d.art.csv",i);
    % 创建示例数据
    
    data = readtable(csvFileName);
    
    % 进行一元方差分析（ANOVA）
    [p_value(i), tbl, stats]= anova1([table2array(data(1:34,5)), table2array(data(35:68,5))], [], 'off');
    F_value(i) = tbl{2, 5}; % 从第2行（组间）和第5列（F值）提取F值
    eta_squared(i) = tbl{2,2} / (tbl{2,2} + tbl{4,2});
end