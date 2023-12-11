%% 这个文件是用于区分三种交互状态下的、各自的、准确率
%% 用于机器学习分类的

clc;clear;
load('9位同学的特征.mat');
%%临时保存所有的特征，然后求九个人的均值。或者是求3*9=27个，都可以
FistFea_Tar = reshape(Features_Tar(1,:,:,:,:),[30*9,6*14]);
SecFea_Tar = reshape(Features_Tar(2,:,:,:,:),[30*9,6*14]);
ThrFea_Tar = reshape(Features_Tar(3,:,:,:,:),[30*9,6*14]);

FistFea_Rst = reshape(Features_Rst(1,:,:,:,:),[30*9,6*14]);
SecFea_Rst = reshape(Features_Rst(2,:,:,:,:),[30*9,6*14]);
ThrFea_Rst = reshape(Features_Rst(3,:,:,:,:),[30*9,6*14]);

FistFea_Act = reshape(Features_Act(1,:,:,:,:),[30*9,6*14]);
SecFea_Act = reshape(Features_Act(2,:,:,:,:),[30*9,6*14]);
ThrFea_Act = reshape(Features_Act(3,:,:,:,:),[30*9,6*14]);

%% 数据预处理
% 找到所有元素均为0的行
rowsToDelete = all(FistFea_Tar == 0, 2);
% 删除所有元素均为0的行
FistFea_Tar(rowsToDelete, :) = [];

% 找到所有元素均为0的行
rowsToDelete = all(SecFea_Tar == 0, 2);
% 删除所有元素均为0的行
SecFea_Tar(rowsToDelete, :) = [];

% 找到所有元素均为0的行
rowsToDelete = all(ThrFea_Tar == 0, 2);
% 删除所有元素均为0的行
ThrFea_Tar(rowsToDelete, :) = [];

% 找到所有元素均为0的行
rowsToDelete = all(FistFea_Rst == 0, 2);
% 删除所有元素均为0的行
FistFea_Rst(rowsToDelete, :) = [];

% 找到所有元素均为0的行
rowsToDelete = all(SecFea_Rst == 0, 2);
% 删除所有元素均为0的行
SecFea_Rst(rowsToDelete, :) = [];

% 找到所有元素均为0的行
rowsToDelete = all(ThrFea_Act == 0, 2);
% 删除所有元素均为0的行
ThrFea_Act(rowsToDelete, :) = [];

% 找到所有元素均为0的行
rowsToDelete = all(FistFea_Act == 0, 2);
% 删除所有元素均为0的行
FistFea_Act(rowsToDelete, :) = [];

% 找到所有元素均为0的行
rowsToDelete = all(SecFea_Act == 0, 2);
% 删除所有元素均为0的行
SecFea_Act(rowsToDelete, :) = [];

% 找到所有元素均为0的行
rowsToDelete = all(ThrFea_Act == 0, 2);
% 删除所有元素均为0的行
ThrFea_Act(rowsToDelete, :) = [];



%1均值,2均方根,3-5四分位点【1，2，3】，6标准差，7峰值，
% 8峰峰值，4-6hz强度，6-12hz强度、11:颤抖的主频率（Dominant Frequency of Tremor，FT）
%12:篇度，13峰度，14，自回归系数
%按照六轴来的，6*n个


% 设置种子
rng(0);  % 保证结果的重复计算仍一致

%% 区分三种IAT  应该是区分三种IAT下各自的准确率 
disp('-----第一种难度------');
data1 = FistFea_Act; 
data2 = FistFea_Tar; 
data3 = FistFea_Rst;


xlables = ["Mean","RMS","Q1","Q2","Q3","SD","PV","PPV","LPSD","HPSD","FT","m3","m4","R"];
% 归一化
data1 = zscore(data1);
data2 = zscore(data2);
data3 = zscore(data3);

index = 0;
% 相关性检验 《筛选特征》《真吐了----》
AllData = [data1(:,index*14+1:index*14+14);data2(:,index*14+1:index*14+14);data3(:,index*14+1:index*14+14)];
% AllData = [data1;data2;data3];


% 计算斯皮尔曼等级相关系数
rho = corr(AllData, 'type', 'Spearman');


% 画出相关系数图
figure;
imagesc(rho);
colorbar;
title('Spearman Rank Correlation for Top 14 Features');
xlabel('Features');
ylabel('Features');
% 添加相关系数标签
[row, col] = size(rho);
for i = 1:row
    for j = 1:col
        text(j, i, sprintf('%.2f', rho(i, j)), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
    end
end
xticks(1:14);
xticklabels(xlables);
yticks(1:14);
yticklabels(xlables);

% 合并数据和标签
data = [data1; data2; data3];
labels = [repmat('F', size(data1, 1), 1); repmat('S', size(data2, 1), 1); repmat('T', size(data3, 1), 1)];

%% 列出要删除的特征，删除10和14
columns_to_delete = [];
for index_delete = 0:5
    columns_to_delete = [columns_to_delete,10+index_delete*14,14+index_delete*14];
end
data(:,columns_to_delete) = [];




% 随机打乱数据
idx = randperm(size(data, 1));
data = data(idx, :);
labels = labels(idx, :);

% 划分数据集为训练集和测试集
splitRatio = 0.8; % 80% 的数据用于训练，20%用于测试
splitIdx = round(splitRatio * size(data, 1));

trainData = data(1:splitIdx, :);
trainLabels = labels(1:splitIdx, :);
testData = data(splitIdx+1:end, :);
testLabels = labels(splitIdx+1:end, :);

% 使用交叉验证进行模型训练和评估
numFolds = 5; % 5折交叉验证
cv = cvpartition(size(trainData, 1), 'KFold', numFolds);

% 存储每个模型的评估指标
svmMetrics = zeros(numFolds, 4);
knnMetrics = zeros(numFolds, 4);
treeMetrics = zeros(numFolds, 4);
nbMetrics = zeros(numFolds, 4);

for fold = 1:numFolds
    % 获取当前交叉验证的训练和测试集
    trainIndices = training(cv, fold);
    testIndices = test(cv, fold);

    foldTrainData = trainData(trainIndices, :);
    foldTrainLabels = trainLabels(trainIndices, :);
    foldTestData = trainData(testIndices, :);
    foldTestLabels = trainLabels(testIndices, :);

    % 使用支持向量机（SVM）进行分类
    svmModel = fitcecoc(foldTrainData, foldTrainLabels);
    svmPredictions = predict(svmModel, foldTestData);
    svmMetrics(fold, :) = calculateMetrics(foldTestLabels, svmPredictions);

    % 使用k最近邻（KNN）进行分类
    knnModel = fitcknn(foldTrainData, foldTrainLabels);
    knnPredictions = predict(knnModel, foldTestData);
    knnMetrics(fold, :) = calculateMetrics(foldTestLabels, knnPredictions);

    % 使用决策树进行分类
    treeModel = fitctree(foldTrainData, foldTrainLabels);
    treePredictions = predict(treeModel, foldTestData);
    treeMetrics(fold, :) = calculateMetrics(foldTestLabels, treePredictions);

    % 使用朴素贝叶斯进行分类
    nbModel = fitcnb(foldTrainData, foldTrainLabels);
    nbPredictions = predict(nbModel, foldTestData);
    nbMetrics(fold, :) = calculateMetrics(foldTestLabels, nbPredictions);
end

% 计算每个模型的平均评估指标
svmAverageMetrics = mean(svmMetrics, 1);
knnAverageMetrics = mean(knnMetrics, 1);
treeAverageMetrics = mean(treeMetrics, 1);
nbAverageMetrics = mean(nbMetrics, 1);

% 显示结果
disp(['SVM Average Accuracy: ', num2str(svmAverageMetrics(1)), ', Precision: ', num2str(svmAverageMetrics(2)), ', Recall: ', num2str(svmAverageMetrics(3)), ', F1 Score: ', num2str(svmAverageMetrics(4))]);
disp(['KNN Average Accuracy: ', num2str(knnAverageMetrics(1)), ', Precision: ', num2str(knnAverageMetrics(2)), ', Recall: ', num2str(knnAverageMetrics(3)), ', F1 Score: ', num2str(knnAverageMetrics(4))]);
disp(['Decision Tree Average Accuracy: ', num2str(treeAverageMetrics(1)), ', Precision: ', num2str(treeAverageMetrics(2)), ', Recall: ', num2str(treeAverageMetrics(3)), ', F1 Score: ', num2str(treeAverageMetrics(4))]);
disp(['Naive Bayes Average Accuracy: ', num2str(nbAverageMetrics(1)), ', Precision: ', num2str(nbAverageMetrics(2)), ', Recall: ', num2str(nbAverageMetrics(3)), ', F1 Score: ', num2str(nbAverageMetrics(4))]);



disp('-----第二种难度------');

data1 = SecFea_Act; 
data2 = SecFea_Tar; 
data3 = SecFea_Rst;


xlables = ["Mean","RMS","Q1","Q2","Q3","SD","PV","PPV","LPSD","HPSD","FT","m3","m4","R"];
% 归一化
data1 = zscore(data1);
data2 = zscore(data2);
data3 = zscore(data3);

index = 0;
% 相关性检验 《筛选特征》《真吐了----》
AllData = [data1(:,index*14+1:index*14+14);data2(:,index*14+1:index*14+14);data3(:,index*14+1:index*14+14)];
% AllData = [data1;data2;data3];


% 计算斯皮尔曼等级相关系数
rho = corr(AllData, 'type', 'Spearman');


% 画出相关系数图
figure;
imagesc(rho);
colorbar;
title('Spearman Rank Correlation for Top 14 Features');
xlabel('Features');
ylabel('Features');
% 添加相关系数标签
[row, col] = size(rho);
for i = 1:row
    for j = 1:col
        text(j, i, sprintf('%.2f', rho(i, j)), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
    end
end
xticks(1:14);
xticklabels(xlables);
yticks(1:14);
yticklabels(xlables);

% 合并数据和标签
data = [data1; data2; data3];
labels = [repmat('F', size(data1, 1), 1); repmat('S', size(data2, 1), 1); repmat('T', size(data3, 1), 1)];

%% 列出要删除的特征，删除10和14
columns_to_delete = [];
for index_delete = 0:5
    columns_to_delete = [columns_to_delete,10+index_delete*14,14+index_delete*14];
end
data(:,columns_to_delete) = [];




% 随机打乱数据
idx = randperm(size(data, 1));
data = data(idx, :);
labels = labels(idx, :);

% 划分数据集为训练集和测试集
splitRatio = 0.8; % 80% 的数据用于训练，20%用于测试
splitIdx = round(splitRatio * size(data, 1));

trainData = data(1:splitIdx, :);
trainLabels = labels(1:splitIdx, :);
testData = data(splitIdx+1:end, :);
testLabels = labels(splitIdx+1:end, :);

% 使用交叉验证进行模型训练和评估
numFolds = 5; % 5折交叉验证
cv = cvpartition(size(trainData, 1), 'KFold', numFolds);

% 存储每个模型的评估指标
svmMetrics = zeros(numFolds, 4);
knnMetrics = zeros(numFolds, 4);
treeMetrics = zeros(numFolds, 4);
nbMetrics = zeros(numFolds, 4);

for fold = 1:numFolds
    % 获取当前交叉验证的训练和测试集
    trainIndices = training(cv, fold);
    testIndices = test(cv, fold);

    foldTrainData = trainData(trainIndices, :);
    foldTrainLabels = trainLabels(trainIndices, :);
    foldTestData = trainData(testIndices, :);
    foldTestLabels = trainLabels(testIndices, :);

    % 使用支持向量机（SVM）进行分类
    svmModel = fitcecoc(foldTrainData, foldTrainLabels);
    svmPredictions = predict(svmModel, foldTestData);
    svmMetrics(fold, :) = calculateMetrics(foldTestLabels, svmPredictions);

    % 使用k最近邻（KNN）进行分类
    knnModel = fitcknn(foldTrainData, foldTrainLabels);
    knnPredictions = predict(knnModel, foldTestData);
    knnMetrics(fold, :) = calculateMetrics(foldTestLabels, knnPredictions);

    % 使用决策树进行分类
    treeModel = fitctree(foldTrainData, foldTrainLabels);
    treePredictions = predict(treeModel, foldTestData);
    treeMetrics(fold, :) = calculateMetrics(foldTestLabels, treePredictions);

    % 使用朴素贝叶斯进行分类
    nbModel = fitcnb(foldTrainData, foldTrainLabels);
    nbPredictions = predict(nbModel, foldTestData);
    nbMetrics(fold, :) = calculateMetrics(foldTestLabels, nbPredictions);
end

% 计算每个模型的平均评估指标
svmAverageMetrics = mean(svmMetrics, 1);
knnAverageMetrics = mean(knnMetrics, 1);
treeAverageMetrics = mean(treeMetrics, 1);
nbAverageMetrics = mean(nbMetrics, 1);

% 显示结果
disp(['SVM Average Accuracy: ', num2str(svmAverageMetrics(1)), ', Precision: ', num2str(svmAverageMetrics(2)), ', Recall: ', num2str(svmAverageMetrics(3)), ', F1 Score: ', num2str(svmAverageMetrics(4))]);
disp(['KNN Average Accuracy: ', num2str(knnAverageMetrics(1)), ', Precision: ', num2str(knnAverageMetrics(2)), ', Recall: ', num2str(knnAverageMetrics(3)), ', F1 Score: ', num2str(knnAverageMetrics(4))]);
disp(['Decision Tree Average Accuracy: ', num2str(treeAverageMetrics(1)), ', Precision: ', num2str(treeAverageMetrics(2)), ', Recall: ', num2str(treeAverageMetrics(3)), ', F1 Score: ', num2str(treeAverageMetrics(4))]);
disp(['Naive Bayes Average Accuracy: ', num2str(nbAverageMetrics(1)), ', Precision: ', num2str(nbAverageMetrics(2)), ', Recall: ', num2str(nbAverageMetrics(3)), ', F1 Score: ', num2str(nbAverageMetrics(4))]);



disp('-----第三种难度------');


data1 = ThrFea_Act; 
data2 = ThrFea_Tar; 
data3 = ThrFea_Rst;


xlables = ["Mean","RMS","Q1","Q2","Q3","SD","PV","PPV","LPSD","HPSD","FT","m3","m4","R"];
% 归一化
data1 = zscore(data1);
data2 = zscore(data2);
data3 = zscore(data3);

index = 0;
% 相关性检验 《筛选特征》《真吐了----》
AllData = [data1(:,index*14+1:index*14+14);data2(:,index*14+1:index*14+14);data3(:,index*14+1:index*14+14)];
% AllData = [data1;data2;data3];


% 计算斯皮尔曼等级相关系数
rho = corr(AllData, 'type', 'Spearman');


% 画出相关系数图
figure;
imagesc(rho);
colorbar;
title('Spearman Rank Correlation for Top 14 Features');
xlabel('Features');
ylabel('Features');
% 添加相关系数标签
[row, col] = size(rho);
for i = 1:row
    for j = 1:col
        text(j, i, sprintf('%.2f', rho(i, j)), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
    end
end
xticks(1:14);
xticklabels(xlables);
yticks(1:14);
yticklabels(xlables);

% 合并数据和标签
data = [data1; data2; data3];
labels = [repmat('F', size(data1, 1), 1); repmat('S', size(data2, 1), 1); repmat('T', size(data3, 1), 1)];

%% 列出要删除的特征，删除10和14
columns_to_delete = [];
for index_delete = 0:5
    columns_to_delete = [columns_to_delete,10+index_delete*14,14+index_delete*14];
end
data(:,columns_to_delete) = [];




% 随机打乱数据
idx = randperm(size(data, 1));
data = data(idx, :);
labels = labels(idx, :);

% 划分数据集为训练集和测试集
splitRatio = 0.8; % 80% 的数据用于训练，20%用于测试
splitIdx = round(splitRatio * size(data, 1));

trainData = data(1:splitIdx, :);
trainLabels = labels(1:splitIdx, :);
testData = data(splitIdx+1:end, :);
testLabels = labels(splitIdx+1:end, :);

% 使用交叉验证进行模型训练和评估
numFolds = 5; % 5折交叉验证
cv = cvpartition(size(trainData, 1), 'KFold', numFolds);

% 存储每个模型的评估指标
svmMetrics = zeros(numFolds, 4);
knnMetrics = zeros(numFolds, 4);
treeMetrics = zeros(numFolds, 4);
nbMetrics = zeros(numFolds, 4);

for fold = 1:numFolds
    % 获取当前交叉验证的训练和测试集
    trainIndices = training(cv, fold);
    testIndices = test(cv, fold);

    foldTrainData = trainData(trainIndices, :);
    foldTrainLabels = trainLabels(trainIndices, :);
    foldTestData = trainData(testIndices, :);
    foldTestLabels = trainLabels(testIndices, :);

    % 使用支持向量机（SVM）进行分类
    svmModel = fitcecoc(foldTrainData, foldTrainLabels);
    svmPredictions = predict(svmModel, foldTestData);
    svmMetrics(fold, :) = calculateMetrics(foldTestLabels, svmPredictions);

    % 使用k最近邻（KNN）进行分类
    knnModel = fitcknn(foldTrainData, foldTrainLabels);
    knnPredictions = predict(knnModel, foldTestData);
    knnMetrics(fold, :) = calculateMetrics(foldTestLabels, knnPredictions);

    % 使用决策树进行分类
    treeModel = fitctree(foldTrainData, foldTrainLabels);
    treePredictions = predict(treeModel, foldTestData);
    treeMetrics(fold, :) = calculateMetrics(foldTestLabels, treePredictions);

    % 使用朴素贝叶斯进行分类
    nbModel = fitcnb(foldTrainData, foldTrainLabels);
    nbPredictions = predict(nbModel, foldTestData);
    nbMetrics(fold, :) = calculateMetrics(foldTestLabels, nbPredictions);
end

% 计算每个模型的平均评估指标
svmAverageMetrics = mean(svmMetrics, 1);
knnAverageMetrics = mean(knnMetrics, 1);
treeAverageMetrics = mean(treeMetrics, 1);
nbAverageMetrics = mean(nbMetrics, 1);

% 显示结果
disp(['SVM Average Accuracy: ', num2str(svmAverageMetrics(1)), ', Precision: ', num2str(svmAverageMetrics(2)), ', Recall: ', num2str(svmAverageMetrics(3)), ', F1 Score: ', num2str(svmAverageMetrics(4))]);
disp(['KNN Average Accuracy: ', num2str(knnAverageMetrics(1)), ', Precision: ', num2str(knnAverageMetrics(2)), ', Recall: ', num2str(knnAverageMetrics(3)), ', F1 Score: ', num2str(knnAverageMetrics(4))]);
disp(['Decision Tree Average Accuracy: ', num2str(treeAverageMetrics(1)), ', Precision: ', num2str(treeAverageMetrics(2)), ', Recall: ', num2str(treeAverageMetrics(3)), ', F1 Score: ', num2str(treeAverageMetrics(4))]);
disp(['Naive Bayes Average Accuracy: ', num2str(nbAverageMetrics(1)), ', Precision: ', num2str(nbAverageMetrics(2)), ', Recall: ', num2str(nbAverageMetrics(3)), ', F1 Score: ', num2str(nbAverageMetrics(4))]);



%% 保存Decision Tree的Acc、Call、F1，然后对三种分别、、算了，用Echarts画吧 

% 准备数据
legends = {'强', '中', '弱'};
metrics = {'Accuracy', 'F1 Score', 'Recall'};

data = [
    0.92273, 0.90656, 0.95363;
    0.91521, 0.91519, 0.94615;
    0.91067, 0.93365, 0.97442
];

% 创建柱状图
figure;
b = bar(data);

% 设置图表标题和标签
title('分类结果指标图');
xlabel('Metrics');
ylabel('Values');

% 设置图例
legend(legends, 'Location', 'Best');

% 设置横坐标刻度
set(gca, 'XTickLabel', metrics);

% 设置y轴范围
ylim([0, 1.09]);

% 添加数据标签
for i = 1:length(legends)
    for j = 1:length(metrics)
        text(b(j).XData(i) + 0.3*(j-2), b(j).YData(i) + 0.02, num2str(data(i, j), '%.3f'), ...
            'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
    end
end

% 调整图表布局
grid on;




% 定义函数计算评估指标
function metrics = calculateMetrics(trueLabels, predictedLabels)
    confusionMat = confusionmat(trueLabels, predictedLabels);
    accuracy = sum(diag(confusionMat)) / sum(confusionMat(:));
    precision = confusionMat(2, 2) / sum(confusionMat(:, 2));
    recall = confusionMat(2, 2) / sum(confusionMat(2, :));
    f1Score = 2 * (precision * recall) / (precision + recall);
    metrics = [accuracy, precision, recall, f1Score];
end

