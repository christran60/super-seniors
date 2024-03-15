function mfccs = get_mfccs(audio_file, num_mel_coeffs, frame_size, ...
                            overlap_size, window)
    
    % Read in the audio file
    [audio_in, fs] = audioread(audio_file);

    % Split the audio signal into frames
    [S, ~, ~] = stft(audio_in, "Window", window, "FFTLength", frame_size, ...
        "OverlapLength", overlap_size, "FrequencyRange", "onesided");
    
    % Define the cutoff frequency and sampling frequency
    % cutoff_frequency = 70; % Hz
    % 
    % % Calculate the normalized cutoff frequency
    % normalized_cutoff = cutoff_frequency / (fs / 2);
    % 
    % % Define the filter order (4 for 24 dB/octave slope)
    % filter_order = 4;
    % 
    % % Design the Butterworth high-pass filter
    % [b, a] = butter(filter_order, normalized_cutoff, 'high');
    % 
    % f = (0:frame_size-1) / frame_size * fs;
    % 
    % S = S .* freqz(b, a, f, fs);

    % Take the magnitude of the frames
    S = abs(S);
    
    % Generate the mel-spaced filterbank
    [filter_bank, ~] = designAuditoryFilterBank(fs, 'FFTLength', frame_size, ...
        'NumBands', num_mel_coeffs, "FrequencyRange", [0 fs/2]);
    
    % Apply the filter bank to the frames to create the mel spectrogram
    mel_spec = filter_bank * S;
    
    % Generate cepstral coefficients with the mel spectrogram
    mfccs_all = cepstralCoefficients(mel_spec, "NumCoeffs", num_mel_coeffs);

    mfccs = mfccs_all(:, 2:end);

end