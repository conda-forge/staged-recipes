// Encodes a 2D uint16 image losslessly with the rev53, rev13 and rev12
// wavelet kernels through the installed ojph library, decodes it back at
// full and at reduced resolution, and checks the result.  For rev13 and
// rev12, decoding with r skipped resolutions must return exactly
// image[::2**r, ::2**r].

#include <ojph/ojph_codestream.h>
#include <ojph/ojph_file.h>
#include <ojph/ojph_mem.h>
#include <ojph/ojph_params.h>
#include <ojph/ojph_version.h>

#include <cstdint>
#include <cstdio>
#include <cstring>
#include <exception>
#include <vector>

namespace {

struct image {
  ojph::ui32 width;
  ojph::ui32 height;
  std::vector<std::uint16_t> pixels;
};

image make_image(ojph::ui32 width, ojph::ui32 height) {
  image img{width, height, std::vector<std::uint16_t>(width * height)};
  std::uint32_t state = 12345u;
  for (ojph::ui32 y = 0; y < height; ++y) {
    for (ojph::ui32 x = 0; x < width; ++x) {
      state = state * 1664525u + 1013904223u;
      std::uint32_t value = (x * 97u + y * 211u) + (state >> 22);
      if ((x / 16 + y / 16) % 3 == 0) value = (state >> 16);
      img.pixels[y * width + x] = static_cast<std::uint16_t>(value);
    }
  }
  return img;
}

std::vector<ojph::ui8> encode(const image& img, ojph::ui32 kernel,
                              ojph::ui32 decompositions) {
  ojph::codestream cs;
  ojph::param_siz siz = cs.access_siz();
  siz.set_image_extent(ojph::point(img.width, img.height));
  siz.set_num_components(1);
  siz.set_component(0, ojph::point(1, 1), 16, false);
  ojph::param_cod cod = cs.access_cod();
  cod.set_reversible(true);
  cod.set_wavelet_kern(kernel);
  cod.set_num_decomposition(decompositions);
  cod.set_color_transform(false);
  cs.set_planar(false);

  ojph::mem_outfile out;
  out.open();
  cs.write_headers(&out);
  ojph::ui32 next_component = 0;
  ojph::line_buf* line = cs.exchange(nullptr, next_component);
  for (ojph::ui32 y = 0; y < img.height; ++y) {
    const std::uint16_t* row = img.pixels.data() + y * img.width;
    for (ojph::ui32 x = 0; x < img.width; ++x) line->i32[x] = row[x];
    line = cs.exchange(line, next_component);
  }
  cs.flush();
  std::vector<ojph::ui8> bytes(out.get_data(),
                               out.get_data() + out.get_used_size());
  cs.close();
  return bytes;
}

bool decode_and_check(const image& img, const std::vector<ojph::ui8>& bytes,
                      ojph::ui32 skipped, bool check_subsampled,
                      const char* name) {
  ojph::mem_infile in;
  in.open(bytes.data(), bytes.size());
  ojph::codestream cs;
  cs.read_headers(&in);
  cs.restrict_input_resolution(skipped, skipped);
  cs.create();
  ojph::param_siz siz = cs.access_siz();
  ojph::ui32 width = siz.get_recon_width(0);
  ojph::ui32 height = siz.get_recon_height(0);
  ojph::ui32 step = 1u << skipped;
  ojph::ui32 expected_width = (img.width + step - 1) / step;
  ojph::ui32 expected_height = (img.height + step - 1) / step;
  bool ok = width == expected_width && height == expected_height;
  if (!ok) {
    std::printf("%s r=%u: decoded %ux%u, expected %ux%u\n", name, skipped,
                width, height, expected_width, expected_height);
  }
  std::size_t mismatches = 0;
  for (ojph::ui32 y = 0; y < height; ++y) {
    ojph::ui32 component = 0;
    ojph::line_buf* line = cs.pull(component);
    if (!ok || !check_subsampled) continue;
    const std::uint16_t* row = img.pixels.data() + (y * step) * img.width;
    for (ojph::ui32 x = 0; x < width; ++x) {
      if (line->i32[x] != static_cast<ojph::si32>(row[x * step])) ++mismatches;
    }
  }
  cs.close();
  if (mismatches != 0) {
    std::printf("%s r=%u: %zu mismatching samples\n", name, skipped,
                mismatches);
    ok = false;
  }
  std::printf("%s r=%u: %ux%u %s\n", name, skipped, width, height,
              ok ? "ok" : "FAILED");
  return ok;
}

}  // namespace

int main() {
  std::printf("ojph %d.%d.%d\n", OPENJPH_VERSION_MAJOR,
              OPENJPH_VERSION_MINOR, OPENJPH_VERSION_PATCH);
  struct case_t {
    const char* name;
    ojph::ui32 kernel;
    bool exact_at_reduced_resolution;
  };
  const case_t cases[] = {
      {"rev53", ojph::param_cod::OJPH_WAVELET_REV53, false},
      {"rev13", ojph::param_cod::OJPH_WAVELET_REV13, true},
      {"rev12", ojph::param_cod::OJPH_WAVELET_REV12, true},
  };
  const ojph::ui32 decompositions = 4;
  bool ok = true;
  try {
    image img = make_image(301, 203);
    for (const case_t& c : cases) {
      std::vector<ojph::ui8> bytes = encode(img, c.kernel, decompositions);
      std::printf("%s: %zu bytes\n", c.name, bytes.size());
      for (ojph::ui32 skipped = 0; skipped <= decompositions; ++skipped) {
        bool check = skipped == 0 || c.exact_at_reduced_resolution;
        ok = decode_and_check(img, bytes, skipped, check, c.name) && ok;
      }
    }
  } catch (const std::exception& e) {
    std::printf("exception: %s\n", e.what());
    return 1;
  }
  return ok ? 0 : 1;
}
