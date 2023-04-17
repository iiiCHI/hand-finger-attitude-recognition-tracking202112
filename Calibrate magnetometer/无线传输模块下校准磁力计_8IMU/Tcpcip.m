% 指定本机IP地址和端口号
ip = '192.168.1.103'; % 监听所有网络接口
port = 8080;

% 创建TCP服务器并打开监听
tcpServerObj = tcpserver(ip, port);
tcpServerObj.InputBufferSize = 30000; % 设置接收数据的缓冲区大小
% start(tcpServerObj);
disp('等待客户端连接...');

% 接受客户端连接
tcpClientObj = accept(tcpServerObj);
disp('客户端已连接');
for i = 1:10
% 接收数据
    dataReceived = read(tcpClientObj, tcpClientObj.NumBytesAvailable);
    disp(dataReceived)
end
% 发送数据
% dataToSend = 'Hello, client!';
% write(tcpClientObj, dataToSend);

% 关闭连接
disp('关闭连接...');
close(tcpClientObj);
close(tcpServerObj);