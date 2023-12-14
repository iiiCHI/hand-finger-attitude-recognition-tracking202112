% clc;clear;
% HandFigAttitude = readmatrix("../DataAns/DataAnsEul.csv");
% 
% AnsMtxCon = [];
% AnsMtxUnc = [];
% 
% for i = 1:3:length(HandFigAttitude)
%     TempRowCon = [];
%     TempRowUnc = [];
%     for j = 1:6
%         %这个是保存，5~22的值
%         t1 = HandFigAttitude(i,4+j*3-2:4+j*3);
%         FigCon = abs(t1)-abs(HandFigAttitude(i+1,4+j*3-2:4+j*3));
%         FigUnc = abs(t1)-abs(HandFigAttitude(i+2,4+j*3-2:4+j*3));
%         % 1,2 / 1交替取，一个手指取三个值，一共取9个值
%         TempRowCon = [TempRowCon,FigCon];
%         TempRowUnc = [TempRowUnc,FigUnc];
%     end
%     AnsMtxCon = [AnsMtxCon;TempRowCon(:,[1, 2, 4, 7, 8, 10, 13, 14, 16])];
%     AnsMtxUnc = [AnsMtxUnc;TempRowUnc(:,[1, 2, 4, 7, 8, 10, 13, 14, 16])];
% end
% 
% 
% 
% AnsConOk = [];
% AnsConOpen = [];
% AnsConClose = [];
% AnsUncOk = [];
% AnsUncOpen = [];
% AnsUncClose = [];
% 
% 
% %% 先取出所有人OK的，所有人OPEN的，所有人CLOSE的
% %% 再取出关节角度的。
% for i = 1:12    
%     %12个人，J是1-3，
%     TempMtxUnc = AnsMtxUnc((i-1)*30+1:i*30,:);
%     TempMtxCon = AnsMtxCon((i-1)*30+1:i*30,:);
%     % 这个如何做？
%     AnsConOk = [AnsConOk;TempMtxCon(1:10,:)];
%     AnsConOpen = [AnsConOpen;TempMtxCon(11:20,:)];
%     AnsConClose = [AnsConClose;TempMtxCon(21:30,:)];
%     AnsUncOk = [AnsUncOk;TempMtxUnc(1:10,:)];
%     AnsUncOpen = [AnsUncOpen;TempMtxUnc(11:20,:)];
%     AnsUncClose = [AnsUncClose;TempMtxUnc(21:30,:)];
%     % 保存，拇指掌指关节，弯曲和偏航。近指关节的弯曲
%     % 保存，食指掌指关节，弯曲和偏航。近指关节的弯曲
%     % 保存，中指掌指关节，弯曲和偏航。近指关节的弯曲    
% end
% 


clc;clear;
HandFigAttitude = readmatrix("../DataAns/DataAnsQuaOnlyValue.csv");

AnsMtxCon = [];
AnsMtxUnc = [];

for i = 1:3:length(HandFigAttitude)
    TempRowCon = [];
    TempRowUnc = [];
    for j = 1:6
        %这个是保存，1~24的值
        t1 = HandFigAttitude(i,j*4-3:j*4);
%         t1(4) = t1(2);
%         t1(2) = HandFigAttitude(i,j*4);
        if dot(HandFigAttitude(i+1,j*4-3:j*4),t1)>0
            HandFigAttitude(i+1,j*4-3) = -HandFigAttitude(i+1,j*4-3);
        end
        if dot(HandFigAttitude(i+2,j*4-3:j*4),t1)>0
            HandFigAttitude(i+2,j*4-3) = -HandFigAttitude(i+2,j*4-3);
        end
        TempRowCon = [TempRowCon,Func_crossProductFuT(HandFigAttitude(i+1,j*4-3:j*4),t1)];
        TempRowUnc = [TempRowUnc,Func_crossProductFuT(HandFigAttitude(i+2,j*4-3:j*4),t1)];
    end
    AnsMtxCon = [AnsMtxCon;TempRowCon];
    AnsMtxUnc = [AnsMtxUnc;TempRowUnc];
end

%% 这个是分出角度来
EulUnc = [];
EulCon = [];
for i=1:6 %啥意思？PIP两个，MCP一个
    TempUnc = quat2eul(AnsMtxUnc(:,i*4-3:i*4),'XYZ');
    TempCon = quat2eul(AnsMtxCon(:,i*4-3:i*4),'XYZ');
    if mod(i,2) == 1
        EulUnc = [EulUnc,TempUnc(:,[1, 2])];%拇指食指掌指近指关节
        EulCon = [EulCon,TempCon(:,[1, 2])];%拇指食指掌指近指关节
    else
        EulUnc = [EulUnc,TempUnc(:,1)];%拇指食指掌指中指关节
        EulCon = [EulCon,TempCon(:,1)];%拇指食指掌指中指关节
    end
%     EulUnc = [EulUnc,TempUnc];%拇指食指掌指近指关节
%     EulCon = [EulCon,TempCon];%拇指食指掌指近指关节
end

%% 这个是把两种方法，三个变量分出来
AnsConOk = zeros(12,9);
AnsConOpen = zeros(12,9);
AnsConClose = zeros(12,9);
AnsUncOk =  zeros(12,9);
AnsUncOpen =  zeros(12,9);
AnsUncClose =  zeros(12,9);


%% 先取出所有人OK的，所有人OPEN的，所有人CLOSE的

%% 再取出关节角度的。
for i = 1:12    
    %12个人，J是1-3，
    TempMtxUnc = EulUnc((i-1)*30+1:i*30,:);
    TempMtxCon = EulCon((i-1)*30+1:i*30,:);
    % 这个如何做？

    % 遍历每一列
    for j = 1:9
        % 获取元素
        non_zero_elements = TempMtxCon(1:10,j);
        non_zero_elements = non_zero_elements(abs(non_zero_elements) < 20);
        
        % 计算均值并赋值给结果矩阵
        if ~isempty(non_zero_elements)
            AnsConOpen(i, j) = mean(non_zero_elements);
        end
    end
%     AnsConOk = [AnsConOk;TempMtxCon(1:10,:)];
    %%% 遍历每一列
    for j = 1:9
        % 获取当前子区间元素
        non_zero_elements = TempMtxCon(11:20,j);
        non_zero_elements = non_zero_elements(abs(non_zero_elements) < 20);
        
        % 计算均值并赋值给结果矩阵
        if ~isempty(non_zero_elements)
            AnsConOk(i, j) = mean(non_zero_elements);
        end
    end

%     AnsConOpen = [AnsConOpen;TempMtxCon(11:20,:)];
    %%% 遍历每一列
    for j = 1:9
        % 获取当前子区间元素
        non_zero_elements = TempMtxCon(21:30,j);
        non_zero_elements = non_zero_elements(abs(non_zero_elements) < 20);
        
        % 计算均值并赋值给结果矩阵
        if ~isempty(non_zero_elements)
            AnsConClose(i, j) = mean(non_zero_elements);
        end
    end
%     AnsConClose = [AnsConClose;TempMtxCon(21:30,:)];
    % 遍历每一列
    for j = 1:9
        % 获取当前子区间元素
        non_zero_elements = TempMtxUnc(1:10,j);
        non_zero_elements = non_zero_elements(abs(non_zero_elements) < 20);
        
        % 计算均值并赋值给结果矩阵
        if ~isempty(non_zero_elements)
            AnsUncOpen(i, j) = mean(non_zero_elements);
        end
    end
%     AnsConOk = [AnsConOk;TempMtxCon(1:10,:)];
    %%% 遍历每一列
    for j = 1:9
        % 获取当前子区间元素
        non_zero_elements = TempMtxUnc(11:20,j);
        non_zero_elements = non_zero_elements(abs(non_zero_elements) < 20);
        
        % 计算均值并赋值给结果矩阵
        if ~isempty(non_zero_elements)
            AnsUncOk(i, j) = mean(non_zero_elements);
        end
    end

%     AnsConOpen = [AnsConOpen;TempMtxCon(11:20,:)];
    %%% 遍历每一列
    for j = 1:9
        % 获取当前子区间元素
        non_zero_elements = TempMtxUnc(21:30,j);
        non_zero_elements = non_zero_elements(abs(non_zero_elements) < 20);
        
        % 计算均值并赋值给结果矩阵
        if ~isempty(non_zero_elements)
            AnsUncClose(i, j) = mean(non_zero_elements);
        end
    end
%     AnsUncOk = [AnsUncOk;TempMtxUnc(1:10,:)];
%     AnsUncOpen = [AnsUncOpen;TempMtxUnc(11:20,:)];
%     AnsUncClose = [AnsUncClose;TempMtxUnc(21:30,:)];
    % 保存，拇指掌指关节，弯曲和偏航。近指关节的弯曲
    % 保存，食指掌指关节，弯曲和偏航。近指关节的弯曲
    % 保存，中指掌指关节，弯曲和偏航。近指关节的弯曲    
end

% %剔除异常值
% AnsUncOk(abs(AnsUncOk)>20)=0;
% AnsConOk(abs(AnsConOk)>20)=0;
% AnsUncOpen(abs(AnsUncOpen)>20)=0;
% AnsConOpen(abs(AnsConOpen)>20)=0;
% AnsUncClose(abs(AnsUncClose)>20)=0;
% AnsConClose(abs(AnsConClose)>20)=0;


%% 取出每个人的四元数的,前12个是open,然后是ok，然后是close
QueCon = zeros(36,24);
QueUnc = zeros(36,24);
for i = 0:11   
    %Open
    QueCon(i+1,:) = mean(abs(AnsMtxCon(i*30+1:i*30+10,:)));
    QueUnc(i+1,:) = mean(abs(AnsMtxUnc(i*30+1:i*30+10,:)));
    %OK
    QueCon(i+1+12,:) = mean(abs(AnsMtxCon(i*30+11:i*30+20,:)));
    QueUnc(i+1+12,:) = mean(abs(AnsMtxUnc(i*30+11:i*30+20,:)));
    %Close
    QueCon(i+1+24,:) = mean(abs(AnsMtxCon(i*30+21:i*30+30,:)));
    QueUnc(i+1+24,:) = mean(abs(AnsMtxUnc(i*30+21:i*30+30,:)));
%     % 归一化操作
%     for j=1:6
%         for k = 0:2
%             QueCon(i+1+k*12,1+(j-1)*4:j*4) = QueCon(i+1+k*12,1+(j-1)*4:j*4)/norm(QueCon(i+1+k*12,1+(j-1)*4:j*4));
%             QueUnc(i+1+k*12,1+(j-1)*4:j*4) = QueUnc(i+1+k*12,1+(j-1)*4:j*4)/norm(QueUnc(i+1+k*12,1+(j-1)*4:j*4));
%         end
%     end

end


%% 判断有无显著差异
data1 = [AnsConClose(:,6);AnsConOk(:,6);AnsConOpen(:,6)];
data2 = [AnsUncClose(:,6);AnsUncOk(:,6);AnsUncOpen(:,6)];

qua1 = data1;
qua2 = data2;

data1 = quat2eul(qua1,'XYZ');
data2 = quat2eul(qua2,'XYZ');

data = data1;

% 正态分布检验
[h, p] = lillietest(data);

% 显示结果
disp(['正态分布检验的p值为: ', num2str(p)]);
disp(['H0假设是否被拒绝: ', num2str(h)]);

% 判断是否符合正态分布
if h == 0
    disp('数据符合正态分布。');
else
    disp('数据不符合正态分布。');
end


% 将数据合并为一个矩阵
data = [data1(:,1); data2(:,1)];

% 创建组别标签
group = [ones(length(data1), 1); 2*ones(length(data2), 1)];

% 进行单因素方差分析
[p, tbl, stats] = anova1(data, group, 'off'); % 'off'参数用于关闭显示ANOVA表格

% 从ANOVA表中获取F值和p值
F_value = tbl{2, 5};  % F值在ANOVA表的第2行第5列
p_value = tbl{2, 6};  % p值在ANOVA表的第2行第6列

% 显示结果
disp(['ANOVA的F值为: ', num2str(F_value)]);
disp(['ANOVA的p值为: ', num2str(p_value)]);


