% 假设你的数据存储在名为 Act、Tst 和 Tar 的变量中

% 数据预处理
numClasses = 3;
numItemsPerClass = 30;
numFeatures = 6 * 11;
Act = Features_Act;
Rst = Features_Rst;
Tar = Features_Tar;
% 将数据整理成矩阵形式，每一行代表一个数据项
data = cat(1, reshape(Act, [numItemsPerClass, numFeatures]), ...
           reshape(Rst, [numItemsPerClass, numFeatures]), ...
           reshape(Tar, [numItemsPerClass, numFeatures]));

% 为每一类生成相应的标签
labels = repelem(1:numClasses, numItemsPerClass)';

% 数据重塑
data = reshape(data, size(data, 1), []);
% 数据分割为训练集和测试集
rng(1); % 设置随机数生成种子，以确保可重复性
cv = cvpartition(labels, 'HoldOut', 0.2); % 将数据分割成训练集和测试集，这里将20%的数据用作测试集

%% 划分训练集和测试集
dataTrain = data(training(cv), :);
labelsTrain = labels(training(cv), :);
dataTest = data(test(cv), :);
labelsTest = labels(test(cv), :);

% 选择多类别分类算法
classifier = fitcecoc(dataTrain, labelsTrain); % 使用多类别分类

% 模型训练
model = fitcecoc(dataTrain, labelsTrain); % 使用多类别分类

% 模型评估
predictions = predict(model, dataTest); % 使用测试数据进行预测
confusion_matrix = confusionmat(labelsTest, predictions); % 计算混淆矩阵
accuracy = sum(diag(confusion_matrix)) / sum(confusion_matrix(:)); % 计算准确性

disp(['准确性: ', num2str(accuracy)]);

%% 选择其他算法模型
% 选择不同的分类算法
% 决策树
tree_model = fitctree(dataTrain, labelsTrain);
tree_predictions = predict(tree_model, dataTest);

% 支持向量机 (SVM)
svm_model = fitcecoc(dataTrain, labelsTrain);
svm_predictions = predict(svm_model, dataTest);

% K最近邻 (K-NN)
knn_model = fitcknn(dataTrain, labelsTrain, 'NumNeighbors', 3);
knn_predictions = predict(knn_model, dataTest);

% 模型评估
confusion_matrix_tree = confusionmat(labelsTest, tree_predictions);
accuracy_tree = sum(diag(confusion_matrix_tree)) / sum(confusion_matrix_tree(:));
disp(['决策树准确性: ', num2str(accuracy_tree)]);

confusion_matrix_svm = confusionmat(labelsTest, svm_predictions);
accuracy_svm = sum(diag(confusion_matrix_svm)) / sum(confusion_matrix_svm(:));
disp(['SVM准确性: ', num2str(accuracy_svm)]);

confusion_matrix_knn = confusionmat(labelsTest, knn_predictions);
accuracy_knn = sum(diag(confusion_matrix_knn)) / sum(confusion_matrix_knn(:));
disp(['K-NN准确性: ', num2str(accuracy_knn)]);


% 计算准确性
disp(['准确性: ', num2str(accuracy)]);

% 计算召回率、精确率和F1分数
precision = diag(confusion_matrix) ./ sum(confusion_matrix, 1)';
recall = diag(confusion_matrix) ./ sum(confusion_matrix, 2);
f1Score = 2 * (precision .* recall) ./ (precision + recall);

disp(['召回率: ', num2str(mean(recall))]);
disp(['F1分数: ', num2str(mean(f1Score))]);

%% 决策树
% 计算准确性
disp(['决策树准确性: ', num2str(accuracy_tree)]);

% 计算召回率、精确率和F1分数
precision_tree = diag(confusion_matrix_tree) ./ sum(confusion_matrix_tree, 1)';
recall_tree = diag(confusion_matrix_tree) ./ sum(confusion_matrix_tree, 2);
f1Score_tree = 2 * (precision_tree .* recall_tree) ./ (precision_tree + recall_tree);

disp(['决策树召回率: ', num2str(mean(recall_tree))]);
disp(['决策树F1分数: ', num2str(mean(f1Score_tree))]);

%% SVM
% 计算准确性
disp(['SVM准确性: ', num2str(accuracy_svm)]);

% 计算召回率、精确率和F1分数
precision_svm = diag(confusion_matrix_svm) ./ sum(confusion_matrix_svm, 1)';
recall_svm = diag(confusion_matrix_svm) ./ sum(confusion_matrix_svm, 2);
f1Score_svm = 2 * (precision_svm .* recall_svm) ./ (precision_svm + recall_svm);

disp(['SVM召回率: ', num2str(mean(recall_svm))]);
disp(['SVMF1分数: ', num2str(mean(f1Score_svm))]);

%% K-NN
% 计算准确性
disp(['K-NN准确性: ', num2str(accuracy_knn)]);

% 计算召回率、精确率和F1分数
precision_knn = diag(confusion_matrix_knn) ./ sum(confusion_matrix_knn, 1)';
recall_knn = diag(confusion_matrix_knn) ./ sum(confusion_matrix_knn, 2);
f1Score_knn = 2 * (precision_knn .* recall_knn) ./ (precision_knn + recall_knn);

disp(['K-NN召回率: ', num2str(mean(recall_knn))]);
disp(['K-NNF1分数: ', num2str(mean(f1Score_knn))]);

