function [M] = Func_getGyroRotateMatrix(g)

    M = [    0,  g(1),  g(2),  g(3);
         -g(1),     0, g(3),  -g(2);
         -g(2),  -g(3),     0, g(1);
         -g(3), g(2),  -g(1),    0];
end