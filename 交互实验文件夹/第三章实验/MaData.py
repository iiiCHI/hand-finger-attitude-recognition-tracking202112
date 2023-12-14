import pandas as pd

filePath = r"G:\\myw\\研究生阶段文档\\毕业流程规范\\A论文\\实验"
userNum = 12   #用户数量，更改这里
for i in range(1,userNum+1):
    for j in range(1,4):
        if j == 1:
            gestureType = "OPEN"
        elif j == 2:
            gestureType = "OK"
        else:
            gestureType = "CLOSE"
        df2 = pd.read_csv(
            filePath + "\DataRaw" + r"\UserId-" + str(i) + r"\UserHand-" + gestureType + r"\rowdata1.csv",header=None)
        for z in range(0,10):
            df = pd.read_csv(
                filePath +"\DataSet"+ "\HumanId"+str(i) + "\HumanId"+str(i)+"GestureId" + str(j) + r"\Times" + str(
                    z) + "data.csv",header=None)
            savePath = filePath + "\DataRaw" + r"\UserId-" + str(i) + r"\UserHand-" + gestureType + r"\rawDataTimes"+str(z)+".csv"
            startTime = float(df.iloc[0,-1])
            endTime = float(df.iloc[-1,-1])
            selectedRows = df2[(df2.iloc[:,-1]>=startTime) & (df2.iloc[:,-1]<=endTime)]
            selectedRows.to_csv(savePath,header=None,index=False)



