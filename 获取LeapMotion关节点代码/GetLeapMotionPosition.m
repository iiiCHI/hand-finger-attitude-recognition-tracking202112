import Leap.*
controller = Controller;
while true
    frame = controller.frame();
    hands = frame.hands();
    
    for i = 1:hands.count()
        hand = hands.get(i);
        fingers = hand.fingers();
        
        for j = 1:fingers.count()
            finger = fingers.get(j);
            bone = finger.bone(Bone.Type.TYPE_DISTAL);
            position = bone.nextJoint();
            
            x = position.getX();
            y = position.getY();
            z = position.getZ();
            
            % 在此处进行处理或输出手部关键点坐标
            disp(['手指', num2str(j), '坐标 (X:', num2str(x), ', Y:', num2str(y), ', Z:', num2str(z), ')']);
        end
    end
end
