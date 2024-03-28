clc,clear,close all;
IMU_num = 3;
disp('…………开始…………');
tc = tcpserver('192.168.1.103',8080,"Timeout",3);
tc.InputBufferSize = 30000;
disp('等待网络串口接入：\n');
while tc.Connected == 0
   pause(0.5);
end
disp('串口接入成功，循环读取数据:\n');
flush(tc)
mtx = [];
flag = 0;
count = 0;
dtm = datetime;
count_pre = 0;
while tc.Connected > 0
    count = count+1;
    try
%         data_rcv = fscanf(tc,'%f')';
% %         disp(data_rcv);
%         if length(data_rcv) ~= IMU_num*9+1
%             flag = flag + 1;
%             disp(string(count)+'->'+string(flag)+'->'+string(length(data_rcv))+"平均时间为:"+string(seconds(datetime - dtm)/(count-count_pre)));
%             count_pre = count;
%             dtm = datetime;
%         else
%             mtx(end+1,:) = data_rcv;
%         end
%% 在这个是用readline做的
        data_rcv = str2num(readline(tc));
        if length(data_rcv) ~= IMU_num*9+1
            flag = flag + 1;
            disp(string(count)+'->'+string(flag)+'->'+string(length(data_rcv))+"平均时间为:"+string(seconds(datetime - dtm)/(count-count_pre)));
            count_pre = count;
            dtm = datetime;
        else
            mtx(end+1,:) = data_rcv;
        end
%         mtx(end+1,:) = data_rcv;
    catch
        disp('Error');
        break;
    end
end
disp('运行结束,开始校准磁力计');
% 
% for i = 1 : length(mtx)
%     for v = 1:length(mtx(i,:))
%         if abs(mtx(i,v))>1000 || abs(mtx(i,v))==0
%             mtx(i,v) = mtx(i-1,v);
%         end
%     end
% end
% 
mag_calibration(mtx,IMU_num)
% disp('运行结束');
% plot3(mtx(:,3*9-2),mtx(:,3*9-1),mtx(:,3*9),'LineStyle','none','Marker','X','MarkerSize',8)



%% 1 
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



