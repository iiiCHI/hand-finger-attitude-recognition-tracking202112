function Joint = Func_getJointPosture(X_k,a,b)
    Joint = Func_crossProductFu(X_k(a*4-3:a*4),X_k(b*4-3:b*4));
end


% syms Q1 Q2 Q3 Q4 q1 q2 q3 q4;
% tt = Func_crossProductFu([q1 q2 q3 q4],[Q1 Q2 Q3 Q4]);