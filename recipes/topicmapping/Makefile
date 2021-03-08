CXXFLAGS = -O3 -funroll-loops -Wall

SOURCES = \
Sources/Infomap-0.15.7/Makefile \
Sources/TopicMapping/optimize_alpha.cpp \
Sources/SingleSliceInfomap/pajek_format.cpp \
Sources/SingleSliceInfomap/get_partition.cpp \
Sources/TopicMapping/show_topic_info.cpp \
Sources/TopicMapping/docmap.cpp

OUT_DIR = $(PREFIX)/bin

TARGET = \
$(OUT_DIR) \
$(OUT_DIR)/Infomap \
$(OUT_DIR)/opt_alpha \
$(OUT_DIR)/edges2pajek \
$(OUT_DIR)/tree2part \
$(OUT_DIR)/show_topic_info \
$(OUT_DIR)/topicmap

all: $(TARGET)

$(OUT_DIR):
	mkdir -p $@

$(OUT_DIR)/Infomap: Sources/Infomap-0.15.7/Makefile
	$(MAKE) -C Sources/Infomap-0.15.7 all

$(OUT_DIR)/opt_alpha: Sources/TopicMapping/optimize_alpha.cpp
	$(CXX) $(CXXFLAGS) -o $@ $<

$(OUT_DIR)/edges2pajek: Sources/SingleSliceInfomap/pajek_format.cpp
	$(CXX) $(CXXFLAGS) -o $@ $<

$(OUT_DIR)/tree2part: Sources/SingleSliceInfomap/get_partition.cpp
	$(CXX) $(CXXFLAGS) -o $@ $<

$(OUT_DIR)/show_topic_info: Sources/TopicMapping/show_topic_info.cpp
	$(CXX) $(CXXFLAGS) -o $@ $<

$(OUT_DIR)/topicmap: Sources/TopicMapping/docmap.cpp
	$(CXX) $(CXXFLAGS) -o $@ $<

