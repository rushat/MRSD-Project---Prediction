function [tsend,ysend] = fft_sse()
%% Define Variables
Fs = 10;
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
    
end