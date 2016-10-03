%   Code written by Rushat Gupta Chadha
%   For more information contact - rushatgc@gmail.com
%   
%   Plotter for "real-time" like streaming of TMS data for prediction of
%   motion and optimal docking point
% 
%   After running the program hit enter on the plot figure to simulate
%   streaming of data
%   -If the program is slow, please turn off legend
%   -Warning: do not hold enter for a long time as MATLAB buffers the
%   keyboard inputs
%   
%   https://github.com/rushat/MRSD-Project---Prediction
%   
%   Version History - 
%   v1.0 - plotter with stream
%   v1.1 - added storage of data for GOOD and BAD prediction labels
%   Future work - add online prediction of GOOD and BAD labels
%   
%   

%% Code starts here 
clc
clear all

%% read file
filename = 'testdata.xlsx';
xlSheet = 'TMSMotion1.xlsx';
range = 'B2:B4065';
% xlSheet = 'TMSMotion4.xlsx';
% range = 'B2:B189489';
Fs = 10;                   % input sampling frquency
dat = xlsread(xlSheet,range);
t = (0:size(dat,1)-1).';
t = t*1/Fs;
% plot(dat)
%% initalize variables
time  = [];
figure;
i=0;
data= [];
prev_top_datapt = 0;        % save the y value for the last topmost point
prev_top_time = 0;          % saves the time for the last topmost point 
prev_top_ind = 1;           % saves index of the last topmost point
prev_mid_index = 1;         % saves the index of mid value while going down
prev_mid_time = 0;          % saves the time of mid value while going down
prev_mid_datapt = 0;        % saves the y value of mid value while going down
prev_mid_index_2 = 1;       % saves the index of mid value while going up
prev_mid_time_2 = 0;        % saves the time of mid value while going up
prev_mid_datapt_2 = 0;      % saves the y value of mid value while going up
found_mid = 0;              % boolean! its 1 if the mid value is found
found_top=0;                % boolean! 1 if top value is found
done = false;               % boolean! avoids repeating the saving of same data set to be written into the excel file
final = [];
%w=1;                       % UNCOMMENT FOR CONTINUOUS RUN, DOESNT DISPLAY FIGURE                 
%% start simultaion
while true
    store = {};
    store{3} = [];
    store{4} = [];
    
    w = waitforbuttonpress;      % 1 for key, 0 for mouse click [COMMENT TO RUN TO STORE DATA]
    if w == 1
        clf
        i = i+1;
        if i > length(dat)       % end of data
            break;
        end
        %% input and smooth data
        data(i) = dat(i);                   % data collected
        time(i) = t(i);                     % time
        data_m = data - mean(data);         % data with mean subtracted
        data_s = smooth(data_m);            % Mean filtering
        store{8} = length(data_s);          % stores number of data points so far. Used for confidence metrid
        figure(1)
        plot(time,data_s,'b')               % plots real data 
        hold on
        found_mid = 0;
        found_mid_2 = 0;
        
        %% identify important points to store
        if i<=90                            % wait to collect some data so the mean fluctuation isnt a lot
            disp('collecting data')
            xlabel('Collecting Data')
        else                                
            tnew = [];
            datmod=[];
            j=0;
            for j = [prev_top_ind:i]
               if j>3                                                   % to avoid index errors
                    slope_f= data_s(j)-data_s(j-1);                     % front slope between poits j-1 and j
                    slope_r = data_s(j-1)-data_s(j-2);                  % back slope between j-1 and j-2
                    if and(slope_r>=0,slope_f<0) && data_s(j)>0         % to record top point based on double derivative and to detect peaks above the mean only. This is to avoid the tiny peaks that develop while smoothing
                        prev_top_ind = j-1;
                        prev_top_time = (prev_top_ind-1)/Fs;
                        prev_top_datapt = data_s(prev_top_ind);
                        found_top = 1;
                    end

                    if and(data_s(j-1)>=0,data_s(j)<0)                   % to find mean intersection while going down. Used for collecting fixed number of points after crossing this 
                        prev_mid_index = j;         
                        prev_mid_time = (prev_mid_index-1)/Fs;
                        prev_mid_datapt = data_s(prev_mid_index);
                        found_mid = 1;
                    end
                    
                    if and(data_s(j-1)<0,data_s(j)>=0)                   % to find mean intersection while going up. This is to determine the velocity and time at the point to compute errors. THIS IS THE EXPECTED DOCKING POINT
                        prev_mid_index_2 = j;
                        prev_mid_time_2 = (prev_mid_index_2-1)/Fs;
                        prev_mid_datapt_2 = data_s(prev_mid_index_2);
                        found_mid_2 = 1;
                        store{3} = prev_mid_time_2;                                       % Actual time at the optimal docking point
                        store{4} = (prev_mid_datapt_2 - data_s(prev_mid_index_2-1))*Fs;   % Actual Velocity at the optimal docking point
                     end
               end
           end
        %% Store data from desired start to desired end
        k=1;
        top_offset = 3;             % no. of data points to be left from the topmost point. This is important because too much information from previous curve affects the predicted curve and makes it more similar to the previous curve
        middle_offset = 6;          % no. of data point to be collected after the mean. this part actually determines how mmuch data from the curve to be predicted is to be taken. More the number , better the prediction but lesser the time for the ROV to get there. 
        for j = [prev_top_ind+top_offset:i]
               if found_top ==1 && found_mid ==1 && j <= (prev_mid_index+middle_offset)
                        tnew(k) = time(j);
                        datmod(k) = data_s(j);
                        k=k+1;
                        
               end
        end
        
        end
        %% perform FFT and Non-linear regression
        if found_mid==1 && length(tnew) >5              % the 5 is so that the predictor doesnt start predicting as soon as it gets a data point. the fft returns a 0 frequency if the data points are too low and prediction is terrible for lesser data points. THis affects visualization
            [t_plot,y_plot]=fft_sse(tnew',datmod',Fs);
            store{7} = length(tnew');                   %CONFIDENCE METRIC ~18 gives good results (top_offset = 3 & middle_offset = 6)
            if ~isempty(t_plot)                         % If the data points are too less, it returns a null matrix (because frequency from fft is 0). This condition rejects the null matrix
            figure(1)
            plot(t_plot,y_plot,'r')                     % plots predicted curve
            if store{7}>18 && store{8}>250             % confidence metric
                xlabel('GOOD prediction')
            else
                xlabel('BAD prediction')
            end
            store{1} = t_plot(length(t_plot));                              % Stores predicted time
            store{2} = (y_plot(length(y_plot))-y_plot(length(y_plot)-1))*Fs;% Stores predicted velocity
            hold on
            plot(tnew',datmod','y')
%             legend('Realtime data stream','predicted curve','collected data');
            store{5} = store{1} - store{3};                                 % Stores error in time 
            store{6} = store{2} - store{4};                                 % Stored error in velocity
            disp('Predicted time,predicted velocity,actual time,actual velocity,error in time, error in velocity, No. data pt')
            disp(store);
            if ~isempty(store{5}) && done == false                          % stores data to determine confidence metric. Manual observation for now. Could be made online
                %xlswrite(filename,store)
                final = vertcat(final,store);                                % stores the prediction and error for each curve
                disp('store');
                done = true;
            elseif isempty(store{5})
                done = false;
            end
            end
        end
    else
        disp('Press Button')
        disp(w)
    end
    
end
xlswrite(filename,final)
disp('done!')