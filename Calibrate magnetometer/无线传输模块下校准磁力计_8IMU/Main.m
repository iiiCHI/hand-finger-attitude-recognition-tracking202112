clc,clear,close all;
disp('…………开始…………');
% tc = tcpserver('192.168.1.103',8080,"Timeout",1);
% tc.InputBufferSize = 30000;
% disp('等待网络串口接入：\n');
% while tc.Connected == 0
%    pause(0.5);
% end
% disp('串口接入成功，循环读取数据:\n');
% flush(tc)

%% UDP连接
% 创建 UDP 对象
udpPort = 8080;  % 选择一个未被使用的端口号
try
fclose(instrfindall('RemoteHost', '192.168.1.103', 'RemotePort', 8080));  % 关闭连接
catch
end
%% 
tc = udp('192.168.1.103', udpPort, 'LocalPort', udpPort);
set(tc, 'InputBufferSize', 4096); % 设置输入缓冲区大小
set(tc, 'Timeout', 2); % 设置等待时间为 5 秒
% 打开 UDP 连接
fopen(tc);
disp(['Listening on UDP port ', num2str(udpPort)]);
%% 
mtx = [];
flag = 0;
count = 0;
dtm = datetime;
count_pre = 0;
while true
    count = count+1;
    try
        data_rcv = fscanf(tc,'%f')';
%         disp(data_rcv);
        if length(data_rcv) ~= 73
            flag = flag + 1;
            disp(string(count)+'->'+string(flag)+'->'+string(length(data_rcv))+"平均时间为:"+string(seconds(datetime - dtm)/(count-count_pre)));
            count_pre = count;
            dtm = datetime;
            if flag >= 21 
                break;
            end
        else
            mtx(end+1,:) = data_rcv;
        end
    catch
        disp('Error');
        break;
    end
end
disp('运行结束,开始校准磁力计');

%% 从文件里读
mtx = readmatrix("date.csv");
%% 结束

for i = 1 : length(mtx)
    for v = 1:length(mtx(i,:))
        if abs(mtx(i,v))>1000
            mtx(i,v) = mtx(i-1,v);
        end
    end
end

mag_calibration8(mtx)
disp('运行结束');
% 
% disp('运行开始')
% tc = tcpserver('192.168.1.103',8080,"Timeout",1);
% disp('等待连接')
% while isempty(tc.select(0.1))
%     disp('');
% end
% client = tc.accept();
% disp('连接成功')
% while true
%     try
%         data = read(client);
%         disp(data)
%     catch
%         disp('Error')
%         break;
%     end
% end
% close(client);



