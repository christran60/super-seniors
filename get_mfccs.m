function mfccs = get_mfccs(audio_file, num_mel_coeffs, frame_size, ...
                            overlap_size, window)
    
    % Read in the audio file
    [audio_in, fs] = audioread(audio_file);

    % Split the audio signal into frames
    [S, ~, ~] = stft(audio_in, "Window", window, "FFTLength", frame_size, ...
        "OverlapLength", overlap_size, "FrequencyRange", "onesided");
    S = abs(S);
        % Compute Mel filterbank
    m = melfb(num_mel_coeffs, frame_size, fs);
 
    melSpectrum = m * S;
    % Apply cepstrum by using DCT
    mfccs = dct(melSpectrum);
    mfccs = transpose(mfccs);
    mfccs = mfccs(:, 2:end);

end
