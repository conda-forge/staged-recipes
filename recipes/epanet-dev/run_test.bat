git clone https://github.com/OpenWaterAnalytics/epanet-example-networks.git
new-item -Name rpt -ItemType directory

foreach ($file in get-ChildItem ./epanet-example-networks/*/*.inp) {
    Echo $file.name
    $basename = $file.BaseName
    run-epanet3 $file "rpt/$basename-rpt.txt"
}
