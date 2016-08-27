function []=lossplotPVPC(data)
runtitle = cell2mat(strcat(data.title(1),data.title(2),data.title(3),data.title(4),data.title(5),data.title(6)));
[X,Y]=meshgrid(sort(data.current),sort(data.frequency));
figure ();h=surf(X,Y,data.lossPVPC','LineWidth',0.5,'FaceAlpha',0.5,'FaceColor','interp','FaceLighting','gouraud'); %'EdgeColor','none'
% camproj('perspective')
title (runtitle, 'Interpreter', 'none','Fontsize',14); 
axis ([min(data.current) max(data.current) 0 max(data.frequency) 1.1*min(min(data.lossPVPC,[],1)) 1.1*max(max(data.lossPVPC,[],1))]);
% axes('Fontsize',12);
hold all;
% contour3 (X,Y,data.lossPVPC',30)
xlabel('Current [A]rms','Fontsize',14);ylabel ('frequency [Hz]','Fontsize',14);
zlabel('Losses [J/m^3/cycle]','Fontsize',14);
set(gca,'FontSize',13)
end