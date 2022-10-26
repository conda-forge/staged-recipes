
#include <chrono>
#include <algorithm>
#include <vector>

//#include "plot_manager.h"
#include "segments.h"
#include "utils.h"


namespace Segs {

    void get_md_block(char *md_tag, int md_idx, int md_l, MdBlock *res) {
        int nmatches = 0;
        int del_length = 0;
        bool is_mm = false;
        while (md_idx < md_l) {
            if (48 <= md_tag[md_idx] && md_tag[md_idx] <= 57) {  // c is numerical
                nmatches = nmatches * 10 + md_tag[md_idx] - 48;
                md_idx += 1;
            } else {
                if (md_tag[md_idx] == 94) {  // del_sign is 94 from ord('^')
                    md_idx += 1;
                    while (65 <= md_tag[md_idx] && md_tag[md_idx] <= 90) {
                        md_idx += 1;
                        del_length += 1;
                    }
                } else {  // save mismatch
                    is_mm = true;
                    md_idx += 1;
                }
                break;
            }
        }
        res->matches = nmatches;
        res->md_idx = md_idx;
        res->is_mm = is_mm;
        res->del_length = del_length;
    }

    void get_mismatched_bases(std::vector<MMbase> &result,
                              char *md_tag, uint32_t r_pos,
                              uint32_t ct_l, uint32_t *cigar_p) {

        uint32_t opp, l, c_idx, s_idx, c_s_idx;
        size_t md_l = strlen(md_tag);
        std::deque<QueueItem> ins_q;
        MdBlock md_block;
        get_md_block(md_tag, 0, md_l, &md_block);
        if (md_block.md_idx == md_l) {
            return;
        }

        c_idx = 0;  // the cigar index
        s_idx = 0;  // sequence index of mismatches
        c_s_idx = 0;  // the index of the current cigar (c_idx) on the input sequence

        opp = cigar_p[0] & BAM_CIGAR_MASK;
        if (opp == 4) {
            c_idx += 1;
            s_idx += cigar_p[0] >> BAM_CIGAR_SHIFT;
            c_s_idx = s_idx;
        } else if (opp == 5) {
            c_idx += 1;
        }

        while (true) {
            if (c_idx < ct_l) {  // consume cigar until deletion reached, collect positions of insertions
                while (c_idx < ct_l) {
                    opp = cigar_p[c_idx] & BAM_CIGAR_MASK;
                    l = cigar_p[c_idx] >> BAM_CIGAR_SHIFT;
                    if (opp == 0 || opp == 8) {  // match
                        c_s_idx += l;
                    } else if (opp == 1) {  // insertion
                        ins_q.push_back({c_s_idx, l});
                        c_s_idx += l;
                    } else {  // opp == 2 or opp == 4 or opp == 5
                        break;
                    }
                    ++c_idx;
                }
                c_idx += 1;
            }

            while (true) {   // consume md tag until deletion reached
                if (!md_block.is_mm) {  // deletion or end or md tag
                    if (md_block.md_idx == md_l) {
                        return;
                    }
                    s_idx = c_s_idx;
                    r_pos += md_block.matches + md_block.del_length;
                    while (!ins_q.empty() &&
                           s_idx + md_block.matches >= ins_q[0].c_s_idx) {  // catch up with insertions
                        ins_q.pop_front();
                    }
                    get_md_block(md_tag, md_block.md_idx, md_l, &md_block);
                    break;
                }

                // check if insertion occurs before mismatch
                while (!ins_q.empty() && s_idx + md_block.matches >= ins_q[0].c_s_idx) {
                    s_idx += ins_q[0].l;
                    ins_q.pop_front();
                }
                s_idx += md_block.matches;
                r_pos += md_block.matches;
                result.push_back({s_idx, r_pos});
                s_idx += 1;
                r_pos += 1;
                get_md_block(md_tag, md_block.md_idx, md_l, &md_block);
            }
        }
    }

    void align_init(Align *self) {
        uint8_t *v;
        char *value;

        bam1_t *src = self->delegate;

        self->pos = src->core.pos;
        self->reference_end = bam_endpos(src);  // reference_end - already checked for 0 length cigar and mapped
        self->cov_start = self->pos;
        self->cov_end = self->reference_end;

        uint32_t pos, l, cigar_l, op, k;
        uint32_t *cigar_p;

        uint8_t *ptr_seq = bam_get_seq(src);
        auto *ptr_qual = bam_get_qual(src);

        cigar_l = src->core.n_cigar;
        self->cigar_l = cigar_l;

        pos = src->core.pos;
        cigar_p = bam_get_cigar(src);

        self->left_soft_clip = 0;
        self->left_hard_clip = 0;
        self->right_soft_clip = 0;

        uint32_t last_op = 0;
        for (k = 0; k < cigar_l; k++) {
            op = cigar_p[k] & BAM_CIGAR_MASK;
            l = cigar_p[k] >> BAM_CIGAR_SHIFT;
            if (op == 4) {
                if (k == 0) {
                    self->cov_start -= l;
                    self->left_soft_clip = l;

                } else {
                    self->cov_end += l;
                    self->right_soft_clip = l;
                }
            } else if (op == 1) {
                self->any_ins.push_back({pos, l});
            } else if (k == 0 && op == 5) {
                self->left_hard_clip = l;
            }

            if (op == BAM_CMATCH || op == BAM_CEQUAL || op == BAM_CDIFF) {
                if (last_op == 1) {
                    if (!self->block_ends.empty() ) {
                        self->block_ends.back() = pos + l;
                    }
//                    self->block_ends.back() = pos + l;
                } else {
                    self->block_starts.push_back(pos);
                    self->block_ends.push_back(pos + l);
                }
//                self->block_starts.push_back(pos);
//                self->block_ends.push_back(pos + l);
                pos += l;
            } else if (op == BAM_CDEL || op == BAM_CREF_SKIP) {
                pos += l;
            }
            last_op = op;
        }

        if (src->core.flag & 16) {  // reverse strand
            self->cov_start -= 1;   // pad between alignments
        } else {
            self->cov_end += 1;
        }

        v = bam_aux_get(self->delegate, "MD");
        if (v == nullptr) {
            self->has_MD = false;
        } else {
            value = (char *) bam_aux2Z(v);
            self->MD = value;
            self->has_MD = true;
        }
        if (bam_aux_get(self->delegate, "SA") != nullptr) {
            self->has_SA = true;
        } else {
            self->has_SA = false;
        }

        self->y = -1;
        self->polygon_height = 0.8;

        int ptrn = NORMAL;
        uint32_t flag = src->core.flag;
        if (flag & 1 && !(flag & 12)) {  // proper-pair, not (unmapped, mate-unmapped)
            if (src->core.tid == src->core.mtid) {
                if (self->pos <= src->core.mpos) {
                    if (~flag & 16) {
                        if (flag & 32) {
                            if (~flag & 2) {
                                ptrn = DEL;
                            }
                        } else {
                            ptrn = INV_F;
                        }
                    } else {
                        if (flag & 32) {
                            ptrn = INV_R;
                        } else {
                            ptrn = DUP;
                        }
                    }
                } else {
                    if (flag & 16) {
                        if (~flag & 32) {
                            if (~flag & 2) {
                                ptrn = DEL;
                            }
                        } else {
                            ptrn = INV_F;
                        }
                    } else {
                        if (~flag & 32) {
                            ptrn = INV_R;
                        } else {
                            ptrn = DUP;
                        }
                    }
                }
            } else {
                ptrn = TRA;
            }
        }
        self->orient_pattern = ptrn;

        if (flag & 2048 || self->has_SA) {
            self->edge_type = 2;  // "SPLIT"
        } else if (flag & 8) {
            self->edge_type = 3;  // "MATE_UNMAPPED"
        } else {
            self->edge_type = 1;  // "NORMAL"
        }
        if (self->has_MD) {
            get_mismatched_bases(self->mismatches, self->MD, self->pos, cigar_l, cigar_p);
            if (!self->mismatches.empty()) {
                // note not all mismatches are drawn, so it doesn't make sense to save the color here. defer that to drawing
                for (auto &mm : self->mismatches) {
                    mm.base = bam_seqi(ptr_seq, mm.idx);
                    mm.qual = ptr_qual[mm.idx];
                }
            }
        }
//        else {
//            get_mismatched_bases_no_MD(self->mismatches, region, self->pos, cigar_l, cigar_p, ptr_seq);
//        }



        self->initialized = true;
    }

    void init_parallel(std::vector<Align> &aligns, int n) { //const char *refSeq, int begin, int rlen) {
        if (n == 1) {
            for (auto &aln : aligns) {
                align_init(&aln);
            }
        } else {
            BS::thread_pool pool(n);
            pool.parallelize_loop(0, aligns.size(),
                                  [&aligns](const int a, const int b) {
                                      for (int i = a; i < b; ++i)
                                          align_init(&aligns[i]);
                                  })
                    .wait();
        }
    }


    void addToCovArray(std::vector<int> &arr, Align &align, int begin, int end, int l_arr) {
        size_t n_blocks = align.block_starts.size();
        for (size_t idx=0; idx < n_blocks; ++idx) {
            uint32_t block_s = align.block_starts[idx];
            if (block_s >= end) { break; }
            uint32_t block_e = align.block_ends[idx];
            if (block_e < begin) { continue; }
            uint32_t s = (block_s >= begin) ? block_s - begin : 0;
            uint32_t e = (block_e < end) ? block_e - begin : l_arr;
            arr[s] += 1;
            arr[e] -= 1;
        }
    }

    int findY(int bamIdx, ReadCollection &rc, std::vector<Align> &rQ, int vScroll, int linkType, Themes::IniOptions &opts, Utils::Region *region, linked_t &linked, bool joinLeft) {

        if (rQ.empty()) {
            return 0;
        }
        Align *q_ptr = &rQ.front();
        const char *qname = nullptr;
        Segs::map_t & lm = linked[bamIdx];

        int i;
        // first find reads that should be linked together using qname
        if (linkType > 0) {
            // find the start and end coverage locations of aligns with same name
            for (i=0; i < (int)rQ.size(); ++i) {
                qname = bam_get_qname(q_ptr->delegate);
                if (linkType == 1) {
                    uint32_t flag = q_ptr->delegate->core.flag;
                    if (q_ptr->has_SA || ~flag & 2) {
                        lm[qname].push_back(i);
                    }
                } else {
                    lm[qname].push_back(i);
                }
                ++q_ptr;
            }

            // set all aligns with same name to have the same start and end coverage locations
            for (auto const& keyVal : lm) {
                const std::vector<int> &ind = keyVal.second;
                int size = (int)ind.size();
                if (size > 1) {
                    uint32_t cs = rQ[ind.front()].cov_start;
                    uint32_t ce = rQ[ind.back()].cov_end;
                      for (auto const j : ind) {
                          rQ[j].cov_start = cs;
                          rQ[j].cov_end = ce;
                    }
                }
            }
        }

        ankerl::unordered_dense::map< std::string, int > linkedSeen;  // Mapping of qname to y value
        std::vector<uint32_t> &ls = rc.levelsStart;
        std::vector<uint32_t> &le = rc.levelsEnd;

        if (ls.empty()) {
            ls.resize(opts.ylim + vScroll, 1215752191);
            le.resize(opts.ylim + vScroll, 0);
        }

        int qLen = (int)rQ.size();  // assume no overflow
        int stopCondition, move, si;
        int memLen = (int)ls.size();

        if (!joinLeft) {
            si = 0;
            stopCondition = qLen;
            move = 1;
            q_ptr = &rQ.front();
        } else {
            si = qLen - 1;
            stopCondition = -1;
            move = -1;
            q_ptr = &rQ.back();
        }

        while (si != stopCondition) {
            si += move;
            if (linkType > 0) {
                qname = bam_get_qname(q_ptr->delegate);
                if (linkedSeen.contains(qname)) {
                    q_ptr->y = linkedSeen[qname];
                    q_ptr += move;
                    continue;
                }
            }

            if (!joinLeft) {
                for (i=0; i < memLen; ++i) {
                    if (q_ptr->cov_start > le[i]) {
                        le[i] = q_ptr->cov_end;
                        if (q_ptr->cov_start < ls[i]) {
                            ls[i] = q_ptr->cov_start;
                        }
                        if (i >= vScroll) {
                            q_ptr->y = i - vScroll;
                        }
                        if (linkType > 0 && lm.contains(qname)) {
                            linkedSeen[qname] = q_ptr->y;
                        }
                        break;
                    }
                }
                if (i == memLen && linkType > 0 && lm.contains(qname)) {
                    linkedSeen[qname] = q_ptr->y;  // y is out of range i.e. -1
                }
                q_ptr += move;

            } else {
                for (i=0; i < memLen; ++i) {
                    if (q_ptr->cov_end < ls[i]) {
                        ls[i] = q_ptr->cov_start;
                        if (q_ptr->cov_end > le[i]) {
                            le[i] = q_ptr->cov_end;
                        }
                        if (i >= vScroll) {
                            q_ptr->y = i - vScroll;
                        }
                        if (linkType > 0 && lm.contains(qname)) {
                            linkedSeen[qname] = q_ptr->y;
                        }
                        break;
                    }
                }
                if (i == memLen && linkType > 0 && lm.contains(qname)) {
                    linkedSeen[qname] = q_ptr->y;  // y is out of range i.e. -1
                }
//                std::string qnamestr = bam_get_qname(q_ptr->delegate);
////                std::cout << "\n idx 39 is " << ls[39] << std::endl;
//
//                if (qnamestr == "HISEQ1:11:H8GV6ADXX:1:1105:8878:96886" && q_ptr->delegate->core.flag == 163 ) {
//                    std::cout << "\nn reads " << rQ.size() << std::endl;
//                    std::cout << "\n idx " << q_ptr->y <<  " " << bam_get_qname(q_ptr->delegate) << " at pos " << q_ptr->pos << std::endl;
//                    int ii = 0;
//                    std::cout << "\n" << q_ptr->y << std::endl;
//                    for (auto &itm : ls) {
//                        std::cout << ii << ": "  << itm <<  ", ";
//                        ii += 1;
//                    }
//                    std::cout << std::endl;
//                }

                q_ptr += move;
            }
        }

        int samMaxY;
        if (!opts.tlen_yscale) {
            samMaxY = memLen - vScroll;
        } else {
            int regionSize = region->end - region->start;
            samMaxY = memLen;
            q_ptr = &rQ.front();
            for (i=0; i < (int)rQ.size(); ++i) {
                int tlen = (int)std::abs(q_ptr->delegate->core.isize);
                if (tlen < regionSize) {
                    q_ptr->y = tlen;
                    if (tlen > samMaxY) {
                        samMaxY = tlen;
                    }
                } else {
                    q_ptr->y = regionSize;
                    samMaxY = regionSize;
                }
                ++q_ptr;
            }
        }
        return samMaxY;
    }
}