clc
clear
filename = 'testdata.xlsx';
xlSheet = 'TMSMotion1.xlsx';
range = 'B2:B4065';
Fs = 10;
dat = xlsread(xlSheet,range);
t = (0:size(dat,1)-1).';
t = t*1/Fs;
%dat = horzcat(t,dat);
time  = [];
figure;
i=0;
data= [];
prev_top_datapt = 0; % save the y value for the last topmost point
prev_top_time = 0; %saves the time for the last topmost point 
prev_top_ind = 1;  % saves index of the last topmost point
prev_mid_index = 1;
prev_mid_time = 0;
prev_mid_datapt = 0;
prev_mid_index_2 = 1;
prev_mid_time_2 = 0;
prev_mid_datapt_2 = 0;
found_mid = 0;
found_top=0;
ignore =1;
while true
    store = {};
    store{3} = [];
    store{4} = [];
    w = waitforbuttonpress;
    if w == 1
        clf
        i = i+1;
        data(i) = dat(i);
        time(i) = t(i);
        %data(i,2) = dat(i,2);
        data_m = data - mean(data);
        data_s = smooth(data_m);
        store{8} = length(data_s);
        figure(1)
        plot(time,data_s,'b')
        hold on
        found_mid = 0;
        found_mid_2 = 0;
        if i<=90
            disp('collecting data')
        else
            

            tnew = [];
            datmod=[];
            j=0;
            for j = [prev_top_ind:i]
    %             prev_top_ind
    %             j
               if j>3
                    slope_f= data_s(j)-data_s(j-1);
                    slope_r = data_s(j-1)-data_s(j-2);
                    if and(slope_r>=0,slope_f<0) && data_s(j)>0
                        prev_top_ind = j-1;
                        prev_top_time = (prev_top_ind-1)/Fs;
                        prev_top_datapt = data_s(prev_top_ind);
                        found_top = 1;
                    end

                    if and(data_s(j-1)>=0,data_s(j)<0)
                        prev_mid_index = j;
                        prev_mid_time = (prev_mid_index-1)/Fs;
                        prev_mid_datapt = data_s(prev_mid_index);
                        found_mid = 1;
                    end
                    
                    if and(data_s(j-1)<0,data_s(j)>=0)
                        prev_mid_index_2 = j;
                        prev_mid_time_2 = (prev_mid_index_2-1)/Fs;
                        prev_mid_datapt_2 = data_s(prev_mid_index_2);
                        found_mid_2 = 1;
                        store{3} = prev_mid_time_2;
                        
                        store{4} = (prev_mid_datapt_2 - data_s(prev_mid_index_2-1))*Fs;
                        
                    end


               end
           end
        
        k=1;
        for j = [prev_top_ind+3:i]
               if found_top ==1 && found_mid ==1 && j <= (prev_mid_index+6)
                        tnew(k) = time(j);
                        datmod(k) = data_s(j);
                        k=k+1;
                        
               end
        end
        
        end
        
        if found_mid==1 && length(tnew) >5
            [t_plot,y_plot]=fft_sse(tnew',datmod',Fs);
            store{7} = length(tnew'); %CONFIDENCE METRIC ~18 gives good results (prev_top_index + 3 abd prev_mid_index + 6
%             ~isempty(t_plot)
            if ~isempty(t_plot)
            figure(1)
            plot(t_plot,y_plot,'r')

            store{1} = t_plot(length(t_plot));
            
            store{2} = (y_plot(length(y_plot))-y_plot(length(y_plot)-1))*Fs;
            hold on
            plot(tnew',datmod','y')
            store{5} = store{1} - store{3};
            store{6} = store{2} - store{4};
            disp('Predicted time,predicted velocity,actual time,actual velocity,error in time, error in velocity, No. data pt')
            disp(store);
            if store{5} ~=[]
                xlswrite(filename,store)
            end
            end
        end
        
   
    else
        disp('Press Button')
        disp(w)
    end
end