//
// Created by Kez Cleal on 23/08/2022.
//
#include <htslib/faidx.h>
#include <htslib/hfile.h>
#include <htslib/sam.h>

#include <cstdio>
#include <cstdlib>
#include <cmath>
#include <iomanip>
#include <iterator>
#include <stdlib.h>
#include <sstream>
#include <string>
#include <vector>

#ifdef __APPLE__
#include <OpenGL/gl.h>
#endif

#include "htslib/faidx.h"
#include "htslib/hfile.h"
#include "htslib/hts.h"
#include "htslib/sam.h"

#include <GLFW/glfw3.h>
#define SK_GL
#include "include/gpu/GrBackendSurface.h"
#include "include/gpu/GrDirectContext.h"
#include "include/gpu/gl/GrGLInterface.h"
#include "include/core/SkCanvas.h"
#include "include/core/SkColorSpace.h"
#include "include/core/SkSurface.h"

#include "drawing.h"
//#include "../include/glfw_keys.h"
#include "hts_funcs.h"
#include "plot_manager.h"
#include "segments.h"
#include "../include/robin_hood.h"
#include "../include/termcolor.h"
#include "themes.h"


namespace Manager {

    constexpr char basemap[] = {'.', 'A', 'C', '.', 'G', '.', '.', '.', 'T', '.', '.', '.', '.', '.', 'N', 'N', 'N'};

    // keeps track of input commands
    bool GwPlot::registerKey(GLFWwindow* wind, int key, int scancode, int action, int mods) {
        if (action == GLFW_RELEASE) {
            if ((key == GLFW_KEY_LEFT_SHIFT || key == GLFW_KEY_RIGHT_SHIFT) && !captureText) {
                shiftPress = false;
            }
            ctrlPress = false;
            return false;
        }
        if (key == GLFW_KEY_LEFT_SHIFT || key == GLFW_KEY_RIGHT_SHIFT) {
            shiftPress = true;
        } else if (shiftPress && GLFW_KEY_SEMICOLON && !captureText) {
            captureText = true;
            inputText.append(":");
            std::cout <<  "\n" << inputText << std::flush;
        } else {
            shiftPress = false;
        }
        if (captureText) {
            if (key == GLFW_KEY_ENTER) {
                captureText = false;
                processText = true;
                shiftPress = false;
                std::cout << "\n";
                return false;
            }
            if (!commandHistory.empty()) {
                if (key == GLFW_KEY_UP && commandIndex > 0) {
                    commandIndex -= 1;
                    inputText = commandHistory[commandIndex];
                    std::cout << "\r" << inputText << std::flush;
                    return true;
                } else if (key == GLFW_KEY_DOWN && commandIndex < commandHistory.size() - 1) {
                    commandIndex += 1;
                    inputText = commandHistory[commandIndex];
                    std::cout << "\r" << inputText << std::flush;
                    return true;
                }
            }

            if (key == GLFW_KEY_LEFT_CONTROL || key == GLFW_KEY_LEFT_SUPER) {
                if (action == GLFW_PRESS) {
                    ctrlPress = true;
                }
            }
            if (ctrlPress && key == GLFW_KEY_V) {
                std::string string = glfwGetClipboardString(window);
                if (!string.empty()) {
                    inputText.append(string);
                    std::cout << "\r" << inputText << std::flush;
                }
            } else {  // character entry
                if (key == GLFW_KEY_SEMICOLON && inputText.size() == 1) {
                    return true;
                } else if (key == GLFW_KEY_BACKSPACE) {
                    if (inputText.size() > 1) {
                        inputText.pop_back();
                        std::string emptyS(100, ' ');
                        std::cout << "\r" << emptyS << std::flush;
                        std::cout << "\r" << inputText << std::flush;
                    }
                }
                const char *letter = glfwGetKeyName(key, scancode);
                if (letter || key == GLFW_KEY_SPACE) {
                    if (key == GLFW_KEY_SPACE) {
                        inputText.append(" ");
                    } else if (key == GLFW_KEY_SEMICOLON && mods == GLFW_MOD_SHIFT) {
                        inputText.append(":");
                    } else {
                        if (mods == GLFW_MOD_SHIFT) { // uppercase
//                            char let = toupper(*letter);
//                            std::string str = toupper(*letter);
//                            inputText.append(str);
                        } else {
                            inputText.append(letter);
                        }

                    }
                    std::cout << "\r" << inputText << std::flush;
                }
            }
            return true;
        }
        return true;
    }

    void printKeyFromValue(int v) {
        robin_hood::unordered_map<std::string, int> key_table;
        Keys::getKeyTable(key_table);
        for (auto &p: key_table) {
            if (p.second == v) {
                std::cout << p.first;
                break;
            }
        }
    }

    void GwPlot::highlightQname() {
        for (auto &cl : collections) {
            for (auto &a: cl.readQueue) {
                if (bam_get_qname(a.delegate) == target_qname) {
                    a.edge_type = 4;
                }
            }
        }
    }

    void printCigar(std::vector<Segs::Align>::iterator r) {
        uint32_t l, cigar_l, op, k;
        uint32_t *cigar_p;
        cigar_l = r->delegate->core.n_cigar;
        cigar_p = bam_get_cigar(r->delegate);
        for (k = 0; k < cigar_l; k++) {
            op = cigar_p[k] & BAM_CIGAR_MASK;
            l = cigar_p[k] >> BAM_CIGAR_SHIFT;
            if (op == 0) {
                std::cout << l << "M";
            } else if (op == 1) {
                std::cout << termcolor::magenta << l << "I" << termcolor::reset;
            } else if (op == 2) {
                std::cout << termcolor::red << l << "D"<< termcolor::reset;
            } else if (op == 8) {
                std::cout << l << "X";
            } else if (op == 4) {
                std::cout << termcolor::bright_blue << l << "S"<< termcolor::reset;
            } else if (op == 5) {
                std::cout << termcolor::blue << l << "H" << termcolor::reset;
            }
            else {
                std::cout << termcolor::blue << l << "?" << termcolor::reset;
            }
        }
    }

    void printSeq(std::vector<Segs::Align>::iterator r, int max=5000) {
        auto l_seq = (int)r->delegate->core.l_qseq;

        if (l_seq == 0) {
            std::cout << "*";
            return;
        }
        uint32_t l, cigar_l, op, k;
        uint32_t *cigar_p;
        cigar_l = r->delegate->core.n_cigar;
        cigar_p = bam_get_cigar(r->delegate);
        uint8_t *ptr_seq = bam_get_seq(r->delegate);
        int i = 0;

        for (k = 0; k < cigar_l; k++) {
            op = cigar_p[k] & BAM_CIGAR_MASK;
            l = cigar_p[k] >> BAM_CIGAR_SHIFT;
            if (i >= max) {
                std::cout << "...";
                return;
            }
            if (op == BAM_CHARD_CLIP) {
                continue;
            } else if (op == BAM_CDEL) {
                for (int n=0; n < l; ++n) {
                    std::cout << "-";
                }

            } else if (op == BAM_CMATCH) {
                for (int n = 0; n < l; ++n) {
                    uint8_t base = bam_seqi(ptr_seq, i);
                    bool mm = false;
                    for (auto &item: r->mismatches) {
                        if (i == item.idx) {
                            std::cout << termcolor::underline;
                            switch (basemap[base]) {
                                case 65 :
                                    std::cout << termcolor::green << "A" << termcolor::reset;
                                    break;
                                case 67 :
                                    std::cout << termcolor::blue << "C" << termcolor::reset;
                                    break;
                                case 71 :
                                    std::cout << termcolor::yellow << "G" << termcolor::reset;
                                    break;
                                case 78 :
                                    std::cout << termcolor::grey << "N" << termcolor::reset;
                                    break;
                                case 84 :
                                    std::cout << termcolor::red << "T" << termcolor::reset;
                                    break;
                            }
                            mm = true;
                            break;
                        }
                    }
                    if (!mm) {
                        switch (basemap[base]) {
                            case 65 :
                                std::cout << "A";
                                break;
                            case 67 :
                                std::cout << "C";
                                break;
                            case 71 :
                                std::cout << "G";
                                break;
                            case 78 :
                                std::cout << "N";
                                break;
                            case 84 :
                                std::cout << "T";
                                break;
                        }
                    }
                    i += 1;
                }

            } else if (op == BAM_CEQUAL) {
                for (int n = 0; n < l; ++n) {
                    uint8_t base = bam_seqi(ptr_seq, i);
                    switch (basemap[base]) {
                        case 65 :
                            std::cout << "A";
                            break;
                        case 67 :
                            std::cout << "C";
                            break;
                        case 71 :
                            std::cout << "G";
                            break;
                        case 78 :
                            std::cout << "N";
                            break;
                        case 84 :
                            std::cout << "T";
                            break;
                    }
                    i += 1;
                }

            } else if (op == BAM_CDIFF) {
                for (int n = 0; n < l; ++n) {
                    uint8_t base = bam_seqi(ptr_seq, i);
                    switch (basemap[base]) {
                        case 65 :
                            std::cout << termcolor::green << "A" << termcolor::reset;
                            break;
                        case 67 :
                            std::cout << termcolor::blue << "C" << termcolor::reset;
                            break;
                        case 71 :
                            std::cout << termcolor::yellow << "G" << termcolor::reset;
                            break;
                        case 78 :
                            std::cout << termcolor::grey << "N" << termcolor::reset;
                            break;
                        case 84 :
                            std::cout << termcolor::red << "T" << termcolor::reset;
                            break;
                    }
                    i += 1;
                }

            } else {
                for (int n=0; n < l; ++n) {
                    uint8_t base = bam_seqi(ptr_seq, i);
                    switch (basemap[base]) {
                        case 65 : std::cout << termcolor::green << "A" << termcolor::reset; break;
                        case 67 : std::cout << termcolor::blue << "C" << termcolor::reset; break;
                        case 71 : std::cout << termcolor::yellow << "G" << termcolor::reset; break;
                        case 78 : std::cout << termcolor::grey << "N" << termcolor::reset; break;
                        case 84 : std::cout << termcolor::red << "T" << termcolor::reset; break;
                    }
                    i += 1;
                }
            }
        }
    }

    void read2sam(std::vector<Segs::Align>::iterator r, const sam_hdr_t* hdr, std::string &sam) {
        uint32_t l, cigar_l, op, k;
        uint32_t *cigar_p;
        cigar_l = r->delegate->core.n_cigar;
        cigar_p = bam_get_cigar(r->delegate);
        const char *rname = sam_hdr_tid2name(hdr, r->delegate->core.tid);
        std::string d = "\t";
        std::ostringstream oss;
        oss << bam_get_qname(r->delegate) << d
            << r->delegate->core.flag << d
            << rname << d
            << r->pos + 1 << d
            << (int)r->delegate->core.qual << d;
        if (cigar_l) {
            for (k = 0; k < cigar_l; k++) {
                op = cigar_p[k] & BAM_CIGAR_MASK;
                l = cigar_p[k] >> BAM_CIGAR_SHIFT;
                oss << l;
                switch (op) {
                    case 0: oss << "M"; break;
                    case 1: oss << "I"; break;
                    case 2: oss << "D"; break;
                    case 3: oss << "N"; break;
                    case 4: oss << "S"; break;
                    case 5: oss << "H"; break;
                    case 6: oss << "P"; break;
                    case 7: oss << "="; break;
                    case 8: oss << "X"; break;
                    default: oss << "B";
                }
            } oss << d;
        } else {
            oss << "*" << d;
        }
        if (r->delegate->core.mtid < 0) {
            oss << "*" << d;
        } else if (r->delegate->core.mtid == r->delegate->core.tid) {
            oss << "=" << d;
        } else {
            oss << sam_hdr_tid2name(hdr, r->delegate->core.mtid) << d;
        }
        oss << r->delegate->core.mpos + 1 << d;
        oss << r->delegate->core.isize << d;
        if (r->delegate->core.l_qseq) {
            uint8_t *ptr_seq = bam_get_seq(r->delegate);
            for (int n = 0; n < r->delegate->core.l_qseq; ++n) {
                oss << basemap[bam_seqi(ptr_seq, n)];
            }
            oss << d;
            uint8_t *ptr_qual = bam_get_qual(r->delegate);
            for (int n = 0; n < r->delegate->core.l_qseq; ++n) {
                uint8_t qual = ptr_qual[n];
                oss << (char)(qual + 33);
            }
            oss << d;
        } else {
            oss << "*" << d << "*" << d;
        }
        uint8_t *s = bam_get_aux(r->delegate);
        uint8_t *end = r->delegate->data + r->delegate->l_data;
        kstring_t str = { 0, 0, NULL };
        while (end - s >= 4) {
            kputc_('\t', &str);
            if ((s = (uint8_t *)sam_format_aux1(s, s[2], s+3, end, &str)) == NULL) {

            }
        }
        kputsn("", 0, &str); // nul terminate
        char * si = str.s;
        for (int n = 0; n < str.l; ++n) {
            oss << *si;
            si ++;
        }
        sam = oss.str();
        ks_free(&str);
    }

    void printRead(std::vector<Segs::Align>::iterator r, const sam_hdr_t* hdr, std::string &sam) {
        const char *rname = sam_hdr_tid2name(hdr, r->delegate->core.tid);
        const char *rnext = sam_hdr_tid2name(hdr, r->delegate->core.mtid);
        std::cout << std::endl << std::endl;
        std::cout << termcolor::bold << "qname    " << termcolor::reset << bam_get_qname(r->delegate) << std::endl;
        std::cout << termcolor::bold << "span     " << termcolor::reset << rname << ":" << r->pos << "-" << r->reference_end << std::endl;
        if (rnext) {
            std::cout << termcolor::bold << "mate     " << termcolor::reset << rnext << ":" << r->delegate->core.mpos << std::endl;
        }
        std::cout << termcolor::bold << "flag     " << termcolor::reset << r->delegate->core.flag << std::endl;
        std::cout << termcolor::bold << "mapq     " << termcolor::reset << (int)r->delegate->core.qual << std::endl;
        std::cout << termcolor::bold << "cigar    " << termcolor::reset; printCigar(r); std::cout << std::endl;
        std::cout << termcolor::bold << "seq      " << termcolor::reset; printSeq(r); std::cout << std::endl;

        read2sam(r, hdr, sam);
    }

    void printSelectedSam(std::string &sam) {
        std::cout << std::endl << sam << std::endl;
    }

    void help(Themes::IniOptions &opts) {
        std::cout << termcolor::italic << "\n* Enter a command by selecting the GW window (not the terminal) and type ':[COMMAND]' *\n" << termcolor::reset;
        std::cout << termcolor::underline << "\nCommand          Modifier        Description                                            \n" << termcolor::reset;
        std::cout << termcolor::green << "add              region(s)       " << termcolor::reset << "Add one or more regions e.g. ':add chr1:1-20000'\n";
        std::cout << termcolor::green << "cov              [of/off]        " << termcolor::reset << "Turn coverage on/off e.g. ':cov off'\n";
        std::cout << termcolor::green << "find, f          qname?          " << termcolor::reset << "To find other alignments from selected read use ':find'. Or\n                                 use ':find [QNAME]' to find target read'\n";
        std::cout << termcolor::green << "goto             loci index?     " << termcolor::reset << "e.g. ':goto chr1:1-20000'. Use index if multiple \n                                 regions are open e.g. ':goto 'chr1 20000' 1'\n";
        std::cout << termcolor::green << "link             [none/sv/all]   " << termcolor::reset << "Switch read-linking ':link all'\n";
        std::cout << termcolor::green << "log2-cov         [of/off]        " << termcolor::reset << "Scale coverage by log2 e.g. ':log2-cov on'\n";
        std::cout << termcolor::green << "quit, q          -               " << termcolor::reset << "Quit GW\n";
        std::cout << termcolor::green << "refresh, r       -               " << termcolor::reset << "Refresh and re-draw the window\n";
        std::cout << termcolor::green << "remove, rm       index           " << termcolor::reset << "Remove a region by index e.g. ':rm 1'\n";
        std::cout << termcolor::green << "sam                              " << termcolor::reset << "Print selected read in sam format'\n";
        std::cout << termcolor::green << "theme            [igv/dark]      " << termcolor::reset << "Switch color theme e.g. ':theme dark'\n";
        std::cout << termcolor::green << "ylim             number          " << termcolor::reset << "The maximum y-limit for the image e.g. ':ylim 100'\n";
        std::cout << termcolor::underline << "\nHot keys                   \n" << termcolor::reset;
        std::cout << "scroll left       " << termcolor::bright_yellow; printKeyFromValue(opts.scroll_left); std::cout << "\n" << termcolor::reset;
        std::cout << "scroll right      " << termcolor::bright_yellow; printKeyFromValue(opts.scroll_right); std::cout << "\n" << termcolor::reset;
        std::cout << "scroll down       " << termcolor::bright_yellow; printKeyFromValue(opts.scroll_down); std::cout << "\n" << termcolor::reset;
        std::cout << "scroll up         " << termcolor::bright_yellow; printKeyFromValue(opts.scroll_up); std::cout << "\n" << termcolor::reset;
        std::cout << "zoom in           " << termcolor::bright_yellow; printKeyFromValue(opts.zoom_in); std::cout << "\n" << termcolor::reset;
        std::cout << "zoom out          " << termcolor::bright_yellow; printKeyFromValue(opts.zoom_out); std::cout << "\n" << termcolor::reset;
        std::cout << "next region view  " << termcolor::bright_yellow; printKeyFromValue(opts.next_region_view); std::cout << "\n" << termcolor::reset;
        std::cout << "cycle link mode   " << termcolor::bright_yellow; printKeyFromValue(opts.cycle_link_mode); std::cout << "\n" << termcolor::reset;
        std::cout << "\n";
    }

    bool GwPlot::commandProcessed() {
        if (inputText.empty()) {
            return false;
        }
        bool valid = false;
        constexpr char delim = ' ';
        constexpr char delim_q = '\'';

        if (inputText == ":q" || inputText == ":quit") {
            throw CloseException();
        } else if (inputText == ":help" || inputText == ":h") {
            help(opts);
            valid = true;
        } else if (inputText == ":refresh" || inputText == ":r") {
            redraw = true; processed = false; valid = true; imageCache.clear();
        } else if (inputText == ":link" || inputText == ":link all") {
            opts.link_op = 2; valid = true;
        } else if (inputText == ":link sv") {
            opts.link_op = 1; valid = true;
        } else if (inputText == ":link none") {
            opts.link_op = 0; valid = true;
        } else if (inputText == ":sam") {
            valid = true;
            if (!selectedAlign.empty()) {
                printSelectedSam(selectedAlign);
            }
            redraw = false;
            processed = true;

        } else if (Utils::startsWith(inputText, ":f") || Utils::startsWith(inputText, ":find")) {
            std::vector<std::string> split = Utils::split(inputText, delim);
            if (!target_qname.empty() && split.size() == 1) {
            } else if (split.size() == 2) {
                target_qname = split.back();
            } else {
                std::cerr << termcolor::red << "Error:" << termcolor::reset << " please provide one qname\n";
                return true;
            }
            redraw = true;
            processed = true;
            highlightQname();
            inputText = "";
            return true;

        } else if (Utils::startsWith(inputText, ":ylim")) {
            std::vector<std::string> split = Utils::split(inputText, delim);
            opts.ylim = std::stoi(split.back());
            samMaxY = opts.ylim;
            valid = true;
        } else if (Utils::startsWith(inputText, ":remove") || Utils::startsWith(inputText, ":rm")) {
            std::vector<std::string> split = Utils::split(inputText, delim);
            int ind = std::stoi(split.back());
            inputText = "";
            valid = true;
            if (ind > regionSelection) {
                regionSelection = 0;
            }
            if (!regions.empty() && ind < regions.size()) {
                if (regions.size() == 1 && ind == 0) {
                    regions.clear();
                } else {
                    regions.erase(regions.begin() + ind);
                }
            } else {
                std::cerr << termcolor::red << "Error:" << termcolor::reset << " region index is out of range. Use 0-based indexing\n";
                return true;
            }
        } else if (Utils::startsWith(inputText, ":cov")) {
            std::vector<std::string> split = Utils::split(inputText, delim);
            if (split.back() == "on") {
                opts.coverage = true; valid = true;
            } else if (split.back() == "off") {
                opts.coverage = false; valid = true;
            } else {
                valid = false;
            }
        } else if (Utils::startsWith(inputText, ":log2-cov")) {
            std::vector<std::string> split = Utils::split(inputText, delim);
            if (split.back() == "on") {
                opts.log2_cov = true; valid = true;
            } else if (split.back() == "off") {
                opts.log2_cov = false; valid = true;
            } else {
                valid = false;
            }
        } else if (Utils::startsWith(inputText, ":theme")) {
            std::vector<std::string> split = Utils::split(inputText, delim);
            if (split.back() == "dark") {
                opts.theme = Themes::DarkTheme();  opts.theme.setAlphas(); valid = true;
            } else if (split.back() == "igv") {
                opts.theme = Themes::IgvTheme(); opts.theme.setAlphas(); valid = true;
            } else {
                valid = false;
            }
        } else if (Utils::startsWith(inputText, ":goto")) {
            std::vector<std::string> split = Utils::split(inputText, delim_q);
            if (split.size() == 1) {
                split = Utils::split(inputText, delim);
            }
            if (split.size() > 1 && split.size() < 4) {
                int index = (split.size() == 3) ? std::stoi(split.back()) : 0;
                if (index < regions.size()) {
                    regions[index] = Utils::parseRegion(split[1]);
                    valid = true;
                } else {
                    std::cerr << termcolor::red << "Error:" << termcolor::reset << " region index is out of range. Use 0-based indexing\n";
                    inputText = "";
                    return true;
                }
            }
        } else if (Utils::startsWith(inputText, ":add"))  {
            std::vector<std::string> split = Utils::split(inputText, delim_q);
            if (split.size() == 1) {
                split = Utils::split(inputText, delim);
            }
            if (split.size() > 1) {
                for (int i=1; i < split.size(); ++i) {
                    regions.push_back(Utils::parseRegion(split[1]));
                }
                valid = true;
            } else {
                std::cerr << termcolor::red << "Error:" << termcolor::reset << " expected a Region e.g. chr1:1-20000\n";
                inputText = "";
                return true;
            }
        }
        if (valid) {
            commandHistory.push_back(inputText);
            redraw = true;
            processed = false;
        } else {
            std::cerr << termcolor::red << "Error:" << termcolor::reset << " command not understood\n";
        }
        inputText = "";
        return true;
    }

    std::string removeZeros(float value) {  // https://stackoverflow.com/questions/57882748/remove-trailing-zero-in-c
        std::stringstream ss;
        ss << std::fixed << std::setprecision(2) << value;
        std::string str = ss.str();
        if(str.find('.') != std::string::npos) {
            str = str.substr(0, str.find_last_not_of('0')+1);
            if(str.find('.') == str.size()-1) {
                str = str.substr(0, str.size()-1);
            }
        }
        return str;
    }

    std::string getSize(long num) {
        int chars_needed = std::ceil(std::log10(num));
        double d;
        std::string a;
        std::string b = " bp";
        if (chars_needed > 3) {
            if (chars_needed > 6) {
                d = (double)num / 1e6;
                d = std::ceil(d * 10) / 10;
                a = removeZeros(d);
                b = " mb";
            } else {
                d = (double)num / 1e3;
                d = std::ceil(d * 10) / 10;
                a = removeZeros(d);
                b = " kb";
            }
        } else {
            a = std::to_string(num);
        }
        return a + b;

    }

    void GwPlot::printRegionInfo() {
        if (regions.empty()) {
            return;
        }
        std::cout << "\r                                                                                ";
        std::cout << termcolor::magenta << "\rShowing   " ;
        int i = 0;
        for (auto &r : regions) {
            std::cout << termcolor::cyan << r.chrom << ":" << r.start << "-" << r.end << termcolor::white << "  (" << getSize(r.end - r.start) << ")";
            if (i != regions.size() - 1) {
                std::cout << "    ";
            }
            i += 1;
        }
        std::cout << termcolor::reset << std::flush;

    }

    void GwPlot::keyPress(GLFWwindow* wind, int key, int scancode, int action, int mods) {
        if (action == GLFW_RELEASE) {
            return;
        }

        // decide if the input key is part of a command or a redraw request
        bool res = registerKey(window, key, scancode, action, mods);
        if (captureText) {
            return;
        }
        try {
            if (commandProcessed()) {
                return;
            }
        } catch (CloseException & mce) {
            glfwSetWindowShouldClose(wind, GLFW_TRUE);
        }
        if (mode == Show::SINGLE) {

            if (action == GLFW_PRESS || action == GLFW_REPEAT) {
                if (key == opts.scroll_right) {
                    int shift = (regions[regionSelection].end - regions[regionSelection].start) * opts.scroll_speed;
                    delete regions[regionSelection].refSeq;
                    Utils::Region N;
                    N.chrom = regions[regionSelection].chrom;
                    N.start = regions[regionSelection].start + shift;
                    N.end = regions[regionSelection].end + shift;
                    N.markerPos = regions[regionSelection].markerPos;
                    N.markerPosEnd = regions[regionSelection].markerPosEnd;
                    fetchRefSeq(N);
                    regions[regionSelection] = N;
                    if (opts.link_op != 0) {
                        processed = false;
                        redraw = true;
                    } else {
                        processed = true;
                        for (auto &cl : collections) {
                            if (cl.regionIdx == regionSelection) {
                                cl.region = N; //regions[regionSelection];
                                HGW::appendReadsAndCoverage(cl,  bams[cl.bamIdx], headers[cl.bamIdx], indexes[cl.bamIdx], opts, opts.coverage, false, &vScroll, linked, &samMaxY);
                            }
                        }
                        redraw = true;
                    }
                    printRegionInfo();

                } else if (key == opts.scroll_left) {
                    int shift = (regions[regionSelection].end - regions[regionSelection].start) * opts.scroll_speed;
                    shift = (regions[regionSelection].start - shift > 0) ? shift : 0;
                    delete regions[regionSelection].refSeq;
                    Utils::Region N;
                    N.chrom = regions[regionSelection].chrom;
                    N.start = regions[regionSelection].start - shift;
                    N.end = regions[regionSelection].end - shift;
                    N.markerPos = regions[regionSelection].markerPos;
                    N.markerPosEnd = regions[regionSelection].markerPosEnd;
                    fetchRefSeq(N);
                    regions[regionSelection] = N;
                    if (opts.link_op != 0) {
                        processed = false;
                        redraw = true;
                    } else {
                        processed = true;
                        for (auto &cl : collections) {
                            if (cl.regionIdx == regionSelection) {
                                cl.region = regions[regionSelection];
                                HGW::appendReadsAndCoverage(cl,  bams[cl.bamIdx], headers[cl.bamIdx], indexes[cl.bamIdx], opts, opts.coverage, true, &vScroll, linked, &samMaxY);
                            }
                        }
                        redraw = true;
                    }
                    printRegionInfo();
                } else if (key == opts.zoom_out) {
                    int shift = ((regions[regionSelection].end - regions[regionSelection].start) * opts.scroll_speed) + 10;
                    int shift_left = (regions[regionSelection].start - shift > 0) ? shift : 0;
                    delete regions[regionSelection].refSeq;
                    Utils::Region N;
                    N.chrom = regions[regionSelection].chrom;
                    N.start = regions[regionSelection].start - shift_left;
                    N.end = regions[regionSelection].end + shift;
                    N.markerPos = regions[regionSelection].markerPos;
                    N.markerPosEnd = regions[regionSelection].markerPosEnd;
                    fetchRefSeq(N);
                    regions[regionSelection] = N;
                    if (opts.link_op != 0) {
                        processed = false;
                        redraw = true;
                    } else {
                        processed = true;
                        for (auto &cl : collections) {
                            if (cl.regionIdx == regionSelection) {
                                cl.region = regions[regionSelection];
                                HGW::appendReadsAndCoverage(cl,  bams[cl.bamIdx], headers[cl.bamIdx], indexes[cl.bamIdx], opts, false, true, &vScroll, linked, &samMaxY);
                                HGW::appendReadsAndCoverage(cl,  bams[cl.bamIdx], headers[cl.bamIdx], indexes[cl.bamIdx], opts, false, false, &vScroll, linked, &samMaxY);
                                if (opts.coverage) {  // re process coverage for all reads
                                    cl.covArr.resize(cl.region.end - cl.region.start + 1);
                                    std::fill(cl.covArr.begin(), cl.covArr.end(), 0);
                                    int l_arr = (int)cl.covArr.size() - 1;
                                    for (auto &i : cl.readQueue) {
                                        Segs::addToCovArray(cl.covArr, i, cl.region.start, cl.region.end, l_arr);
                                    }
                                }
                            }
                        }
                        redraw = true;
                    }
                    printRegionInfo();
                } else if (key == opts.zoom_in) {
                    if (regions[regionSelection].end - regions[regionSelection].start > 50) {
                        int shift = (regions[regionSelection].end - regions[regionSelection].start) * opts.scroll_speed;
                        int shift_left = (regions[regionSelection].start - shift > 0) ? shift : 0;
                        delete regions[regionSelection].refSeq;
                        Utils::Region N;
                        N.chrom = regions[regionSelection].chrom;
                        N.start = regions[regionSelection].start + shift_left;
                        N.end = regions[regionSelection].end - shift;
                        N.markerPos = regions[regionSelection].markerPos;
                        N.markerPosEnd = regions[regionSelection].markerPosEnd;
                        fetchRefSeq(N);
                        regions[regionSelection] = N;
                        if (opts.link_op != 0) {
                            processed = false;
                            redraw = true;
                        } else {
                            processed = true;
                            for (auto &cl : collections) {
                                if (cl.regionIdx == regionSelection) {
                                    cl.region = regions[regionSelection];
                                    HGW::trimToRegion(cl, opts.coverage);
                                }
                            }
                            redraw = true;
                        }
                        printRegionInfo();
                    }
                } else if (key == opts.next_region_view) {
                    regionSelection += 1;
                    if (regionSelection >= regions.size()) {
                        regionSelection = 0;
                    }
                    std::cout << "\nRegion    " << regionSelection << std::endl;
                }
            }
        } else {  // show::TILED
            int bLen = opts.number.x * opts.number.y;
            if (action == GLFW_PRESS || action == GLFW_REPEAT) {
                if (key == opts.scroll_right) {
                    blockStart += bLen;
                    redraw = true;
                    std::cout << "\r                      ";
                    std::cout << termcolor::magenta << "\rIndex     " << termcolor::reset << blockStart << std::flush;

                } else if (key == opts.scroll_left) {
                    blockStart = (blockStart - bLen > 0) ? blockStart - bLen : 0;
                    redraw = true;
                    std::cout << "\r                      ";
                    std::cout << termcolor::magenta << "\rIndex     " << termcolor::reset << blockStart << std::flush;
                } else if (key == opts.zoom_out) {
                    opts.number.x += 1;
                    opts.number.y += 1;
                    redraw = true;
                } else if (key == opts.zoom_in) {
                    opts.number.x = (opts.number.x - 1 > 0) ? opts.number.x - 1 : 1;
                    opts.number.y = (opts.number.y - 1 > 0) ? opts.number.y - 1 : 1;
                    redraw = true;
                }
            }
        }
        if (key == opts.cycle_link_mode) {
            opts.link_op = (opts.link_op == 2) ? 0 : opts.link_op += 1;
            std::string lk = (opts.link_op > 0) ? ((opts.link_op == 1) ? "sv" : "all") : "none";
            std::cout << "\nLinking selection " << lk << std::endl;
            imageCache.clear();
            processed = false;
            redraw = true;
        }
        if (redraw) {
            linked.clear();
        }
    }

    void GwPlot::pathDrop(GLFWwindow* wind, int count, const char** paths) {
        bool good = false;
        for (int i=0; i < count; ++ i) {
            std::string pth = *paths;
            if (Utils::endsWith(pth, ".bam") || Utils::endsWith(pth, ".cram")) {
                good = true;
                std::cout << "Loading: " << pth << std::endl;
                bam_paths.push_back(pth);
                htsFile* f = sam_open(pth.c_str(), "r");
                hts_set_threads(f, opts.threads);
                bams.push_back(f);
                sam_hdr_t *hdr_ptr = sam_hdr_read(f);
                headers.push_back(hdr_ptr);
                hts_idx_t* idx = sam_index_load(f, pth.c_str());
                indexes.push_back(idx);
                linked.resize(bams.size());
            } else if (Utils::endsWith(pth, ".vcf.gz") || Utils::endsWith(pth, ".vcf") || Utils::endsWith(pth, ".bcf")) {
                good = true;
                std::cout << "Loading: " << pth << std::endl;
                setVariantFile(pth, opts.start_index, false);
                imageCache.clear();
                blockStart = 0;
                mode = Manager::Show::TILED;
                std::cout << termcolor::magenta << "Index     " << termcolor::reset << blockStart << std::endl;
            }
            ++paths;
        }
        if (good) {
            processed = false;
            redraw = true;
        }
    }
    int GwPlot::getCollectionIdx(float x, float y) {
        if (y <= refSpace) {
            return -1;
        }
        int idx = 0;
        for (auto &cl: collections) {
            float min_x = cl.xOffset;
            float max_x = cl.xScaling * ((float)(cl.region.end - cl.region.start)) + min_x;
            float min_y = cl.yOffset;
            float max_y = min_y + trackY;
            if (x > min_x && x < max_x && y > min_y && y < max_y) {
                return idx;
            }
            idx += 1;
        }
        return -1;
    }

    void GwPlot::mouseButton(GLFWwindow* wind, int button, int action, int mods) {
        double x, y;
        glfwGetCursorPos(window, &x, &y);

        int windowW, windowH;  // convert screen coords to frame buffer coords
        glfwGetWindowSize(wind, &windowW, &windowH);
        float xW, yW;
        if (fb_width > windowW) {
            float ratio = (float) fb_width / (float) windowW;
            xW = x * ratio;
            yW = y * ratio;
        } else {
            xW = x;
            yW = y;
        }

        if (xDrag == -1000000) {
            xDrag = 0;
            xOri = x;
        }
        xDrag = x - xOri;

        if (mode == Manager::SINGLE && button == GLFW_MOUSE_BUTTON_LEFT) {
            if (collections.empty()) {
                return;
            }

            int idx = getCollectionIdx(xW, yW);

            if (idx == -1) {
                return;
            }
            regionSelection = idx;
            Segs::ReadCollection &cl = collections[idx];
            regionSelection = cl.regionIdx;
            if (action == GLFW_PRESS) {
                clicked = cl.region;
                clickedIdx = idx;
            }
            if (std::abs(xDrag) < 2 && action == GLFW_RELEASE) {
                int pos = (int) (((xW - (float) cl.xOffset) / cl.xScaling) +
                                 (float) cl.region.start);
                int level = (int) ((yW - (float) cl.yOffset) /
                                   (trackY / (float) cl.levelsStart.size()));
                std::vector<Segs::Align>::iterator bnd;
                bnd = std::lower_bound(cl.readQueue.begin(), cl.readQueue.end(), pos,
                                       [&](const Segs::Align &lhs, const int pos) { return lhs.pos < pos; });
                while (true) {
                    if (bnd->y == level && bnd->pos <= pos && pos < bnd->reference_end) {
                        bnd->edge_type = 4;
                        target_qname = bam_get_qname(bnd->delegate);
                        printRead(bnd, headers[cl.bamIdx], selectedAlign);
                        redraw = true;
                        processed = true;
                        break;
                    }
                    if (bnd == cl.readQueue.begin()) {
                        break;
                    }
                    --bnd;
                }
                xDrag = -1000000;

            } else if (action == GLFW_RELEASE) {
                auto w = (float) ((cl.region.end - cl.region.start) * (float) regions.size());
                if (w >= 50000) {
                    int travel = (int) (w * (xDrag / windowW));
                    if (cl.region.start - travel < 0) {
                        travel = cl.region.start;
                    }
//                    regionSelection = cl.regionIdx;

                    delete regions[regionSelection].refSeq;
                    Utils::Region N;
                    N.chrom = cl.region.chrom;
                    N.start = cl.region.start - travel;
                    N.end = cl.region.end - travel;
                    N.markerPos = regions[regionSelection].markerPos;
                    N.markerPosEnd = regions[regionSelection].markerPosEnd;
                    fetchRefSeq(N);
                    bool lt_last = N.start < cl.region.start;
                    regions[regionSelection] = N;
                    if (opts.link_op != 0) {
                        processed = false;
                        redraw = true;
                    } else {
                        processed = true;
                        for (auto &cl : collections) {
                            if (cl.regionIdx == regionSelection) {
                                cl.region = regions[regionSelection];
                                HGW::appendReadsAndCoverage(cl,  bams[cl.bamIdx], headers[cl.bamIdx], indexes[cl.bamIdx], opts, opts.coverage, lt_last, &vScroll, linked, &samMaxY);
                            }
                        }
                        redraw = true;
                    }
                }
                printRegionInfo();
            }
            xOri = x;

        } else if (mode == Manager::SINGLE && button == GLFW_MOUSE_BUTTON_RIGHT && action == GLFW_RELEASE) {
             if (!multiRegions.empty() || !imageCache.empty()) {
                mode = Manager::TILED;
                xDrag = -1000000;
                redraw = true;
                processed = false;
                std::cout << termcolor::magenta << "\nIndex     " << termcolor::reset << blockStart << std::flush;
             }
        } else if (mode == Manager::TILED) {
            if (button == GLFW_MOUSE_BUTTON_RIGHT && action == GLFW_RELEASE) {
                std::vector<Utils::BoundingBox> bboxes = Utils::imageBoundingBoxes(opts.number, fb_width, fb_height);
                int i = 0;
                for (auto &b: bboxes) {
                    if (xW > b.xStart && xW < b.xEnd && yW > b.yStart && yW < b.yEnd) {
                        break;
                    }
                    ++i;
                }
                if (i == bboxes.size()) {
                    xDrag = -1000000;
                    return;
                }
                if (bams.size() > 0) {
                    if (i < multiRegions.size() && !bams.empty()) {
                        mode = Manager::SINGLE;
                        std::cout << termcolor::magenta << "\nVariant   " << termcolor::reset << multiLabels[blockStart + i].variantId << std::endl;
                        regions = multiRegions[blockStart + i];
                        redraw = true;
                        processed = false;
                        printRegionInfo();
                        fetchRefSeqs();
                    }
                }
            } else if (button == GLFW_MOUSE_BUTTON_LEFT && action == GLFW_RELEASE) {
                if (std::fabs(xDrag) > fb_width / 8) {
                    int nmb = opts.number.x * opts.number.y;
                    if (xDrag > 0) {
                        blockStart = (blockStart - nmb < 0) ? 0 : blockStart - nmb;
                        redraw = true;
                        std::cout << "\r                      ";
                        std::cout << termcolor::magenta << "\rIndex     " << termcolor::reset << blockStart << std::flush;
                    } else {
                        blockStart += nmb;
                        redraw = true;
                        std::cout << "\r                      ";
                        std::cout << termcolor::magenta << "\rIndex     " << termcolor::reset << blockStart << std::flush;
                    }
                } else if (std::fabs(xDrag) < 5) {
                    std::vector<Utils::BoundingBox> bboxes = Utils::imageBoundingBoxes(opts.number, fb_width, fb_height);
                    int i = 0;
                    for (auto &b: bboxes) {
                        if (xW > b.xStart && xW < b.xEnd && yW > b.yStart && yW < b.yEnd) {
                            break;
                        }
                        ++i;
                    }
                    if (i == bboxes.size()) {
                        xDrag = -1000000;
                        return;
                    }
                    multiLabels[blockStart + i].next();
                    multiLabels[blockStart + i].clicked = true;
                    multiLabels[blockStart + i].savedDate = Utils::dateTime();
                    redraw = true;
                }
                xDrag = -1000000;
            }
        }
    }

    void GwPlot::mousePos(GLFWwindow* wind, double xPos, double yPos) {
        if (lastX == -1) {
            lastX = xPos;
        }
        int state = glfwGetMouseButton(window, GLFW_MOUSE_BUTTON_LEFT);
        bool lt_last = xPos < lastX;
        lastX = xPos;
        if (state == GLFW_PRESS) {
            xDrag = xPos - xOri;
            if (mode == Manager::SINGLE) {
                if (collections.empty()) {
                    return;
                }
                int windowW, windowH;  // convert screen coords to frame buffer coords
                glfwGetWindowSize(wind, &windowW, &windowH);
                if (fb_width > windowW) {
                    xPos *= (float) fb_width / (float) windowW;
                    yPos *= (float) fb_height / (float) windowH;
                }
                int regionSelection = getCollectionIdx(xPos, yPos);
                if (regionSelection == -1) {
                    return;
                }

                Segs::ReadCollection &cl = collections[regionSelection];

                if (cl.region.end - cl.region.start < 50000 && clickedIdx == regionSelection) {
                    auto w = (float) ((cl.region.end - cl.region.start) * (float) regions.size());
                    int travel = (int) (w * (xDrag / windowW));
                    if (cl.region.start - travel < 0) {
                        travel = cl.region.start;
                    }
                    regionSelection = cl.regionIdx;

                    delete regions[regionSelection].refSeq;

                    Utils::Region N;
                    N.chrom = cl.region.chrom;
                    N.start = clicked.start - travel;
                    N.end = clicked.end - travel;
                    N.markerPos = regions[regionSelection].markerPos;
                    N.markerPosEnd = regions[regionSelection].markerPosEnd;
                    fetchRefSeq(N);

                    regions[regionSelection] = N;

                    if (opts.link_op != 0) {
                        processed = false;
                        redraw = true;
                    } else {
                        processed = true;
                        for (auto &cl : collections) {
                            if (cl.regionIdx == regionSelection) {
                                cl.region = regions[regionSelection];
                                HGW::appendReadsAndCoverage(cl,  bams[cl.bamIdx], headers[cl.bamIdx], indexes[cl.bamIdx], opts, opts.coverage, !lt_last, &vScroll, linked, &samMaxY);
                            }
                        }
                        redraw = true;
                    }
                }
            }
        }
    }

    void GwPlot::scrollGesture(GLFWwindow* wind, double xoffset, double yoffset) {
        if (mode == Manager::SINGLE) {
            if (yoffset < 0) {
                keyPress(wind, opts.zoom_out, 0, GLFW_PRESS, 0);
            } else {
                keyPress(wind, opts.zoom_in, 0, GLFW_PRESS, 0);
            }
        } else {
            if (yoffset < 0) {
                keyPress(wind, opts.scroll_right, 0, GLFW_PRESS, 0);
            } else {
                keyPress(wind, opts.scroll_left, 0, GLFW_PRESS, 0);
            }
        }

    }

    void GwPlot::windowResize(GLFWwindow* wind, int x, int y) {
        resizeTriggered = true;
        resizeTimer = std::chrono::high_resolution_clock::now();
    }
}