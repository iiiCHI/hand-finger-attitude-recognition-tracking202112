
scoms = instrfindall;
stopasync(scoms);
fclose(scoms);

%д����
% SerialNumber = serial("COM20", 'BaudRate', 115200);
% fopen(SerialNumber);
% DataMtx = [9,9,9];
% % Func_writeSerPort(SerialNumber,DataMtx);
% for i = 1:10    
%     fprintf(SerialNumber, 66666);
% end
% disp('д��˳���')
%�����ݣ�������
SerialNumber2 = serial('COM20', 'BaudRate', 115200);
SerialNumber2.Timeout = 3;
% s = serial(serialPort, 'BaudRate', 512000);

% s.BytesAvailableFcnMode='byte';  % ��������
SerialNumber2.InputBufferSize=4096;
SerialNumber2.OutputBufferSize=4096;
fopen(SerialNumber2);
while true
%     cc = str2double(strsplit(fscanf(SerialNumber2,'%f,'), ','))
    cc = fscanf(SerialNumber2,'%f,')';
    length(cc)
end

scoms = instrfindall;
stopasync(scoms);
fclose(scoms);
