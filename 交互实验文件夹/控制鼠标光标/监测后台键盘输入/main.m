fprintf('按下 "p" 键以结束程序...\n');

while true
    % 检测键盘输入
    if kbhit
        key = getkey;
        % 如果检测到 "p" 键，则退出循环
        if key == 'p'
            fprintf('程序已结束。\n');
            break;
        end
    end
    
    % 打印自然数
    fprintf('%d\n', randi(100)); % 这里使用 randi(100) 生成一个随机的自然数，您可以根据需要更改生成自然数的方式
end

function key = getkey
    % 此函数用于获取键盘输入
    [~,~,keyCode] = KbWait([], 2);
    key = KbName(keyCode);
end

function result = kbhit
    % 此函数用于检测键盘是否有输入
    result = false;
    [~,~,keyCode] = KbCheck;
    if any(keyCode)
        result = true;
    end
end
