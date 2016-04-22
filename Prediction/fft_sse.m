function [t_n_hat,y_n_hat] = fft_sse(t,y,Fs)
%% Define Variables
N = size(y,1);
X_ = ones(N,3);

%% Run FFT
dat = y;
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
 

G = [f1' magX];
xIndex = find(magX == max(magX), 1, 'first');
frequency = f1(ind);
dom_f = mean(5-frequency);
dom_f = 0.1205;
if dom_f~=0
%% Use Dom frequency to fit to sinusoidal function (regression)
X_(:,2) = cos((2*pi)*dom_f*t);
X_(:,3) = sin((2*pi)*dom_f*t);

y = y(:);
beta = X_\y;
yhat = beta(1)+beta(2)*cos((2*pi)*dom_f*t)+beta(3)*sin((2*pi)*dom_f*t);


%% SSE

k = 1;
per_10 = dom_f/5;
omega = dom_f-per_10:dom_f/100:dom_f+per_10;
for om = dom_f-per_10:dom_f/100:dom_f+per_10
    
    X_(:,2) = cos((2*pi)*om*t);
    X_(:,3) = sin((2*pi)*om*t);

    y = y(:);
    beta = X_\y;
%     beta(1) = 0;
    yhat = beta(1)+beta(2)*cos((2*pi)*om*t)+beta(3)*sin((2*pi)*om*t);
    
    SSE(k) = 0;
    for i = 1:size(yhat)
        SSE(k) = SSE(k) + (yhat(i) - y(i))^2;
    end
    
    [M,I] = min(SSE);
    om_final = omega(I);
    %     if k > 1
%         if SSE(k)<=SSE(k-1)
%             om_final = om;
%         end
%     end
     k = k+1;
end

    X_(:,2) = cos((2*pi)*om_final*t);
    X_(:,3) = sin((2*pi)*om_final*t);

    y = y(:);
    beta = X_\y;
%     beta(1) = 0;
    t_hat = t(1):1/Fs:t(1)+10;
    yhat = beta(1)+beta(2)*cos((2*pi)*om_final*t_hat)+beta(3)*sin((2*pi)*om_final*t_hat);

    %% till when?
    t_n_hat = [];
    y_n_hat = [];
    for i = 1:length(t_hat)-1
        t_n_hat(i) = t_hat(i);
        y_n_hat(i) = yhat(i);
        if and(yhat(i+1)>=0,yhat(i)<0)
            ind_to_stop = i;
            t_n_hat(i) = t_hat(i);
            y_n_hat(i) = yhat(i);
            t_n_hat(i+1) = t_hat(i+1);
            y_n_hat(i+1) = yhat(i+1);
            break;
        end
    end

else
      t_n_hat = [];
      y_n_hat = [];
end    
     %% plot
%     figure;
%     plot(t,y,'b');
%     hold on
%     plot(t_n_hat,y_n_hat,'r','linewidth',2);
%     title('0.3Hz')
end