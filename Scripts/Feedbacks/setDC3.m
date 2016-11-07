function [ outDC ] = setDC3(iDC,Ilimit,pwr_obj,N4TH)
%setDC3 supllies DC current from HP power supplier
%   new version, from scratch

if ~iDC
    % if set current is 0
    outputHP(0,pwr_obj);    % turn off
    outDC = 0;
    return;
end
   
on = str2double(query(pwr_obj,'OUTP?'));    % is output on?
if ~on
    % output is off
    supCurrent(0,pwr_obj);	% set current to 0 in order to prevent peaks
    outputHP(1,pwr_obj);    % turn on power supplier output
    pause(3);   % pause
end

fprintf(N4TH,'SPEED,WINDOW,0.2');
pause(0.25);

supVoltage(5,pwr_obj);  % set voltage
outDC = getDC(N4TH,1);  % get first reading
err = (outDC-iDC)/iDC;

errInterval = 0.02; cor = 10;
Kp = 10; steps = 5; steady = 0;
stable = 0;

while ~stable
    % while current is not stable
    outDC = getDC(N4TH);  % get reading
    err(end+1) = (outDC-iDC)/iDC;

    u = Kp*err(end);
    outDC = (1+u)*iDC;
    outDC = outDC*(outDC>0);    % if outDC is negative - set to 0
    
    if steady || abs(err(end)) < errInterval
        % if measurement declared before as steady
        % or error is legitimate
        outDC = iDC; steady = 1;
    elseif abs(err(end)) < 2*errInterval
        if err(end) > 0
            % slow decrease
            space = 0.5;
            for ind = 1:steps
                outDC = (1+space-space*ind/steps)*iDC
                supCurrent(outDC,pwr_obj);
                
                plot(1:length(outDC),outDC,'-ob',...
                    [1 length(outDC)],[iDC iDC],'-r',...
                    [1 length(outDC)],(1-errInterval)*[iDC iDC],'-g',...
                    [1 length(outDC)],(1+errInterval)*[iDC iDC],'-g');
                title('DC current control')
                text(1.2,0.5*iDC,['I = ' num2str(outDC)]);
                hold off;
                
                pause(0.5);
            end
        elseif err(end) < 0 
            % slow increase
            space = 0.5;
            for ind = 1:steps
                outDC = (1-space+space*ind/steps)*iDC
                supCurrent(outDC,pwr_obj);
                
                plot(1:length(outDC),outDC,'-ob',...
                    [1 length(outDC)],[iDC iDC],'-r',...
                    [1 length(outDC)],(1-errInterval)*[iDC iDC],'-g',...
                    [1 length(outDC)],(1+errInterval)*[iDC iDC],'-g');
                title('DC current control')
                text(1.2,0.5*iDC,['I = ' num2str(outDC)]);
                hold off;
                
                pause(0.5);
            end
        end
        steady = 1;
    end
    
    supCurrent(outDC,pwr_obj);
    
    plot(1:length(outDC),outDC,'-ob',...
        [1 length(outDC)],[iDC iDC],'-r',...
        [1 length(outDC)],(1-errInterval)*[iDC iDC],'-g',...
        [1 length(outDC)],(1+errInterval)*[iDC iDC],'-g');
    title('DC current control')
    text(1.2,0.5*iDC,['I = ' num2str(outDC)]);
    hold off;
    
    if numel(err) > cor && ~sum(abs(err((end-cor):end)) > errInterval)
        % if last 10 temperatures were in the interval - stop
        stable = 1;
    end
    
end

end

