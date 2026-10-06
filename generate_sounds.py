import wave
import math
import struct
import random
import os

os.makedirs("assets/audio", exist_ok=True)
SAMPLE_RATE = 44100

def write_wav(filename, samples):
    with wave.open(filename, 'w') as wav_file:
        wav_file.setnchannels(1)  # Mono
        wav_file.setsampwidth(2)  # 16-bit
        wav_file.setframerate(SAMPLE_RATE)
        # Pack to 16-bit PCM
        raw_data = bytearray()
        for s in samples:
            val = max(-32767, min(32767, int(s * 32767)))
            raw_data.extend(struct.pack('<h', val))
        wav_file.writeframes(raw_data)
    print(f"Generated {filename} ({len(samples)/SAMPLE_RATE:.1f}s)")

# 1. Loud Siren (Alternating high-low piercing frequency)
def gen_siren(duration=4.0):
    samples = []
    total_samples = int(SAMPLE_RATE * duration)
    phase = 0.0
    for i in range(total_samples):
        t = i / SAMPLE_RATE
        # oscillate between 800 Hz and 1300 Hz
        freq = 1050 + 250 * math.sin(2 * math.pi * 3.5 * t)
        phase += 2 * math.pi * freq / SAMPLE_RATE
        # Add harmonic for sharpness
        sample = 0.7 * math.sin(phase) + 0.3 * math.sin(2 * phase)
        samples.append(sample * 0.95)
    return samples

# 2. Digital Beep (Classic loud alarm clock beeping pattern: beep-beep-beep-beep pause)
def gen_digital_beep(duration=4.0):
    samples = []
    total_samples = int(SAMPLE_RATE * duration)
    for i in range(total_samples):
        t = i / SAMPLE_RATE
        cycle_t = t % 1.0  # 1 second loop
        # 4 beeps in 0.8s, then 0.2s silence
        beep_idx = int(cycle_t / 0.2)
        in_beep_t = cycle_t % 0.2
        if beep_idx < 4 and in_beep_t < 0.12:
            # 2000 Hz square-like sharp tone
            env = math.sin(math.pi * (in_beep_t / 0.12))
            sample = env * (0.8 * math.sin(2 * math.pi * 2040 * t) + 0.2 * math.sin(2 * math.pi * 4080 * t))
        else:
            sample = 0.0
        samples.append(sample * 0.95)
    return samples

# 3. Military Wakeup Horn / Energetic Rhythmic Alarm
def gen_military_alarm(duration=4.0):
    samples = []
    total_samples = int(SAMPLE_RATE * duration)
    # Notes in Hz: C4 (261.6), E4 (329.6), G4 (392.0), C5 (523.25)
    notes = [
        (392.0, 0.25), (523.25, 0.25), (659.25, 0.25), (783.99, 0.4),
        (0.0, 0.1),
        (659.25, 0.2), (783.99, 0.4), (0.0, 0.15),
        (523.25, 0.2), (659.25, 0.2), (783.99, 0.6), (0.0, 0.3)
    ]
    seq_duration = sum(n[1] for n in notes)
    for i in range(total_samples):
        t = i / SAMPLE_RATE
        cur_t = t % seq_duration
        accum = 0.0
        freq = 0.0
        for f, dur in notes:
            if accum <= cur_t < accum + dur:
                freq = f
                break
            accum += dur
        if freq > 0:
            sample = 0.7 * math.sin(2 * math.pi * freq * t) + 0.3 * math.sin(2 * math.pi * freq * 2 * t)
        else:
            sample = 0.0
        samples.append(sample * 0.9)
    return samples

# 4. Gentle Chimes (Ascending soothing morning bells)
def gen_gentle_chimes(duration=5.0):
    samples = [0.0] * int(SAMPLE_RATE * duration)
    chimes = [
        (0.2, 523.25),  # C5
        (1.0, 659.25),  # E5
        (1.8, 783.99),  # G5
        (2.6, 987.77),  # B5
        (3.4, 1046.50), # C6
    ]
    for start_t, freq in chimes:
        start_idx = int(start_t * SAMPLE_RATE)
        bell_len = int(1.8 * SAMPLE_RATE)
        for j in range(bell_len):
            idx = start_idx + j
            if idx < len(samples):
                t_bell = j / SAMPLE_RATE
                decay = math.exp(-3.5 * t_bell)
                val = decay * (0.7 * math.sin(2 * math.pi * freq * t_bell) +
                               0.3 * math.sin(2 * math.pi * freq * 2.75 * t_bell))
                samples[idx] += val * 0.6
    return samples

# 5. Rain Sleep Ambience (Filtered noise)
def gen_rain_ambience(duration=6.0):
    samples = []
    total_samples = int(SAMPLE_RATE * duration)
    last_val = 0.0
    for _ in range(total_samples):
        # Pink noise approximation + low pass
        white = random.uniform(-1.0, 1.0)
        last_val = (last_val * 0.85) + (white * 0.15)
        samples.append(last_val * 0.8)
    return samples

# 6. Ocean Waves Sleep Ambience
def gen_ocean_ambience(duration=6.0):
    samples = []
    total_samples = int(SAMPLE_RATE * duration)
    last_val = 0.0
    for i in range(total_samples):
        t = i / SAMPLE_RATE
        # Surge envelope every ~4 seconds
        surge = 0.3 + 0.7 * (0.5 * (1 + math.sin(2 * math.pi * 0.25 * t)))
        white = random.uniform(-1.0, 1.0)
        last_val = (last_val * 0.88) + (white * 0.12)
        samples.append(last_val * surge * 0.9)
    return samples

# 7. White Noise
def gen_white_noise(duration=5.0):
    return [random.uniform(-0.35, 0.35) for _ in range(int(SAMPLE_RATE * duration))]

write_wav("assets/audio/loud_siren.wav", gen_siren())
write_wav("assets/audio/digital_beep.wav", gen_digital_beep())
write_wav("assets/audio/military_alarm.wav", gen_military_alarm())
write_wav("assets/audio/gentle_chimes.wav", gen_gentle_chimes())
write_wav("assets/audio/rain_sleep.wav", gen_rain_ambience())
write_wav("assets/audio/ocean_waves.wav", gen_ocean_ambience())
write_wav("assets/audio/white_noise.wav", gen_white_noise())
print("All audio files generated successfully.")
