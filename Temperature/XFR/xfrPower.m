function [ I , V ] = xfrPower( Power, R , XFR )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
Plimit = 60;	% Watt

if Power > Plimit
    return
end

V = sqrt(Power*R);
I = V/R;

fprintf(XFR,['Iset ' num2str(I)]);
fprintf(XFR,['Vset ' num2str(V)]);
outputXFR(1,XFR);
end