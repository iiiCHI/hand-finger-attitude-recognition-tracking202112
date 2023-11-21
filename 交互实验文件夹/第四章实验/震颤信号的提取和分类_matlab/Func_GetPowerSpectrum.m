function [PSlog,PSf] = Func_GetPowerSpectrum(RowData,fs)
%FUNC_GETPOWERSPECTRUM 这个函数是用来求功率谱的，输入为原始数据，输出为功率谱结果
%   输入参数为：原始数据和采样率
    [PSlog,PSf] = pwelch(RowData, [], [], [], fs);
    PSlog = 10*log10(PSlog);
end

