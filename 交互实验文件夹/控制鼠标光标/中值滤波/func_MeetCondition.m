function [IsMeet] = func_MeetCondition(Quaternion,Col,Range)
% FUNC_MEETCONDITION 这个就是为了看姿态某一项是否符合预期
%   输入：
%       Quaternion： 姿态四元数
%       Col：        第N个数字
%       Range：      范围
%   输出：
%       IsMeet：
%   创始人：马永伟     日期：2023年8月15日
    if Quaternion(Col)>Range
        IsMeet = false;
    else
        IsMeet = true;
    end

end

