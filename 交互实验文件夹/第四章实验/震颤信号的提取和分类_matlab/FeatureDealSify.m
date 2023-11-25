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



% 设置种子
rng(1);  % 保证结果的重复计算仍一致

%% 区分三种交互意图
data1 = FistFea_Act; 
data2 = SecFea_Act; 
data3 = ThrFea_Act;
% 合并数据和标签
data = [data1; data2; data3];
labels = [repmat('F', size(data1, 1), 1); repmat('S', size(data2, 1), 1); repmat('T', size(data3, 1), 1)];


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

% 分类和计算准确率，F1分数，召回率
% 计算分类器模型
% 使用支持向量机（SVM）进行分类
svmModel = fitcecoc(trainData, trainLabels);
svmPredictions = predict(svmModel, testData);

% 使用k最近邻（KNN）进行分类
knnModel = fitcknn(trainData, trainLabels);
knnPredictions = predict(knnModel, testData);

% 使用决策树进行分类
treeModel = fitctree(trainData, trainLabels);
treePredictions = predict(treeModel, testData);

% 使用朴素贝叶斯进行分类
nbModel = fitcnb(trainData, trainLabels);
nbPredictions = predict(nbModel, testData);

% 计算混淆矩阵
svmConfusionMat = confusionmat(testLabels, svmPredictions);
knnConfusionMat = confusionmat(testLabels, knnPredictions);
treeConfusionMat = confusionmat(testLabels, treePredictions);
nbConfusionMat = confusionmat(testLabels, nbPredictions);

% 计算准确度、F1分数和召回率
svmAccuracy = sum(diag(svmConfusionMat)) / sum(svmConfusionMat(:));
svmPrecision = svmConfusionMat(2, 2) / sum(svmConfusionMat(:, 2));
svmRecall = svmConfusionMat(2, 2) / sum(svmConfusionMat(2, :));
svmF1Score = 2 * (svmPrecision * svmRecall) / (svmPrecision + svmRecall);

knnAccuracy = sum(diag(knnConfusionMat)) / sum(knnConfusionMat(:));
knnPrecision = knnConfusionMat(2, 2) / sum(knnConfusionMat(:, 2));
knnRecall = knnConfusionMat(2, 2) / sum(knnConfusionMat(2, :));
knnF1Score = 2 * (knnPrecision * knnRecall) / (knnPrecision + knnRecall);

treeAccuracy = sum(diag(treeConfusionMat)) / sum(treeConfusionMat(:));
treePrecision = treeConfusionMat(2, 2) / sum(treeConfusionMat(:, 2));
treeRecall = treeConfusionMat(2, 2) / sum(treeConfusionMat(2, :));
treeF1Score = 2 * (treePrecision * treeRecall) / (treePrecision + treeRecall);

nbAccuracy = sum(diag(nbConfusionMat)) / sum(nbConfusionMat(:));
nbPrecision = nbConfusionMat(2, 2) / sum(nbConfusionMat(:, 2));
nbRecall = nbConfusionMat(2, 2) / sum(nbConfusionMat(2, :));
nbF1Score = 2 * (nbPrecision * nbRecall) / (nbPrecision + nbRecall);


% 显示结果
disp(['SVM Accuracy: ', num2str(svmAccuracy), ', Precision: ', num2str(svmPrecision), ', Recall: ', num2str(svmRecall), ', F1 Score: ', num2str(svmF1Score)]);
disp(['KNN Accuracy: ', num2str(knnAccuracy), ', Precision: ', num2str(knnPrecision), ', Recall: ', num2str(knnRecall), ', F1 Score: ', num2str(knnF1Score)]);
disp(['Decision Tree Accuracy: ', num2str(treeAccuracy), ', Precision: ', num2str(treePrecision), ', Recall: ', num2str(treeRecall), ', F1 Score: ', num2str(treeF1Score)]);
disp(['Naive Bayes Accuracy: ', num2str(nbAccuracy), ', Precision: ', num2str(nbPrecision), ', Recall: ', num2str(nbRecall), ', F1 Score: ', num2str(nbF1Score)]);





disp('-----------');
%% 进行三种行为的分类

data1 = [FistFea_Act;SecFea_Act;ThrFea_Act]; 
data2 = [FistFea_Rst;SecFea_Rst;ThrFea_Rst]; 
data3 = [FistFea_Tar;SecFea_Tar;ThrFea_Tar];

% 合并数据和标签
data = [data1; data2; data3];
labels = [repmat('F', size(data1, 1), 1); repmat('S', size(data2, 1), 1); repmat('T', size(data3, 1), 1)];


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

% 分类和计算准确率，F1分数，召回率

% 使用支持向量机（SVM）进行分类
svmModel = fitcecoc(trainData, trainLabels);
% 使用k最近邻（KNN）进行分类
knnModel = fitcknn(trainData, trainLabels);
% 使用决策树进行分类
treeModel = fitctree(trainData, trainLabels);
% 使用朴素贝叶斯进行分类
nbModel = fitcnb(trainData, trainLabels);
% 使用支持向量机（SVM）进行分类
svmPredictions = predict(svmModel, testData);
% 使用k最近邻（KNN）进行分类
knnPredictions = predict(knnModel, testData);
% 使用决策树进行分类
treePredictions = predict(treeModel, testData);
% 使用朴素贝叶斯进行分类
nbPredictions = predict(nbModel, testData);

% 计算混淆矩阵
svmConfusionMat = confusionmat(testLabels, svmPredictions);
knnConfusionMat = confusionmat(testLabels, knnPredictions);
treeConfusionMat = confusionmat(testLabels, treePredictions);
nbConfusionMat = confusionmat(testLabels, nbPredictions);

% 计算准确度、F1分数和召回率
svmAccuracy = sum(diag(svmConfusionMat)) / sum(svmConfusionMat(:));
svmPrecision = svmConfusionMat(2, 2) / sum(svmConfusionMat(:, 2));
svmRecall = svmConfusionMat(2, 2) / sum(svmConfusionMat(2, :));
svmF1Score = 2 * (svmPrecision * svmRecall) / (svmPrecision + svmRecall);

knnAccuracy = sum(diag(knnConfusionMat)) / sum(knnConfusionMat(:));
knnPrecision = knnConfusionMat(2, 2) / sum(knnConfusionMat(:, 2));
knnRecall = knnConfusionMat(2, 2) / sum(knnConfusionMat(2, :));
knnF1Score = 2 * (knnPrecision * knnRecall) / (knnPrecision + knnRecall);

treeAccuracy = sum(diag(treeConfusionMat)) / sum(treeConfusionMat(:));
treePrecision = treeConfusionMat(2, 2) / sum(treeConfusionMat(:, 2));
treeRecall = treeConfusionMat(2, 2) / sum(treeConfusionMat(2, :));
treeF1Score = 2 * (treePrecision * treeRecall) / (treePrecision + treeRecall);

nbAccuracy = sum(diag(nbConfusionMat)) / sum(nbConfusionMat(:));
nbPrecision = nbConfusionMat(2, 2) / sum(nbConfusionMat(:, 2));
nbRecall = nbConfusionMat(2, 2) / sum(nbConfusionMat(2, :));
nbF1Score = 2 * (nbPrecision * nbRecall) / (nbPrecision + nbRecall);


% 显示结果
disp(['SVM Accuracy: ', num2str(svmAccuracy), ', Precision: ', num2str(svmPrecision), ', Recall: ', num2str(svmRecall), ', F1 Score: ', num2str(svmF1Score)]);
disp(['KNN Accuracy: ', num2str(knnAccuracy), ', Precision: ', num2str(knnPrecision), ', Recall: ', num2str(knnRecall), ', F1 Score: ', num2str(knnF1Score)]);
disp(['Decision Tree Accuracy: ', num2str(treeAccuracy), ', Precision: ', num2str(treePrecision), ', Recall: ', num2str(treeRecall), ', F1 Score: ', num2str(treeF1Score)]);
disp(['Naive Bayes Accuracy: ', num2str(nbAccuracy), ', Precision: ', num2str(nbPrecision), ', Recall: ', num2str(nbRecall), ', F1 Score: ', num2str(nbF1Score)]);


