clear;

% UserId = 8;
% 记录特征的矩阵
Features_Rst = [];%是难度x轮数x人数x6x特征个数
Features_Act = [];%是难度x轮数x人数x6x特征个数
Features_Tar = [];%是难度x轮数x人数x6x特征个数

%FistFea = reshape(Features_Tar(1,:,:,:,:),[30*9,6*14]);//用来提取某一个难度的特征的
                                         % 怎么分的呢，先按照轮数，1-30轮，往后是人数，
                                         % 后面是，先按照IMU的6个参数，再按照特征去划分。
for UserId = 1:9
    disp(['UserId:',num2str(UserId)])
    % 指定CSV文件路径
    % 使用readmatrix函数读取CSV文件数据（包括表头）
    dataIMU     = readmatrix(['./DataSet/UserId_',num2str(UserId),'_RowImu.csv']);
    dataAction  = readmatrix(['./DataSet/UserId_',num2str(UserId),'_UserAction.csv']);
    CountFeature = 1;
    % 获取矩阵的行数
    numRows = size(dataAction, 1);
    for index = 1:numRows
    % for index = 7:7
        currentRow = dataAction(index, :);    
        if currentRow(8) == 0
            continue;
        end
        % 获取第14列的数据
        column14 = dataIMU(:, 14);    
        % RstStart,RstEnd
        Rst = [];
        Act = [];
        Tar = [];
        
        
        % 创建逻辑索引，找到满足条件的行
        logicalIndex = column14 > currentRow(3) & column14 < currentRow(4);
        % 使用逻辑索引筛选矩阵的行
        Rst = dataIMU(logicalIndex, :);
        % 创建逻辑索引，找到满足条件的行
        logicalIndex = column14 > currentRow(5) & column14 < currentRow(6);
        % 使用逻辑索引筛选矩阵的行
        Act = dataIMU(logicalIndex, :);
        % 创建逻辑索引，找到满足条件的行
        logicalIndex = column14 > currentRow(7) & column14 < currentRow(8);
        % 使用逻辑索引筛选矩阵的行
        Tar = dataIMU(logicalIndex, :);
        
        disp(['ID:',num2str(currentRow(1)),'  Round',num2str(currentRow(2))])
        
        for Fature_index = 1:6
            if size(Tar,1)>1400
                [Features_Tar(floor(currentRow(1)/90)+1,currentRow(2),UserId,Fature_index,:),After_Tar] = Calu_Feature(Tar(:,Fature_index),222);
            else
                disp(['False UserId:',num2str(UserId),'  Round:',num2str(currentRow(2)),' Tar Size error:',num2str(size(Tar(:,Fature_index)))])
            end
            
            if size(Act,1)>200
                [Features_Act(floor(currentRow(1)/90)+1,currentRow(2),UserId,Fature_index,:),After_Act] = Calu_Feature(Act(:,Fature_index),222);
            else
                disp(['False UserId:',num2str(UserId),'  Round:',num2str(currentRow(2)),' Act Size error:',num2str(size(Act(:,Fature_index)))])
            end
            if size(Rst,1)>1400
                [Features_Rst(floor(currentRow(1)/90)+1,currentRow(2),UserId,Fature_index,:),After_Rst] = Calu_Feature(Rst(:,Fature_index),222);
           else
                disp(['False UserId:',num2str(UserId),'  Round:',num2str(currentRow(2)),' Rst Size error:',num2str(size(Rst(:,Fature_index)))])
            end   
        end
    %     CountFeature = CountFeature+1;
    end
end
% 均方根是均方根的平均强度（Mean Intensity，MI）：
% 这是用来量化震颤强度的参数。
% MI是三个轴上均方根（RMS）值的平均值。
% 在震颤分析中，RMS通常用来表示信号的振幅。
% 在Matlab中，你可以使用rms函数来计算信号的均方根值。
% 颤抖的主频率（Dominant Frequency of Tremor，FT）：
% 
% 这是用来量化震颤频率的参数。
% 使用SPECTROGRAM函数来生成时间-频率谱图，从中估计颤抖的主频率。

wlable = ['x','y','z'];

AGIndex = 3;
FeaIndex = 1;%1均值,2均方根,3-5四分位点【1，2，3】，6标准差，7峰值，8峰峰值，4-6hz强度，6-12hz强度、颤抖的主频率（Dominant Frequency of Tremor，FT）
figure;
for AGIndex = 4:6
    subplot(3,1,AGIndex-3);
    hold on
%     plot(sort(Features_Act(:,AGIndex,FeaIndex),'descend'))
%     plot(sort(Features_Rst(:,AGIndex,FeaIndex),'descend'))
%     plot(sort(Features_Tar(:,AGIndex,FeaIndex),'descend'))
    plot(Features_Act(1,:,AGIndex-3,FeaIndex))
    plot(Features_Rst(1,:,AGIndex-3,FeaIndex))
    plot(Features_Tar(1,:,AGIndex-3,FeaIndex))
    % 添加标题和标签
%     title(['陀螺仪',wlable(AGIndex-3),'轴：静止性震颤信号（4Hz-6Hz）']);
    title(['陀螺仪',wlable(AGIndex-3),'轴：运动性震颤信号（6Hz-12hz）']);    
    ylabel('功率谱密度');
end
% 添加图例
xlabel('交互轮数序号');
legend('intention tremor', 'res area', 'target area');



% % 画图，滤波前后的信号
% figure;
% subplot(2,1,1)
% plot([1:size(After_Tar,1)]/222,Tar(:,Fature_index),'blue')
% legend('滤波前');
% ylabel('角速度 deg/s');
% subplot(2,1,2)
% plot([1:size(After_Tar,1)]/222,After_Tar,'red')
% legend('滤波后');
% xlabel('时间 s');
% ylabel('角速度 deg/s');


% AGIndex = 6;
% FeaIndex = 4;%1均值,均方根,2-4四分位点【1，2，3】，5标准差，6峰值，7峰峰值，4-6hz强度，6-12hz强度
% for FeaIndex = 1:10
%     figure(FeaIndex);
%     subplot(3,1,1);
%     plot(Features_Act(:,AGIndex,FeaIndex))
%     figure(FeaIndex);
%     subplot(3,1,2);
%     plot(Features_Rst(:,AGIndex,FeaIndex))
%     figure(FeaIndex);
%     subplot(3,1,3);
%     plot(Features_Tar(:,AGIndex,FeaIndex))
% end

