%reco_name='091e790d3feaea64a474b828354b4045_R00224226_20171223115229';   % long wav, DER=0
reco_name='159aa66f30b173143645c44fbd73a83d_R00114b70_20171120162129';  % short wav, server-user
%reco_name='03ca58eab0d35413f8d4ca65fb24c191_R0001437c_20180203171533';   % long wav, 2servers
wav_filename=['wav_files/',reco_name,'.wav']; % wav name

% choose one system here %
system='BIC';
%system='ivector_plda';

% read rttm files
if strcmpi(system,'BIC')
    sd_segments=read_rttm('rttm_files/sd_BIC.rttm',reco_name); % sd_BIC.rttm
else
    sd_segments=read_rttm('rttm_files/sd_ivector_plda.rttm',reco_name); % sd_ivector_plda.rttm
end
[sd_rows,sd_columns]=size(sd_segments);
ref_segments=read_rttm('rttm_files/ref.rttm',reco_name); % ref.rttm
[ref_rows,ref_columns]=size(ref_segments);

% system annotation
cprintf('Label annotation:    ')
cprintf('*red','red\"×\": ')
cprintf('black','Speaker Confusion  ')
cprintf('*comment','green\".\": ')
cprintf('black','Correct Label')
cprintf('\n')

% play the beginning synthetic sound
period=0.1;
Fs=8000;
t_end=sd_segments(1,1);
samples=[1,t_end*Fs];
[y,Fs] = audioread(wav_filename,samples);
cprintf('black','Playing');
tmp='.';
t = timer('TimerFcn','cprintf(tmp);', 'Period', period, 'ExecutionMode', 'fixedRate', 'TasksToExecute',int32(t_end/period) );  
start(t);
sound(y,Fs);
pause(t_end);
cprintf('\n');

% overlapped part !!!!
silence_start=t_end; %0
sd_index=1;
ref_index=1;
ref_segment=ref_segments(ref_index,:);
ref_segment_start=ref_segment(1);
ref_segment_end=ref_segment_start+ref_segment(2);
while (sd_index<=sd_rows)
    %sd_index
    sd_segment=sd_segments(sd_index,:);
    sd_segment_start=sd_segment(1);
    sd_segment_duration=sd_segment(2);
    sd_segment_end=sd_segment_start+sd_segment_duration;
    sd_segment_label=sd_segment(3);
    % play the silence segment
    samples=[double(int32(silence_start*Fs)),double(int32(sd_segment_start*Fs))];
    [y,Fs] = audioread(wav_filename,samples); 
    sound(y,Fs);
    pause(sd_segment_start-silence_start);
    % calculate confusion sections
    confusion_sections=[];
    while (ref_segment_start<sd_segment_end)
        if (ref_segment_end<=sd_segment_start)
            ref_index = ref_index + 1;
            if (ref_index>ref_rows) break; end
            ref_segment=ref_segments(ref_index,:);
            ref_segment_start=ref_segment(1);
            ref_segment_end=ref_segment_start+ref_segment(2);
            continue;
        end
        % handle overlapped part
        ref_segment_label=ref_segment(3);
        if (ref_index<ref_rows&&ref_segments(ref_index+1,1)==ref_segment_start)% overlapped
            %cprintf('!!!!');
            ref_segment_label=3.0;
            ref_segment(3)=3.0;
            ref_index = ref_index+1;
        end
        if (ref_segment_end>sd_segment_end)
            if (sd_segment_label+ref_segment_label==3.0) % confusion
                if(ref_segment_start<=sd_segment_start)
                    confusion=[1,int32(sd_segment_duration/period)];
                else
                    confusion=[int32((ref_segment_start-sd_segment_start)/period)+1,int32(sd_segment_duration/period)];
                end
                confusion_sections=[confusion_sections;confusion];
            end
            %ref_index=ref_index+1;
            ref_segment_start=sd_segment_end;
            break;
        else
            if (sd_segment_label+ref_segment_label==3.0) % confusion
                if(ref_segment_start<=sd_segment_start)
                    confusion=[1,int32((ref_segment_end-sd_segment_start)/period)];
                else
                    confusion=[int32((ref_segment_start-sd_segment_start)/period)+1,int32((ref_segment_end-sd_segment_start)/period)];
                end
                confusion_sections=[confusion_sections;confusion];
            end
            ref_index = ref_index + 1;
            if (ref_index>ref_rows) break; end
            ref_segment=ref_segments(ref_index,:);
            ref_segment_start=ref_segment(1);
            ref_segment_end=ref_segment_start+ref_segment(2);
        end
    end
    % play the speech segment
    %confusion_sections
    samples=[double(int32(Fs*sd_segment_start)),double(int32(Fs*sd_segment_end))];
    [y,Fs] = audioread(wav_filename,samples);
    spk=char('A'+sd_segment_label-1);
    %cprintf('_blue','%d %c: ',sd_segment_start,spk);
    cprintf('_blue','%c: ',spk);
    t = timer('TimerFcn','myprint(confusion_sections,t);', 'Period', 0.1, 'ExecutionMode', 'fixedRate', 'TasksToExecute',int32(sd_segment_duration/0.1));  
    start(t);
    sound(y,Fs);
    pause(sd_segment_duration);
    cprintf('\n');
    
    sd_index = sd_index+1;
    silence_start=sd_segment_end;
end

