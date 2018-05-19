function segments = read_rttm (rttm_name,reco_name)
segments=[];
read=false;
tune=false;
fp=fopen(rttm_name,'r'); 
while (~feof(fp)) 
    str=fgetl(fp);
    tokens = regexp(str,' *','split');
    reco=tokens(2);
    if (strcmpi(reco,reco_name))
        start=str2double(tokens(4));
        duration=str2double(tokens(5));
        str_label=tokens(8);
        if strcmpi(str_label,'A')
            str_label='1';
        elseif strcmpi(str_label,'B')
            str_label='2';
        end
        if (~read && strcmpi(str_label,'2')) tune=true; end
        label=str2double(str_label);
        if (tune) label=3-label; end
        segment=[start,duration,label];
        segments=[segments;segment];
        
        read=true;
    end
    if (read==true && ~strcmpi(reco,reco_name) )
        break;
    end
end
fclose(fp);

end