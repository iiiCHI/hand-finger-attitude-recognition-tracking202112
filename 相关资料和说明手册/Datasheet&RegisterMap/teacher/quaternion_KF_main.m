% This is the main program of the Bilinear Quaternion-based Kalman filter
% designed for estimating attitude of a body.
%
% The pseudo-measurement is used here in order to transform the non-linear observation
% equation to a linear one.
%
% This program calls three other routines:
%   - converg: the external algorithm, can be Gauss-Newton or Newton
%
% By Haipeng Wang, Nov. 2018
%
% Date          Author          Notes
% 11/04/2018    haipeng wang    Initial release
% 12/06/2018    haipeng wang    2nd release, correct the drift problem,
% forgot to delete the inv() function as replacing it with / operator.

% addpath('/Users/haipengwang/BoxSync/navigation/attitude_estimation/matlab/iAttitudeEstimator201809/kalman_filter/');      % include quaternion library
% addpath('/Users/haipengwang/BoxSync/navigation/attitude_estimation/matlab/iAttitudeEstimator201809/external_algorithm/');      % include quaternion library
% addpath('/Users/haipengwang/BoxSync/navigation/attitude_estimation/matlab/iAttitudeEstimator201809/quaternion_library/');      % include quaternion library

clc; clear;

MS2S = 1e-6;

%% command window output to a log file
% diary iiDiaryFile;


%% reading measurements from series port.
delete(instrfindall);

% config serial port
% create a serial port obj
serialPort = 'COM3';
s = serial(serialPort, 'BaudRate', 115200);
fopen(s); % connect to the device.
if strcmp(s.Status, 'closed')
    return;
elseif  strcmp(s.Status, 'open')
    disp('open');
end

disp('Start...');
timestamp_prev = 0;


%% demo vector for plot
figure;
grid;
axis equal;
axis([-2 2 -2 2 -2 2]);
hx = animatedline('DisplayName', 'X', 'Color', 'b', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
hy = animatedline('DisplayName', 'Y', 'Color', 'r', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
hz = animatedline('DisplayName', 'Z', 'Color', 'g', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
title('AE, X-blue, Y-red, Z-green');


%% Used for external converg algorithm
% define gravity and Earth magnetic field vector in earth frame (_n).
g_n = [0; 0; -1]; % gravity
% geomagnetic field, renew with your location.
m_n = [-0.5; 0; sqrt(3)/2]; 
ye = [g_n; m_n];

%% KF Step 0: initial conditions, prior estimate and covariance
x_hat_minus = [0.5; 0.5; 0.5; 0.5]; % keep unit quaternion (norm(q)=1).
P_minus = diag([0.5 0.5 0.5 0.5]);

% Process noise and measurement covariance matrix
cov_gyro_x = 1.1915*1e-6; cov_gyro_y = 1.8574*1e-6; cov_gyro_z = 1.0264*1e-6;
Sigma_gyro = diag([cov_gyro_x cov_gyro_y cov_gyro_z]); % covariance for gyro sensor.

% Pseudo-Measurement matrix
H = eye(4);

% Covariance for pseudo-measurement of quaternion.
% Place accelerometer on table, keep steady state for a while, calculate
% following sd (standard deviation) for xyz-axis of acc.
% Do the same test for magnetometer.
% sd_acc_x = 3.0089*1e-6; sd_acc_y = 1e-2; sd_acc_z = 1e-2;
% sd_mag_x = 1e-2; sd_mag_y = 1e-2; sd_mag_z = 1e-2;
% R_sensor = diag([sd_acc_x^2 sd_acc_y^2 sd_acc_z^2 sd_mag_x^2 sd_mag_y^2 sd_mag_z^2]);

% R_sensor = diag([(0.110^2) (0.167^2) (0.045^2) (0.03^2) (0.03^2) (0.03^2)]);

cov_acc_x = 3.0089*(1e-6); cov_acc_y = 1.5584*(1e-6); cov_acc_z = 5.1914*(1e-6);
cov_mag_x = 5.6174*(1e-5); cov_mag_y = 5.6283*(1e-5); cov_mag_z = 5.3426*(1e-5);
R_sensor = diag([cov_acc_x cov_acc_y cov_acc_z cov_mag_x cov_mag_y cov_mag_z]);

% Empty inputbuffer, addressing the slowing plotting, but suffer from data
% loss
if s.BytesAvailable > 0
    % Empty buffer by reading all contents of the buffer.
    % this let plot the ONLY current data, throw away old data.
    fread(s, s.BytesAvailable);
end

% Read the first data, in order to calculate the 1st sampling interval.
rawData = fscanf(s,'%f')';
if length(rawData) == 20
    % check NaN data
    if any(isnan(rawData))
        disp('NaN found in rawData')
        %rawData
        return
    end
    timestamp_prev = rawData(19)*MS2S; % rawdata is millisecond.
end


%% KF loop begin here ---->
% loop for each new measurement.
% Acturally, start the loop from second measurement.
while true
    % Data Step 1:
    % Read data from series port.
    % Read sensors (angular rates, gravity, and magnetic field)
    % Reading time-varying of gyro, acc, and mag
    
    % Empty inputbuffer
%     if s.BytesAvailable > 0
%         % Empty buffer by reading all contents of the buffer.
%         % this let plot the ONLY current data, throw away old data.
%         fread(s, s.BytesAvailable);
%     end
    
    % The fgetl, fgets, fscanf, and fread functions operate synchronously and
    % block the MATLAB Command Window until the operation completes.
    rawData = fscanf(s,'%f')';
    if length(rawData) == 20
        % check NaN data
        if any(isnan(rawData))
            %disp('NaN found in rawData')
            %rawData
            continue
        end
        timestamp_curr = rawData(19)*MS2S; % rawdata is millisecond.
        % rawdata of acc is in g, 1g, 2g, etc.
        acc = [rawData(1); rawData(2); rawData(3)];
        % rawdata from gryo is in degree, convert degree to radian.
        gyro = [rawData(4); rawData(5); rawData(6)].*(pi/180);
        % raw data is in uT(1e-6 T), geomagnetic field is measured in gauss
        % Earth's surface ranges from 0.25--0.65 gauss.
        % uT * 1e-2 = gauss
        mag = [rawData(8); rawData(7); -rawData(9)].*(1e-3); % here use 1e-3.
    else
        % wrong rawData
        %disp(strcat('wrong rawData', num2str(length(rawData))));
        continue
    end
    
    % External Algorithm Step 2: converge the quaternion using x_hat(k|k-1)
    yb = [acc/norm(acc); mag/norm(mag)];
    
    % first guess is the initial prior value,
    % and following guess is previous x_hat_minus.
    % q is new pseduo-measurement.
    [q, A] = converg(ye, yb, x_hat_minus);
%     [q, A] = converg_individual(yb);
    
    % The A matrix relates the covariance of the measurement noise (6 by 6)
    % to the covariance of quaternions after covergence (4 by 4).
    R = A*R_sensor*A'; % A is 4*6 matrix, and R is 4*4 matrix, R_sensor is 6*6 matrix.
%     R = A*R_sensor_acc*A'; % A is 4*6 matrix, and R is 4*4 matrix, R_sensor is 6*6 matrix.
    
    % KF Step 1: Determine the Kalman gain
%     K = P_minus*H'*inv(H*P_minus*H' + R);
    K = P_minus*H'/(H*P_minus*H' + R);
    
    % KF Step 2: Update estimate with measurement
    x_hat_plus = x_hat_minus + K*(q - H*x_hat_minus);
    % x_hat_plus = x_hat_plus/(sqrt(x_hat_plus'*x_hat_plus));    
    x_hat_plus = x_hat_plus/norm(x_hat_plus);   % renormalization 
    
    % KF Step 3: Update error covariance
    % Joseph form to guarantee symmetry and positive-definiteness.
    % P = (eye(4) - K*(H)) * P * (eye(4) - K*(H))' + K*R*K'; 
    P_plus = (eye(4) - K*H)*P_minus;
    
    % KF Step 4: Project ahead for both estimate and covariance
    delta_t = timestamp_curr - timestamp_prev;
    phi = transition(gyro(1), gyro(2), gyro(3), delta_t);
    x_hat_minus = phi*x_hat_plus;
    
    qm = qmatrix(x_hat_minus);
    Q = (qm*Sigma_gyro*qm').*((delta_t^2)/4);
    P_minus = phi*P_plus*phi' + Q; % phi is the process transition matrix
    
    timestamp_prev = timestamp_curr;
    
    % Plot
    % 1, rotate using quaternion directly
    iplot_q(x_hat_plus', hx,hy,hz);
    % 2, rotate using DCM
    % iplot(q2DCM(x_hat_plus), h);
end
% KF loop end <-----

%% close serial port
fclose(s); % disconnect device.
delete(s); %  remove it from memory.
clear s; % remove it from the MatLab workspace.
disp('End...');

% diary off;
% type iDiaryFile;