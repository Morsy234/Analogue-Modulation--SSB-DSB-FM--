clc;
clear all;
close all;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Q1%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1. Use Matlab to read the attached audio file which has a sampling frequency Fs= 48 KHz. Find the spectrum of this signal.
%transfer mysound from time to frequency domain

[file, path] = uigetfile();
filename = fullfile(path, file);
[mysound, Fm] = audioread(filename);
%sound output
sound(mysound, Fm);
pause(10);
mysound_audioinfo = audioinfo('eric.wav');
t = 0 : seconds(1/Fm) : seconds(mysound_audioinfo.Duration);
t = t(1:end-1);

mysound_Frequency_domain = fftshift(abs(fft(mysound)));
%length of mysound
mysound_length = length(mysound);
%frequency spacing within signal
freq_shift = (-mysound_length/2:mysound_length/2-1) * (Fm/mysound_length);
%plotting the sound in time domain
figure(1);
plot(t, mysound);title('mysound in time domain');
% plotting the sound in frequency domain
figure(2);
plot(freq_shift, mysound_Frequency_domain); title('mysound in frequency domain');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Q2%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2. Using an ideal Filter, remove all frequencies greater than 4 KHz.
% Apply lowePass Filter
n = 4000/(Fm/2);
%we use low-pass filter of the 20th order
[low, high] = butter(20,n,'low');
mysound_filtered_timeDomain = filter(low,high,mysound);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Q3%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 3. Obtain the filtered signal in time domain, this is a band limited signal 
% of BW=4 KHz. You could play the sound back, to make sure only small distortion was introduced.
%convert filterd mysound from frequency to time domain
mysound_filtered_freqDomain = fftshift(abs(fft(mysound_filtered_timeDomain)));
%sample spacing
mysound_filtered_timeDomain_length = length(mysound_filtered_timeDomain);
freq_shift = (-mysound_filtered_timeDomain_length/2:mysound_filtered_timeDomain_length/2-1) * (Fm/mysound_filtered_timeDomain_length);
%plotting the filtered sound in time domain
figure(3);
plot(t, mysound_filtered_timeDomain);title('mysound filtered in time domain');
%plotting the spectrum of the filtered mysound
figure(4);
plot(freq_shift, mysound_filtered_freqDomain); title('mysound filtered in frequency domain');
sound(mysound_filtered_timeDomain, Fm);
pause(10);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Q4%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 4. Generate a DSB-SC modulated signal and plot its spectrum. Choose the carrier frequency to be 100kHz. 
% Remember to set the sampling frequency to Five times the carrier frequency Fs = 5??.
% carrier_freq -> Fc = 100KHz
carrier_freq = 100000;
%resampling mysound filtered signal to have freq=5*carrier freq
mysound_filtered_Time_Domain_resampled = resample(mysound_filtered_timeDomain, 5 * carrier_freq, Fm);
%length of resampled signal
new_mysound_length = length(mysound_filtered_Time_Domain_resampled);
new_mysound_dis = new_mysound_length / (5 * carrier_freq);
%frequency spacing within resampled signal
t = linspace(0, new_mysound_dis, new_mysound_length);
mysound_filtered_Freq_Domain_resampled = fftshift(abs( fft(mysound_filtered_Time_Domain_resampled) ));

%our carrier signal
carrier = cos(2 * pi * carrier_freq * t)';
%carrier = permute(carrier, [2,1]);
%double side band supressed carrier in time domain
DSB_SC_timeDomain = mysound_filtered_Time_Domain_resampled .* carrier;
%double side band supressed carrier in frequency domain
DSB_SC_freqDomain = fftshift(abs(fft(DSB_SC_timeDomain)));
DSB_SC_freqDomain_length = length(DSB_SC_freqDomain);
new_freq_shift = (-DSB_SC_freqDomain_length/2:DSB_SC_freqDomain_length/2-1) * ((5 * carrier_freq)/DSB_SC_freqDomain_length);
figure(5);
plot(t,DSB_SC_timeDomain); title('DSB-SC Time Domain');
figure(6);
plot(new_freq_shift, DSB_SC_freqDomain); title('DSB-SC spectrum');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Q5%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 5. Obtain the SSB by filtering out the USB (we need to get LSB only) of the DSB-SC modulated signal using an ideal filter then Plot the spectrum again.
% SSB-SC MODULATION
% Hilbert transform of baseband-->(phase shifter 90 deg)
mysound_filtered_Time_Domain_resampled_resampled = imag(hilbert(mysound_filtered_Time_Domain_resampled));
carrier_image = imag(hilbert(carrier));
% Single Side Band with Lower Side Band
%Get the SSB SC in time domain-->x(t)cos(2*pi*fc*t)+x^(t)sin(2*pi*fc*t)
SSB_SC_timeDomain = mysound_filtered_Time_Domain_resampled .* carrier + mysound_filtered_Time_Domain_resampled_resampled .* carrier_image;
%SSB SC in frequency domain 
SSB_SC_freqDomain = fftshift( abs(fft(SSB_SC_timeDomain)));
%Plot the lower side band of SSB-SC in time domain and frequency domain
figure(7);
plot(t,SSB_SC_timeDomain);title('SSB-SC LSB Time Domain');
figure(8);
plot(new_freq_shift,SSB_SC_freqDomain);title('SSB-SC LSB Spectrum');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Q6%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 6. Use coherent detection with no noise interference to get the received signal 
% (to demodulate the SSB-SC) and play the file back also sketch the received waveform and spectrum.
% COHERENT DETECTION
%Multiply the SSB-SC with the carrier
demodulated_SSB_SC_timeDomain = SSB_SC_timeDomain.*carrier; %the output signal after multiplying ssb signal with carrier frequency
%Get the SSB-SC in frequency domain
demodulated_SSB_SC_freqDomain = fftshift(abs(fft(demodulated_SSB_SC_timeDomain)));
CutOffFreq = carrier_freq/((5 * carrier_freq)/2);             % Normalized cutoff frequency
%Pass the demodulated signal through low pass filter to get the original signal
[low, high] = butter(20,CutOffFreq,'low'); % 20th order low-pass filter
demodulated_SSB_SC_timeDomain_lowpassfilter = filter(low,high,demodulated_SSB_SC_timeDomain);
demodulated_SSB_SC_freqDomain_lowpassfilter = fftshift(abs(fft(demodulated_SSB_SC_timeDomain_lowpassfilter)));
%plot the output signal in time domain and frequency domain
figure(9);
plot(t, demodulated_SSB_SC_timeDomain_lowpassfilter);title('SSB-SC Demodulated Signal in Time Domain');
figure(10);
plot(new_freq_shift, demodulated_SSB_SC_freqDomain_lowpassfilter);title('SSB-SC Demodulated Spectrum');
%resample the output signal and play sound
demodulated_SSB_SC_timeDomain_lowpassfilter = resample(demodulated_SSB_SC_timeDomain_lowpassfilter,Fm,5 * carrier_freq);
sound(demodulated_SSB_SC_timeDomain_lowpassfilter, Fm);
pause(10);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Q7%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 7. Repeat steps 5 and 6, only this time. Use a practical 4th order Butterworth filter.
%Get the cutoff frequency and pass it through a butter filter
lower_freq=(carrier_freq-4e3)/((5*carrier_freq)/2);
higher_freq=carrier_freq/((5*carrier_freq)/2);
cut_off_frequency=[lower_freq,higher_freq]; 
[low, high] = butter(4,cut_off_frequency);
%Filter the USB from DSB-SC to get LSB using butterworth filter
SSB_SC_timeDomain_butterworth = filter(low, high, DSB_SC_timeDomain);
SSB_SC_freqDomain_butterworth = fftshift(abs(fft(SSB_SC_timeDomain_butterworth)));
%Plot SSB-SC in time domain and frequency domain
figure(11);
plot(t, SSB_SC_timeDomain_butterworth);title('SSB-SC time domain using practical Butterworth filter');
figure(12);
plot(new_freq_shift, SSB_SC_freqDomain_butterworth);title('SSB-SC spectrum using practical Butterworth filter');

%Demodulation of practical butter worth
%Multiply the butterworth signal with the carrier
demodulated_SSB_SC_timeDomain_butterworth = SSB_SC_timeDomain_butterworth .* carrier;
demodulated_SSB_SC_timeDomain_butterworth_length = length(fft(demodulated_SSB_SC_timeDomain_butterworth));
CutOffFreq = carrier_freq/((5 * carrier_freq)/2);
[low, high] = butter(4,CutOffFreq,'low'); % 4th order low-pass filter
%Pass through a lowpass filter to get the original signal
demodulated_SSB_SC_timeDomain_butterworth = filter(low, high, demodulated_SSB_SC_timeDomain_butterworth);
demodulated_SSB_SC_freqDomain_butterworth = fftshift(abs(fft(demodulated_SSB_SC_timeDomain_butterworth)));
%Plot the output signal in time domain and frequency domain
figure(13);
plot(t, demodulated_SSB_SC_timeDomain_butterworth);title('SSB-SC ButterWorth Demodulated in Time Domian');
figure(14);
plot(new_freq_shift, demodulated_SSB_SC_freqDomain_butterworth);title('SSB-SC ButterWorth Demodulated Spectrum');
demodulated_SSB_SC_timeDomain_butterworth = resample(demodulated_SSB_SC_timeDomain_butterworth,Fm,5*carrier_freq);
%Play the sound
sound(demodulated_SSB_SC_timeDomain_butterworth, Fm);
pause(10);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Q8%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 8. For the ideal filter case, get the received signal again but when noise is added to SSB-SC with SNR = 0, 10, and 30 
% also play the received sound and sketch the received waveform/spectrum in each case.
% ADDING NOISE TO SIGNAL
CutOffFreq = carrier_freq/((5 * carrier_freq)/2);
[low, high] = butter(20,CutOffFreq,'low');
%CASE 1 
%add guassian noise of 0 dB
SSB_Noise_1 = awgn(SSB_SC_timeDomain, 0);
%multiply signal with carrier
SSB_Noise_1 = SSB_Noise_1 .* carrier;
%pass signal through lowpass filter to remove USB
SSB_Noise_1 = filter(low,high,SSB_Noise_1);
SSB_Noise_1_spectrum = fftshift(abs(fft(SSB_Noise_1)));
%plot generated signal and play sound
figure(15);
plot(t, SSB_Noise_1);title('SSB-SC Signal With Guassian Noise of 0 dB in time domain');
figure(16);
plot(new_freq_shift, SSB_Noise_1_spectrum);title('SSB-SC Signal With Guassian Noise of 0 dB in frequency domain');
SSB_Noise_1 = resample(SSB_Noise_1,Fm,5*carrier_freq);
sound(SSB_Noise_1, Fm);
pause(10);

%CASE 2
%add guassian noise of 10 dB
SSB_Noise_2 = awgn(SSB_SC_timeDomain, 10);
%multiply signal with carrier
SSB_Noise_2 = SSB_Noise_2 .* carrier;
%pass signal through lowpass filter to remove USB
SSB_Noise_2 = filter(low,high,SSB_Noise_2);
SSB_Noise_2_spectrum = fftshift(abs(fft(SSB_Noise_2)));
%plot generated signal and play sound
figure(17);
plot(t, SSB_Noise_2);title('SSB-SC Signal With Guassian Noise of 10 dB in time domain');
figure(18);
plot(new_freq_shift, SSB_Noise_2_spectrum);title('SSB-SC Signal With Guassian Noise of 10 dB in frequency domain');
SSB_Noise_2 = resample(SSB_Noise_2,Fm,5*carrier_freq);
sound(SSB_Noise_2, Fm);
pause(10);

%CASE 3
%add guassian noise of 30 dB
SSB_Noise_3 = awgn(SSB_SC_timeDomain, 30);
%multiply signal with carrier
SSB_Noise_3 = SSB_Noise_3 .* carrier;
%pass signal through lowpass filter to remove USB
SSB_Noise_3 = filter(low,high,SSB_Noise_3);
SSB_Noise_3_spectrum = fftshift(abs(fft(SSB_Noise_3)));
%plot generated signal and play sound
figure(19);title('SSB-SC Signal With Guassian Noise of 30 dB in time domain');
plot(t, SSB_Noise_3);
figure(20);
plot(new_freq_shift, SSB_Noise_3_spectrum);title('SSB-SC Signal With Guassian Noise of 30 dB in frequency domain');
SSB_Noise_3 = resample(SSB_Noise_3,Fm,5*carrier_freq);
sound(SSB_Noise_3, Fm);
pause(10);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Q9%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 9. For the ideal filter case, generate a SSB-TC. As with experiment one, set the DC bias to twice the maximum of the message. 
% Use envelope detector to demodulate the message (without noise) . Play back the received message and sketch its waveform.
%get the carrier amplitude to be twice the max amplitude of resampled signal
carrier_amp = 2 * max(real(mysound_filtered_timeDomain));
%double side band transmitted carrier in time domain
DSB_TC_timeDomain = (carrier_amp + mysound_filtered_Time_Domain_resampled) .* carrier;
%double side band transmitted carrier in frequency domain
DSB_TC_freqDomain = fftshift(abs(fft(DSB_TC_timeDomain)));
%plot DSB-TC in time domain and frequency domain
figure(21);
plot(t, DSB_TC_timeDomain); title('DSB-TC in Time Domain');
figure(22);
plot(new_freq_shift, DSB_TC_freqDomain); title('DSB-TC spectrum');
%Pass the DSB-TC through a low pass filter to get the original signal
design_filter = designfilt('lowpassfir', 'FilterOrder', 8000, 'CutoffFrequency', carrier_freq, 'SampleRate', 5*carrier_freq);
SSB_TC_timeDomain  = filter(design_filter, DSB_TC_timeDomain);
SSB_TC_freqDomain = fftshift(abs(fft(SSB_TC_timeDomain)));
%plot the generated signal in time domain and frequency domain
figure(23);
plot(t, SSB_TC_timeDomain); title('SSB-TC in Time Domain');
figure(24);
plot(new_freq_shift, SSB_TC_freqDomain); title('SSB-TC spectrum');
%Use hilbert transform to create envelope detector for SSB-TC
received_envelope_SSB_TC_timeDomain = abs(hilbert(SSB_TC_timeDomain));
received_envelope_SSB_TC_freqDomain = fftshift(abs(fft(received_envelope_SSB_TC_timeDomain)));
%plot generated signal in time domain and frequency domain
figure(25);
plot(t, received_envelope_SSB_TC_timeDomain);title('Envelope of SSB-TC in time domain');
figure(26);
plot(new_freq_shift, received_envelope_SSB_TC_freqDomain);title('Envelope of SSB-TC in frequency domain');
%play sound
received_envelope_SSB_TC_timeDomain = resample(received_envelope_SSB_TC_timeDomain,Fm,5*carrier_freq);
sound(received_envelope_SSB_TC_timeDomain, Fm);