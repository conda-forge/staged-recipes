//
// Created by Kez Cleal on 25/07/2022.
//
#include <algorithm>
#include <filesystem>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <iterator>
#include <cstring>
#include <ctime>
#include <sstream>
#include <string>

#include "../include/unordered_dense.h"
#include "utils.h"

#if defined(_WIN32)
    #include <windows.h>
    #include <Shlwapi.h>
    #include <io.h>

    #define access _access_s
#endif

#ifdef __APPLE__
    #include <libgen.h>
    #include <limits.h>
    #include <mach-o/dyld.h>
    #include <unistd.h>
#endif

#ifdef __linux__
#include <limits.h>
    #include <libgen.h>
    #include <unistd.h>

    #if defined(__sun)
        #define PROC_SELF_EXE "/proc/self/path/a.out"
    #else
        #define PROC_SELF_EXE "/proc/self/exe"
    #endif

#endif

namespace Utils {

#if defined(_WIN32)
    std::string getExecutablePath() {
        char rawPathName[MAX_PATH];
        GetModuleFileNameA(NULL, rawPathName, MAX_PATH);
        return std::string(rawPathName);
    }

    std::string getExecutableDir() {
        std::string executablePath = getExecutablePath();
        char* exePath = new char[executablePath.length()];
        strcpy(exePath, executablePath.c_str());
        PathRemoveFileSpecA(exePath);
        std::string directory = std::string(exePath);
        delete[] exePath;
        return directory;
    }
#endif

#ifdef __linux__

    std::string getExecutablePath() {
        char rawPathName[PATH_MAX];
        realpath(PROC_SELF_EXE, rawPathName);
        return std::string(rawPathName);
    }

    std::string getExecutableDir() {
        std::string executablePath = getExecutablePath();
        char *executablePathStr = new char[executablePath.length() + 1];
        strcpy(executablePathStr, executablePath.c_str());
        char *executableDir = dirname(executablePathStr);
        delete[] executablePathStr;
        return std::string(executableDir);
    }

#endif

#ifdef __APPLE__
    std::string getExecutablePath() {
        char rawPathName[PATH_MAX];
        char realPathName[PATH_MAX];
        uint32_t rawPathSize = (uint32_t) sizeof(rawPathName);

        if (!_NSGetExecutablePath(rawPathName, &rawPathSize)) {
            realpath(rawPathName, realPathName);
        }
        return std::string(realPathName);
    }

    std::string getExecutableDir() {
        std::string executablePath = getExecutablePath();
        char *executablePathStr = new char[executablePath.length() + 1];
        strcpy(executablePathStr, executablePath.c_str());
        char *executableDir = dirname(executablePathStr);
        delete[] executablePathStr;
        return std::string(executableDir);
    }
#endif

    bool is_file_exist(std::string FileName) {
        const std::filesystem::path p = FileName;
        return (std::filesystem::exists(p));
    }

    bool endsWith(const std::string &mainStr, const std::string &toMatch) {
        if (mainStr.size() >= toMatch.size() &&
            mainStr.compare(mainStr.size() - toMatch.size(), toMatch.size(), toMatch) == 0)
            return true;
        else
            return false;
    }

    bool startsWith(const std::string &mainStr, const std::string &toMatch) {
        if (mainStr.size() >= toMatch.size() && mainStr.compare(0, toMatch.size(), toMatch) == 0)
            return true;
        else
            return false;
    }

    template<typename Out>
    void split(const std::string &s, char delim, Out result) {
        std::istringstream iss(s);
        std::string item;
        while (std::getline(iss, item, delim)) {
            *result++ = item;
        }
    }

    std::vector<std::string> split(const std::string &s, char delim) {
        std::vector<std::string> elems;
        split(s, delim, std::back_inserter(elems));
        elems.erase(std::remove_if(elems.begin(), elems.end(),  // remove empty strings
                                   [&](std::string const &cmp) -> bool {
                                       return cmp == "";
                                   }), elems.end());
        return elems;
    }

    void strToRegion(Region *r, std::string &s, const char delim) {
        size_t start = 0;
        size_t end = s.find(delim);
        r->chrom = s.substr(start, end - start);
        start = end + 1;
        end = s.find(delim, start);
        if (end != std::string::npos) {
            r->start = std::stoi(s.substr(start, end - start));
            start = end + 1;
            end = s.find(delim, start);
            r->end = std::stoi(s.substr(start, end - start));
        } else {
            r->start = std::stoi(s.substr(start, s.size()));
            r->end = r->start + 1;
        }
    }

    Region parseRegion(std::string &s) {
        Region reg;
        std::string s2;
        if (s.find(":") != std::string::npos) {
            s.erase(std::remove(s.begin(), s.end(), ','), s.end());
            std::replace(s.begin(), s.end(), '-', ':');
            Utils::strToRegion(&reg, s, ':');
        } else if (s.find(",") != std::string::npos) {
            Utils::strToRegion(&reg, s, ',');
        } else if (s.find("\t") != std::string::npos) {
            Utils::strToRegion(&reg, s, '\t');
        } else if (s.find("_") != std::string::npos) {
            Utils::strToRegion(&reg, s, '_');
        } else if (s.find(" ") != std::string::npos) {
            Utils::strToRegion(&reg, s, ' ');
        }
        if (reg.chrom.length() == 0 || reg.start == -1 || reg.end == -1) {
            std::cerr << "Error: unable to parse region";
            std::abort();
        }
        if (reg.start > reg.end) {
            std::cerr << "Error: region end < region start";
            std::abort();
        }
        if (reg.start == reg.end) {
            reg.end += 1;
        }
        reg.markerPos = -1;
        return reg;
    }

    Dims parseDimensions(std::string &s) {
        Dims d = {0, 0};
        int start = 0;
        int end = s.find('x');
        d.x = std::stoi(s.substr(start, end - start));
        start = end + 1;
        end = s.find('x', start);
        d.y = std::stoi(s.substr(start, end - start));
        if (d.x == 0) {
            std::cerr << "Error: dimension x was 0" << std::endl;
            std::abort();
        }
        return d;
    }

    int intervalOverlap(int start1, int end1, int start2, int end2) {
        return std::max(0, std::min(end1, end2) - std::max(start1, start2));
    }

    bool isOverlapping(uint32_t start1, uint32_t end1, uint32_t start2, uint32_t end2) {
        return start1 <= end2 && start2 <= end1;
    }

    std::vector<BoundingBox>
    imageBoundingBoxes(Dims &dims, float windowWidth, float windowHeight, float padX, float padY) {
        float w = windowWidth / dims.x;
        float h = windowHeight / dims.y;
        std::vector<BoundingBox> bboxes;
        bboxes.resize(dims.x * dims.y);
        int i = 0;
        for (int x = 0; x < dims.x; ++x) {
            for (int y = 0; y < dims.y; ++y) {
                BoundingBox &b = bboxes[i];
                b.xStart = (w * (float) x) + padX;
                b.yStart = (h * (float) y) + padY;
                b.xEnd = b.xStart + w - padX;
                b.yEnd = b.yStart + h - padY;
                b.width = w - padX * 2;
                b.height = h - padY * 2;
                ++i;
            }
        }
        return bboxes;
    }

//    Label::Label(std::string &parsed, std::vector<std::string> &inputLabels, std::string &variantId, std::string &vartype) {
//        this->variantId = variantId;
//        this->vartype = vartype;
//        savedDate = "";
//        i = 0;
//        clicked = false;
//        labels.push_back(parsed);
//        for (auto &v : inputLabels) {
//            if (v != parsed) {
//                labels.push_back(v);
//            }
//        }
//    }

    Label makeLabel(std::string &chrom, int pos, std::string &parsed, std::vector<std::string> &inputLabels, std::string &variantId, std::string &vartype,
                    std::string savedDate, bool clicked) {
        Label l;
        l.chrom = chrom;
        l.pos = pos;
        l.variantId = variantId;
        l.vartype = vartype;
        l.savedDate = savedDate;
        l.i = 0;
        l.clicked = clicked;
        l.labels.push_back(parsed);
        for (auto &v : inputLabels) {
            if (v != parsed) {
                l.labels.push_back(v);
            }
        }
        return l;
    }

    void Label::next() {
        savedDate = "";
        if (i == labels.size() - 1) {
            i = 0;
        } else {
            i += 1;
        }
    }

    std::string & Label::current() {
        return labels[i];
    }

    std::string dateTime() {
        auto t = std::time(nullptr);
        auto tm = *std::localtime(&t);
        std::ostringstream oss;
        oss << std::put_time(&tm, "%d-%m-%Y_%H-%M-%S");
        auto str = oss.str();
        return str;
    }

    void saveLabels(std::vector<Utils::Label> &multiLabels, std::string path) {
        std::string str = dateTime();
        std::ofstream f;
        f.open (path);
        f << "#chrom\tpos\tvariant_ID\tlabel\tvar_type\tlabelled_date\n";
        for (auto &l : multiLabels) {
            f << l.chrom << "\t" << l.pos << "\t" << l.variantId << "\t" << l.current() << "\t" << l.vartype << "\t" << ((l.i > 0) ? str : l.savedDate) << std::endl;
        }
        f.close();
    }

    void openLabels(std::string path, ankerl::unordered_dense::map< std::string, Utils::Label> &label_dict, std::vector<std::string> &inputLabels) {
        std::ifstream f;
        std::string s;
        std::string savedDate;
        f.open(path);
        int idx = 0;
        while (std::getline(f, s)) {
            if (idx > 0) {
                std::vector<std::string> v = split(s, '\t');
                bool clicked = !v[5].empty();
                int pos = std::stoi(v[1]);
                if (v.size() == 5) {
                    savedDate = "";
                } else {
                    savedDate = v[5];
                }
                Label l = makeLabel(v[0], pos, v[3], inputLabels, v[2], v[4], savedDate, clicked);
                std::string key = v[2];
                label_dict[key] = l;
            }
            idx += 1;
        }
    }
}
