function [h]=lossplotPC(data)
% runtitle = cell2mat(strcat(data.title(1),data.title(2),data.title(3),data.title(4),data.title(5),data.title(6)));
[X,Y] = meshgrid(sort(data.iAC),sort(data.frequency));
h = figure();surf(X,Y,data.lossPC','FaceColor','interp','FaceLighting','gouraud');
title (data.runtitle, 'Interpreter', 'none','Fontsize',14); 
axis ([min(data.iAC) max(data.iAC) min(data.frequency) max(data.frequency) min(min(data.lossPC,[],1)) max(max(data.lossPC,[],1))]);
% axes('Fontsize',12);
xlabel('AC Current [A]rms','Fontsize',14);ylabel ('frequency [Hz]','Fontsize',14);
zlabel('Q per Cycle [J/cycle]','Fontsize',14);
set(gca,'FontSize',13)

end