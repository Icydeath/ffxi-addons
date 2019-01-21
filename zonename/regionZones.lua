--[[    BSD License Disclaimer
        Copyright © 2018, sylandro
        All rights reserved.

        Redistribution and use in source and binary forms, with or without
        modification, are permitted provided that the following conditions are met:

            * Redistributions of source code must retain the above copyright
              notice, this list of conditions and the following disclaimer.
            * Redistributions in binary form must reproduce the above copyright
              notice, this list of conditions and the following disclaimer in the
              documentation and/or other materials provided with the distribution.
            * Neither the name of giltracker nor the
              names of its contributors may be used to endorse or promote products
              derived from this software without specific prior written permission.

        THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
        ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
        WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
        DISCLAIMED. IN NO EVENT SHALL sylandro BE LIABLE FOR ANY
        DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
        (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
        LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
        ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
        (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
        SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

region_zones = {}

region_zones.map = {
    [0] = S{230,231,232,233},
    [1] = S{234,235,236,237},
    [2] = S{238,239,240,241,242},
    [3] = S{243,244,245,246},
    [4] = S{100,101,139,140,141,142,167,190},
    [5] = S{102,103,108,193,196,248},
    [6] = S{1,2,104,105,149,150,195},
    [7] = S{106,107,143,144,172,173,191},
    [8] = S{109,110,147,148,197},
    [9] = S{115,116,145,146,169,170,192,194},
    [10] = S{3,4,117,118,198,213,249},
    [11] = S{7,8,119,120,151,152,200},
    [12] = S{9,10,111,166,203,204,206},
    [13] = S{5,6,112,161,162,165},
    [14] = S{126,127,157,158,179,184},
    [15] = S{121,122,153,154,202,251},
    [16] = S{114,125,168,208,209,247},
    [17] = S{113,128,174,201,212,128},
    [18] = S{123,176,250,252},
    [19] = S{124,159,160,163,205,207,211},
    [20] = S{130,177,178,180,181},
    [21] = S{39,40,41,42,134,135,185,186,187,188,294,295,296,297},
    [22] = S{11,12,13},
    [23] = S{26},
    [24] = S{24,25,27,28,29,30,31,32},
    [25] = S{14,16,17,18,19,20,21,22,23},
    [26] = S{33,34,35,36},
    [27] = S{37,38},
    [28] = S{58,59},
    [29] = S{48,50,52,71},
    [30] = S{65,66,67,68,51},
    [31] = S{61,62,63,64},
    [32] = S{53,54,55,56,57,60,69,78,79},
    [33] = S{72,73,74,75,76,77},
    [34] = S{80,81,86},
    [35] = S{82,84,175},
    [36] = S{87,88,89,93},
    [37] = S{83,90,91,171},
    [38] = S{94,95,96,129},
    [39] = S{97,98,164},
    [40] = S{136},
    [41] = S{137},
    [42] = S{85},
    [43] = S{92},
    [44] = S{99},
    [45] = S{155,138,156},
    [46] = S{15,45,132,215,216,217,218,253,254,255},
    [47] = S{182,222},
    [48] = S{43,44,183},
    [49] = S{284},
    [50] = S{280,258,256,257},
    [51] = S{259,260,261,262,263,265,266,267,268,269,270,271,272,273,281,264,282},
    [52] = S{274,276,277,275},
    [53] = S{288,289},
    [54] = S{291,292,293},
}
return region_zones

--not mapped
--airships: 223,224,225,226
--ferries: 227,228,46,47,220,221
--other: 70,285,131,285,290
--not existent: 49,133,189,199,210,214,219,229,278,279,286,287
--???: 283
