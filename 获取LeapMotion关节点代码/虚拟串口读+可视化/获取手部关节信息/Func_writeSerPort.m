function Func_writeSerPort(SerialNumber,DataMtx)
%FUNC_WRITESERPORT 这个函数的功能是将数据写进Serial串口中
% 第一个是串口信息
% 输出是是否成功
fwrite(SerialNumber, DataMtx)
end

