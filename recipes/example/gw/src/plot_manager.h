//
// Created by Kez Cleal on 25/07/2022.
//

#pragma once

#include <iostream>
#ifdef __APPLE__
    #include <OpenGL/gl.h>
#endif

#include "htslib/faidx.h"
#include "htslib/hfile.h"
#include "htslib/hts.h"
#include "htslib/vcf.h"
#include "htslib/sam.h"
#include "htslib/tbx.h"

#include <chrono>
#include <GLFW/glfw3.h>
#include <string>
#include <utility>
#include <vector>

#include "../include/BS_thread_pool.h"
#include "drawing.h"
#include "glfw_keys.h"
#include "hts_funcs.h"
#include "../include/robin_hood.h"
#include "utils.h"
#include "segments.h"
#include "themes.h"

#define SK_GL
#include "include/gpu/GrBackendSurface.h"
#include "include/gpu/GrDirectContext.h"
#include "include/gpu/gl/GrGLInterface.h"
#include "include/core/SkCanvas.h"
#include "include/core/SkColorSpace.h"
#include "include/core/SkSurface.h"


namespace Manager {

    class CloseException : public std::exception {};

    typedef ankerl::unordered_dense::map< std::string, std::vector<int>> map_t;
//    typedef robin_hood::unordered_flat_map< const char *, std::vector<int>> map_t;
    typedef std::vector< map_t > linked_t;

    enum Show {
        SINGLE,
        TILED
    };

    class HiddenWindow {
    public:
        HiddenWindow () = default;
        ~HiddenWindow () = default;
        GLFWwindow *window;
        void init(int width, int height);
    };

    /*
     * Deals with managing genomic data
     */
    class GwPlot {
    public:
        GwPlot(std::string reference, std::vector<std::string> &bampaths, Themes::IniOptions &opts, std::vector<Utils::Region> &regions,
               std::vector<std::string> &track_paths);
        ~GwPlot();

        int vScroll;
        int fb_width, fb_height;
        bool drawToBackWindow;

        std::string reference;

        std::vector<std::string> bam_paths;
        std::vector<htsFile* > bams;
        std::vector<sam_hdr_t* > headers;
        std::vector<hts_idx_t* > indexes;

        std::vector<HGW::GwTrack> tracks;
        std::string outLabelFile;

        std::vector<Utils::Region> regions;
        std::vector<std::vector<Utils::Region>> multiRegions;  // used for creating tiled regions

        std::vector<std::string> labelChoices;
        std::vector<Utils::Label> multiLabels;  // used for labelling tiles

        std::vector<Segs::ReadCollection> collections;

        HGW::VCFfile vcf;

//        robin_hood::unordered_flat_map< int, sk_sp<SkImage>> imageCache;
        ankerl::unordered_dense::map< int, sk_sp<SkImage>> imageCache;
        ankerl::unordered_dense::map< std::string, Utils::Label> inputLabels;

        Themes::IniOptions opts;
        Themes::Fonts fonts;

        faidx_t* fai;
        GLFWwindow* window;
        GLFWwindow* backWindow;

        Show mode;

        std::string selectedAlign;

        void init(int width, int height);

        void initBack(int width, int height);

        void setGlfwFrameBufferSize();

        void setVariantFile(const std::string &path, int startIndex, bool cacheStdin);

        void setOutLabelFile(const std::string &path);

        void setLabelChoices(std::vector<std::string> & labels);

        void saveLabels();

        void fetchRefSeq(Utils::Region &rgn);

        void fetchRefSeqs();

        void clearCollections();

        void processBam();

        void setScaling();

        void setVariantSite(std::string &chrom, long start, std::string &chrom2, long stop);

        void appendVariantSite(std::string &chrom, long start, std::string &chrom2, long stop, std::string & rid, std::string &label, std::string &vartype);

        int startUI(GrDirectContext* sContext, SkSurface *sSurface);

        void keyPress(GLFWwindow* window, int key, int scancode, int action, int mods);

        void mouseButton(GLFWwindow* wind, int button, int action, int mods);

        void mousePos(GLFWwindow* wind, double x, double y);

        void scrollGesture(GLFWwindow* wind, double xoffset, double yoffset);

        void windowResize(GLFWwindow* wind, int x, int y);

        void pathDrop(GLFWwindow* window, int count, const char** paths);

        void drawSurfaceGpu(SkCanvas *canvas);

        void runDraw(SkCanvas *canvas);

        sk_sp<SkImage> makeImage();

        void printRegionInfo();


    private:

        bool redraw;
        bool processed;
        bool calcScaling;

        bool resizeTriggered;
        std::chrono::high_resolution_clock::time_point resizeTimer;

        std::string inputText;
        std::string target_qname;

        bool captureText, shiftPress, ctrlPress, processText;
        std::vector< std::string > commandHistory;
        int commandIndex;

        float totalCovY, covY, totalTabixY, tabixY, trackY, regionWidth, bamHeight, refSpace;

        double xDrag, xOri, lastX;

        int samMaxY;

        float yScaling;

        linked_t linked;

        int blockStart, blockLen, regionSelection;

        Utils::Region clicked;
        int clickedIdx;

        void drawScreen(SkCanvas* canvas, GrDirectContext* sContext);

        void tileDrawingThread(SkCanvas* canvas, GrDirectContext* sContext, SkSurface *sSurface);

        void drawTiles(SkCanvas* canvas, GrDirectContext* sContext, SkSurface *sSurface);

        bool registerKey(GLFWwindow* window, int key, int scancode, int action, int mods);

        bool commandProcessed();

        int getCollectionIdx(float x, float y);

        void highlightQname();

    };

    void imageToPng(sk_sp<SkImage> &img, std::string &outdir);

    struct VariantJob {
        std::string chrom;
        std::string chrom2;
        long start;
        long stop;
    };

}