//
// Created by Kez Cleal on 04/08/2022.
//

#include <algorithm>
#include <chrono>
#include <string>
#include <vector>

#include "htslib/hts.h"
#include "htslib/sam.h"
#include "htslib/tbx.h"
#include "htslib/vcf.h"
#include "htslib/synced_bcf_reader.h"

#include "../include/BS_thread_pool.h"

#include "segments.h"
#include "themes.h"
#include "hts_funcs.h"


namespace HGW {

    Segs::Align make_align(bam1_t* src) {
        Segs::Align a;
        a.delegate = src;
        return a;
    }

    void collectReadsAndCoverage(Segs::ReadCollection &col, htsFile *b, sam_hdr_t *hdr_ptr,
                                 hts_idx_t *index, Themes::IniOptions &opts, Utils::Region *region, bool coverage) {
        bam1_t *src;
        hts_itr_t *iter_q;

        int tid = sam_hdr_name2tid(hdr_ptr, region->chrom.c_str());
        std::vector<Segs::Align>& readQueue = col.readQueue;
        readQueue.push_back(make_align(bam_init1()));
        iter_q = sam_itr_queryi(index, tid, region->start, region->end);
        if (iter_q == nullptr) {
            std::cerr << "\nError: Null iterator when trying to fetch from HTS file in collectReadsAndCoverage " << region->chrom << " " << region->start << " " << region->end << std::endl;
            std::terminate();
        }
        while (sam_itr_next(b, iter_q, readQueue.back().delegate) >= 0) {
            src = readQueue.back().delegate;
            if (src->core.flag & 4 || src->core.n_cigar == 0) {
                continue;
            }
            readQueue.push_back(make_align(bam_init1()));
        }
        src = readQueue.back().delegate;
        if (src->core.flag & 4 || src->core.n_cigar == 0) {
            bam_destroy1(src);
            readQueue.pop_back();
        }
        Segs::init_parallel(readQueue, opts.threads);
        if (coverage) {
            int l_arr = (int)col.covArr.size() - 1;
            for (auto &i : readQueue) {
                Segs::addToCovArray(col.covArr, i, region->start, region->end, l_arr);
            }
        }
        col.processed = true;
    }

    void trimToRegion(Segs::ReadCollection &col, bool coverage) {
        std::vector<Segs::Align>& readQueue = col.readQueue;
        Utils::Region *region = &col.region;
        while (!readQueue.empty()) {
            Segs::Align &item = readQueue.back();
            if (item.cov_start > region->end + 1000) {
                if (item.y != -1) {
                    col.levelsEnd[item.y] = item.cov_start - 1;
                }
                readQueue.pop_back();
            } else {
                break;
            }
        }
        int idx = 0;
        for (auto &item : readQueue) {  // drop out of scope reads
            if (item.cov_end < region->start - 1000) {
                if (item.y != -1) {
                    col.levelsStart[item.y] = item.cov_end + 1;
                }
                bam_destroy1(item.delegate);
                idx += 1;
            } else {
                break;
            }
        }
        if (idx > 0) {
            readQueue.erase(readQueue.begin(), readQueue.begin() + idx);
        }
        if (coverage) {  // re process coverage for all reads
            col.covArr.resize(col.region.end - col.region.start + 1);
            std::fill(col.covArr.begin(), col.covArr.end(), 0);
            int l_arr = (int)col.covArr.size() - 1;
            for (auto &i : col.readQueue) {
                Segs::addToCovArray(col.covArr, i, col.region.start, col.region.end, l_arr);
            }
        }
    }

    void appendReadsAndCoverage(Segs::ReadCollection &col, htsFile *b, sam_hdr_t *hdr_ptr,
                                 hts_idx_t *index, Themes::IniOptions &opts, bool coverage, bool left, int *vScroll, Segs::linked_t &linked, int *samMaxY) {

        bam1_t *src;
        hts_itr_t *iter_q;
        std::vector<Segs::Align>& readQueue = col.readQueue;
        Utils::Region *region = &col.region;
        int tid = sam_hdr_name2tid(hdr_ptr, region->chrom.c_str());
        int lastPos;
        if (!readQueue.empty()) {
            if (left) {
                lastPos = readQueue.front().pos; // + 1;
            } else {
                lastPos = readQueue.back().pos; // + 1;
            }
        } else {
            if (left) {
                lastPos = 1215752190;
            } else {
                lastPos = 0;
            }
        }

        std::vector<Segs::Align> newReads;
        if (left && (readQueue.empty() || readQueue.front().cov_end > region->start)) {
            while (!readQueue.empty()) {  // remove items from RHS of queue, reduce levelsEnd
                Segs::Align &item = readQueue.back();
                if (item.cov_start > region->end) {
                    if (item.y != -1) {
                        col.levelsEnd[item.y] = item.cov_start - 1;
                        if (col.levelsStart[item.y] == col.levelsEnd[item.y]) {
                            col.levelsStart[item.y] = 1215752191;
                            col.levelsEnd[item.y] = 0;
                        }
                    }
                    bam_destroy1(readQueue.back().delegate);
                    readQueue.pop_back();
                } else {
                    break;
                }
            }
            int end_r;
            if (readQueue.empty()) {
                std::fill(col.levelsStart.begin(), col.levelsStart.end(), 1215752191);
                std::fill(col.levelsEnd.begin(), col.levelsEnd.end(), 0);
                end_r = region->end;
            } else {
//                end_r = region->end; //readQueue.front().reference_end; //pos;
                end_r = readQueue.front().reference_end;
                if (end_r < region->start) {
                    return; // reads are already in the queue
                }
            }

//            std::cout << std::endl;
//            for (auto &itm : col.levelsEnd) {
//                std::cout << itm << ", ";
//            }; std::cout << std::endl;

            // not sure why this is needed. Without the left pad, some alignments are not collected for small regions??
            long begin = (region->start - 1000) > 0 ? region->start - 1000 : 0;
            iter_q = sam_itr_queryi(index, tid, begin, end_r);
            if (iter_q == nullptr) {
                std::cerr << "\nError: Null iterator when trying to fetch from HTS file in appendReadsAndCoverage (left) " << region->chrom << " " << region->start<< " " << end_r << " " << region->end << std::endl;
                std::terminate();
            }
            newReads.push_back(make_align(bam_init1()));

            while (sam_itr_next(b, iter_q, newReads.back().delegate) >= 0) {
                src = newReads.back().delegate;
                if (src->core.flag & 4 || src->core.n_cigar == 0) {
                    continue;
                }
                if (src->core.pos >= lastPos) {
                    break;
                }
                newReads.push_back(make_align(bam_init1()));
            }
            src = newReads.back().delegate;
            if (src->core.flag & 4 || src->core.n_cigar == 0 || src->core.pos >= lastPos) {
                bam_destroy1(src);
                newReads.pop_back();
            }

        } else if (!left && lastPos < region->end) {
            int idx = 0;
            for (auto &item : readQueue) {  // drop out of scope reads
                if (item.cov_end < region->start - 1000) {
                    if (item.y != -1) {
                        col.levelsStart[item.y] = item.cov_end + 1;
                        if (col.levelsStart[item.y] == col.levelsEnd[item.y]) {
                            col.levelsStart[item.y] = 1215752191;
                            col.levelsEnd[item.y] = 0;
                        }
                    }
                    bam_destroy1(item.delegate);
                    idx += 1;
                } else {
                    break;
                }
            }
            if (idx > 0) {
                readQueue.erase(readQueue.begin(), readQueue.begin() + idx);
            }
            if (readQueue.empty()) {
                std::fill(col.levelsStart.begin(), col.levelsStart.end(), 1215752191);
                std::fill(col.levelsEnd.begin(), col.levelsEnd.end(), 0);
            }
            iter_q = sam_itr_queryi(index, tid, lastPos, region->end);
            if (iter_q == nullptr) {
                std::cerr << "\nError: Null iterator when trying to fetch from HTS file in appendReadsAndCoverage (!left) " << region->chrom << " " << lastPos << " " << region->end << std::endl;
                std::terminate();
            }
            newReads.push_back(make_align(bam_init1()));

            while (sam_itr_next(b, iter_q, newReads.back().delegate) >= 0) {
                src = newReads.back().delegate;
                if (src->core.flag & 4 || src->core.n_cigar == 0 || src->core.pos <= lastPos) {
                    continue;
                }
                if (src->core.pos > region->end) {
                    break;
                }
                newReads.push_back(make_align(bam_init1()));
            }
            src = newReads.back().delegate;
            if (src->core.flag & 4 || src->core.n_cigar == 0 || src->core.pos <= lastPos || src->core.pos > region->end) {
                bam_destroy1(src);
                newReads.pop_back();
            }
        }

        if (!newReads.empty()) {
            Segs::init_parallel(newReads, opts.threads);
            int maxY = Segs::findY(col.bamIdx, col, newReads, *vScroll, opts.link_op, opts, region, linked, left);
            if (maxY > *samMaxY) {
                *samMaxY = maxY;
            }
            if (!left) {
                std::move(newReads.begin(), newReads.end(), std::back_inserter(readQueue));
            } else {
                std::move(readQueue.begin(), readQueue.end(), std::back_inserter(newReads));
                col.readQueue = newReads;
            }
        }
        if (coverage) {  // re process coverage for all reads
            col.covArr.resize(region->end - region->start + 1);
            std::fill(col.covArr.begin(), col.covArr.end(), 0);
            int l_arr = (int)col.covArr.size() - 1;
            for (auto &i : readQueue) {
                Segs::addToCovArray(col.covArr, i, region->start, region->end, l_arr);
            }
        }
        col.processed = true;
    }

    VCFfile::~VCFfile() {
        if (fp && !path.empty()) {
            vcf_close(fp);
            bcf_destroy(v);
        }
        if (!lines.empty()) {
            for (auto &v: lines) {
                bcf_destroy1(v);
            }
        }
    }

    void VCFfile::open(std::string f) {
        done = false;
        path = f;
        fp = bcf_open(f.c_str(), "r");
        hdr = bcf_hdr_read(fp);
        v = bcf_init1();

        std::string l2p(label_to_parse);
        v->max_unpack = BCF_UN_INFO;

        if (l2p.empty()) {
            parse = -1;
        } else if (l2p.rfind("info.", 0) == 0) {
            parse = 7;
            info_field_type = -1;
            tag = l2p.substr(5, l2p.size() - 5);
            bcf_idpair_t *id = hdr->id[0];
            for (int i=0; i< hdr->n[0]; ++i) {
                std::string key = id->key;
                if (key == tag) {
                    // this gives the info field type?! ouff
                    info_field_type = id->val->info[BCF_HL_INFO] >>4 & 0xf;
                    break;
                }
                ++id;
            }
            if (info_field_type == -1) {
                std::cerr << "Error: could not find --parse-label in info" << std::endl;
                std::terminate();
            }
        } else if (l2p.find("filter") != std::string::npos) {
            parse = 6;
        } else if (l2p.find("qual") != std::string::npos) {
            parse = 5;
        } else if (l2p.find("id") != std::string::npos) {
            parse = 2;
        } else {
            std::cerr << "Error: --label-to-parse was not understood, accepted fields are 'id / qual / filter / info.$NAME'";
            std::terminate();
        }
    }

    void VCFfile::next() {
        int res = bcf_read(fp, hdr, v);

        if (cacheStdin) {
            lines.push_back(bcf_dup(v));
        }

        if (res < -1) {
            std::cerr << "Error: reading vcf resulted in error code " << res << std::endl;
            std::terminate();
        } else if (res == -1) {
            done = true;
        }
        bcf_unpack(v, BCF_UN_INFO);

        start = v->pos;
        stop = start + v->rlen;
        chrom = bcf_hdr_id2name(hdr, v->rid);
        rid = v->d.id;

        int variant_type = bcf_get_variant_types(v);
        char *strmem = nullptr;
        int *intmem = nullptr;
        int mem = 0;
        int imem = 0; //sizeof(int);
        bcf_info_t *info_field;

        switch (variant_type) {
            case VCF_SNP: vartype = "SNP"; break;
            case VCF_INDEL: vartype = "INDEL"; break;
            case VCF_OVERLAP: vartype = "OVERLAP"; break;
            case VCF_BND: vartype = "BND"; break;
            case VCF_REF: vartype = "REF"; break;
            case VCF_OTHER: vartype = "OTHER"; break;
            case VCF_MNP: vartype = "MNP"; break;
            default: vartype = "NA"; break;
        }

        if (variant_type == VCF_SNP || variant_type == VCF_INDEL || variant_type == VCF_OVERLAP) {
            chrom2 = chrom;
        } else {  // variant type is VCF_REF or VCF_OTHER or VCF_BND
            if (variant_type == VCF_BND) {
                chrom2 = chrom;  // todo deal with BND types here
            } else {
                info_field = bcf_get_info(hdr, v, "CHR2");  // try and find chrom2 in info
                if (info_field != nullptr) {
                    int resc = bcf_get_info_string(hdr,v,"CHR2",&strmem,&mem);
                    if (resc < 0) {
                        std::cerr << "Error: could not parse CHR2 field, error was " << resc << std::endl;
                        std::terminate();
                    }
                    chrom2 = strmem;
                } else {
                    chrom2 = chrom;  // todo deal should this raise an error?
                }
                info_field = bcf_get_info(hdr, v, "CHR2_POS");  // try and find chrom2 in info
                if (info_field != nullptr) {
                    int resc = bcf_get_info_int32(hdr, v, "CHR2_POS", &intmem, &imem);
                    if (resc < 0) {
                        std::cerr << "Error: could not parse CHR2 field, error was " << resc << std::endl;
                        std::terminate();
                    }
                    stop = *intmem;
                }
            }
        }

        info_field = bcf_get_info(hdr, v, "SVTYPE");  // try and find chrom2 in info
        if (info_field != nullptr) {
            char *svtmem = nullptr;
            mem = 0;
            int resc = bcf_get_info_string(hdr, v, "SVTYPE", &svtmem,&mem);
            if (resc < 0) {
            } else {
                vartype = svtmem;
            }
        }

        label = "";
        char *strmem2 = nullptr;
        int resw = -1;
        int mem2 = 0;
        int32_t *ires = nullptr;
        float *fres = nullptr;
//        std::string parsedVal;
        switch (parse) {
            case -1:
                label = ""; break;
            case 2:
                label = rid; break;
            case 5:
                label = std::to_string(v->qual); break;
            case 6:  // parse filter field
                if (v->d.n_flt == 0) {
                    label = "PASS";
                } else {
                    label = hdr->id[BCF_DT_ID][*v->d.flt].key;  // does this work for multiple filters?
//                    std::cout << "Filter key and value " << *v->d.flt << " " << hdr->id[BCF_DT_ID][*v->d.flt].key << std::endl;
                }
                break;
            case 7:
                switch (info_field_type) {
                    case BCF_HT_INT:
                        resw = bcf_get_info_int32(hdr,v,tag.c_str(),&ires,&mem2);
                        label = std::to_string(*ires);
                        break;
                    case BCF_HT_REAL:
                        resw = bcf_get_info_float(hdr,v,tag.c_str(),&fres,&mem2);
                        label = std::to_string(*fres);
                        break;
                    case BCF_HT_STR:
                        resw = bcf_get_info_string(hdr,v,tag.c_str(),&strmem2,&mem2);
                        label = strmem2;
                        break;
                    case BCF_HT_FLAG:
                        resw = bcf_get_info_flag(hdr,v,tag.c_str(),0,0);
                        break;
                    default:
                        resw = bcf_get_info_string(hdr,v,tag.c_str(),&strmem2,&mem2);
                        label = strmem2;
                        break;
                }
                if (resw == -1) {
                    std::cerr << "Error: could not parse tag " << tag << " from info field" << std::endl;
                    std::terminate();
                }
                break;
        }
    }

    GwTrack::~GwTrack() {
        // these cause segfaults?
//        if (fp != nullptr) {
//            hts_close(fp);
//        }
//        if (idx_v != nullptr) {
//            hts_idx_destroy(idx_v);
//        }
//        if (hdr != nullptr) {
//            bcf_hdr_destroy(hdr);
//        }
//        if (v != nullptr) {
//            bcf_destroy1(v);
//        }
//        if (t != nullptr) {
//            tbx_destroy(t);
//        }
    }

    void GwTrack::open(std::string &p) {
        path = p;
        if (Utils::endsWith(p, ".bed")) {
            kind = BED_NOI;
        } else if (Utils::endsWith(p, ".bed.gz")) {
            kind = BED_IDX;
        } else if (Utils::endsWith(p, ".vcf.gz") || Utils::endsWith(p, ".vcf")) {
            std::cerr << "Error: only indexed .bcf.gz variant files are supported as tracks, not vcf's" << std::endl;
            std::terminate();
        } else if (Utils::endsWith(p, ".bcf")) {
            kind = BCF_IDX;
        } else {
            kind = GW_LABEL;
        }
        if (kind == BED_NOI || kind == GW_LABEL) {
            std::fstream fpu;
            fpu.open(p, std::ios::in);
            if (!fpu.is_open()) {
                std::cerr << "Error: opening track file " << path << std::endl;
                std::terminate();
            }
            std::string tp;
            const char delim = '\t';
            int lastb = -1;
            bool sorted = true;
            while(getline(fpu, tp)) {
                if (tp[0] == '#') {
                    continue;
                }
                std::vector<std::string> parts = Utils::split(tp, delim);
                if (parts.size() < 3) {
                    std::cerr << "Error: parsing file, not enough columns in line split by tab " << parts.size() << std::endl;
                }
                Utils::TrackBlock b;
                b.line = tp;
                b.chrom = parts[0];
                if (!allBlocks.contains(b.chrom)) {
                    lastb = -1;
                }
                b.start = std::stoi(parts[1]);
                b.strand = 0;
                if (kind == BED_NOI) {  // bed
                    b.end = std::stoi(parts[2]);
                    if (parts.size() > 3) {
                        b.name = parts[3];
                        if (parts.size() >= 6) {
                            if (parts[5] == "+") {
                                b.strand = 1;
                            } else if (parts[5] == "-") {
                                b.strand = 2;
                            }
                        }
                    }
                } else { // assume gw_label file
                    b.end = b.start + 1;
                }
                allBlocks[b.chrom].push_back(b);
                if (b.start > lastb) {
                    sorted = false;
                }
                lastb = b.start;
            }
            if (!sorted) {
                std::cout << "Unsorted file: sorting blocks from " << path << std::endl;
                for (auto &item : allBlocks) {
                    std::sort(item.second.begin(), item.second.end(),
                              [](const Utils::TrackBlock &a, const Utils::TrackBlock &b)-> bool { return a.start < b.start || (a.start == b.start && a.end > b.end);});
                }
            }
        } else if (kind == BED_IDX) {
            fp = hts_open(p.c_str(), "r");
            idx_t = tbx_index_load(p.c_str());
        } else if (kind == BCF_IDX) {
            fp = bcf_open(p.c_str(), "r");
            hdr = bcf_hdr_read(fp);
            idx_v = bcf_index_load(p.c_str());
            v = bcf_init1();
        }
    }

    void GwTrack::fetch(const Utils::Region *rgn) {
        if (kind > 2) {  // non-indexed
            if (allBlocks.contains(rgn->chrom)) {
                std::vector<Utils::TrackBlock> vals = allBlocks[rgn->chrom];
                vals_end = vals.end();
                iter_blk = std::lower_bound(vals.begin(), vals.end(), rgn->start,
                                            [](Utils::TrackBlock &a, int x)-> bool { return a.start < x;});
                region_end = rgn->end;
                done = false;
            } else {
                done = true;
            }
        } else {
            if (kind == BED_IDX) {
                int tid = tbx_name2id(idx_t, rgn->chrom.c_str());
                iter_q = tbx_itr_queryi(idx_t, tid, rgn->start, rgn->end);
                if (iter_q == nullptr) {
                    std::cerr << "\nError: Null iterator when trying to fetch from indexed bed file in fetch " << rgn->chrom
                              << " " << rgn->start << " " << rgn->end << std::endl;
                    std::terminate();
                }
                done = false;
            } else if (kind == BCF_IDX) {
                int tid = bcf_hdr_name2id(hdr, rgn->chrom.c_str());
                iter_q = bcf_itr_queryi(idx_v, tid, rgn->start, rgn->end);
                if (iter_q == nullptr) {
                    std::cerr << "\nError: Null iterator when trying to fetch from vcf file in fetch " << rgn->chrom << " " << rgn->start << " " << rgn->end << std::endl;
                    std::terminate();
                }
                done = false;
            }
        }
    }

    void GwTrack::next() {

        int res;
        if (kind == BCF_IDX) {
            res = bcf_itr_next(fp, iter_q, v);
            if (res < 0) {
                if (res < -1) {
                    std::cerr << "Error: iterating bcf file returned " << res << std::endl;
                }
                done = true;
                return;
            }
            bcf_unpack(v, BCF_UN_INFO);
            start = v->pos;
            stop = start + v->rlen;
            chrom = bcf_hdr_id2name(hdr, v->rid);
            rid = v->d.id;
            int variant_type = bcf_get_variant_types(v);
            switch (variant_type) {
                case VCF_SNP: vartype = "SNP"; break;
                case VCF_INDEL: vartype = "INDEL"; break;
                case VCF_OVERLAP: vartype = "OVERLAP"; break;
                case VCF_BND: vartype = "BND"; break;
                case VCF_OTHER: vartype = "OTHER"; break;
                case VCF_MNP: vartype = "MNP"; break;
                default: vartype = "REF";
            }
        } else if (kind == BED_IDX) {
            kstring_t str = {0,0,0};
            res = tbx_itr_next(fp, idx_t, iter_q, &str);
            if (res < 0) {
                if (res < -1) {
                    std::cerr << "Error: iterating bcf file returned " << res << std::endl;
                }
                done = true;
                return;
            }
            std::vector<std::string> parts = Utils::split(str.s, '\t');
            chrom = parts[0];
            start = std::stoi(parts[1]);
            stop = std::stoi(parts[2]);
            if (parts.size() > 2) {
                rid = parts[3];
            } else {
                rid = "";
            }
            vartype = "";

        } else if (kind > 2) {
            if (iter_blk != vals_end) {
                if (iter_blk->start < region_end) {
                    chrom = iter_blk->chrom;
                    start = iter_blk->start;
                    stop = iter_blk->end;
                    rid = iter_blk->name;
                    ++iter_blk;
                } else {
                    done = true;
                }
            } else {
                done = true;
            }
        }
    }

    void saveVcf(VCFfile &input_vcf, std::string path, std::vector<Utils::Label> multiLabels) {

        std::cout << "\nSaving output vcf\n";
        if (multiLabels.empty()) {
            std::cerr << "Error: no labels detected\n";
            return;
        }

        ankerl::unordered_dense::map< std::string, Utils::Label> label_dict;
        for (auto &l : multiLabels) {
            label_dict[l.variantId] = l;
        }

        int res;

        bcf_hdr_t *new_hdr = bcf_hdr_init("w");

        new_hdr = bcf_hdr_merge(new_hdr, input_vcf.hdr);
        if (bcf_hdr_sync(new_hdr) < 0) {
            std::cerr << "bcf_hdr_sync(hdr2) after merge\n";
            std::terminate();
        }

        const char *lg = "##source=GW>";
        res = bcf_hdr_append(new_hdr, lg);
        for (auto &l: multiLabels[0].labels) {
            if (l != "PASS") {
                std::string str = "##FILTER=<ID=" + l + ",Description=\"GW custom label\">";
                res = bcf_hdr_append(new_hdr, str.c_str());
                if (res < 0) {
                    std::cerr << "bcf_hdr_append(new_hdr) failed\n";
                    std::terminate();
                }
            }
        }

        const char *l0 = "##INFO=<ID=GW_DATE,Number=1,Type=String,Description=\"Date of GW label\">";
        const char *l1 = "##INFO=<ID=GW_PREV,Number=1,Type=String,Description=\"Previous GW label\">";

        res = bcf_hdr_append(new_hdr, l0);
        res = bcf_hdr_append(new_hdr, l1);

        htsFile *fp_out = bcf_open(path.c_str(), "w");
        res = bcf_hdr_write(fp_out, new_hdr);
        if (res < 0) {
            std::cerr << "Error: Unable to write new header\n";
            std::terminate();
        }
        if (!input_vcf.lines.empty()) {
            // todo loop over cached lines here
        } else {
            // reset to start of file
            input_vcf.open(input_vcf.path);
        }
        while (true) {
            input_vcf.next();
            if (input_vcf.done) {
                break;
            }
            if (label_dict.contains(input_vcf.rid)) {
                Utils::Label &l =  label_dict[input_vcf.rid];
                const char *prev_label = new_hdr->id[BCF_DT_ID][*input_vcf.v->d.flt].key;
                int filter_id = bcf_hdr_id2int(new_hdr, BCF_DT_ID, l.current().c_str());
                res = bcf_update_filter(new_hdr, input_vcf.v, &filter_id, 1);
                if (res < 0) {
                    std::cerr << "Error: Failed to update filter, id " << input_vcf.v->rid << std::endl;
                }
                if (!l.savedDate.empty()) {
                    res = bcf_update_info_string(new_hdr, input_vcf.v, "GW_PREV", prev_label);
                    if (res < 0) {
                        std::cerr << "Error: Updating GW_PREV failed, id " << input_vcf.v->rid << std::endl;
                    }

                    res = bcf_update_info_string(new_hdr, input_vcf.v, "GW_DATE", l.savedDate.c_str());
                    if (res < 0) {
                        std::cerr << "Error: Updating GW_DATE failed, id " << input_vcf.v->rid << std::endl;
                    }
                }
                res = bcf_write(fp_out, new_hdr, input_vcf.v);
                if (res < 0) {
                    std::cerr << "Error: Writing new vcf record failed, id " << input_vcf.v->rid << std::endl;
                }

            } else {
                res = bcf_write(fp_out, new_hdr, input_vcf.v);
                if (res < 0) {
                    std::cerr << "Error: Writing new vcf record failed, id " << input_vcf.v->rid << std::endl;
                    break;
                }
            }
        }
        bcf_hdr_destroy(new_hdr);
        bcf_close(fp_out);
    }
}