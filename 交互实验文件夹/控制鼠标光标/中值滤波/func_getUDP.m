% 创建 UDP 对象
udpPort = 8080;  % 选择一个未被使用的端口号
udpObj = udp('192.168.1.103', udpPort, 'LocalPort', udpPort);
set(udpObj, 'InputBufferSize', 4096); % 设置输入缓冲区大小
set(udpObj, 'Timeout', 2); % 设置等待时间为 5 秒
% 打开 UDP 连接
fopen(udpObj);

disp(['Listening on UDP port ', num2str(udpPort)]);

try
    while true
        % 从 UDP 端口读取数据
        %data = fread(udpObj, udpObj.InputBufferSize);
        Input = fscanf(udpObj,'%f')'; 
        % 处理接收到的数据
        % 这里可以根据你的需求对接收到的数据进行处理
        
        disp(Input);
    end
catch ME
    % 发生错误或者按下 Ctrl+C 停止时关闭连接
    fclose(udpObj);
    delete(udpObj);
    clear udpObj;
    rethrow(ME);
end


% 强制关闭 UDP 连接
udpPort = 8080;  % 设置连接的端口号
try
    fclose(instrfindall('RemoteHost', '192.168.1.103', 'RemotePort', udpPort));  % 关闭连接
catch
end

