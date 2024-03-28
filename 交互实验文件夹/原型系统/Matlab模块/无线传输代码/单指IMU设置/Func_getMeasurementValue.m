function [Z_k, R_k,Qacc,Qmag] = Func_getMeasurementValue(a, m, Sigma_u)
%% 通过加速度计与磁力计计算得到观测值的结果。
% 输入为三轴加速度计，三轴磁力计。
% 输出为 每一轮的观测值
% compute the measurement from acc and mag data
% notice: code is copyed from ../BaseKalmanFilter_raw.m
ax = a(1);
ay = a(2);
az = a(3);
mx = m(1);
my = m(2);
mz = m(3);

% compute Qacc

if az >= 0
    
    lambda_1 = sqrt((az+1)/2);
    
    Qacc = [lambda_1; -ay/(2*lambda_1); ax/(2*lambda_1); 0];
    
else
    
    lambda_2 = sqrt((1-az)/2);
    
    Qacc = [-ay/(2*lambda_2); lambda_2; 0; ax/(2*lambda_2)];
end

% compute the intermediate frame
% l = Func_getQuarRotateMatrix([Qacc(1);-Qacc(2);-Qacc(3);-Qacc(4)]).'*[mx;my;mz];
l = Func_getQuarRotateMatrix(Qacc).'*[mx;my;mz];
lx = l(1);
ly = l(2);
lz = l(3);
Gamma = lx^2 + ly^2;

% compute Qmag
if lx >= 0
    
    Qmag = [(Gamma+lx*(Gamma)^(1/2))^(1/2) / (2*Gamma)^(1/2);
            0;
            0;
            ly / (2*(Gamma+lx*(Gamma)^(1/2)))^(1/2)];
            %这个ly是<0的。符号不统一啊。
else
        
    Qmag = [ly / (2*(Gamma-lx*(Gamma)^(1/2)))^(1/2);
            0;
            0;
           (Gamma-lx*(Gamma)^(1/2))^(1/2) / (2*Gamma)^(1/2)];
end

% compute the measurement using Qacc and Qmag
Z_k = Func_crossProduct(Qacc, Qmag);

Qacc0 = Qacc(1);
Qacc1 = Qacc(2);
Qacc2 = Qacc(3);
Qacc3 = Qacc(4);
Qmag0 = Qmag(1);
Qmag3 = Qmag(4);

%% Update Gain

if az >= 0
    
    h = sqrt(1+az);
    ZpartialQacc = [Qmag0, 0,      0,     -Qmag3;
                         0,     Qmag0,  Qmag3, 0;
                         0,     -Qmag3, Qmag0, 0;
                     Qmag3, 0,      0,     Qmag0];
    ZpartialQmag = [Qacc0, -Qacc1, Qacc2, 0;
                    Qacc1, Qacc0,  0,     Qacc2;
                    Qacc2, 0,      Qacc0, -Qacc1;
                    0,     -Qacc2, Qacc1, Qacc0];
    Zpartialf1 = [ZpartialQacc ZpartialQmag];
    
    f1partialacc = [0,   0,    1/h;
                    0,   -2/h, ay/(h^3);
                    2/h, 0,    -ax/(h^3);
                    0,   0,    0];
    if lx >= 0
        
        beta1 = sqrt(Gamma+lx*sqrt(Gamma));
        f1partialmag = [(ly^2)/(beta1*Gamma),      (lx*ly)/(beta1*Gamma),   0;
                        0,                         0,                       0;
                        0,                         0,                       0;
                        -(ly*beta1)/(Gamma^(3/2)), (lx*beta1)/(Gamma^(3/2)), 0];
        
    else
        
        beta2 = sqrt(Gamma-lx*sqrt(Gamma));
        f1partialmag = [(ly*beta2)/(Gamma^(3/2)), (lx*beta2)/(Gamma^(3/2)), 0;
                        0,                        0,                        0;
                        0,                        0,                        0;
                        -(ly^2)/(beta2*Gamma),    (lx*ly)/(beta2*Gamma),    0];
        
    end
    
    f1partialf2 = [f1partialacc, zeros(4,3);
        zeros(4,3),  f1partialmag]/sqrt(8);
    
    f2partiala = [eye(3) zeros(3)];
    f2partiallx = [mz-(2*ax*mx+ay*my)/(h^2), (-ax*my)/(h^2), ax*(ax*mx+ay*my)/(h^4), 1-(ax/h)^2, -(ax*ay)/(h^2), ax];
    f2partially = [(-ay*mx)/(h^2), mz-(ax*mx+2*ay*my)/(h^2), ay*(ax*mx+ay*my)/(h^4), -(ax*ay)/(h^2), 1-(ay/h)^2, ay];
    f2partiallz = [-mx, -my, mz, -ax, -ay, az];
    f2partialu = [f2partiala; f2partiallx; f2partially; f2partiallz];
    
else
    % az<0 的情况
    
    h = sqrt(1-az);
    ZpartialQacc = [Qmag0, 0,      0,    -Qmag3;
                        0,     Qmag0,  Qmag3, 0;
                        0,     -Qmag3, Qmag0, 0;
                    Qmag3, 0,      0,     Qmag0];
    ZpartialQmag = [Qacc0, -Qacc1, 0,      -Qacc3;
                    Qacc1, Qacc0,  -Qacc3,      0;
                    0,     Qacc3,  Qacc0,  -Qacc1;
                    Qacc3, 0,      Qacc1,  Qacc0];
    Zpartialf1 = [ZpartialQacc ZpartialQmag];
    
    f1partialacc = [0,   -2/h, -ay/(h^3);
                    0,   0,    -1/h;
                    0,   0,    0;
                    2/h, 0,    ax/(h^3)];
    if lx >= 0
        
        beta1 = sqrt(Gamma+lx*sqrt(Gamma));
        f1partialmag = [(ly^2)/(beta1*Gamma),      -(lx*ly)/(beta1*Gamma),   0;
                        0,                         0,                        0;
                        0,                         0,                        0;
                        -(ly*beta1)/(Gamma^(3/2)), (lx*beta1)/(Gamma^(3/2)), 0];
        
    else
        
        beta2 = sqrt(Gamma-lx*sqrt(Gamma));
        f1partialmag = [(ly*beta2)/(Gamma^(3/2)), -(lx*beta2)/(Gamma^(3/2)), 0;
                         0,                        0,                        0;
                         0,                        0,                        0;
                         -(ly^2)/(beta2*Gamma),    (lx*ly)/(beta2*Gamma),    0];
        
    end
    
    f1partialf2 = [f1partialacc, zeros(4,3);
        zeros(4,3),  f1partialmag]/sqrt(8);
    
    f2partiala = [eye(3) zeros(3)];
    f2partiallx = [mz-(2*ax*mx-ay*my)/(h^2),    (ax*my)/(h^2),   ax*(-ax*mx+ay*my)/(h^4),    1-(ax/h)^2,     -(ax*ay)/(h^2), ax];
    f2partially = [(-ay*mx)/(h^2),   mz-(ax*mx-2*ay*my)/(h^2),   ay*(-ax*mx+ay*my)/(h^4),    -(ax*ay)/(h^2), -1+(ay/h)^2,    ay];
    f2partiallz = [mx,               -my,                        -mz,                        ax,             ay,             -az];
    f2partialu = [f2partiala; f2partiallx; f2partially; f2partiallz];
    
end

Jacobi = Zpartialf1 * f1partialf2 * f2partialu;
R_k = Jacobi * Sigma_u * Jacobi';