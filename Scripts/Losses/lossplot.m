function [h]=lossplot(data)
% runtitle = cell2mat(strcat(data.title(1),data.title(2),data.title(3),data.title(4),data.title(5),data.title(6)));
[X,Y] = meshgrid(sort(data.iAC),sort(data.frequency));
h = figure();surf(X,Y,1000.*data.loss','FaceColor','interp','FaceLighting','gouraud');
title (data.runtitle, 'Interpreter', 'none','Fontsize',14); 
axis ([min(data.iAC) max(data.iAC) min(data.frequency) max(data.frequency) 1100*min(min(data.loss,[],1)) 1100*max(max(data.loss,[],1))]);
% axes('Fontsize',12);
xlabel('AC Current [A]rms','Fontsize',14);ylabel ('frequency [Hz]','Fontsize',14);
zlabel('Losses [mW]','Fontsize',14);
set(gca,'FontSize',13)

end