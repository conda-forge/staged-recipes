//
// Created by Kez Cleal on 12/08/2022.
//
#include <algorithm>
#include <cmath>
#include <cstdio>
#include <cstdint>
#include <vector>
#include <utility>
#include <stdio.h>

#include <GLFW/glfw3.h>

#define SK_GL
#include "include/gpu/GrBackendSurface.h"
#include "include/gpu/GrDirectContext.h"
#include "include/gpu/gl/GrGLInterface.h"
#include "include/core/SkCanvas.h"
#include "include/core/SkColorSpace.h"
#include "include/core/SkSurface.h"
#include "include/core/SkData.h"
#include "include/core/SkStream.h"
#include "include/core/SkImage.h"
#include "include/core/SkImageInfo.h"
#include "include/core/SkSize.h"
#include "include/core/SkPaint.h"
#include "include/core/SkPath.h"
#include "include/core/SkPoint.h"
#include "include/core/SkTypeface.h"
#include "include/core/SkFont.h"
#include "include/core/SkTextBlob.h"

#include "htslib/hts.h"
#include "htslib/sam.h"

#include "../include/BS_thread_pool.h"
#include "../include/robin_hood.h"

#include "hts_funcs.h"
#include "drawing.h"

//#include "utils.h"
//#include "segments.h"
//#include "themes.h"


namespace Drawing {

    char indelChars[50];
    constexpr float polygonHeight = 0.85;

    void drawCoverage(const Themes::IniOptions &opts, const std::vector<Segs::ReadCollection> &collections,
                      SkCanvas *canvas, const Themes::Fonts &fonts, const float covYh, const float refSpace) {

        const Themes::BaseTheme &theme = opts.theme;
        SkPaint paint = theme.fcCoverage;
        SkPath path;
        std::vector<sk_sp < SkTextBlob> > text;
        std::vector<sk_sp < SkTextBlob> > text_ins;
        std::vector<float> textX, textY;
        std::vector<float> textX_ins, textY_ins;

        float covY = covYh * 0.95;

        int last_bamIdx = 0;
        float yOffsetAll = refSpace;

        for (auto &cl: collections) {
            if (cl.covArr.empty() || cl.readQueue.empty()) {
                continue;
            }
            if (cl.bamIdx != last_bamIdx) {
                yOffsetAll += cl.yPixels;
            }
            float xScaling = cl.xScaling;
            float xOffset = cl.xOffset;
            float tot, mean, n;
            const std::vector<int> & covArr_r = cl.covArr;
            std::vector<float> c;
            c.resize(cl.covArr.size());
            c[0] = cl.covArr[0];
            int cMaxi = (c[0] > 10) ? c[0] : 10;
            tot = (float)c[0];
            n = 0;
            if (tot > 0) {
                n += 1;
            }
            float cMax;
            for (size_t i=1; i<c.size(); ++i) { // cum sum
                c[i] = ((float)covArr_r[i]) + c[i-1];
                if (c[i] > cMaxi) {
                    cMaxi = (int)c[i];
                }
                if (c[i] > 0) {
                    tot += c[i];
                    n += 1;
                }
            }
            if (n > 0) {
                mean = tot / n;
                mean = ((float)((int)(mean * 10))) / 10;
            } else {
                mean = 0;
            }

            if (opts.log2_cov) {
                for (size_t i=0; i<c.size(); ++i) {
                    if (c[i] > 0) { c[i] = std::log2(c[i]); }
                }
                cMax = std::log2(cMaxi);
            } else {
                cMax = cMaxi;
            }
            // normalize to space available
            for (auto &i : c) {
                i = ((1 - (i / cMax)) * covY) * 0.7;
                i += yOffsetAll + (covY * 0.3);
            }
            int step;
            if (c.size() > 2000) {
                step = std::max(1, (int)(c.size() / 2000));
            } else {
                step = 1;
            }

            float lastY = yOffsetAll + covY;
            double x = xOffset;

            path.reset();
            path.moveTo(x, lastY);
            for (size_t i=0; i<c.size(); ++i)  {
                if (i % step == 0 || i == c.size() - 1) {
                    path.lineTo(x, lastY);
                    path.lineTo(x, c[i]);
                }
                lastY = c[i];
                x += xScaling;
            }
            path.lineTo(x - xScaling, yOffsetAll + covY);
            path.lineTo(xOffset, yOffsetAll + covY);
            path.close();
            canvas->drawPath(path, paint);

            std::sprintf(indelChars, "%d", cMaxi);

            sk_sp<SkTextBlob> blob = SkTextBlob::MakeFromString(indelChars, fonts.overlay);
            canvas->drawTextBlob(blob, xOffset + 25, (covY * 0.3) + yOffsetAll + 10, theme.tcDel);
            path.reset();
            path.moveTo(xOffset, (covY * 0.3) + yOffsetAll);
            path.lineTo(xOffset + 20, (covY * 0.3) + yOffsetAll);
            path.moveTo(xOffset, covY + yOffsetAll);
            path.lineTo(xOffset + 20, covY + yOffsetAll);
            canvas->drawPath(path, theme.lcJoins);

            char * ap = indelChars;
            ap += std::sprintf(indelChars, "%s", "avg. ");
            std::sprintf(ap, "%.1f", mean);

            if (((covY * 0.5) + yOffsetAll + 10 - fonts.fontMaxSize) - ((covY * 0.3) + yOffsetAll + 10) > 0) { // dont overlap text
                blob = SkTextBlob::MakeFromString(indelChars, fonts.overlay);
                canvas->drawTextBlob(blob, xOffset + 25, (covY * 0.5) + yOffsetAll + 10, theme.tcDel);
            }
            last_bamIdx = cl.bamIdx;
        }
    }

    inline void chooseFacecolors(int mapq, const Segs::Align &a, SkPaint &faceColor, const Themes::BaseTheme &theme) {
        if (mapq == 0) {
            switch (a.orient_pattern) {
                case Segs::NORMAL:
                    faceColor = theme.fcNormal0;
                    break;
                case Segs::DEL:
                    faceColor = theme.fcDel0;
                    break;
                case Segs::INV_F:
                    faceColor = theme.fcInvF0;
                    break;
                case Segs::INV_R:
                    faceColor = theme.fcInvR0;
                    break;
                case Segs::DUP:
                    faceColor = theme.fcDup0;
                    break;
                case Segs::TRA:
                    faceColor = theme.mate_fc0[a.delegate->core.mtid % 48];
                    break;
            }
        } else {
            switch (a.orient_pattern) {
                case Segs::NORMAL:
                    faceColor = theme.fcNormal;
                    break;
                case Segs::DEL:
                    faceColor = theme.fcDel;
                    break;
                case Segs::INV_F:
                    faceColor = theme.fcInvF;
                    break;
                case Segs::INV_R:
                    faceColor = theme.fcInvR;
                    break;
                case Segs::DUP:
                    faceColor = theme.fcDup;
                    break;
                case Segs::TRA:
                    faceColor = theme.mate_fc[a.delegate->core.mtid % 48];
                    break;
            }
        }
    }

    inline void chooseEdgeColor(int edge_type, SkPaint &edgeColor, const Themes::BaseTheme &theme) {
        if (edge_type == 2) {
            edgeColor = theme.ecSplit;
        } else if (edge_type == 4) {
            edgeColor = theme.ecSelected;
        } else {
            edgeColor = theme.ecMateUnmapped;
        }
    }

    inline void
    drawRectangle(SkCanvas *canvas, const float polygonH, const float yScaledOffset, const float start, const float width, const float xScaling,
                  const float xOffset, const SkPaint &faceColor, SkRect &rect) {
        rect.setXYWH((start * xScaling) + xOffset, yScaledOffset, width * xScaling, polygonH);
        canvas->drawRect(rect, faceColor);
    }

    inline void
    drawLeftPointedRectangle(SkCanvas *canvas, const float polygonH, const float yScaledOffset, float start, float width,
                             const float xScaling, const float maxX, const float xOffset, const SkPaint &faceColor, SkPath &path, const float slop) {
        start *= xScaling;
        width *= xScaling;
        if (start < 0) {
            width += start;
            start = 0;
        }
        if (start + width > maxX) {
            width = maxX - start;
        }
        path.reset();
        path.moveTo(start + xOffset, yScaledOffset);
        path.lineTo(start - slop + xOffset, yScaledOffset + polygonH / 2);
        path.lineTo(start + xOffset, yScaledOffset + polygonH);
        path.lineTo(start + width + xOffset, yScaledOffset + polygonH);
        path.lineTo(start + width + xOffset, yScaledOffset);
        path.close();
        canvas->drawPath(path, faceColor);
    }

    inline void
    drawRightPointedRectangle(SkCanvas *canvas, const float polygonH, const float yScaledOffset, float start, float width,
                              const float xScaling, const float maxX, const float xOffset, const SkPaint &faceColor, SkPath &path,
                              const float slop) {
        start *= xScaling;
        width *= xScaling;
        if (start < 0) {
            width += start;
            start = 0;
        }
        if (start + width > maxX) {
            width = maxX - start;
        }
        path.reset();
        path.moveTo(start + xOffset, yScaledOffset);
        path.lineTo(start + xOffset, yScaledOffset + polygonH);
        path.lineTo(start + width + xOffset, yScaledOffset + polygonH);
        path.lineTo(start + width + slop + xOffset, yScaledOffset + polygonH / 2);
        path.lineTo(start + width + xOffset, yScaledOffset);
        path.close();
        canvas->drawPath(path, faceColor);
    }

    inline void drawHLine(SkCanvas *canvas, SkPath &path, const SkPaint &lc, const float startX, const float y, const float endX) {
        path.reset();
        path.moveTo(startX, y);
        path.lineTo(endX, y);
        canvas->drawPath(path, lc);
    }

    void drawIns(SkCanvas *canvas, float y0, float start, float yScaling, float xOffset,
                 float yOffset, float textW, const SkPaint &sidesColor, const SkPaint &faceColor, SkPath &path,
                 SkRect &rect) {

        float x = start + xOffset;
        float y = y0 * yScaling;
        float ph = polygonHeight * yScaling;
        float overhang = textW * 0.125;
        rect.setXYWH(x - (textW / 2) - 2, y + yOffset, textW + 2, ph);
        canvas->drawRect(rect, faceColor);

        path.reset();
        path.moveTo(x - (textW / 2) - overhang, yOffset + y + ph * 0.05);
        path.lineTo(x + (textW / 2) + overhang, yOffset + y + ph * 0.05);
        path.moveTo(x - (textW / 2) - overhang, yOffset + y + ph * 0.95);
        path.lineTo(x + (textW / 2) + overhang, yOffset + y + ph * 0.95);
        path.moveTo(x, yOffset + y);
        path.lineTo(x, yOffset + y + ph);
        canvas->drawPath(path, sidesColor);
    }

    void drawMismatchesNoMD(SkCanvas *canvas, SkRect &rect, const Themes::BaseTheme &theme, const Utils::Region &region, const Segs::Align &align,
                            float width, float xScaling, float xOffset, float mmPosOffset, float yScaledOffset, float pH, int l_qseq) {
        uint32_t r_pos = align.pos;
        uint32_t cigar_l = align.cigar_l;
        uint8_t *ptr_seq = bam_get_seq(align.delegate);
        uint32_t *cigar_p = bam_get_cigar(align.delegate);
        auto *ptr_qual = bam_get_qual(align.delegate);

        int r_idx;
        uint32_t idx = 0;
        const char *refSeq = region.refSeq;
        if (refSeq == nullptr) {
            return;
        }
        int rlen = region.end - region.start;
        int op, l, colorIdx;
        float p;

        for (int k = 0; k < cigar_l; k++) {
            op = cigar_p[k] & BAM_CIGAR_MASK;
            l = cigar_p[k] >> BAM_CIGAR_SHIFT;


            if (op == BAM_CSOFT_CLIP) {
                idx += l;
                continue;
            }
            else if (op == BAM_CINS) {
                idx += l;
                continue;
            }
            else if (op == BAM_CDEL) {
                r_pos += l;
                continue;
            }
            else if (op == BAM_CREF_SKIP) {
                r_pos += l;
                continue;
            }
            else if (op == BAM_CHARD_CLIP || op == BAM_CEQUAL) {
                continue;
            }
            else if (op == BAM_CDIFF) {
                for (int i=0; i < l; ++l) {
                    if (r_pos >= region.start) {
                        char bam_base = bam_seqi(ptr_seq, idx);
                        p = ((int)r_pos - region.start) * xScaling;
                        colorIdx = (l_qseq == 0) ? 10 : (ptr_qual[idx] > 10) ? 10 : ptr_qual[idx];
                        rect.setXYWH(p + xOffset + mmPosOffset, yScaledOffset, width, pH);
                        switch (bam_base) {
                            case 1: canvas->drawRect(rect, theme.BasePaints[bam_base][colorIdx]); break;
                            case 2: canvas->drawRect(rect, theme.BasePaints[bam_base][colorIdx]); break;
                            case 4: canvas->drawRect(rect, theme.BasePaints[bam_base][colorIdx]); break;
                            case 8: canvas->drawRect(rect, theme.BasePaints[bam_base][colorIdx]); break;
                            default: canvas->drawRect(rect, theme.BasePaints[bam_base][colorIdx]); break;
                        }
                    }
                    idx += 1;
                    r_pos += 1;
                }
            }
            else {  // BAM_CMATCH
                // A==1, C==2, G==4, T==8, N==>8
                for (int i=0; i < l; ++i) {
                    r_idx = (int)r_pos - region.start;
                    if (r_idx < 0) {
                        idx += 1;
                        r_pos += 1;
                        continue;
                    }

                    if (r_idx > rlen) {
                        break;
                    }
                    char ref_base;
                    switch (refSeq[r_idx]) {
                        case 'A': ref_base = 1; break;
                        case 'C': ref_base = 2; break;
                        case 'G': ref_base = 4; break;
                        case 'T': ref_base = 8; break;
                        case 'N': ref_base = 15; break;
                        case 'a': ref_base = 1; break;
                        case 'c': ref_base = 2; break;
                        case 'g': ref_base = 4; break;
                        case 't': ref_base = 8; break;
                        case 'n': ref_base = 15; break;
                    }
                    char bam_base = bam_seqi(ptr_seq, idx);
                    if (bam_base != ref_base) {
                        p = ((int)r_pos - region.start) * xScaling;
                        colorIdx = (l_qseq == 0) ? 10 : (ptr_qual[idx] > 10) ? 10 : ptr_qual[idx];
                        rect.setXYWH(p + xOffset + mmPosOffset, yScaledOffset, width, pH);
                        switch (bam_base) {
                            case 1: canvas->drawRect(rect, theme.BasePaints[bam_base][colorIdx]); break;
                            case 2: canvas->drawRect(rect, theme.BasePaints[bam_base][colorIdx]); break;
                            case 4: canvas->drawRect(rect, theme.BasePaints[bam_base][colorIdx]); break;
                            case 8: canvas->drawRect(rect, theme.BasePaints[bam_base][colorIdx]); break;
                            default: canvas->drawRect(rect, theme.BasePaints[bam_base][colorIdx]); break;
                        }
                    }
                    idx += 1;
                    r_pos += 1;
                }
            }
        }
    }

    void drawBams(const Themes::IniOptions &opts, const std::vector<Segs::ReadCollection> &collections,
                  SkCanvas *canvas, float yScaling, const Themes::Fonts &fonts, const Segs::linked_t &linked, int linkOp, float refSpace) {

        SkPaint faceColor;
        SkPaint edgeColor;

        SkRect rect;
        SkPath path;

        const Themes::BaseTheme &theme = opts.theme;

        std::vector<sk_sp < SkTextBlob> > text;
        std::vector<sk_sp < SkTextBlob> > text_ins;
        std::vector<float> textX, textY;
        std::vector<float> textX_ins, textY_ins;

        for (auto &cl: collections) {

            int regionBegin = cl.region.start;
            int regionEnd = cl.region.end;
            int regionLen = regionEnd - regionBegin;

            float xScaling = cl.xScaling;
            float xOffset = cl.xOffset;
            float yOffset = cl.yOffset;
            float regionPixels = regionLen * xScaling;
//            float pointSlop = ((regionLen / 100) * 0.25) * xScaling;
            float pointSlop = (tan(0.42) * (yScaling/2));  // radians

            float textDrop = (yScaling - fonts.fontHeight) / 2;

            bool plotSoftClipAsBlock = regionLen > opts.soft_clip_threshold;
            bool plotPointedPolygons = regionLen < 50000;

            float pH = yScaling * polygonHeight;

            for (auto &a: cl.readQueue) {

                int Y = a.y;
                if (Y == -1) {
                    continue;
                }
                int mapq = a.delegate->core.qual;
                float yScaledOffset = (Y * yScaling) + yOffset;

                chooseFacecolors(mapq, a, faceColor, theme);

                bool pointLeft, edged;
                if (plotPointedPolygons) {
                    pointLeft = (a.delegate->core.flag & 16) != 0;
                } else {
                    pointLeft = false;
                }
                size_t nBlocks = a.block_starts.size();

                if (regionLen < 100000 && a.edge_type != 1) {
                    edged = true;
                    chooseEdgeColor(a.edge_type, edgeColor, theme);
                } else {
                    edged = false;
                }

                double width, s, e, yh, textW;
                int lastEnd = 1215752191;
                bool line_only;
                for (size_t idx = 0; idx < nBlocks; ++idx) {
                    s = a.block_starts[idx];
                    if (idx > 0) {
                        lastEnd = a.block_ends[idx-1];
                    }

                    if (s > regionEnd) {
                        if (lastEnd < regionEnd) {
                            line_only = true;
                        } else {
                            break;
                        }
                    } else {
                        line_only = false;
                    }

                    e = a.block_ends[idx];
                    if (e < regionBegin) { continue; }
                    s -= regionBegin;
                    e -= regionBegin;
                    s = (s < 0) ? 0: s;
                    e = (e > regionLen) ? regionLen : e;
                    width = e - s;
                    if (!line_only) {
                        if (plotPointedPolygons) {
                            if (pointLeft) {
                                if (s > 0 && idx == 0 && a.left_soft_clip == 0) {
                                    drawLeftPointedRectangle(canvas, pH, yScaledOffset, s, width, xScaling,
                                                             regionPixels, xOffset, faceColor, path, pointSlop);
                                    if (edged) {
                                        drawLeftPointedRectangle(canvas, pH, yScaledOffset, s, width, xScaling,
                                                                 regionPixels, xOffset, edgeColor, path, pointSlop);
                                    }
                                } else {
                                    drawRectangle(canvas, pH, yScaledOffset, s, width, xScaling, xOffset,
                                                  faceColor, rect);
                                    if (edged) {
                                        drawRectangle(canvas, pH, yScaledOffset, s, width, xScaling, xOffset,
                                                      edgeColor, rect);
                                    }
                                }
                            } else {
                                if (e < regionLen && idx == nBlocks - 1 && a.right_soft_clip == 0) {
                                    drawRightPointedRectangle(canvas, pH, yScaledOffset, s, width, xScaling,
                                                              regionPixels, xOffset, faceColor, path, pointSlop);
                                    if (edged) {
                                        drawRightPointedRectangle(canvas, pH, yScaledOffset, s, width, xScaling,
                                                                  regionPixels, xOffset, edgeColor, path, pointSlop);
                                    }
                                } else {
                                    drawRectangle(canvas, pH, yScaledOffset, s, width, xScaling, xOffset,
                                                  faceColor, rect);
                                    if (edged) {
                                        drawRectangle(canvas, pH, yScaledOffset, s, width, xScaling, xOffset,
                                                      edgeColor, rect);
                                    }
                                }
                            }
                        } else {
                            drawRectangle(canvas, pH, yScaledOffset, s, width, xScaling, xOffset, faceColor,
                                          rect);
                            if (edged) {
                                drawRectangle(canvas, pH, yScaledOffset, s, width, xScaling, xOffset,
                                              edgeColor, rect);
                            }
                        }
                    }

                    // add lines and text between gaps
                    if (idx > 0) {
                        float lastEnd = (int)a.block_ends[idx - 1] - regionBegin;
                        int isize = s - lastEnd;
                        lastEnd = (lastEnd < 0) ? 0 : lastEnd;
                        int size = s - lastEnd;
                        float delBegin = lastEnd * xScaling;
                        float delEnd = delBegin + (size * xScaling);
                        yh = (Y + polygonHeight * 0.5) * yScaling + yOffset;
                        if (size <= 0) { continue; }
                        if (regionLen < 500000 && size >= opts.indel_length) { // line and text
                            std::sprintf(indelChars, "%d", isize);
                            size_t sl = strlen(indelChars);
                            textW = fonts.textWidths[sl - 1];
                            float textBegin = ((lastEnd + size / 2) * xScaling) - (textW / 2);
                            float textEnd = textBegin + textW;
                            if (textBegin < 0) {
                                textBegin = 0;
                                textEnd = textW;
                            } else if (textEnd > regionPixels) {
                                textBegin = regionPixels - textW;
                                textEnd = regionPixels;
                            }
                            text.push_back(SkTextBlob::MakeFromString(indelChars, fonts.fonty));
                            textX.push_back(textBegin + xOffset);
                            textY.push_back((Y + polygonHeight) * yScaling - textDrop + yOffset);
                            if (textBegin > delBegin) {
                                drawHLine(canvas, path, theme.lcJoins, delBegin + xOffset, yh, textBegin + xOffset);
                                drawHLine(canvas, path, theme.lcJoins, textEnd + xOffset, yh, delEnd + xOffset);
                            }
                        } else if (size / (float) regionLen > 0.0005) { // (regionLen < 50000 || size > 100) { // line only
                            delEnd = std::min(regionPixels, delEnd);
                            drawHLine(canvas, path, theme.lcJoins, delBegin + xOffset, yh, delEnd + xOffset);
                        }
                    }
                }

                // add soft-clip blocks
                int start = a.pos - regionBegin;
                int end = a.reference_end - regionBegin;
                auto l_seq = (int)a.delegate->core.l_qseq;

                if (a.left_soft_clip > 0) {
                    width = (plotSoftClipAsBlock || l_seq == 0) ? (float) a.left_soft_clip : 0;
                    s = start - a.left_soft_clip;
                    if (s < 0) {
                        width += s;
                        s = 0;
                    }

                    e = start + width;
                    if (start > regionLen) {
                        //width -= regionLen - start;
//                        width -= e - regionLen;
                        width = regionLen - start;
                    }

//                    std::string qq = "SRR9001772.54163";
//                    if (bam_get_qname(a.delegate) == qq) {
//                        std::cout << width << std::endl;
//                    }

                    if (e > 0 && s < regionLen && width > 0) {
                        if (pointLeft && plotPointedPolygons) {
                            drawLeftPointedRectangle(canvas, pH, yScaledOffset, s, width, xScaling,
                                                     regionPixels, xOffset,
                                                     (mapq == 0) ? theme.fcSoftClip0 : theme.fcSoftClip,
                                                     path, pointSlop);
                        } else {
                            drawRectangle(canvas, pH, yScaledOffset, s, width, xScaling, xOffset,
                                          (mapq == 0) ? theme.fcSoftClip0 : theme.fcSoftClip, rect);
                        }
                    }
                }
                if (a.right_soft_clip > 0) {
                    if (plotSoftClipAsBlock || l_seq == 0) {
                        s = end;
                        width = (float) a.right_soft_clip;
                    } else {
                        s = end + a.right_soft_clip;
                        width = 0;
                    }
                    e = s + width;
                    if (s < 0) {
                        width += s;
                        s = 0;
                    }
                    if (e > regionLen) {
                        width = regionLen - s;
                        e = regionLen;
                    }
                    if (s < regionLen && e > 0) {
                        if (!pointLeft && plotPointedPolygons) {
                            drawRightPointedRectangle(canvas, pH, yScaledOffset, s, width, xScaling,
                                                      regionPixels, xOffset,
                                                      (mapq == 0) ? theme.fcSoftClip0 : theme.fcSoftClip, path,
                                                      pointSlop);
                        } else {
                            drawRectangle(canvas, pH, yScaledOffset, s, width, xScaling,
                                          xOffset, (mapq == 0) ? theme.fcSoftClip0 : theme.fcSoftClip, rect);
                        }
                    }
                }

                // add insertions
                if (!a.any_ins.empty()) {
                    for (auto &ins: a.any_ins) {
                        float p = (ins.pos - regionBegin) * xScaling;
                        if (0 <= p && p < regionPixels) {
                            std::sprintf(indelChars, "%d", ins.length);
                            size_t sl = strlen(indelChars);
//                            int sl = ceil(log10(ins.length));
                            textW = fonts.textWidths[sl - 1];
                            if (ins.length > opts.indel_length) {
                                if (regionLen < 500000) {  // line and text
                                    drawIns(canvas, Y, p, yScaling, xOffset, yOffset, textW, theme.insS,
                                            theme.fcIns, path, rect);
                                    text_ins.push_back(SkTextBlob::MakeFromString(indelChars, fonts.fonty));
                                    textX_ins.push_back(p - (textW / 2) + xOffset - 2);
                                    textY_ins.push_back(((Y + polygonHeight) * yScaling) + yOffset - textDrop);
                                } else {  // line only
                                    drawIns(canvas, Y, p, yScaling, xOffset, yOffset, xScaling, theme.insS,
                                            theme.fcIns, path, rect);
                                }
                            } else if (regionLen < 100000) {  // line only
                                drawIns(canvas, Y, p, yScaling, xOffset, yOffset, xScaling, theme.insS,
                                        theme.fcIns, path, rect);
                            }
                        }
                    }
                }

                // add mismatches
                if (regionLen > opts.snp_threshold && plotSoftClipAsBlock) {
                    continue;
                }
                if (l_seq == 0) {
                    continue;
                }
                float mmPosOffset, mmScaling;
                if (regionLen < 500) {
                    mmPosOffset = 0.05;
                    mmScaling = 0.9;
                } else {
                    mmPosOffset = 0;
                    mmScaling = 1;
                }
                int colorIdx;

                int32_t l_qseq = a.delegate->core.l_qseq;
                if (regionLen <= opts.snp_threshold && !a.mismatches.empty()) {
                    float mms = xScaling * mmScaling;
                    width = (regionLen < 500000) ? ((1. > mms) ? 1. : mms) : xScaling;
                    for (auto &m: a.mismatches) {
                        float p = ((int)m.pos - regionBegin) * xScaling;
                        if (0 < p && p < regionPixels) {
                            colorIdx = (l_qseq == 0) ? 10 : (m.qual > 10) ? 10 : m.qual;
                            rect.setXYWH(p + xOffset + mmPosOffset, yScaledOffset, width, pH);
//                            canvas->drawRect(rect, theme.BasePaints[m.base][colorIdx]);
                            canvas->drawRoundRect(rect, 5, 5, theme.BasePaints[m.base][colorIdx]);
                        }
                    }
                } else if (!a.has_MD) {
                    float mms = xScaling * mmScaling;
                    width = (regionLen < 500000) ? ((1. > mms) ? 1. : mms) : xScaling;
                    drawMismatchesNoMD(canvas, rect, theme, cl.region, a, width, xScaling, xOffset, mmPosOffset, yScaledOffset, pH, l_qseq);
                }

                // add soft-clips
                if (!plotSoftClipAsBlock) {
                    uint8_t *ptr_seq = bam_get_seq(a.delegate);
                    uint8_t *ptr_qual = bam_get_qual(a.delegate);
                    if (a.right_soft_clip > 0) {
                        int pos = (int)a.reference_end - regionBegin;
                        if (pos < regionLen && a.cov_end > regionBegin) {
                            int opLen = (int)a.right_soft_clip;
                            for (int idx = l_seq - opLen; idx < l_seq; ++idx) {
                                float p = pos * xScaling;
                                if (0 <= p && p < regionPixels) {
                                    uint8_t base = bam_seqi(ptr_seq, idx);
                                    uint8_t qual = ptr_qual[idx];
                                    colorIdx = (l_qseq == 0) ? 10 : (qual > 10) ? 10 : qual;
                                    rect.setXYWH(p + xOffset + mmPosOffset, yScaledOffset, xScaling * mmScaling, pH);
                                    canvas->drawRect(rect, theme.BasePaints[base][colorIdx]);
                                } else if (p > regionPixels) {
                                    break;
                                }
                                pos += 1;
                            }
                        }
                    }
                    if (a.left_soft_clip > 0) {
                        int opLen = (int)a.left_soft_clip;
                        int pos = (int)a.pos - regionBegin - opLen;
                        for (int idx = 0; idx < opLen; ++idx) {
                            float p = pos * xScaling;
                            if (0 <= p && p < regionPixels) {
                                uint8_t base = bam_seqi(ptr_seq, idx);
                                uint8_t qual = ptr_qual[idx];
                                colorIdx = (l_qseq == 0) ? 10 : (qual > 10) ? 10 : qual;
                                rect.setXYWH(p + xOffset + mmPosOffset, yScaledOffset, xScaling * mmScaling, pH);
                                canvas->drawRect(rect, theme.BasePaints[base][colorIdx]);
                            } else if (p >= regionPixels) {
                                break;
                            }
                            pos += 1;
                        }
                    }
                }
            }

            // draw markers
            if (cl.region.markerPos != -1) {
                float rp = refSpace + 6 + (cl.bamIdx * cl.yPixels);
                float xp = refSpace * 0.3;
                float markerP = (xScaling * (float)(cl.region.markerPos - cl.region.start)) + cl.xOffset;
                if (markerP > cl.xOffset && markerP < regionPixels - cl.xOffset) {
                    path.reset();
                    path.moveTo(markerP, rp);
                    path.lineTo(markerP - xp, rp);
                    path.lineTo(markerP, rp + refSpace);
                    path.lineTo(markerP + xp, rp);
                    path.lineTo(markerP, rp);
                    canvas->drawPath(path, theme.marker_paint);
                }
                float markerP2 = (xScaling * (float)(cl.region.markerPosEnd - cl.region.start)) + cl.xOffset;
                if (markerP2 > cl.xOffset && markerP2 < (regionPixels + cl.xOffset)) {
                    path.reset();
                    path.moveTo(markerP2, rp);
                    path.lineTo(markerP2 - xp, rp);
                    path.lineTo(markerP2, rp + refSpace);
                    path.lineTo(markerP2 + xp, rp);
                    path.lineTo(markerP2, rp);
                    canvas->drawPath(path, theme.marker_paint);
                }
            }

            // draw text last
            for (int i = 0; i < text.size(); ++i) {
                canvas->drawTextBlob(text[i].get(), textX[i], textY[i], theme.tcDel);
            }
            for (int i = 0; i < text_ins.size(); ++i) {
                canvas->drawTextBlob(text_ins[i].get(), textX_ins[i], textY_ins[i], theme.tcIns);
            }
        }

        // draw connecting lines between linked alignments
        if (linkOp > 0) {
            for (int idx=0; idx < linked.size(); ++idx) {
                Segs::map_t lm = linked[idx];
                if (!linked.empty()) {
                    SkPaint paint;
                    for (auto const& keyVal : lm) {
                        const std::vector<int> &ind = keyVal.second;
                        int size = (int)ind.size();
                        if (size > 1) {
                            const Segs::ReadCollection & rc = collections[idx];
                            float max_x = rc.xOffset + (((float)rc.region.end - (float)rc.region.start) * rc.xScaling);

                            for (int jdx=0; jdx < size - 1; ++jdx) {
                                const Segs::Align &segA = rc.readQueue[ind[jdx]];
                                const Segs::Align &segB = rc.readQueue[ind[jdx + 1]];
                                if (segA.y == -1 || segB.y == -1 || (segA.delegate->core.tid != segB.delegate->core.tid)) {
                                    continue;
                                }
                                long cstart = std::min(segA.block_ends.front(), segB.block_ends.front());
                                long cend = std::max(segA.block_starts.back(), segB.block_starts.back());

                                double x_a = ((double)cstart - (double)rc.region.start) * rc.xScaling;
                                double x_b = ((double)cend - (double)rc.region.start) * rc.xScaling;

                                x_a = (x_a < 0) ? 0: x_a;
                                x_b = (x_b < 0) ? 0 : x_b;
                                x_a += rc.xOffset;
                                x_b += rc.xOffset;
                                x_a = (x_a > max_x) ? max_x : x_a;
                                x_b = (x_b > max_x) ? max_x : x_b;
                                float y = ((float)segA.y * yScaling) + ((polygonHeight / 2) * yScaling) + rc.yOffset;

                                switch (segA.orient_pattern) {
                                    case Segs::DEL: paint = theme.fcDel; break;
                                    case Segs::DUP: paint = theme.fcDup; break;
                                    case Segs::INV_F: paint = theme.fcInvF; break;
                                    case Segs::INV_R: paint = theme.fcInvR; break;
                                    default: paint = theme.fcNormal; break;
                                }
                                paint.setStyle(SkPaint::kStroke_Style);
                                paint.setStrokeWidth(2);
                                path.reset();
                                path.moveTo(x_a, y);
                                path.lineTo(x_b, y);
                                canvas->drawPath(path, paint);
                            }
                        }
                    }
                }
            }
        }
    }

    void drawRef(const Themes::IniOptions &opts, const std::vector<Segs::ReadCollection> &collections,
                  SkCanvas *canvas, const Themes::Fonts &fonts, float h, float nRegions) {
        SkRect rect;
        SkPaint faceColor;
        const Themes::BaseTheme &theme = opts.theme;
        float offset = 0;

//        float h = fonts.fontMaxSize;
        float textW = fonts.overlayWidth;
        float minLetterSize = ((float)opts.dimensions.x / nRegions) / textW;
        for (auto &cl: collections) {
            int size = cl.region.end - cl.region.start;
            double xScaling = cl.xScaling;
            double xPixels = (xScaling * size) + cl.xOffset;
            const char *ref = cl.region.refSeq;
            if (ref == nullptr) {
                continue;
            }
            double i = cl.xOffset;

            if (textW > 0 && (float)size < minLetterSize && fonts.fontMaxSize <= h) {
                double v = (xScaling - textW) / 2;
                float yp = h * 0.66;
                while (*ref) {
                    switch ((unsigned int)*ref) {
                        case 65: faceColor = theme.fcA; break;
                        case 67: faceColor = theme.fcC; break;
                        case 71: faceColor = theme.fcG; break;
                        case 78: faceColor = theme.fcN; break;
                        case 84: faceColor = theme.fcT; break;
                        case 97: faceColor = theme.fcA; break;
                        case 99: faceColor = theme.fcC; break;
                        case 103: faceColor = theme.fcG; break;
                        case 110: faceColor = theme.fcN; break;
                        case 116: faceColor = theme.fcT; break;
                    }
                    if (i + v > xPixels) {
                        break;
                    }
                    canvas->drawTextBlob(SkTextBlob::MakeFromText(ref, 1, fonts.overlay, SkTextEncoding::kUTF8),
                                         i + v, yp, faceColor);
                    i += xScaling;
                    ++ref;
                }
            } else if (size < 20000) {
                while (*ref) {
                    rect.setXYWH(i, offset, xScaling, h);
                    switch ((unsigned int)*ref) {
                        case 65: canvas->drawRect(rect, theme.fcA); break;
                        case 67: canvas->drawRect(rect, theme.fcC); break;
                        case 71: canvas->drawRect(rect, theme.fcG); break;
                        case 78: canvas->drawRect(rect, theme.fcN); break;
                        case 84: canvas->drawRect(rect, theme.fcT); break;
                        case 97: canvas->drawRect(rect, theme.fcA); break;
                        case 99: canvas->drawRect(rect, theme.fcC); break;
                        case 103: canvas->drawRect(rect, theme.fcG); break;
                        case 110: canvas->drawRect(rect, theme.fcN); break;
                        case 116: canvas->drawRect(rect, theme.fcT); break;
                    }
                    i += xScaling;
                    ++ref;
                }
            }
            // todo add pixelHeight to offset
        }
    }

    void drawBorders(const Themes::IniOptions &opts, float fb_width, float fb_height,
                 SkCanvas *canvas, size_t nregions, size_t nbams, float totalTabixY, float tabixY, size_t tracks_size) {
        SkPath path;
        float refSpace = fb_height * 0.02;
        float gap2 = fb_width * 0.004;
        if (nregions > 1) {
            float x = fb_width / nregions;
            float step = x;
            path.reset();
            for (int i=0; i < nregions - 1; ++i) {
                path.moveTo(x, 0);
                path.lineTo(x, fb_height);
                x += step;
            }
            canvas->drawPath(path, opts.theme.lcLightJoins);
        }
        if (nbams > 1) {
            float y = (fb_height - totalTabixY - refSpace - gap2) / nbams;
            float step = y;
            y += refSpace;
            path.reset();
            for (int i=0; i<nbams - 1; ++i) {
                path.moveTo(0, y);
                path.lineTo(fb_width, y);
                y += step;
            }
            canvas->drawPath(path, opts.theme.lcLightJoins);
        }
        if (tracks_size) {
            float step = totalTabixY / tracks_size;
            float y = fb_height - totalTabixY + step;
            for (int i=0; i<tracks_size-1; ++i) {
                path.moveTo(0, y);
                path.lineTo(fb_width, y);
                y += step;
            }
            canvas->drawPath(path, opts.theme.lcLightJoins);
        }
    }

    void drawLabel(const Themes::IniOptions &opts, SkCanvas *canvas, SkRect &rect, Utils::Label &label, Themes::Fonts &fonts) {
        float pad = 5;
        sk_sp<SkTextBlob> blob = SkTextBlob::MakeFromString(label.current().c_str(), fonts.overlay);
        canvas->drawTextBlob(blob, rect.left() + pad, rect.bottom() - pad, opts.theme.tcDel);
        if (label.i > 0) {
            canvas->drawRect(rect, opts.theme.lcJoins);
        }
    }

    void drawTracks(Themes::IniOptions &opts, float fb_width, float fb_height,
                     SkCanvas *canvas, float totalTabixY, float tabixY, std::vector<HGW::GwTrack> &tracks,
                     const std::vector<Utils::Region> &regions, const Themes::Fonts &fonts) {

        if (tracks.empty()) {
            return;
        }
        float gap = fb_width*0.002;
        float gap2 = 2*gap;
        float padX = gap;
        float padY = 0;

        float stepX = fb_width / regions.size();
        float stepY = totalTabixY / tracks.size();
        float refSpace = fb_height * 0.02;
        float y = fb_height - totalTabixY + refSpace;
        float h = stepY * 0.2;
        float t = 0.005 * fb_width;
        SkRect rect;
        SkPath path;

//        opts.theme.lcJoins.setAntiAlias(true);
        opts.theme.lcLightJoins.setAntiAlias(true);
        for (auto &rgn : regions) {
            float xScaling = (stepX - gap2) / (rgn.end - rgn.start);
            for (auto & trk : tracks) {
                trk.fetch(&rgn);
                while (true) {
                    trk.next();
                    if (trk.done) {
                        break;
                    }
//                    float e = (trk.stop < rgn.end) ? trk.stop - rgn.start : rgn.end;
                    float x, w, textW;
                    if (trk.start < rgn.start && trk.stop >= rgn.end) {
                        rect.setXYWH(padX, y + padY - h, stepX - gap2, h);
                        canvas->drawRoundRect(rect, 5, 5, opts.theme.fcTrack);
                        canvas->drawRoundRect(rect, 5, 5, opts.theme.lcLightJoins);
                    } else if (trk.start < rgn.start) {
                        w = (trk.stop - rgn.start) * xScaling;
                        rect.setXYWH(padX, y + padY - h, w, h);
                        canvas->drawRoundRect(rect, 5, 5, opts.theme.fcTrack);
                        canvas->drawRoundRect(rect, 5, 5, opts.theme.lcLightJoins);

                    } else if (trk.stop > rgn.end) {
                        x = (trk.start - rgn.start) * xScaling;
                        w = (rgn.end - trk.start) * xScaling;
                        rect.setXYWH(x + padX, y + padY - h, w, h);
                        canvas->drawRoundRect(rect, 5, 5, opts.theme.fcTrack);
                        canvas->drawRoundRect(rect, 5, 5, opts.theme.lcLightJoins);
                        if (w > t) {
                            textW = fonts.overlayWidth * (trk.rid.size() + 1);
                            if (rect.left() + textW < padX + stepX - gap2 - gap2) {
                                rect.setXYWH(x + padX, y + (h/2) + padY, textW, h);
                                canvas->drawRect(rect, opts.theme.bgPaint);
                                sk_sp<SkTextBlob> blob = SkTextBlob::MakeFromString(trk.rid.c_str(), fonts.overlay);
                                canvas->drawTextBlob(blob, rect.left(), rect.bottom(), opts.theme.tcDel);
                            }
                        }
                        path.moveTo(x + padX, y + padY - h);
                        path.lineTo(x + padX, y + (h/2) + padY);
                        canvas->drawPath(path, opts.theme.lcJoins);

                    } else { // all within view
                        x = (trk.start - rgn.start) * xScaling;
                        w = (trk.stop - trk.start) * xScaling;
                        rect.setXYWH(x + padX, y + padY - h, w, h);
                        canvas->drawRoundRect(rect, 5, 5, opts.theme.fcTrack);
                        canvas->drawRoundRect(rect, 5, 5, opts.theme.lcLightJoins);
                        if (w > t) {
                            textW = fonts.overlayWidth * (trk.rid.size() + 1);
                            if (rect.left() + textW < padX + stepX - gap2 - gap2) {
                                rect.setXYWH(x + padX, y + (h/2) + padY, textW, h);
                                canvas->drawRect(rect, opts.theme.bgPaint);
                                sk_sp<SkTextBlob> blob = SkTextBlob::MakeFromString(trk.rid.c_str(), fonts.overlay);
                                canvas->drawTextBlob(blob, rect.left(), rect.bottom(), opts.theme.tcDel);
                            }
                        }
                        path.moveTo(x + padX, y + padY - h);
                        path.lineTo(x + padX, y + (h/2) + padY);
                        canvas->drawPath(path, opts.theme.lcJoins);
                    }
                }
                padY += stepY;
            }
            padY = 0;
            padX += stepX;
        }
//        opts.theme.lcJoins.setAntiAlias(false);
        opts.theme.lcLightJoins.setAntiAlias(false);
    }
}