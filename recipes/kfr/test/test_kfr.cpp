// Exercises every installed KFR library: dft, dsp, io and audio.
#include <kfr/audio.hpp>
#include <kfr/base.hpp>
#include <kfr/dft.hpp>
#include <kfr/dsp.hpp>
#include <kfr/io.hpp>

#include <cmath>
#include <cstdio>

using namespace kfr;

static int check(bool ok, const char* what)
{
    std::printf("%-28s %s\n", what, ok ? "ok" : "FAILED");
    return ok ? 0 : 1;
}

int main()
{
    println(library_version(), " running on ", cpu_runtime());
    int failures = 0;

    // dft: a sine with 8 cycles over 1024 samples peaks in bin 8
    {
        const size_t size = 1024;
        univector<complex<fbase>> in(size), out(size), back(size);
        for (size_t i = 0; i < size; ++i)
            in[i] = std::sin(fbase(2) * c_pi<fbase> * fbase(8) * fbase(i) / fbase(size));
        const dft_plan<fbase> plan(size);
        univector<u8> temp(plan.temp_size);
        plan.execute(out, in, temp);
        size_t peak = 0;
        for (size_t i = 1; i < size / 2; ++i)
            if (cabs(out[i]) > cabs(out[peak]))
                peak = i;
        failures += check(peak == 8, "dft forward");

        plan.execute(back, out, temp, true);
        fbase err = 0;
        for (size_t i = 0; i < size; ++i)
            err = std::max(err, fbase(cabs(back[i] / fbase(size) - in[i])));
        failures += check(err < fbase(1e-4), "dft inverse");
    }

    // dsp: an elliptic low-pass (needs Boost.Math at build time) removes a tone above cut-off
    {
        const fbase fs = 48000;
        zpk filt       = iir_lowpass(elliptic(8, fbase(1), fbase(80)), fbase(1000), fs);
        iir_params<fbase> bqs = to_sos<fbase>(filt);
        univector<fbase> x(48000);
        for (size_t i = 0; i < x.size(); ++i)
            x[i] = std::sin(fbase(2) * c_pi<fbase> * fbase(10000) * fbase(i) / fs);
        univector<fbase> y = iir(x, bqs);
        failures += check(rms(y.slice(24000)) < fbase(1e-3), "dsp elliptic low-pass");
    }

    // audio + io: WAV round trip
    {
        audiofile_format format;
        format.container   = audiofile_container::wave;
        format.codec       = audiofile_codec::lpcm;
        format.bit_depth   = 24;
        format.channels    = 2;
        format.sample_rate = 44100;

        const size_t frames = 4096;
        audio_data_interleaved data(format.channels, frames);
        for (size_t i = 0; i < frames * format.channels; ++i)
            data.data[i] = fbase(0.5) * std::sin(fbase(0.01) * fbase(i));

        auto encoder = create_wave_encoder();
        bool written = encoder && encoder->open("kfr_test.wav", format) && encoder->write(data) &&
                       encoder->close();
        failures += check(written, "audio write wav");

        auto decoder = create_decoder_for_file("kfr_test.wav");
        bool opened  = decoder && decoder->open("kfr_test.wav");
        failures += check(opened, "audio open wav");
        if (opened)
        {
            auto read = decoder->read_all();
            bool same = read && read->size == frames && read->channels == format.channels;
            for (size_t i = 0; same && i < frames * format.channels; ++i)
                same = std::abs(read->data[i] - data.data[i]) < fbase(1e-5);
            failures += check(same, "audio read wav");
        }
    }

    return failures;
}
