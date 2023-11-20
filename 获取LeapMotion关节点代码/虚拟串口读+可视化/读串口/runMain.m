% 人员编号
UserId = 1;
% 手势编号 1：Open、2：OK、3：Close
UserHandId = 1;
UserHandSet = ["Open","OK","Close"];
% Round编号
RoundId = 1;


FileName = (sprintf(".\\data\\UserId-%d\\UserHand-%s\\rowdata%d.csv",UserId,UserHandSet(UserHandId),RoundId));


% 打开CSV文件以读取
fileID = fopen(FileName, 'r');

% 读取文件的每一行
data = textscan(fileID, '%s', 'Delimiter', '\n');

% 关闭文件
fclose(fileID);

% 初始化变量来存储整数和字符串数据
intData = zeros(length(data{1}), 73); % 假设有x行
strData = cell(length(data{1}), 1);

% 处理每一行数据
for i = 1:length(data{1})
    % 将一行数据拆分为单个字段
    fields = strsplit(data{1}{i}, ',');

    % 将前73个字段解析为整数
    intFields = str2double(fields(1:73));

    % 存储整数数据
    intData(i, :) = intFields;

    % 存储第74个字段作为字符串
    strData{i} = fields{74};
end

% 现在intData包含整数数据，strData包含字符串数据
