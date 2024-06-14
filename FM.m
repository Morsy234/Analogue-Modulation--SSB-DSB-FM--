clc;
clear all;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%this will make the user select the file to be used and list it in the current folder(return the name and path to the file when the user clicks open)
[file, path] = uigetfile();
%the filepath to be used will be saved in filename
filename = fullfile(path, file);
%the soundfile will be saved in "mysound" and the sampling frequency of that wavfile will be saved in Fm
[mysound, Fm] = audioread(filename);
%sound output
sound(mysound, Fm);
pause(8);
%length of mysound
mysound_length = length(mysound);
mysound_audio_info = audioinfo('eric.wav');
t = 0:seconds(1 / Fm):seconds(mysound_audio_info.Duration);
t = t(1:end - 1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Q1%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%frequency spacing within signal
freq_shift = (-mysound_length / 2 : mysound_length / 2 - 1) * (Fm / mysound_length);
%transfere mysound from time to frequency domain
mysound_Frequency_domain = fftshift(abs(fft(mysound)));
figure(1);
plot(freq_shift, mysound_Frequency_domain); title('mysound in frequency domain');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Q2%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% to create low-Pass Filter
n = 4000 / (Fm / 2); %%--------------> Normalization by dividing by nyquist frequency Fc =2Fm (Fm is Fs & n is Fc)
%we use low-pass filter of the 20th order
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

%%%%%%%%%question2%%%%%%%%%%


carrier_freq = 100000;
Fm = 5 * carrier_freq;
resampledSignal = resample(mysound_filtered_Time_Domain, Fm, carrier_freq);
t_resampled = linspace(0, length(resampledSignal) / Fm, length(resampledSignal));
A = max(abs(resampledSignal));
Kf = 0.2 / (2 * pi * max(cumsum(resampledSignal) * (1 / Fm)));
delta = Kf .* cumsum(resampledSignal).';
NBFM_time = A .* cos(2 * pi * carrier_freq * t_resampled + delta);

% Plot NBFM signal in time domain
figure(3);
subplot(2, 1, 1);
plot(t_resampled, NBFM_time);
title('NBFM Signal in Time Domain');
xlabel('Time (s)');
ylabel('Amplitude');

% Convert NBFM signal to frequency domain
NBFM_freq_domain = fftshift(abs(fft(NBFM_time)));
% Length of NBFM signal in time domain
NBFM_length = length(NBFM_time);
% Sample spacing
freq_shift_NBFM = (-NBFM_length / 2 : NBFM_length / 2 - 1) * (Fm / NBFM_length);

% Plot NBFM signal in frequency domain
subplot(2, 1, 2);
plot(freq_shift_NBFM, NBFM_freq_domain);
title('NBFM Signal in Frequency Domain');
xlabel('Frequency (Hz)');
ylabel('Magnitude');



%%%%question3%%%%%%%%%%
%%beta<<1
 
%%%%question4%%%%%%%%%%

signalDiff_AM = diff(NBFM_time);
signal_envelope = abs(hilbert(signalDiff_AM)); 
signal_envelopeResampled = resample(signal_envelope, Fm, carrier_freq);

t_envelopeResampled = linspace(0, length(signal_envelopeResampled) / Fm, length(signal_envelopeResampled));

figure(4);
subplot(2, 1, 1);
plot(t_envelopeResampled, signal_envelopeResampled);
title('Envelope of NBFM Signal in Time Domain');
xlabel('Time (s)');
ylabel('Amplitude');

% Convert the envelope signal to frequency domain
envelope_freq_domain = fftshift(abs(fft(signal_envelopeResampled)));
% Length of the envelope signal in time domain
envelope_length = length(signal_envelopeResampled);
% Sample spacing
freq_shift_envelope = (-envelope_length / 2 : envelope_length / 2 - 1) * (Fm / envelope_length);

% Plot envelope signal in frequency domain
subplot(2, 1, 2);
plot(freq_shift_envelope, envelope_freq_domain);
title('Envelope of NBFM Signal in Frequency Domain');
xlabel('Frequency (Hz)');
ylabel('Magnitude');