function myprint (confusion_sections,t)

%confusion_sections
[rows,columns]=size(confusion_sections);
for i=1:rows
    if(confusion_sections(i,1)<=t.TasksExecuted && confusion_sections(i,2)>=t.TasksExecuted)
        cprintf('*red',' ×');
        return;
    end
end
cprintf('*comment',' .');
end