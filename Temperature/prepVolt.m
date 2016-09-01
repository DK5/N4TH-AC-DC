function prepVolt( volt_obj )
%prepVolt( volt_obj ) prepares voltmeter for one-shot readings

fprintf(volt_obj, ':trace:feed:control never');	% Stop storing readings
fprintf(volt_obj, ':trace:clear');              % Clear buffer
fprintf(volt_obj, ':trace:points 16');          % assign place for 1 reading
fprintf(volt_obj, ':trace:feed sense');         % Store raw input readings
fprintf(volt_obj, ':trace:feed:control next');	% Start storing readings

end

