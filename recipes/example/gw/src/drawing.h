//
// Created by Kez Cleal on 12/08/2022.
//

#pragma once

#include <GLFW/glfw3.h>
#include <string>
#include <utility>
#include <vector>

#define SK_GL
#include "include/gpu/GrBackendSurface.h"
#include "include/gpu/GrDirectContext.h"
#include "include/gpu/gl/GrGLInterface.h"
#include "include/core/SkCanvas.h"
#include "include/core/SkColorSpace.h"
#include "include/core/SkSurface.h"

#include "../include/BS_thread_pool.h"
#include "../include/robin_hood.h"
#include "hts_funcs.h"

#include "utils.h"
#include "segments.h"
#include "themes.h"


namespace Drawing {

    void drawCoverage(const Themes::IniOptions &opts, const std::vector<Segs::ReadCollection> &collections,
                      SkCanvas *canvas, const Themes::Fonts &fonts, float covY, float refSpace);

    void drawBams(const Themes::IniOptions &opts, const std::vector<Segs::ReadCollection> &collections, SkCanvas* canvas,
                  float yScaling, const Themes::Fonts &fonts, const Segs::linked_t &linked, int linkOp, float refSpace);

    void drawRef(const Themes::IniOptions &opts, const std::vector<Segs::ReadCollection> &collections,
                 SkCanvas *canvas, const Themes::Fonts &fonts, float refSpace, float nRegions);

    void drawBorders(const Themes::IniOptions &opts, float fb_width, float fb_height,
                     SkCanvas *canvas, size_t nbams, size_t nregions, float totalTabixY, float tabixY, size_t tracks_size);

    void drawLabel(const Themes::IniOptions &opts, SkCanvas *canvas, SkRect &rect, Utils::Label &label, Themes::Fonts &fonts);

    void drawTracks(Themes::IniOptions &opts, float fb_width, float fb_height,
                    SkCanvas *canvas, float totalTabixY, float tabixY, std::vector<HGW::GwTrack> &tracks,
                    const std::vector<Utils::Region> &regions, const Themes::Fonts &fonts);

}