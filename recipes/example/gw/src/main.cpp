//
// Created by Kez Cleal on 25/07/2022.
//
#include <algorithm>
#include <filesystem>
#include <htslib/faidx.h>
#include <iostream>
#include <random>
#include <string>

#include "argparse.h"
#include "../include/BS_thread_pool.h"
#include "glob.h"

#include "hts_funcs.h"
#include "plot_manager.h"
#include "themes.h"
#include "utils.h"



#ifdef __APPLE__
    #include <OpenGL/gl.h>
#endif
#include "GLFW/glfw3.h"
#define SK_GL
#include "include/gpu/GrBackendSurface.h"
#include "include/gpu/GrDirectContext.h"
#include "include/gpu/gl/GrGLInterface.h"
#include "include/core/SkCanvas.h"
#include "include/core/SkColorSpace.h"
#include "include/core/SkSurface.h"


// skia context has to be managed from global space to work
GrDirectContext *sContext = nullptr;
SkSurface *sSurface = nullptr;


int main(int argc, char *argv[]) {

    std::cout << "\n"
                 "█▀▀ █ █ █\n"
                 "█▄█ ▀▄▀▄▀" << std::endl;

    Themes::IniOptions iopts;
    iopts.readIni();

    static const std::vector<std::string> img_fmt = { "png", "pdf" };
    static const std::vector<std::string> img_themes = { "igv", "dark" };
    static const std::vector<std::string> links = { "none", "sv", "all" };
    static const std::vector<std::string> backend = { "raster", "gpu" };

    argparse::ArgumentParser program("gw", "0.1");
    program.add_argument("genome")
            .required()
            .help("Reference genome in .fasta format with .fai index file");
    program.add_argument("-b", "--bam")
            .default_value(std::string{""}).append()
            .help("Bam/cram alignment file. Repeat for multiple files stacked vertically");
    program.add_argument("-r", "--region")
            .append()
            .help("Region of alignment file to display in window. Repeat to horizontally split window into multiple regions");
    program.add_argument("-v", "--variants")
            .default_value(std::string{""}).append()
            .help("VCF/BCF/BED/BEDPE file to derive regions from. Can not be used with -i");
    program.add_argument("-i", "--images")
            .append()
            .help("Glob path to .png images to displaye e.g. '*.png'. Can not be used with -v");
    program.add_argument("-o", "--outdir")
            .append()
            .help("Output folder to save images");
    program.add_argument("-n", "--no-show")
            .default_value(false).implicit_value(true)
            .help("Don't display images to screen");
    program.add_argument("-d", "--dims")
            .default_value(iopts.dimensions_str).append()
            .help("Image dimensions (px)");
    program.add_argument("-u", "--number")
            .default_value(iopts.number_str).append()
            .help("Images tiles to display (used with -v and -i)");
    program.add_argument("--theme")
            .default_value(iopts.theme_str)
            .action([](const std::string& value) {
                if (std::find(img_themes.begin(), img_themes.end(), value) != img_themes.end()) { return value;}
                std::cerr << "Error: --theme not in {igv, dark}" << std::endl;
                abort();
            }).help("Image theme igv|dark");
    program.add_argument("--fmt")
            .default_value(iopts.fmt)
            .action([](const std::string& value) {
                if (std::find(img_fmt.begin(), img_fmt.end(), value) != img_fmt.end()) { return value;}
                return std::string{ "png" };
            }).help("Output file format");
    program.add_argument("--track")
            .default_value(std::string{""}).append()
            .help("Track to display at bottom of window BED/VCF. Repeat for multiple files stacked vertically");
    program.add_argument("-t", "--threads")
            .default_value(iopts.threads).append().scan<'i', int>()
            .help("Number of threads to use");
    program.add_argument("--parse-label")
            .default_value(iopts.parse_label).append()
            .help("Label to parse from vcf file (used with -v) e.g. 'filter' or 'info.SU' or 'qual'");
    program.add_argument("--labels")
            .default_value(iopts.labels).append()
            .help("Choice of labels to use. Provide as comma-separated list e.g. 'PASS,FAIL'");
    program.add_argument("--in-labels")
            .default_value(std::string{""}).append()
            .help("Input labels from tab-separated FILE (use with -v or -i)");
    program.add_argument("--out-vcf")
            .default_value(std::string{""}).append()
            .help("Output labelling results to vcf FILE (the -v option is required)");
    program.add_argument("--out-labels")
            .default_value(std::string{""}).append()
            .help("Output labelling results to tab-separated FILE (use with -v or -i)");
    program.add_argument("--start-index")
            .default_value(0).append().scan<'i', int>()
            .help("Start labelling from -v / -i index (zero-based)");
    program.add_argument("--resume")
            .default_value(false).implicit_value(true)
            .help("Resume labelling from last user-labelled variant");
    program.add_argument("--pad")
            .default_value(iopts.pad).append().scan<'i', int>()
            .help("Padding +/- in bp to add to each region from -v or -r");
    program.add_argument("--ylim")
            .default_value(iopts.ylim).append().scan<'i', int>()
            .help("Maximum y limit (depth of coverage) of image");
    program.add_argument("--no-cov")
            .default_value(false).implicit_value(true)
            .help("Scale coverage track to log2");
    program.add_argument("--log2-cov")
            .default_value(false).implicit_value(true)
            .help("Scale coverage track to log2");
    program.add_argument("--split-view-size")
            .default_value(iopts.split_view_size).append().scan<'i', int>()
            .help("Max variant size before region is split into two smaller panes (used with -v only)");
    program.add_argument("--indel-length")
            .default_value(iopts.indel_length).append().scan<'i', int>()
            .help("Indels >= this length (bp) will have text labels");
    program.add_argument("--tlen-y").default_value(false).implicit_value(true)
            .help("Y-axis will be set to template-length (tlen) bp. Relevant for paired-end reads only");
    program.add_argument("--link")
            .default_value(iopts.link)
            .action([](const std::string& value) {
                if (std::find(links.begin(), links.end(), value) != links.end()) { return value;}
                return std::string{ "None" };
            }).help("Draw linking lines between these alignments");

    // check input for errors and merge input options with IniOptions
    try {
        program.parse_args(argc, argv);
    }
    catch (const std::runtime_error& err) {
        std::cerr << err.what() << std::endl;
        std::cerr << program;
        std::exit(1);
    }

    auto genome = program.get<std::string>("genome");
    if (iopts.references.find(genome) != iopts.references.end()){
        genome = iopts.references[genome];
    } else if (!Utils::is_file_exist(genome)) {
        std::cerr << "Error: Genome not found" << std::endl;
        abort();
    }

    std::vector<std::string> bam_paths;
    if (program.is_used("-b")) {
        bam_paths = program.get<std::vector<std::string>>("-b");
    }

    std::vector<Utils::Region> regions;
    if (program.is_used("-r")) {
        std::vector<std::string> regions_str;
        regions_str = program.get<std::vector<std::string>>("-r");
        for (size_t i=0; i < regions_str.size(); i++){
            regions.push_back(Utils::parseRegion(regions_str[i]));
        }
    }

    std::vector<std::filesystem::path> image_glob;
    if (program.is_used("-i")) {
        image_glob = glob::glob(program.get<std::string>("-i"));
    }

    std::string outdir;
    if (program.is_used("-o")) {
        outdir = program.get<std::string>("-o");
        if (!std::filesystem::is_directory(outdir) || !std::filesystem::exists(outdir)) { // Check if src folder exists
            std::filesystem::create_directory(outdir); // create src folder
        }
    }

    if (program.is_used("-n")) {
        iopts.no_show = program.get<bool>("-n");
    }

    if (program.is_used("--theme") && program.get<std::string>("--theme") == "dark") {
        iopts.theme = Themes::DarkTheme();
    } else {  // defaults to igv theme
    }

    if (program.is_used("--dims")) {
        auto d = program.get<std::string>("--dims");
        iopts.dimensions = Utils::parseDimensions(d);
    }

    if (program.is_used("-u")) {
        auto d = program.get<std::string>("-u");
        iopts.number = Utils::parseDimensions(d);
    }

    std::vector<std::string> tracks;
    if (program.is_used("--track")) {
        tracks = program.get<std::vector<std::string>>("--track");
        for (auto &trk: tracks){
            if (!Utils::is_file_exist(trk)) {
                std::cerr << "Error: track file does not exists - " << trk << std::endl;
                std::abort();
            }
            iopts.tracks[genome].push_back(trk);
        }
    }

    if (program.is_used("--indel-length")) {
        iopts.indel_length = program.get<int>("--indel-length");
    }

    if (program.is_used("--link")) {
        auto lnk = program.get<std::string>("--link");
        if (lnk == "none") {
            iopts.link_op = 0;
        } else if (lnk == "sv") {
            iopts.link_op = 1;
        } else if (lnk == "all") {
            iopts.link_op = 2;
        } else {
            std::cerr << "Link type not known [none/sv/all]\n";
            std::terminate();
        }
    }

    if (program.is_used("--threads")) {
        iopts.threads = program.get<int>("--threads");
    }
    if (program.is_used("--parse-label")) {
        iopts.parse_label = program.get<std::string>("--parse-label");
    }
    if (program.is_used("--labels")) {
        iopts.labels = program.get<std::string>("--labels");
    }
    if (program.is_used("--ylim")) {
        iopts.ylim = program.get<int>("--ylim");
    }
    if (program.is_used("--log2-cov")) {
        iopts.log2_cov = true;
    }
    if (program.is_used("--no-cov")) {
        iopts.coverage = false;
    }
    if (program.is_used("--start-index")) {
        iopts.start_index = program.get<int>("--start-index");
    }


    /*
     * / Gw start
     */
    Manager::GwPlot plotter = Manager::GwPlot(genome, bam_paths, iopts, regions, tracks);

    if (!iopts.no_show) {  // plot something to screen

        // initialize display screen
        plotter.init(iopts.dimensions.x, iopts.dimensions.y);

        int fb_height, fb_width;
        glfwGetFramebufferSize(plotter.window, &fb_width, &fb_height);


        sContext = GrDirectContext::MakeGL(nullptr).release();

        GrGLFramebufferInfo framebufferInfo;
        framebufferInfo.fFBOID = 0;
        framebufferInfo.fFormat = GL_RGBA8;  // GL_SRGB8_ALPHA8; //
        GrBackendRenderTarget backendRenderTarget(fb_width, fb_height, 0, 0, framebufferInfo);
        if (!backendRenderTarget.isValid()) {
            std::cerr << "ERROR: backendRenderTarget was invalid" << std::endl;
            glfwTerminate();
            std::terminate();
        }
        sSurface = SkSurface::MakeFromBackendRenderTarget(sContext,
                                                          backendRenderTarget,
                                                          kBottomLeft_GrSurfaceOrigin,
                                                          kRGBA_8888_SkColorType,
                                                          nullptr,
                                                          nullptr).release();
        if (!sSurface) {
            std::cerr << "ERROR: sSurface could not be initialized (nullptr). The frame buffer format needs changing\n";
            sContext->releaseResourcesAndAbandonContext();
            std::terminate();
        }

        if (!program.is_used("--variants") && !program.is_used("--images")) {
            int res = plotter.startUI(sContext, sSurface);  // plot regions
            if (res < 0) {
                std::cerr << "ERROR: Plot to screen returned " << res << std::endl;
                std::terminate();
            }
        } else if (program.is_used("--variants")) {  // plot variants as tiled images

            auto v = program.get<std::string>("--variants");
            std::vector<std::string> labels = Utils::split(iopts.labels, ',');
            bool cacheStdin = v == "-" && program.is_used("--out-vcf");
            if (program.is_used("--in-labels")) {
                Utils::openLabels(program.get<std::string>("--in-labels"), plotter.inputLabels, labels);
            }

            if (program.is_used("--out-labels")) {
                plotter.setOutLabelFile(program.get<std::string>("--out-labels"));
            }

            plotter.setVariantFile(v, iopts.start_index, cacheStdin);
            plotter.setLabelChoices(labels);
            plotter.mode = Manager::Show::TILED;

            int res = plotter.startUI(sContext, sSurface);
            if (res < 0) {
                std::cerr << "ERROR: Plot to screen returned " << res << std::endl;
                std::terminate();
            }

            if (program.is_used("--out-vcf")) {
                HGW::saveVcf(plotter.vcf, program.get<std::string>("--out-vcf"), plotter.multiLabels);
            }
        }

    } else {  // save plot to file, use GPU if single image and GPU available, or use raster backend otherwise


        if (!program.is_used("--variants") && !program.is_used("--images") && !regions.empty()) {

            if (outdir.empty()) {
                std::cerr << "Error: please provide an output directory using --outdir\n";
                std::terminate();
            }

            plotter.initBack(iopts.dimensions.x, iopts.dimensions.y);

            int fb_height, fb_width;
            glfwGetFramebufferSize(plotter.backWindow, &fb_width, &fb_height);


//            sk_sp<GrDirectContext> context = GrDirectContext::MakeGL(nullptr);
//            SkImageInfo info = SkImageInfo::MakeN32Premul(fb_width, fb_height);
//            sk_sp<SkSurface> gpuSurface(SkSurface::MakeRenderTarget(context.get(), SkBudgeted::kNo, info));
//            if (!gpuSurface) {
//                std::cerr << "ERROR: gpuSurface could not be initialized (nullptr)\n";
//                std::terminate();
//            }
//            SkCanvas *canvas = gpuSurface->getCanvas();

            sContext = GrDirectContext::MakeGL(nullptr).release();
            GrGLFramebufferInfo framebufferInfo;
            framebufferInfo.fFBOID = 0;
            framebufferInfo.fFormat = GL_RGBA8;  // GL_SRGB8_ALPHA8; //
            GrBackendRenderTarget backendRenderTarget(fb_width, fb_height, 0, 0, framebufferInfo);
            if (!backendRenderTarget.isValid()) {
                std::cerr << "ERROR: backendRenderTarget was invalid" << std::endl;
                glfwTerminate();
                std::terminate();
            }
            sSurface = SkSurface::MakeFromBackendRenderTarget(sContext,
                                                              backendRenderTarget,
                                                              kBottomLeft_GrSurfaceOrigin,
                                                              kRGBA_8888_SkColorType,
                                                              nullptr,
                                                              nullptr).release();
            if (!sSurface) {
                std::cerr << "ERROR: sSurface could not be initialized (nullptr). The frame buffer format needs changing\n";
                sContext->releaseResourcesAndAbandonContext();
                std::terminate();
            }
            SkCanvas *canvas = sSurface->getCanvas();

            plotter.opts.theme.setAlphas();
            plotter.drawSurfaceGpu(canvas);

            sk_sp<SkImage> img(sSurface->makeImageSnapshot());
            if (!img) { std::cout << "!img" << std::endl; return 1; }
            sk_sp<SkData> png(img->encodeToData());
            if (!png) { std::cout << "!png" << std::endl; return 1; }
            fs::path fname = regions[0].chrom + "_" + std::to_string(regions[0].start) + "_" + std::to_string(regions[0].end) + ".png";
            fs::path out_path = outdir / fname;
            SkFILEWStream out(out_path.c_str());
            (void)out.write(png->data(), png->size());

        } else if (program.is_used("--variants") && !program.is_used("--out-vcf")) {

            if (outdir.empty()) {
                std::cerr << "Error: please provide an output directory using --outdir\n";
                std::terminate();
            }

            auto v = program.get<std::string>("--variants");


            if (Utils::endsWith(v, "vcf") || Utils::endsWith(v, "vcf.gz") || Utils::endsWith(v, "bcf")) {

                iopts.theme.setAlphas();

                auto vcf = HGW::VCFfile();
                vcf.cacheStdin = false;
                vcf.label_to_parse = iopts.parse_label.c_str();
                vcf.open(v);

                std::vector<Manager::VariantJob> jobs;
                while (!vcf.done) {
                    vcf.next();
                    Manager::VariantJob job;
                    job.chrom = vcf.chrom;
                    job.chrom2 = vcf.chrom2;
                    job.start = vcf.start;
                    job.stop = vcf.stop;
                    jobs.push_back(job);
//                    if (jobs.size() >= 500)
//                        break;
                } // shuffling might help distribute high cov regions between jobs
                std::shuffle(std::begin(jobs), std::end(jobs), std::random_device());

                BS::thread_pool pool(iopts.threads);
                iopts.threads = 1;
                fs::path dir(outdir);

                pool.parallelize_loop(0, jobs.size(),
                                      [&](const int a, const int b) {

                                          Manager::GwPlot plt = Manager::GwPlot(genome, bam_paths, iopts, regions, tracks);
                                          plt.fb_width = iopts.dimensions.x;
                                          plt.fb_height = iopts.dimensions.y;
                                          sk_sp<SkSurface> rasterSurface = SkSurface::MakeRasterN32Premul(iopts.dimensions.x, iopts.dimensions.y);
                                          SkCanvas *canvas = rasterSurface->getCanvas();

                                          for (int i = a; i < b; ++i) {
                                              Manager::VariantJob job = jobs[i];
                                              plt.setVariantSite(job.chrom, job.start, job.chrom2, job.stop);
                                              plt.runDraw(canvas);
                                              sk_sp<SkImage> img(rasterSurface->makeImageSnapshot());
                                              fs::path file (std::to_string(i) + ".png");
                                              fs::path full_path = dir / file;
                                              std::string outname = full_path.string();
                                              Manager::imageToPng(img, outname);
                                          }
                                      })
                        .wait();

            }

        } else if (program.is_used("--variants") && program.is_used("--out-vcf") && program.is_used("--in-labels")) {

            auto v = program.get<std::string>("--variants");
            std::vector<std::string> labels = Utils::split(iopts.labels, ',');
            if (program.is_used("--in-labels")) {
                Utils::openLabels(program.get<std::string>("--in-labels"), plotter.inputLabels, labels);
            }
            plotter.setVariantFile(v, iopts.start_index, false);
            plotter.setLabelChoices(labels);
            plotter.mode = Manager::Show::TILED;

            HGW::VCFfile & vcf = plotter.vcf;
            std::vector<std::string> empty_labels{};
            while (true) {
                vcf.next();
                if (vcf.done) {break; }
                if (plotter.inputLabels.contains(vcf.rid)) {
                    plotter.multiLabels.push_back(plotter.inputLabels[vcf.rid]);
                } else {
                    plotter.multiLabels.push_back(Utils::makeLabel(vcf.chrom, vcf.start, vcf.label, empty_labels, vcf.rid, vcf.vartype, "", 0));
                }
            }
            if (program.is_used("--out-vcf")) {
                HGW::saveVcf(plotter.vcf, program.get<std::string>("--out-vcf"), plotter.multiLabels);
            }
        }
    }
    std::cout << "\nGw finished\n";
    return 0;
};