function loss = stk_losscrit(type, zi_, zpmean, zpvar)

switch(type)
    case 1 % EI
        Mn = max(zi_);
        loss = -Mn;
    case 2 % EI with Mn = max(zp)
        Mn = max(zpmean);
        loss = -Mn;
    case 3 % EEI
        Mn = max(zi_);
        expected_excess = stk_distrib_normal_ei(Mn, zpmean, sqrt(zpvar));
        loss = mean(expected_excess); %loss = 1/ng*sum(expected_excess);
    case 4 % EEI with Mn = max(zp)
        Mn = max(zpmean);
        expected_excess = stk_distrib_normal_ei(Mn, zpmean, sqrt(zpvar));
        loss = mean(expected_excess); %loss = 1/ng*sum(expected_excess);
end
end
