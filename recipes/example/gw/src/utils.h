//
// Created by Kez Cleal on 25/07/2022.
//

#pragma once

#include <string>
#include <vector>
#include "../include/unordered_dense.h"


namespace Utils {

//    enum GwFileTypes {
//        VCF,
//        BED,
//        BEDPE,
//        None
//    };

    bool endsWith(const std::string &mainStr, const std::string &toMatch);

    bool startsWith(const std::string &mainStr, const std::string &toMatch);

    std::vector<std::string> split(const std::string &s, char delim);

    // https://stackoverflow.com/questions/1528298/get-path-of-executable
    std::string getExecutableDir();

    bool is_file_exist(std::string FileName);

    struct TrackBlock {
        std::string chrom, name, line;
        int start, end;
        int strand;  // 0 is none, 1 forward, 2 reverse
        std::vector<int> s;  // block starts and block ends for bed12
        std::vector<int> e;
    };

    struct Region {
        std::string chrom;
        int start, end;
        int markerPos, markerPosEnd;
        const char *refSeq;
        Region() {
            chrom = "";
            start = -1;
            end = -1;
            refSeq = nullptr;
        }
    };

    Region parseRegion(std::string &r);

    struct Dims {
        int x, y;
    };

    Dims parseDimensions(std::string &s);

    int intervalOverlap(int start1, int end1, int start2, int end2);

    bool isOverlapping(uint32_t start1, uint32_t end1, uint32_t start2, uint32_t end2);

    struct BoundingBox {
        float xStart, yStart, xEnd, yEnd, width, height;
    };

    std::vector<BoundingBox> imageBoundingBoxes(Dims &dims, float wndowWidth, float windowHeight, float padX=5, float padY=5);

    class Label {
    public:
        Label() {};
        ~Label() = default;
        std::string chrom, variantId, savedDate, vartype;
        std::vector<std::string> labels;
        int i, pos;
        bool clicked;

        void next();
        std::string& current();
    };

    std::string dateTime();

    Label makeLabel(std::string &chrom, int pos, std::string &parsed, std::vector<std::string> &inputLabels, std::string &variantId, std::string &vartype,
                    std::string savedDate, bool clicked);


    void saveLabels(std::vector<Utils::Label> &multiLabels, std::string path);

    void openLabels(std::string path, ankerl::unordered_dense::map< std::string, Utils::Label> &label_dict, std::vector<std::string> &inputLabels);

}