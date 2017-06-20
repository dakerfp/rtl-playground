/*
import math

bits = 8

def sinlut(bits):
	rlut = [1.0 - math.cos(float(i) * 2 * math.pi / 2**bits) for i in range(2**bits)]
	return [min(int(round(x * (2 ** (bits-1)))), (2**(bits))-1) for x in rlut]

print('''
function [%d-1:0] sinlut;
input [%d-1:0] x;
begin
case(x)
''' % (bits, bits))
for i, x in enumerate(sinlut(8)):
    print("%d: sinlut = %d;" % (i,x))
print('''
default: sinlut = 0;
endcase
end
endfunction
''')
*/

function [8-1:0] sinlut;
input [8-1:0] x;
begin
case(x)

0: sinlut = 0;
1: sinlut = 0;
2: sinlut = 0;
3: sinlut = 0;
4: sinlut = 1;
5: sinlut = 1;
6: sinlut = 1;
7: sinlut = 2;
8: sinlut = 2;
9: sinlut = 3;
10: sinlut = 4;
11: sinlut = 5;
12: sinlut = 6;
13: sinlut = 6;
14: sinlut = 7;
15: sinlut = 9;
16: sinlut = 10;
17: sinlut = 11;
18: sinlut = 12;
19: sinlut = 14;
20: sinlut = 15;
21: sinlut = 17;
22: sinlut = 18;
23: sinlut = 20;
24: sinlut = 22;
25: sinlut = 23;
26: sinlut = 25;
27: sinlut = 27;
28: sinlut = 29;
29: sinlut = 31;
30: sinlut = 33;
31: sinlut = 35;
32: sinlut = 37;
33: sinlut = 40;
34: sinlut = 42;
35: sinlut = 44;
36: sinlut = 47;
37: sinlut = 49;
38: sinlut = 52;
39: sinlut = 54;
40: sinlut = 57;
41: sinlut = 60;
42: sinlut = 62;
43: sinlut = 65;
44: sinlut = 68;
45: sinlut = 70;
46: sinlut = 73;
47: sinlut = 76;
48: sinlut = 79;
49: sinlut = 82;
50: sinlut = 85;
51: sinlut = 88;
52: sinlut = 91;
53: sinlut = 94;
54: sinlut = 97;
55: sinlut = 100;
56: sinlut = 103;
57: sinlut = 106;
58: sinlut = 109;
59: sinlut = 112;
60: sinlut = 115;
61: sinlut = 119;
62: sinlut = 122;
63: sinlut = 125;
64: sinlut = 128;
65: sinlut = 131;
66: sinlut = 134;
67: sinlut = 137;
68: sinlut = 141;
69: sinlut = 144;
70: sinlut = 147;
71: sinlut = 150;
72: sinlut = 153;
73: sinlut = 156;
74: sinlut = 159;
75: sinlut = 162;
76: sinlut = 165;
77: sinlut = 168;
78: sinlut = 171;
79: sinlut = 174;
80: sinlut = 177;
81: sinlut = 180;
82: sinlut = 183;
83: sinlut = 186;
84: sinlut = 188;
85: sinlut = 191;
86: sinlut = 194;
87: sinlut = 196;
88: sinlut = 199;
89: sinlut = 202;
90: sinlut = 204;
91: sinlut = 207;
92: sinlut = 209;
93: sinlut = 212;
94: sinlut = 214;
95: sinlut = 216;
96: sinlut = 219;
97: sinlut = 221;
98: sinlut = 223;
99: sinlut = 225;
100: sinlut = 227;
101: sinlut = 229;
102: sinlut = 231;
103: sinlut = 233;
104: sinlut = 234;
105: sinlut = 236;
106: sinlut = 238;
107: sinlut = 239;
108: sinlut = 241;
109: sinlut = 242;
110: sinlut = 244;
111: sinlut = 245;
112: sinlut = 246;
113: sinlut = 247;
114: sinlut = 249;
115: sinlut = 250;
116: sinlut = 250;
117: sinlut = 251;
118: sinlut = 252;
119: sinlut = 253;
120: sinlut = 254;
121: sinlut = 254;
122: sinlut = 255;
123: sinlut = 255;
124: sinlut = 255;
125: sinlut = 255;
126: sinlut = 255;
127: sinlut = 255;
128: sinlut = 255;
129: sinlut = 255;
130: sinlut = 255;
131: sinlut = 255;
132: sinlut = 255;
133: sinlut = 255;
134: sinlut = 255;
135: sinlut = 254;
136: sinlut = 254;
137: sinlut = 253;
138: sinlut = 252;
139: sinlut = 251;
140: sinlut = 250;
141: sinlut = 250;
142: sinlut = 249;
143: sinlut = 247;
144: sinlut = 246;
145: sinlut = 245;
146: sinlut = 244;
147: sinlut = 242;
148: sinlut = 241;
149: sinlut = 239;
150: sinlut = 238;
151: sinlut = 236;
152: sinlut = 234;
153: sinlut = 233;
154: sinlut = 231;
155: sinlut = 229;
156: sinlut = 227;
157: sinlut = 225;
158: sinlut = 223;
159: sinlut = 221;
160: sinlut = 219;
161: sinlut = 216;
162: sinlut = 214;
163: sinlut = 212;
164: sinlut = 209;
165: sinlut = 207;
166: sinlut = 204;
167: sinlut = 202;
168: sinlut = 199;
169: sinlut = 196;
170: sinlut = 194;
171: sinlut = 191;
172: sinlut = 188;
173: sinlut = 186;
174: sinlut = 183;
175: sinlut = 180;
176: sinlut = 177;
177: sinlut = 174;
178: sinlut = 171;
179: sinlut = 168;
180: sinlut = 165;
181: sinlut = 162;
182: sinlut = 159;
183: sinlut = 156;
184: sinlut = 153;
185: sinlut = 150;
186: sinlut = 147;
187: sinlut = 144;
188: sinlut = 141;
189: sinlut = 137;
190: sinlut = 134;
191: sinlut = 131;
192: sinlut = 128;
193: sinlut = 125;
194: sinlut = 122;
195: sinlut = 119;
196: sinlut = 115;
197: sinlut = 112;
198: sinlut = 109;
199: sinlut = 106;
200: sinlut = 103;
201: sinlut = 100;
202: sinlut = 97;
203: sinlut = 94;
204: sinlut = 91;
205: sinlut = 88;
206: sinlut = 85;
207: sinlut = 82;
208: sinlut = 79;
209: sinlut = 76;
210: sinlut = 73;
211: sinlut = 70;
212: sinlut = 68;
213: sinlut = 65;
214: sinlut = 62;
215: sinlut = 60;
216: sinlut = 57;
217: sinlut = 54;
218: sinlut = 52;
219: sinlut = 49;
220: sinlut = 47;
221: sinlut = 44;
222: sinlut = 42;
223: sinlut = 40;
224: sinlut = 37;
225: sinlut = 35;
226: sinlut = 33;
227: sinlut = 31;
228: sinlut = 29;
229: sinlut = 27;
230: sinlut = 25;
231: sinlut = 23;
232: sinlut = 22;
233: sinlut = 20;
234: sinlut = 18;
235: sinlut = 17;
236: sinlut = 15;
237: sinlut = 14;
238: sinlut = 12;
239: sinlut = 11;
240: sinlut = 10;
241: sinlut = 9;
242: sinlut = 7;
243: sinlut = 6;
244: sinlut = 6;
245: sinlut = 5;
246: sinlut = 4;
247: sinlut = 3;
248: sinlut = 2;
249: sinlut = 2;
250: sinlut = 1;
251: sinlut = 1;
252: sinlut = 1;
253: sinlut = 0;
254: sinlut = 0;
255: sinlut = 0;

default: sinlut = 0;
endcase
end
endfunction

