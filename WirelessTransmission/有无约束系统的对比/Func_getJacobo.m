function Jacobi = Func_getJacobo(q1,q2)
    q00 = q1(1);
    q01 = q1(2);
    q02 = q1(3);
    q03 = q1(4);
    q10 = q2(1);
    q11 = q2(2);
    q12 = q2(3);
    q13 = q2(4);
    Jacobi = [
        q10,-q11,-q12,-q13, q00,-q01,-q02,-q03;
        q11, q10, q13,-q12, q01, q00,-q03, q02;
        q12,-q13, q10, q11, q02, q03, q00,-q01;
        q13, q12,-q11, q10, q03,-q02, q01, q00;  
    ];


end