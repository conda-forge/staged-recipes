import pyladoc


def test_update_svg_ids():
    test_str = r"""
    <g id="figure_1">
    <g id="patch_1">
    <path d="M 0 15.0336
    L 24.570183 15.0336
    L 24.570183 0
    L 0 0
    z
    " style="fill: #ffffff"/>
    </g>
    <g id="axes_1">
    <g id="text_1">
        <!-- $\lambda_{\text{mix}}$ -->
        <g transform="translate(3.042219 10.351343) scale(0.1 -0.1)">
        <defs>
        <path id="DejaVuSans-Oblique-3bb" d="M 2350 4316


    " clip-path="url(#p8dcad2f367)" style="fill: none; stroke: #000000; stroke-width: 1.5; stroke-linecap: square"/>


    <clipPath id="p8dcad2f367">
    <rect x="57.6" y="41.472" width="357.12" height="266.112"/>
    </clipPath>
    </defs>


        <path id="DejaVuSans-Oblique-78" d="M 3841 3500
    L 2234 1784

        </defs>
        <use xlink:href="#DejaVuSans-Oblique-78" transform="translate(0 0.3125)"/>
        <use xlink:href="#DejaVuSans-Oblique-69" transform="translate(59.179688 -16.09375) scale(0.7)"/>
        </g>
    </g>

    <svg xmlns:xlink="http://www.w3.org/1999/xlink" width="24.570183pt" height="15.0336pt" viewBox="0 0 24.570183 15.0336" xmlns="http://www.w3.org/2000/svg" version="1.1">

    <defs>
    <style type="text/css">*{stroke-linejoin: round; stroke-linecap: butt}</style>
    </defs>
    <g id="figure_1">
    <g id="patch_1">
    <path d="M 0 15.0336
    L 24.570183 15.0336
    L 24.570183 0
    L 0 0
    z
    " style="fill: #ffffff"/>
    </g>
    <g id="axes_1">
    <g id="text_1">
        <!-- $\lambda_{\text{mix}}$ -->
        <g transform="translate(3.042219 10.351343) scale(0.1 -0.1)">
        <defs>
        <path id="DejaVuSans-Oblique-3bb" d="M 2350 4316
    L 3125 0
    L 2516 0
    L 2038 2588
    L 328 0
    L -281 0
    L 1903 3356
    L 1794 3975
    Q 1725 4369 1391 4369
    L 1091 4369
    L 1184 4863
    L 1550 4856
    Q 2253 4847 2350 4316
    z
    " transform="scale(0.015625)"/>
        <path id="DejaVuSans-6d" d="M 3328 2828
    Q 3544 3216 3844 3400
    Q 4144 3584 4550 3584
    Q 5097 3584 5394 3201
    Q 5691 2819 5691 2113
    L 5691 0
    L 5113 0
    L 5113 2094
    Q 5113 2597 4934 2840
    Q 4756 3084 4391 3084
    Q 3944 3084 3684 2787
    Q 3425 2491 3425 1978
    L 3425 0
    L 2847 0
    L 2847 2094
    Q 2847 2600 2669 2842
    Q 2491 3084 2119 3084
    Q 1678 3084 1418 2786
    Q 1159 2488 1159 1978
    L 1159 0
    L 581 0
    L 581 3500
    L 1159 3500
    L 1159 2956
    Q 1356 3278 1631 3431
    Q 1906 3584 2284 3584
    Q 2666 3584 2933 3390
    Q 3200 3197 3328 2828
    z
    " transform="scale(0.015625)"/>
        <path id="DejaVuSans-69" d="M 603 3500
    L 1178 3500
    L 1178 0
    L 603 0
    L 603 3500
    z
    M 603 4863
    L 1178 4863
    L 1178 4134
    L 603 4134
    L 603 4863
    z
    " transform="scale(0.015625)"/>
        <path id="DejaVuSans-78" d="M 3513 3500
    L 2247 1797
    L 3578 0
    L 2900 0
    L 1881 1375
    L 863 0
    L 184 0
    L 1544 1831
    L 300 3500
    L 978 3500
    L 1906 2253
    L 2834 3500
    L 3513 3500
    z
    " transform="scale(0.015625)"/>
        </defs>
        <use xlink:href="#DejaVuSans-Oblique-3bb" transform="translate(0 0.015625)"/>
        <use xlink:href="#DejaVuSans-6d" transform="translate(59.179688 -16.390625) scale(0.7)"/>
        <use xlink:href="#DejaVuSans-69" transform="translate(127.368164 -16.390625) scale(0.7)"/>
        <use xlink:href="#DejaVuSans-78" transform="translate(146.816406 -16.390625) scale(0.7)"/>
        </g>
    </g>
    </g>
    </g>
    </svg>
    """

    unique_id = 'xx-rgerergre-yy-trhsrthrst--xx'

    result = pyladoc.svg_tools.update_svg_ids(test_str, unique_id)

    print(result)

    assert result.replace(f"svg-{unique_id}-", '') == test_str
