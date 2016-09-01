function setYokoCurrent( I, yoko )
%setYokoCurrent( I, yoko ) supplies current (uA) from the yokogawa
%   I - current (uA)
%   yoko - yokogawa object
Istr = num2str(I*1e-6);
fprintf(yoko,['F5 SA',Istr,' O1 E']);
end