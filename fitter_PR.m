clear;
%% Read Data from File

y = xlsread('TMSMotion1.xlsx');
y = y(1:size(y,1) - 5);
%y = y_orig(200:250);

%% Read Data from Arduino
% %make sure no old serial ports are open
% clear
% delete(instrfindall);
% 
% %connect to serial port and set baud rate
% s1 = serial('/dev/tty.usbmodem1411','BaudRate', 9600);
% 
% % open connection and send identification (to initalize it or something???)
% fopen(s1);
% fprintf(s1, '*IDN?');
% 
% %number of points to be plotted
% numberOfPoints = 2000;
% 
% %initialize with zeros, to hold yvalues
% yVal(1:numberOfPoints)= 0;
% 
% % x axis points
% xVal = (1:numberOfPoints);
% 
% %create an empty plot
% thePlot = plot(nan);
% 
% %delay or pause so serial data doesnt stutter
% %pause(1);
% 
% hold on
% for index = (1:numberOfPoints)
% 
%     %reading value from Arduino
%     yVal(index) = str2double(fgets(s1));
%      
%     %every 100 points, plot the entire graph
%     % this might be a bad way to do it, but at least it's "real-time"
%     if mod(index,100) == 0
%         set(thePlot,'YData',yVal, 'XData', xVal);
%         drawnow
%         hold on
%     end
%   
% end
% 
% %yVal = yVal(50:numberOfPoints);
% %xVal = xVal(50:numberOfPoints);
% figure
% plot(xVal, yVal);
% 
% y = yVal.';

%% Define Variables
Fs = 100;
t = ( (0:size(y,1)-1)/Fs ).'; %plot(y, t,y_orig); xlabel('Time (s)'); ylabel('IR Readings');
N = size(y,1);
X_ = ones(N,3);

%% Run FFT
dat = y - mean(y);
X = fft(dat);

%% Extract dominant frequency (fft)
dF = Fs/N;                      % hertz
f1 = -Fs/2:dF:Fs/2-dF;           % hertz
f1 = abs(f1);
magX = abs(X)/N;
max_mag = max(magX);
cutoff = 0.5*max_mag;
[ind] = find(magX > cutoff);
mag_needed = magX(ind);
%%%%NOTE: CURRENTLY ONLY USING DOM FREQUENCY%%%%    ?????????? HOW ????????
%dom_f = 0.1872659176; 

G = [f1' magX];
xIndex = find(magX == max(magX), 1, 'first');
frequency = f1(ind);
dom_f = mean( 50-frequency )


%% Use Dom frequency to fit to sinusoidal function (regression)
X_(:,2) = cos((2*pi)*dom_f*t);
X_(:,3) = sin((2*pi)*dom_f*t);

y = y(:);
beta = X_\y
yhat = beta(1)+beta(2)*cos((2*pi)*dom_f*t)+beta(3)*sin((2*pi)*dom_f*t);


%% SSE
k = 1
per_10 = dom_f/10;
for om = dom_f-per_10:dom_f/100:dom_f+per_10
    
    X_(:,2) = cos((2*pi)*om*t);
    X_(:,3) = sin((2*pi)*om*t);

    y = y(:);
    beta = X_\y;
    yhat = beta(1)+beta(2)*cos((2*pi)*om*t)+beta(3)*sin((2*pi)*om*t);
    
    SSE(k) = 0;
    for i = 1:size(yhat)
        SSE(k) = SSE(k) + (yhat(i) - y(i))^2;
    end
    if k > 1
        if SSE(k)<SSE(k-1)
            om_final = om;
        end
    end
    k = k+1;
end

    X_(:,2) = cos((2*pi)*om_final*t);
    X_(:,3) = sin((2*pi)*om_final*t);

    y = y(:);
    beta = X_\y;
    yhat = beta(1)+beta(2)*cos((2*pi)*om_final*t)+beta(3)*sin((2*pi)*om_final*t);
    
    %% plot
    figure;
    plot(t,y,'b');
    hold on
    plot(t,yhat,'r','linewidth',2);
    title('0.3Hz')
    
