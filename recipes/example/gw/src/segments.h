#pragma once

#include <cstdint>
#include <cstring>
#include <vector>
#include <deque>
#include <iostream>
#include <vector>

#include "../include/BS_thread_pool.h"
#include "../include/robin_hood.h"
#include "../include/unordered_dense.h"
#include "htslib/sam.h"

//#include "plot_manager.h"
#include "themes.h"
#include "utils.h"


namespace Segs {

    typedef ankerl::unordered_dense::map< std::string, std::vector<int>> map_t;
//    typedef robin_hood::unordered_map< const char *, std::vector<int> > map_t;
    typedef std::vector< map_t > linked_t;

    enum Pattern {
        NORMAL,
        DEL,
        INV_F,
        INV_R,
        DUP,
        TRA,
    };

    typedef int64_t hts_pos_t;

    struct InsItem {
        uint32_t pos, length;
    };

    struct QueueItem {
        uint32_t c_s_idx, l;
    };

    struct MMbase {
        uint32_t idx, pos;
        uint8_t qual, base;
    };

    struct MdBlock {
        uint32_t matches, md_idx, del_length;
        bool is_mm;
    };

    void get_md_block(char *md_tag, int md_idx, int md_l, MdBlock *res);

    void get_mismatched_bases(std::vector<MMbase> &result, char *md_tag, uint32_t r_pos, uint32_t ct_l, uint32_t *cigar_p);

    struct Align {
        bam1_t *delegate;

        int cov_start, cov_end, orient_pattern, left_soft_clip, right_soft_clip, left_hard_clip;
        float polygon_height;
        bool has_SA, has_NM, has_MD, initialized;
        int NM, y, edge_type;
        char *MD;

        uint32_t pos, reference_end, cigar_l;
        std::vector<uint32_t> block_starts, block_ends;
        std::vector<InsItem> any_ins;
        std::vector<MMbase> mismatches;
    };

    class ReadCollection {
    public:
       ReadCollection() {};
        ~ReadCollection() = default;
        int bamIdx, regionIdx;
        Utils::Region region;
        std::vector<int> covArr;
        std::vector<uint32_t> levelsStart, levelsEnd;
        std::vector<Align> readQueue;
        float xScaling, xOffset, yOffset, yPixels;
        bool processed;
    };

    void init_parallel(std::vector<Align> &aligns, int n); //const char *refSeq, int begin, int rlen);

    void addToCovArray(std::vector<int> &arr, Align &align, int begin, int end, int l_arr);

    int findY(int bamIdx, ReadCollection &rc, std::vector<Align> &rQ, int vScroll, int linkType, Themes::IniOptions &opts, Utils::Region *region, linked_t &linked, bool joinLeft);

    void dropOutOfScope(std::vector< Utils::Region > &regions, std::vector< Segs::ReadCollection >& rcs, size_t nBams);
}