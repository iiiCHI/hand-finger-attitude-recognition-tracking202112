% 读取 PNG 文件
originalImage = imread('your_image.png');

% 创建保存缩小图片的文件夹
mkdir('zoom_images');

% 设置缩小倍率
zoomFactors = linspace(2.01, 8, 600); % 从0.1到1，共100个数

for i = 1:numel(zoomFactors)
    % 缩小图片并设置背景色为透明
    zoomedImage = imresize(originalImage, zoomFactors(i), 'Antialiasing', true);
    
    % 生成文件名
    filename = sprintf('zoom_images/zoom_缩小倍率%.2f.png', zoomFactors(i));
    
    % 保存缩小后的图片
    imwrite(zoomedImage, filename, 'Alpha', uint8(any(zoomedImage ~= 0, 3)) * 255);
end
