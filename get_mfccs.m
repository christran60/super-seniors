function mfccs = get_mfccs(audio_file, num_mel_coeffs, frame_size, ...
                            overlap_size, window)
    
    % Read in the audio file
    [audio_in, fs] = audioread(audio_file);

    % Split the audio signal into frames
    [S, ~, ~] = stft(audio_in, "Window", window, "FFTLength", frame_size, ...
        "OverlapLength", overlap_size, "FrequencyRange", "onesided");

    % Take the magnitude of the frames
    S = abs(S);
    
    % Generate the mel-spaced filterbank
    [filter_bank, ~] = designAuditoryFilterBank(fs, 'FFTLength', frame_size, ...
        'NumBands', num_mel_coeffs, "FrequencyRange", [0 fs/2]);
    
    %disp("sizes of mfcc:" + size(filter_bank) + ", "+size(S))

    % Apply the filter bank to the frames to create the mel spectrogram
    mel_spec = filter_bank * S;
    
    % Generate cepstral coefficients with the mel spectrogram
    mfccs_all = cepstralCoefficients(mel_spec, "NumCoeffs", num_mel_coeffs);

    % Remove the first MFCC (DC component)
    mfccs = mfccs_all(:, 2:end);

end