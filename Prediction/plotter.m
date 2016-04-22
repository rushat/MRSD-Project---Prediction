clc;
clear all;
Fs = 10;

% fileID = fopen('capture_0_3.txt','r');
% formatSpec = '%f';
% sizeA = [1 Inf];
% Data = fscanf(fileID,formatSpec,sizeA);
% dat = Data.';
% dat = dat(2:size(dat, 1) - 2, :);

xlSheet = 'TMSMotion1.xlsx';
range = 'B2:B4065';
dat = xlsread(xlSheet,range);

%dat = 10*sin(2*pi*2*t);
dat = dat - mean(dat);
% 
% end_ = 1;
% for i = 1:size(dat,1)-5
%     if( dat(i,1) < 0 && dat(i+5,1) > 0 )
%         end_ = i+5;
%         break;
%     end
% end
% dat = dat(end_:end-10,1);

% from = 934;
% to = 954;
% datmod = dat((from+1):(to+1))
% tnew = (from:from+(size(datmod,1)-1)).';
% tnew = tnew*1/Fs

t = (0:size(dat,1)-1).';
t = t*1/Fs;
plot(t,dat)
%cutOFF = 5;
%val = cutOFF*(2/Fs);
%b = fir1(15,val);

%dat = filter(b, 1, dat);

% t = [1:4064].';
% t = t/10;
N = size(dat,1);
xlabel('Time'); ylabel('Height(m)');



   X = fft(dat);
   %% Frequency specifications:
   dF = Fs/N;                      % hertz
   f1 = -Fs/2:dF:Fs/2-dF;           % hertz
   f1 = abs(f1);
   magX = abs(X)/N;
   phsX = angle(X)/N;
   [ind] = find(magX > 0.01);
    mag_needed = magX(ind);
    phs_needed = phsX(ind);
    omegas = f1(ind);
    omegas = (Fs/2)*ones(size(omegas)) - omegas;
   amp = mag_needed;
  phs_needed = repmat(phs_needed.', [size(t, 1), 1]);
ang_freq = 2*pi*t*omegas;
 sinA = sin(ang_freq);
%cosA = cos(ang_freq);

 Y = sinA*amp;

% plot(t,Y);
legend('Reconstruction');
xlabel('time');
ylabel('displacement from mean');
   %% Plot the spectrum:
%    figure;
%     scatter(f1,abs(X)/N);
%    xlabel('Frequency (in hertz)');
%    title('Magnitude Response');
   
%    figure;
%    plot(f1,angle(X)/N);
%    xlabel('Frequency (in hertz)');
%    title('Phase Response');
   %axis([-0.001 0.001 0 inf]);