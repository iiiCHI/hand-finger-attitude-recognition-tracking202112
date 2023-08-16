% 生成示例数据
data = randperm(100);

% 定义滑动窗口大小和中值存储容器
window_size = 5;
num_elements = numel(data);
medians = zeros(1, num_elements - window_size + 1);

% 滑动窗口计算中值
for i = 1:num_elements - window_size + 1
    window = data(i:i+window_size-1);
    sorted_window = sort(window);
    medians(i) = median(sorted_window);
end

disp("原始数据:");
disp(data);
disp("滑动窗口按递增顺序的中值:");
disp(medians);
