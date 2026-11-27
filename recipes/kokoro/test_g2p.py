# Exercise kokoro's text-to-phoneme stack without downloading model weights.
from misaki import en, espeak

from kokoro import KPipeline

# espeak-ng via espeakng-loader + phonemizer-fork
fallback = espeak.EspeakFallback(british=False)
g2p_fr = espeak.EspeakG2P(language="fr-fr")
ps, _ = g2p_fr("bonjour")
print("fr:", ps)
assert ps

# spacy + en_core_web_sm (must be installed, otherwise misaki downloads it)
g2p = en.G2P(trf=False, british=False, fallback=fallback)
# "Zyxquorbt" is not in misaki's lexicon, so it goes through the espeak fallback
ps, tokens = g2p("Hello world, Zyxquorbt has 42 apples.")
print("en:", ps)
assert ps and "❓" not in ps, ps

pipeline = KPipeline(lang_code="a", repo_id="hexgrad/Kokoro-82M", model=False)
results = list(pipeline("Kokoro is an open-weight TTS model.", voice=None))
print("pipeline:", [r.phonemes for r in results])
assert results and results[0].phonemes and results[0].audio is None
