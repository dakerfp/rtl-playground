/*
import math
import random

bits = 8

def randlut(bits):
	r = range(1 << bits)
	random.shuffle(r)
	return r

print('''
function [%d:0] randlut;
input [%d:0] x;
case(x)
''' % (bits - 1, bits - 1)
for i, x in enumerate(randlut(8)):
    print("%d: randlut = %d;" % (i,x))
print('''
default: randlut = 0;
endcase
endfunction
''')
*/

function [7:0] randlut;
input [7:0] x;
begin
case(x)
0: randlut = 11;
1: randlut = 81;
2: randlut = 195;
3: randlut = 31;
4: randlut = 232;
5: randlut = 74;
6: randlut = 248;
7: randlut = 49;
8: randlut = 23;
9: randlut = 191;
10: randlut = 83;
11: randlut = 210;
12: randlut = 60;
13: randlut = 129;
14: randlut = 93;
15: randlut = 242;
16: randlut = 197;
17: randlut = 117;
18: randlut = 19;
19: randlut = 192;
20: randlut = 3;
21: randlut = 42;
22: randlut = 176;
23: randlut = 68;
24: randlut = 120;
25: randlut = 20;
26: randlut = 218;
27: randlut = 199;
28: randlut = 119;
29: randlut = 221;
30: randlut = 168;
31: randlut = 135;
32: randlut = 211;
33: randlut = 158;
34: randlut = 163;
35: randlut = 200;
36: randlut = 241;
37: randlut = 107;
38: randlut = 87;
39: randlut = 224;
40: randlut = 236;
41: randlut = 36;
42: randlut = 51;
43: randlut = 233;
44: randlut = 234;
45: randlut = 115;
46: randlut = 78;
47: randlut = 14;
48: randlut = 21;
49: randlut = 145;
50: randlut = 85;
51: randlut = 104;
52: randlut = 244;
53: randlut = 77;
54: randlut = 39;
55: randlut = 254;
56: randlut = 17;
57: randlut = 13;
58: randlut = 159;
59: randlut = 220;
60: randlut = 116;
61: randlut = 102;
62: randlut = 59;
63: randlut = 132;
64: randlut = 65;
65: randlut = 142;
66: randlut = 194;
67: randlut = 162;
68: randlut = 24;
69: randlut = 89;
70: randlut = 252;
71: randlut = 131;
72: randlut = 73;
73: randlut = 201;
74: randlut = 79;
75: randlut = 1;
76: randlut = 136;
77: randlut = 188;
78: randlut = 172;
79: randlut = 25;
80: randlut = 92;
81: randlut = 82;
82: randlut = 216;
83: randlut = 72;
84: randlut = 118;
85: randlut = 186;
86: randlut = 26;
87: randlut = 214;
88: randlut = 217;
89: randlut = 150;
90: randlut = 177;
91: randlut = 209;
92: randlut = 70;
93: randlut = 84;
94: randlut = 190;
95: randlut = 226;
96: randlut = 219;
97: randlut = 165;
98: randlut = 44;
99: randlut = 111;
100: randlut = 130;
101: randlut = 227;
102: randlut = 98;
103: randlut = 69;
104: randlut = 55;
105: randlut = 123;
106: randlut = 56;
107: randlut = 193;
108: randlut = 222;
109: randlut = 94;
110: randlut = 110;
111: randlut = 27;
112: randlut = 230;
113: randlut = 196;
114: randlut = 4;
115: randlut = 80;
116: randlut = 169;
117: randlut = 91;
118: randlut = 126;
119: randlut = 16;
120: randlut = 124;
121: randlut = 171;
122: randlut = 43;
123: randlut = 101;
124: randlut = 139;
125: randlut = 179;
126: randlut = 63;
127: randlut = 187;
128: randlut = 12;
129: randlut = 166;
130: randlut = 140;
131: randlut = 228;
132: randlut = 6;
133: randlut = 86;
134: randlut = 100;
135: randlut = 155;
136: randlut = 5;
137: randlut = 122;
138: randlut = 149;
139: randlut = 75;
140: randlut = 189;
141: randlut = 247;
142: randlut = 28;
143: randlut = 183;
144: randlut = 66;
145: randlut = 127;
146: randlut = 29;
147: randlut = 141;
148: randlut = 170;
149: randlut = 255;
150: randlut = 182;
151: randlut = 88;
152: randlut = 128;
153: randlut = 121;
154: randlut = 237;
155: randlut = 35;
156: randlut = 251;
157: randlut = 22;
158: randlut = 18;
159: randlut = 152;
160: randlut = 137;
161: randlut = 90;
162: randlut = 198;
163: randlut = 231;
164: randlut = 204;
165: randlut = 58;
166: randlut = 151;
167: randlut = 125;
168: randlut = 223;
169: randlut = 47;
170: randlut = 106;
171: randlut = 143;
172: randlut = 239;
173: randlut = 134;
174: randlut = 174;
175: randlut = 8;
176: randlut = 32;
177: randlut = 161;
178: randlut = 103;
179: randlut = 181;
180: randlut = 33;
181: randlut = 15;
182: randlut = 30;
183: randlut = 154;
184: randlut = 138;
185: randlut = 173;
186: randlut = 246;
187: randlut = 215;
188: randlut = 160;
189: randlut = 203;
190: randlut = 175;
191: randlut = 112;
192: randlut = 157;
193: randlut = 0;
194: randlut = 148;
195: randlut = 249;
196: randlut = 180;
197: randlut = 133;
198: randlut = 96;
199: randlut = 185;
200: randlut = 146;
201: randlut = 50;
202: randlut = 76;
203: randlut = 113;
204: randlut = 206;
205: randlut = 229;
206: randlut = 245;
207: randlut = 167;
208: randlut = 144;
209: randlut = 108;
210: randlut = 208;
211: randlut = 105;
212: randlut = 212;
213: randlut = 2;
214: randlut = 45;
215: randlut = 114;
216: randlut = 38;
217: randlut = 205;
218: randlut = 240;
219: randlut = 71;
220: randlut = 10;
221: randlut = 53;
222: randlut = 61;
223: randlut = 202;
224: randlut = 253;
225: randlut = 52;
226: randlut = 147;
227: randlut = 67;
228: randlut = 99;
229: randlut = 48;
230: randlut = 184;
231: randlut = 238;
232: randlut = 207;
233: randlut = 57;
234: randlut = 46;
235: randlut = 109;
236: randlut = 40;
237: randlut = 95;
238: randlut = 37;
239: randlut = 178;
240: randlut = 164;
241: randlut = 225;
242: randlut = 156;
243: randlut = 7;
244: randlut = 9;
245: randlut = 243;
246: randlut = 54;
247: randlut = 62;
248: randlut = 153;
249: randlut = 97;
250: randlut = 235;
251: randlut = 34;
252: randlut = 41;
253: randlut = 250;
254: randlut = 64;
255: randlut = 213;
endcase
end
endfunction

