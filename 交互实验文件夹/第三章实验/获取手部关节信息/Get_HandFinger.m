clc;clear;
Hand_posture_ans = zeros(1,28);
Unconstrained_Hand_posture_ans = zeros(1,28);
for UserId = 1:12
    for UserHandId = 1:3
        for RoundId = 0:9
            % 人员信息
%             UserId = 1;
            % 手势编号 1：Open、2：OK、3：Close
%             UserHandId = 1;
            UserHandSet = ["Open","OK","Close"];
            % Round编号
%             RoundId = 1;
            fprintf("Human-Id%d--GestureId%d---Times%d\n",UserId,UserHandId,RoundId);
            HandFigAttitude = readmatrix(sprintf("..\\DataSet\\HumanId%d\\HumanId%dGestureId%d\\Times%ddata.csv",UserId,UserId,UserHandId,RoundId));
            % HandFigAttitude = readmatrix(".\Times0data.csv");
            % for i = 1:20
            %     HandFigAttitude(:,i*4-3:i*4) = Func_crossProductFuAll([cos(pi/4),0,-sin(pi/4),0],HandFigAttitude(:,i*4-3:i*4));
            % end
            % 里面包含了80个数据，为4*4*5 表示 五根手指（拇指、食指、中指、无名指、小指）的四个骨节姿态
            HandPosture = Func_getHandPosture(HandFigAttitude,3,2);
            RowData = readmatrix(sprintf("..\\DataRaw\\UserId-%d\\UserHand-%s\\rawDataTimes%d.csv",UserId,UserHandSet(UserHandId),RoundId));
            %滤波，去除噪声值
            RowData = smoothdata(RowData,"rlowess",5);
            [Hand_posture_ans,Unconstrained_Hand_posture_ans] = Func_GetKalManData(RowData,8);
            rawEul = [];
            UncEul = [];
            ConEul = [];
            %滤波，去除噪声值
            HandPosture = smoothdata(HandPosture,"rlowess",5);
            for i=1:6
                rawEul = [rawEul,quat2eul(HandPosture(:,i*4-3:i*4),'ZYX')/pi*180];%分别是
                UncEul = [UncEul,quat2eul(Unconstrained_Hand_posture_ans(:,4+i*4-3:4+i*4),'XYZ')/pi*180];%食指掌指关节
                ConEul = [ConEul,quat2eul(Hand_posture_ans(:,4+i*4-3:4+i*4),'XYZ')/pi*180];%食指掌指关节
            end
            
            EulValueRaw = [max(rawEul);min(rawEul);mean(rawEul)];
            EulValueUnc = [max(UncEul);min(UncEul);mean(UncEul)];
            EulValueCon = [max(ConEul);min(ConEul);mean(ConEul)];
            
            QuaRaw = [max(HandPosture);min(HandPosture);mean(HandPosture)];
            QuaCon = [max(Hand_posture_ans(:,5:end));min(Hand_posture_ans(:,5:end));mean(Hand_posture_ans(:,5:end))];
            QuaUncon = [max(Unconstrained_Hand_posture_ans(:,5:end));min(Unconstrained_Hand_posture_ans(:,5:end));mean(Unconstrained_Hand_posture_ans(:,5:end))];
            
            %% 保存到一个csv里面
            FileAnsEul = "..\DataAns\DataAnsEul.csv";
            FileAnsQua = "..\DataAns\DataAnsQua.csv";
            %第一行为第1个人的第一轮的，要最大最小吗？不要吧，只要个平均值就行吧。
            %SavaData = [;min(ConEul);min(UncEul)];%分别是，原始，有约束，无约束
            SavaDataEul = [table({UserId,UserHandSet(UserHandId),RoundId,'Tru',min(rawEul)});table({UserId,UserHandSet(UserHandId),RoundId,'Con',min(ConEul)});table({UserId,UserHandSet(UserHandId),RoundId,'Unc',min(UncEul)})];
            %writematrix(Title, FileAns, 'WriteMode', 'append');
            SavaDataQua = [table({UserId,UserHandSet(UserHandId),RoundId,'Tru',QuaRaw(2,:)});table({UserId,UserHandSet(UserHandId),RoundId,'Con',QuaCon(2,:)});table({UserId,UserHandSet(UserHandId),RoundId,'Unc',QuaUncon(2,:)})];
            writetable(SavaDataEul, FileAnsEul, 'WriteMode', 'append');
            writetable(SavaDataQua, FileAnsQua, 'WriteMode', 'append');

        end

    end
end
