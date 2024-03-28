function [q, A] = converg_doup_aqua(yb)
    % This file is external algorithm, which computes rotation quaternion by using AQUA algorithm.
    % It is a single-frame algorithm.
    %
    % AQUA takes sequential two-step corrections,
    % and decouples the correction to yaw from Earth mag field with the correction to roll&pitch from gravity.
    % So it enables mag disturbance only to affect yaw.
    % but due to the sequential process nature, the acc disturbance will affect both roll&pitch and yaw.
    %
    % By default:
    % 1) all vector is column vector.    
    %
    % One input:
    % yb (6*1) is measurements of gravity and geomagnetic field in sensor bogy frame.
    % acc and mag in yb are already normalized before input this function.
    %
    % Two returns:
    % 1) q: pseudo-measurement quaternion calculated from AQUA
    %    q (1*4 row vector) is the pseudo-measurement.
    %    q=[q0 q1 q2 q3], q0 is scalar component.
    % 2) A: covariance propagation matrix, used to update the covariance of pseudo-quaternion.
    %
    % Reference:
    % Roberto G. Valenti, 
    % "A Linear Kalman Filter for MARG Orientation Estimation Using the Algebraic Quaternion Algorithm"
    % IEEE TRANSACTIONS ON INSTRUMENTATION AND MEASUREMENT, VOL. 65, NO. 2, FEBRUARY 2016
    %
    % by Haipeng Wang, Dec.2018.
    %
    % Date          Author          Notes
    % 12/16/2018    haipeng wang    Initial release.


    %% 1. q_acc
    % a, m are measurements from acc, mag in body frame respectively.
    a = yb(1:3); m = yb(4:6); % already normalized
    
    lambda1 = sqrt((1 + a(3))/2);
    lambda2 = sqrt((1 - a(3))/2);
    if a(3) >= 0 % if a_z >= 0
        % qa = qacc(1) = lambda1; qacc(2) = -a(2)/(2*lambda1); qacc(3) = a(1)/(2*lambda1); qacc(4) = 0;
        qa = [lambda1; -a(2)/(2*lambda1); a(1)/(2*lambda1); 0];
        
    else
        % qacc(1) = -a(2)/(2*lambda2); qacc(2) = lambda2; qacc(3) = 0; qacc(4) = a(1)/(2*lambda2);
        qa = [-a(2)/(2*lambda2); lambda2; 0; a(1)/(2*lambda2)];
    end
    
    %% 2. q_mag
    % Here, since l is based on qa, so it has the sequential nature, which
    % let the linear acceleration disturbance affect both the yaw and roll/pitch.
    l = quatrotate(qa', m');
    gamma = l(1)^2 + l(2)^2;
    
    if l(1) >= 0
        % qm = qmag(1) = (sqrt(gamma + l(1)*sqrt(gamma)))/(sqrt(2*gamma)); qmag(2) = 0; qmag(3) = 0; qmag(4) = l(2)/(sqrt(2)*sqrt(gamma + l(1)*sqrt(gamma)));
        qm = [(sqrt(gamma + l(1)*sqrt(gamma)))/(sqrt(2*gamma)); 0; 0; l(2)/(sqrt(2)*sqrt(gamma + l(1)*sqrt(gamma)))];
    else
        % qmag(1) = l(2)/(sqrt(2)*sqrt(gamma - l(1)*sqrt(gamma))); qmag(2) = 0; qmag(3) = 0; qmag(4) = sqrt(gamma - l(1)*sqrt(gamma))/(sqrt(2*gamma));
        qm = [l(2)/(sqrt(2)*sqrt(gamma - l(1)*sqrt(gamma))); 0; 0; sqrt(gamma - l(1)*sqrt(gamma))/(sqrt(2*gamma))];
    end

    %% 3. q_total = q_mag*q_acc
%     qmag = quatconj(qmag'); qacc = quatconj(qacc'); % change q(n->b) to q(b->n)
%     q = quatmultiply(qmag, qacc)';
    q = quatmultiply(quatconj(qm'), quatconj(qa'))'; % usage: x_n = q*x_b*conj(q), where x_b in body frame.
    
    
    %% 4. Jacobian matrix for covariance matrix calculation.
    if a(3) >= 0
        % chain rule: d(q)/d(q_acc) d(q)/d(q_mag),
        % qa is quaternion q_acc, qm is q_mag
        % 1. d(q)/d(f1)
        DqDqa = [qm(1) 0 0 -qm(4);
            0 qm(1) qm(4) 0;
            0 -qm(4) q(1) 0;
            qm(4) 0 0 qm(1)];
        DqDqm = [qa(1) -qa(2) qa(3) 0;
            qa(2) qa(1) 0 qa(3);
            qa(3) 0 qa(1) -qa(2);
            0 -qa(3) qa(2) qa(1)];
        DqDf1 = [DqDqa DqDqm]; % 4*8 matrix
        
        % 2. d(f1)/d(f2)
%         l = quatrotate(qa', m')'; % defined before, comment here.
%         gamma = l(1)^2 + l(2)^2;  % defined before, comment here.
        kappa = sqrt(1 + a(3));

        beta1 = sqrt(gamma + l(1)*sqrt(gamma));
        beta2 = sqrt(gamma - l(1)*sqrt(gamma));
        
        if l(1) >= 0
            % d(q_acc)/d(acc)
            DqaDa = [0 0 1/kappa;
                0 -2/kappa a(2)/kappa^3;
                2/kappa 0 -a(1)/kappa^3;
                0 0 0];
            % d(q_mag)/d(l)
            DqmDl = [l(2)^2/(beta1*gamma) l(1)*l(2)/(beta1*gamma) 0;
                0 0 0;
                0 0 0;
                -l(2)*beta1/(gamma^(3/2)) l(1)*beta1/(gamma^(3/2)) 0];
            % 2. d(f1)/d(f2) as lx >= 0
            Df1Df2 = [DqaDa zeros(4,3);
                zeros(4,3) DqmDl].*(1/(2*sqrt(2)));
        else % lx < 0
            % d(q_acc)/d(acc)
            DqaDa = [0 0 1/kappa;
                0 -2/kappa a(2)/kappa^3;
                2/kappa 0 -a(1)/kappa^3;
                0 0 0];
            % d(q_mag)/d(l)
            DqmDl = [l(2)*beta2/(gamma^(3/2)) l(1)*beta2/(gamma^(3/2)) 0;
                0 0 0;
                0 0 0;
                -l(2)^2/(beta2*gamma) l(1)*l(2)/(beta2*gamma) 0];
            % d(f1)/d(f2) as lx < 0
            Df1Df2 = [DqaDa zeros(4,3);
                zeros(4,3) DqmDl].*(1/(2*sqrt(2)));
        end
        % 3. d(f2)/du = d(l)/d(u), u = [a m]
        Df2Du = [eye(3) zeros(3);
            m(3)-(2*a(1)*m(1)+a(2)*m(2))/kappa^2 -a(1)*m(2)/kappa^2 a(1)*(a(1)*m(1)+a(2)*m(2))/kappa^4 1-a(1)^2/kappa^2 -a(1)*a(2)/kappa^2 a(1);
            -a(2)*m(1)/kappa^2 m(3)-(a(1)*m(1)+2*a(2)*m(2))/kappa^2 a(2)*(a(1)*m(1)+a(2)*m(2))/kappa^4 -a(1)*a(2)/kappa^2 1-a(2)^2/kappa^2 a(2);
            -m(1) -m(2) m(3) -a(1) -a(2) a(3)];
        
        % 3. d(f2)/du = d(l)/d(u) is
        Df2Du = [eye(3) zeros(3);
            m(3)-(2*a(1)*m(1)+a(2)*m(2))/kappa^2 -a(1)*m(2)/kappa^2 a(1)*(a(1)*m(1)+a(2)*m(2))/kappa^4 1-a(1)^2/kappa^2 -a(1)*a(2)/kappa^2 a(1);
            -a(2)*m(1)/kappa^2 m(3)-(a(1)*m(1)+2*a(2)*m(2))/kappa^2 a(2)*(a(1)*m(1)+a(2)*m(2))/kappa^4 -a(1)*a(2)/kappa^2 1-a(2)^2/kappa^2 a(2);
            -m(1) -m(2) m(3) -a(1) -a(2) a(3)];
    else % az < 0
        % chain rule: d(q)/d(q_acc) d(q)/d(q_mag),
        % qa is quaternion q_acc, qm is q_mag
        % 1. d(q)/d(f1)
        DqDqa = [qm(1) 0 0 -qm(4);
            0 qm(1) qm(4) 0;
            0 -qm(4) q(1) 0;
            qm(4) 0 0 qm(1)];
        DqDqm = [qa(1) -qa(2) 0 -qa(4);
            qa(2) qa(1) -qa(4) 0;
            0 qa(4) qa(1) -qa(2);
            qa(4) 0 qa(2) qa(1)];
        DqDf1 = [DqDqa DqDqm]; % 4*8 matrix
        
        % 2. d(f1)/d(f2)
        % d(q_acc)/d(acc)
%         l = quatrotate(qa', m')'; % defined before, comment here.
%         gamma = l(1)^2 + l(2)^2;  % defined before, comment here.
        kappa = sqrt(1 - a(3));

        beta1 = sqrt(gamma + l(1)*sqrt(gamma));
        beta2 = sqrt(gamma - l(1)*sqrt(gamma));
        if l(1) >= 0
            % d(q_acc)/d(a)
            DqaDa = [0 -2/kappa -a(2)/kappa^3;
                0 0 -1/kappa;
                0 0 0;
                2/kappa 0 a(1)/kappa^3];
            % d(q_mag)/d(l)
            DqmDl = [l(2)^2/(beta1*gamma) -l(1)*l(2)/(beta1*gamma) 0;
                0 0 0;
                0 0 0;
                -l(2)*beta1/(gamma^(3/2)) l(1)*beta1/(gamma^(3/2)) 0];
            % d(f1)/d(f2) as lx >= 0
            Df1Df2 = [DqaDa zeros(4,3);
                zeros(4,3) DqmDl].*(1/(2*sqrt(2)));
        else % lx < 0
            % d(q_acc)/d(a)
            DqaDa = [0 -2/kappa -a(2)/kappa^3;
                0 0 -1/kappa;
                0 0 0;
                2/kappa 0 a(1)/kappa^3];
            % d(q_mag)/d(l)
            DqmDl = [l(2)*beta2/(gamma^(3/2)) -l(1)*beta2/(gamma^(3/2)) 0;
                0 0 0;
                0 0 0;
                -l(2)^2/(beta2*gamma) l(1)*l(2)/(beta2*gamma) 0];
            
            % d(f1)/d(f2) as lx < 0
            Df1Df2 = [DqaDa zeros(4,3);
                zeros(4,3) DqmDl].*(1/(2*sqrt(2)));
        end
        % 3. d(f2)/du = d(l)/d(u) is
        Df2Du = [eye(3) zeros(3);
            m(3)-(2*a(1)*m(1)-a(2)*m(2))/kappa^2 a(1)*m(2)/kappa^2 a(1)*(-a(1)*m(1)+a(2)*m(2))/kappa^4 1-a(1)^2/kappa^2 -a(1)*a(2)/kappa^2 a(1);
            -a(2)*m(1)/kappa^2 m(3)-(a(1)*m(1)-2*a(2)*m(2))/kappa^2 a(2)*(-a(1)*m(1)+a(2)*m(2))/kappa^4 -a(1)*a(2)/kappa^2 -1+a(2)^2/kappa^2 a(2);
            m(1) -m(2) -m(3) a(1) -a(2) -a(3)];
    end
    
    % quaternion covariance propagation matrix: [Sigma_q] = [A]*[Sigma_(a+m)]*[A']
    A = DqDf1*Df1Df2*Df2Du;
