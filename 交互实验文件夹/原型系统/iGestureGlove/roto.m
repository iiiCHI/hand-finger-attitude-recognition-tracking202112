% 读取 PNG 文件
originalImage = imread('your_image.png');

% 设置旋转角度的步长
stepAngle = 1; % 1度

% 创建保存旋转图片的文件夹
mkdir('rotated_images');

% 获取图像的中心坐标
centerX = size(originalImage, 2) / 2;
centerY = size(originalImage, 1) / 2;

% 创建圆形蒙版
[maskX, maskY] = meshgrid(1:size(originalImage, 2), 1:size(originalImage, 1));
radius = size(originalImage, 2) / 2;
mask = (maskX - centerX).^2 + (maskY - centerY).^2 <= radius^2;

% 360°循环
for angle = 0:stepAngle:359
    % 旋转图片
    rotatedImage = imrotate(originalImage, angle, 'bilinear', 'crop');
    
    % 应用圆形蒙版
    maskedRotatedImage = rotatedImage;
    maskedRotatedImage(repmat(~mask, [1, 1, size(rotatedImage, 3)])) = 0;
    
    % 计算旋转后图像的外接矩形大小
    diagLength = sqrt(sum(size(maskedRotatedImage).^2));
    outputSize = ceil([diagLength diagLength]);
    
    % 创建与原始图像相同大小的透明图像
    transparentImage = uint8(zeros(size(originalImage)));
    
    % 计算旋转后图像的中心坐标
    rotatedCenterX = size(maskedRotatedImage, 2) / 2;
    rotatedCenterY = size(maskedRotatedImage, 1) / 2;
    
    % 计算旋转后图像在透明图像中的位置
    offsetX = round(centerX - rotatedCenterX);
    offsetY = round(centerY - rotatedCenterY);
    
    % 在透明图像中绘制旋转后的图像
    transparentImage(offsetY+1:offsetY+size(maskedRotatedImage,1), offsetX+1:offsetX+size(maskedRotatedImage,2), :) = maskedRotatedImage;
    
    % 将逻辑数组转换为 uint8 类型，表示 alpha 通道
    alphaChannel = uint8(any(transparentImage > 0, 3)) * 255;
    
    % 保存包含 alpha 通道的 PNG 图像
    angleStr = num2str(angle, '%d');
    imwrite(transparentImage, ['rotated_images/rotated_image_' angleStr '.png'], 'Alpha', alphaChannel);
end
