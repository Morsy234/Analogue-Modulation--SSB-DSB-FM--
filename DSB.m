clc;
clear all;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Q1%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%frequency spacing within signal[file, path] = uigetfile();
[file, path] = uigetfile();

filename = fullfile(path, file);

[mysound, Fm] = audioread(filename);

sound(mysound, Fm);
pause(8);

mysound_length = length(mysound);
mysound_audio_info = audioinfo('eric.wav');
t = 0:seconds(1 / Fm):seconds(mysound_audio_info.Duration);
t = t(1:end - 1);

freq_shift = (-mysound_length / 2 : mysound_length / 2 - 1) * (Fm / mysound_length);

mysound_Frequency_domain = fftshift(abs(fft(mysound)));
figure(1);
plot(freq_shift, mysound_Frequency_domain); title('mysound in frequency domain');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Q2%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% low-Pass Filter
% Normalization by dividing by nyquist frequency Fc =2Fm (Fm is Fs & n is Fc)
n = 4000 / (Fm / 2); 
% use low-pass filter 
[low, high] = butter(20, n, 'low');
mysound_filtered_Time_Domain = filter(low, high, mysound);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Q3%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%plotting filtered mysound it time domain
figure(2);
plot(t, mysound_filtered_Time_Domain); title('mysound filtered in time domain');
%convert filterd mysound from time domain to freq domain
mysound_filtered_freq_Domain = fftshift(abs(fft(mysound_filtered_Time_Domain)));
%length of filtered signal in time domain
mysound_filtered_Time_Domain_length = length(mysound_filtered_Time_Domain);
%sample spacing
freq_shift = (-mysound_filtered_Time_Domain_length / 2:mysound_filtered_Time_Domain_length / 2 - 1) * (Fm / mysound_filtered_Time_Domain_length);
figure(3);
plot(freq_shift, mysound_filtered_freq_Domain); title('mysound filtered in freq domain (BW=4K HZ)');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Q4%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%sound output before filtering
sound(mysound, Fm);
pause(8);
%sound output after filtering
sound(mysound_filtered_Time_Domain, Fm);
pause(8);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Q5%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
carrier_freq = 100000;
%resampling mysound filtered signal to have freq=5*carrier freq
mysound_filtered_Time_Domain_resampled = resample(mysound_filtered_Time_Domain, 5 * carrier_freq, Fm);
%length of resampled signal
new_mysound_length = length(mysound_filtered_Time_Domain_resampled);
new_mysound_dis = new_mysound_length / (5 * carrier_freq);
t = linspace(0, new_mysound_dis, new_mysound_length);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%our carrier signal
carrier = cos(2 * pi * carrier_freq * t)';
%double side band supressed carrier in time domain
DSB_SC_timeDomain = mysound_filtered_Time_Domain_resampled .* carrier;%m(t)Cos(2 *Pi *fc *t)
%double side band supressed carrier in frequency domain
DSB_SC_freqDomain = fftshift(abs(fft(DSB_SC_timeDomain)));
DSB_SC_freqDomain_length = length(DSB_SC_freqDomain);
new_freq_shift = (-DSB_SC_freqDomain_length / 2:DSB_SC_freqDomain_length / 2 - 1) * ((5 * carrier_freq) / DSB_SC_freqDomain_length);
figure(4);
plot(new_freq_shift, abs(DSB_SC_freqDomain)); title('DSB-SC spectrum');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%get the carrier amplitude to be twice the max amplitude of resampled signal
%to make sure that Ac>signal amplitude
%(under modulation)(modulation index=0.5)
carrier_amp = 2 * max(mysound_filtered_Time_Domain_resampled);
%double side band transmitted carrier in time domain
DSB_TC_timeDomain = (carrier_amp + mysound_filtered_Time_Domain_resampled) .* carrier;% (Ac + m(t))Cos(2 *Pi *fc *t)
%double side band transmitted carrier in frequency domain
DSB_TC_freqDomain = fftshift(abs(fft(DSB_TC_timeDomain)));
figure(5);
plot(new_freq_shift, DSB_TC_freqDomain); title('DSB-TC spectrum');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Q6,7%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
env_DSB_SC = abs(hilbert(DSB_SC_timeDomain));
figure(6);
%resampling back to Fm
env_DSB_SC = resample(env_DSB_SC, Fm, 5 * carrier_freq);
%length of resampled signal
env_sound_SC_length = length(env_DSB_SC);
t_env_sc = linspace(0, (5 * carrier_freq), env_sound_SC_length);
%plotting the envelope of the DSB-SC
plot(t_env_sc, env_DSB_SC); title('envelope of the DSB-SC');
%{
After seeing the plot of the evelope of the DSB-SC We observe that most
of the signal is lost due to the clipping of the envelope detection. That
is because of the phase reversal in the modulated signal.DSB-SB
%}
%sounding the audio of the envelope
sound(env_DSB_SC, Fm);
pause(8);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
env_DSB_TC = abs(hilbert(DSB_TC_timeDomain));
%resampling back to Fm
env_DSB_TC = resample(env_DSB_TC, Fm, 5 * carrier_freq);
%length of resampled signal
env_sound_TC_length = length(env_DSB_TC);
t_env_tc = linspace(0, (5 * carrier_freq), env_sound_TC_length);
figure(7);
%plotting the envelope of the DSB-TC
plot(t_env_tc, env_DSB_TC); title('envelope of the DSB-TC');
%{
After seeing the plot of the envelope of the DSB-TC We observe that all
the signal is recovered, and that is due to no phase reversal because of
that the modulation index < 1.a<A
So envelope detector should be used with DSB-TC
%}
%sounding the audio of the DSB-TC
sound(env_DSB_TC, Fm);
pause(8);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Q8%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%adding noise
out_0db = awgn(DSB_SC_timeDomain, 0, 'measured');
out_10db = awgn(DSB_SC_timeDomain, 10, 'measured');
out_30db = awgn(DSB_SC_timeDomain, 30, 'measured');

%getting the coherent in time domain
coherent_0db = (out_0db .* carrier) .* 2;
coherent_10db = (out_10db .* carrier) .* 2;
coherent_30db = (out_30db .* carrier) .* 2;

%resampling all the coherents
coherent_0db_resampled = resample(coherent_0db, Fm, 5 * carrier_freq);
coherent_10db_resampled = resample(coherent_10db, Fm, 5 * carrier_freq);
coherent_30db_resampled = resample(coherent_30db, Fm, 5 * carrier_freq);

%length of resampled signal
coherent_0db_sound_length = length(coherent_0db_resampled);
coherent_0db_dis = coherent_0db_sound_length / (5 * carrier_freq);
coherent_10db_sound_length = length(coherent_10db_resampled);
coherent_10db_dis = coherent_10db_sound_length / (5 * carrier_freq);
coherent_30db_sound_length = length(coherent_30db_resampled);
coherent_30db_dis = coherent_30db_sound_length / (5 * carrier_freq);

%frequency spacing within resampled signal
coherent_0db_freq_shift = ((coherent_0db_sound_length / coherent_0db_dis) / 2) * linspace(-1, 1, (coherent_0db_sound_length / coherent_0db_dis));
coherent_10db_freq_shift = ((coherent_10db_sound_length / coherent_10db_dis) / 2) * linspace(-1, 1, (coherent_10db_sound_length / coherent_10db_dis));
coherent_30db_freq_shift = ((coherent_30db_sound_length / coherent_30db_dis) / 2) * linspace(-1, 1, (coherent_30db_sound_length / coherent_30db_dis));

t_0dp = linspace(0, (5 * carrier_freq), coherent_0db_sound_length);
t_10dp = linspace(0, (5 * carrier_freq), coherent_10db_sound_length);
t_30dp = linspace(0, (5 * carrier_freq), coherent_30db_sound_length);

%plotting the coherent of the noisy output in time domain and sounding them
figure(8);
plot(t_0dp, coherent_0db_resampled); title('coherent of DSB-SC with SNR of 0db time domain');
%sound(coherent_0db_resampled, Fm);
%pause(8);
figure(9);
plot(t_10dp, coherent_10db_resampled); title('coherent of DSB-SC with SNR of 10db time domain');
sound(coherent_10db_resampled, Fm);
pause(8);
figure(10);
plot(t_10dp, coherent_30db_resampled); title('coherent of DSB-SC with SNR of 30db time domain');% nearly equal m(t)
sound(coherent_30db_resampled, Fm);
pause(8);

%getting the coherent in freq domain
coherent_0db_freq = fftshift(fft(coherent_0db_resampled, numel(coherent_0db_freq_shift)));
coherent_10db_freq = fftshift(fft(coherent_10db_resampled, numel(coherent_10db_freq_shift)));
coherent_30db_freq = fftshift(fft(coherent_30db_resampled, numel(coherent_30db_freq_shift)));

%plotting the coherent of the noisy output in freq domain
figure(11);
plot(coherent_0db_freq_shift, abs(coherent_0db_freq)); title('coherent of DSB-SC with SNR of 0db freq domain');
figure(12);
plot(coherent_10db_freq_shift, abs(coherent_10db_freq)); title('coherent of DSB-SC with SNR of 10db freq domain');
figure(13);
plot(coherent_30db_freq_shift, abs(coherent_30db_freq)); title('coherent of DSB-SC with SNR of 30db freq domain');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Q9%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%getting the coherent in time domain
freq_shifted_coherent_0db = out_0db .* (cos(2 * pi * (carrier_freq + 100) * t)');

%resampling the coherent
freq_shifted_coherent_0db_resampled = resample(freq_shifted_coherent_0db, Fm, 5 * carrier_freq);

%length of resampled signal
freq_shifted_coherent_0db_sound_length = length(freq_shifted_coherent_0db_resampled);
freq_shifted_coherent_0db_dis = freq_shifted_coherent_0db_sound_length / (5 * carrier_freq);

%frequency spacing within resampled signal
freq_shifted_coherent_0db_freq_shift = ((freq_shifted_coherent_0db_sound_length / freq_shifted_coherent_0db_dis) / 2) * linspace(-1, 1, (freq_shifted_coherent_0db_sound_length / freq_shifted_coherent_0db_dis));

t_freq_shifted_0dp = linspace(0, (5 * carrier_freq), freq_shifted_coherent_0db_sound_length);

%plotting the coherent of the noisy output in time domain and sounding it
figure(14);
plot(t_freq_shifted_0dp, freq_shifted_coherent_0db_resampled); title('coherent of DSB-SC freq shifted with SNR of 0db time domain');
sound(freq_shifted_coherent_0db_resampled, Fm);
pause(8);

%getting the coherent in freq domain
freq_shifted_coherent_0db_freq = fftshift(fft(freq_shifted_coherent_0db_resampled, numel(freq_shifted_coherent_0db_freq_shift)));

%plotting the coherent of the noisy output in freq domain
figure(15);
plot(freq_shifted_coherent_0db_freq_shift, abs(freq_shifted_coherent_0db_freq)); title('coherent of DSB-SC freq shifted with SNR of 0db freq domain');
%****************************
%getting the coherent in time domain
freq_shifted_coherent_10db = out_10db .* (cos(2 * pi * (carrier_freq + 100) * t)');

%resampling the coherent
freq_shifted_coherent_10db_resampled = resample(freq_shifted_coherent_10db, Fm, 5 * carrier_freq);

%length of resampled signal
freq_shifted_coherent_10db_sound_length = length(freq_shifted_coherent_10db_resampled);
freq_shifted_coherent_10db_dis = freq_shifted_coherent_10db_sound_length / (5 * carrier_freq);

%frequency spacing within resampled signal
freq_shifted_coherent_10db_freq_shift = ((freq_shifted_coherent_10db_sound_length / freq_shifted_coherent_10db_dis) / 2) * linspace(-1, 1, (freq_shifted_coherent_10db_sound_length / freq_shifted_coherent_10db_dis));

t_freq_shifted_10dp = linspace(0, (5 * carrier_freq), freq_shifted_coherent_10db_sound_length);

%plotting the coherent of the noisy output in time domain and sounding it
figure(16);
plot(t_freq_shifted_10dp, freq_shifted_coherent_10db_resampled); title('coherent of DSB-SC freq shifted with SNR of 10db time domain');
sound(freq_shifted_coherent_10db_resampled, Fm);
pause(8);

%getting the coherent in freq domain
freq_shifted_coherent_10db_freq = fftshift(fft(freq_shifted_coherent_10db_resampled, numel(freq_shifted_coherent_10db_freq_shift)));

%plotting the coherent of the noisy output in freq domain
figure(17);
plot(freq_shifted_coherent_10db_freq_shift, abs(freq_shifted_coherent_10db_freq)); title('coherent of DSB-SC freq shifted with SNR of 10db freq domain');
%****************************
%getting the coherent in time domain
freq_shifted_coherent_30db = out_30db .* (cos(2 * pi * (carrier_freq + 100) * t)');

%resampling the coherent
freq_shifted_coherent_30db_resampled = resample(freq_shifted_coherent_30db, Fm, 5 * carrier_freq);

%length of resampled signal
freq_shifted_coherent_30db_sound_length = length(freq_shifted_coherent_30db_resampled);
freq_shifted_coherent_30db_dis = freq_shifted_coherent_30db_sound_length / (5 * carrier_freq);

%frequency spacing within resampled signal
freq_shifted_coherent_30db_freq_shift = ((freq_shifted_coherent_30db_sound_length / freq_shifted_coherent_30db_dis) / 2) * linspace(-1, 1, (freq_shifted_coherent_30db_sound_length / freq_shifted_coherent_30db_dis));

t_freq_shifted_30dp = linspace(0, (5 * carrier_freq), freq_shifted_coherent_30db_sound_length);

%plotting the coherent of the noisy output in time domain and sounding it
figure(18);
plot(t_freq_shifted_30dp, freq_shifted_coherent_30db_resampled); title('coherent of DSB-SC freq shifted with SNR of 30db time domain');
sound(freq_shifted_coherent_30db_resampled, Fm);
pause(8);

%getting the coherent in freq domain
freq_shifted_coherent_30db_freq = fftshift(fft(freq_shifted_coherent_30db_resampled, numel(freq_shifted_coherent_30db_freq_shift)));

%plotting the coherent of the noisy output in freq domain
figure(19);
plot(freq_shifted_coherent_30db_freq_shift, abs(freq_shifted_coherent_30db_freq)); title('coherent of DSB-SC freq shifted with SNR of 30db freq domain');
%%%%%%%%%name of this phenomenon: A-synchronous detection frequency error (frequency shift)%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Q10%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%getting the coherent in time domain
phase_shifted_coherent_0db = (out_0db .* (cos((2 * pi * carrier_freq * t) + (20 * (pi / 180)))')) .* 2;

%resampling the coherent
phase_shifted_coherent_0db_resampled = resample(phase_shifted_coherent_0db, Fm, 5 * carrier_freq);

%length of resampled signal
phase_shifted_coherent_0db_sound_length = length(phase_shifted_coherent_0db_resampled);
phase_shifted_coherent_0db_dis = phase_shifted_coherent_0db_sound_length / (5 * carrier_freq);

%frequency spacing within resampled signal
phase_shifted_coherent_0db_freq_shift = ((phase_shifted_coherent_0db_sound_length / phase_shifted_coherent_0db_dis) / 2) * linspace(-1, 1, (phase_shifted_coherent_0db_sound_length / phase_shifted_coherent_0db_dis));

t_phase_shifted_0dp = linspace(0, (5 * carrier_freq), freq_shifted_coherent_0db_sound_length);

%plotting the coherent of the noisy output in time domain and sounding it
figure(20);
plot(t_phase_shifted_0dp, phase_shifted_coherent_0db_resampled); title('coherent of DSB-SC phase shifted with SNR of 0db time domain');
sound(phase_shifted_coherent_0db_resampled, Fm);
pause(8);

%getting the coherent in freq domain
phase_shifted_coherent_0db_freq = fftshift(fft(phase_shifted_coherent_0db_resampled, numel(phase_shifted_coherent_0db_freq_shift)));

%plotting the coherent of the noisy output in freq domain
figure(21);
plot(phase_shifted_coherent_0db_freq_shift, abs(phase_shifted_coherent_0db_freq)); title('coherent of DSB-SC phase shifted with SNR of 0db freq domain');
%**********************
%getting the coherent in time domain
phase_shifted_coherent_10db = (out_10db .* (cos((2 * pi * carrier_freq * t) + (20 * (pi / 180)))')) .* 2;

%resampling the coherent
phase_shifted_coherent_10db_resampled = resample(phase_shifted_coherent_10db, Fm, 5 * carrier_freq);

%length of resampled signal
phase_shifted_coherent_10db_sound_length = length(phase_shifted_coherent_10db_resampled);
phase_shifted_coherent_10db_dis = phase_shifted_coherent_10db_sound_length / (5 * carrier_freq);

%frequency spacing within resampled signal
phase_shifted_coherent_10db_freq_shift = ((phase_shifted_coherent_10db_sound_length / phase_shifted_coherent_10db_dis) / 2) * linspace(-1, 1, (phase_shifted_coherent_10db_sound_length / phase_shifted_coherent_10db_dis));

t_phase_shifted_10dp = linspace(0, (5 * carrier_freq), freq_shifted_coherent_10db_sound_length);

%plotting the coherent of the noisy output in time domain and sounding it
figure(22);
plot(t_phase_shifted_10dp, phase_shifted_coherent_10db_resampled); title('coherent of DSB-SC phase shifted with SNR of 10db time domain');
sound(phase_shifted_coherent_10db_resampled, Fm);
pause(8);

%getting the coherent in freq domain
phase_shifted_coherent_10db_freq = fftshift(fft(phase_shifted_coherent_10db_resampled, numel(phase_shifted_coherent_10db_freq_shift)));

%plotting the coherent of the noisy output in freq domain
figure(23);
plot(phase_shifted_coherent_10db_freq_shift, abs(phase_shifted_coherent_10db_freq)); title('coherent of DSB-SC phase shifted with SNR of 10db freq domain');
%*************
%getting the coherent in time domain
phase_shifted_coherent_30db = (out_30db .* (cos((2 * pi * carrier_freq * t) + (20 * (pi / 180)))')) .* 2;

%resampling the coherent
phase_shifted_coherent_30db_resampled = resample(phase_shifted_coherent_30db, Fm, 5 * carrier_freq);

%length of resampled signal
phase_shifted_coherent_30db_sound_length = length(phase_shifted_coherent_30db_resampled);
phase_shifted_coherent_30db_dis = phase_shifted_coherent_30db_sound_length / (5 * carrier_freq);

%frequency spacing within resampled signal
phase_shifted_coherent_30db_freq_shift = ((phase_shifted_coherent_30db_sound_length / phase_shifted_coherent_30db_dis) / 2) * linspace(-1, 1, (phase_shifted_coherent_30db_sound_length / phase_shifted_coherent_30db_dis));

t_phase_shifted_30dp = linspace(0, (5 * carrier_freq), freq_shifted_coherent_30db_sound_length);

%plotting the coherent of the noisy output in time domain and sounding it
figure(24);
plot(t_phase_shifted_30dp, phase_shifted_coherent_30db_resampled); title('coherent of DSB-SC phase shifted with SNR of 30db time domain');
sound(phase_shifted_coherent_30db_resampled, Fm);
pause(8);

%getting the coherent in freq domain
phase_shifted_coherent_30db_freq = fftshift(fft(phase_shifted_coherent_30db_resampled, numel(phase_shifted_coherent_30db_freq_shift)));

%plotting the coherent of the noisy output in freq domain
figure(25);
plot(phase_shifted_coherent_30db_freq_shift, abs(phase_shifted_coherent_30db_freq)); title('coherent of DSB-SC phase shifted with SNR of 30db freq domain');