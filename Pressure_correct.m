function [p_c]=Pressure_correct(y,density,V_far,M_far)

    Cp0 = y./(0.5*density*power(V_far,2));
    Cp = Cp0 ./ (sqrt(1-power(M_far,2))+(power(M_far,2)/(1+sqrt(1-power(M_far,2))))*Cp0/2);
    p_c = (0.5*density*power(V_far,2)).*Cp;
    
end


