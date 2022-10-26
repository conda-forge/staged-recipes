//
// Created by Kez Cleal on 04/08/2022.
//

#pragma once

#include <string>
#include <vector>

#include "htslib/faidx.h"
#include "htslib/hfile.h"
#include "htslib/hts.h"
#include "htslib/vcf.h"
#include "htslib/sam.h"
#include "htslib/tbx.h"

#include "segments.h"
#include "themes.h"


namespace HGW {

    class VCFfile {
    public:
        VCFfile () = default;
        ~VCFfile();
        htsFile *fp;
        bcf_hdr_t *hdr;
        std::vector<bcf1_t*> lines;
        bcf1_t *v;
        std::string path;
        std::string chrom, chrom2, rid, vartype, label, tag;
        int parse;
        int info_field_type;
        const char *label_to_parse;
        long start, stop;
        bool done;
        bool cacheStdin;

        void open(std::string f);
        void next();

    };

    void collectReadsAndCoverage(Segs::ReadCollection &col, htsFile *bam, sam_hdr_t *hdr_ptr,
                                 hts_idx_t *index, Themes::IniOptions &opts, Utils::Region *region, bool coverage);

    void trimToRegion(Segs::ReadCollection &col, bool coverage);

    void appendReadsAndCoverage(Segs::ReadCollection &col, htsFile *bam, sam_hdr_t *hdr_ptr,
                                hts_idx_t *index, Themes::IniOptions &opts, bool coverage, bool left, int *vScroll, Segs::linked_t &linked, int *samMaxY);

    enum FType {
        BED_IDX,
        VCF_IDX,
        BCF_IDX,
        BED_NOI,
        GW_LABEL
    };

    class GwTrack {
    public:
        GwTrack() {};
        ~GwTrack(); // = default;

        std::string path;
        std::string chrom, chrom2, rid, vartype;
        int start, stop;
        FType kind;  // 0 bed no idx, 1 bed with idx, 2 vcf-like with idx, 3 gw label file

        htsFile *fp;
        tbx_t *idx_t;
        hts_idx_t *idx_v;
        bcf_hdr_t *hdr;

        bcf1_t *v;
        tbx_t *t;

        hts_itr_t * iter_q;

        int region_end;
        std::vector<Utils::TrackBlock>::iterator vals_end;
        std::vector<Utils::TrackBlock>::iterator iter_blk;

        ankerl::unordered_dense::map< std::string, std::vector<Utils::TrackBlock>>  allBlocks;
        Utils::TrackBlock block;
        bool done;

        void open(std::string &p);
        void fetch(const Utils::Region *rgn);
        void next();
    };

    void saveVcf(VCFfile &input_vcf, std::string path, std::vector<Utils::Label> multiLabels);
}