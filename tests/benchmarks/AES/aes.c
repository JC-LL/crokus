#include <stdio.h>

void aes(int st[16], int k[16]) {
	int i, j;
	int statemt[16];
	int key[16];

	int temp;
	int x;

	int word[4][120];

	int tmp01[4];
	int in;

	int ret[8 * 4];

	const int Sbox[16][16] = { { 0x63, 0x7c, 0x77, 0x7b, 0xf2, 0x6b, 0x6f, 0xc5,
			0x30, 0x01, 0x67, 0x2b, 0xfe, 0xd7, 0xab, 0x76 }, { 0xca, 0x82,
			0xc9, 0x7d, 0xfa, 0x59, 0x47, 0xf0, 0xad, 0xd4, 0xa2, 0xaf, 0x9c,
			0xa4, 0x72, 0xc0 }, { 0xb7, 0xfd, 0x93, 0x26, 0x36, 0x3f, 0xf7,
			0xcc, 0x34, 0xa5, 0xe5, 0xf1, 0x71, 0xd8, 0x31, 0x15 }, { 0x04,
			0xc7, 0x23, 0xc3, 0x18, 0x96, 0x05, 0x9a, 0x07, 0x12, 0x80, 0xe2,
			0xeb, 0x27, 0xb2, 0x75 }, { 0x09, 0x83, 0x2c, 0x1a, 0x1b, 0x6e,
			0x5a, 0xa0, 0x52, 0x3b, 0xd6, 0xb3, 0x29, 0xe3, 0x2f, 0x84 }, {
			0x53, 0xd1, 0x00, 0xed, 0x20, 0xfc, 0xb1, 0x5b, 0x6a, 0xcb, 0xbe,
			0x39, 0x4a, 0x4c, 0x58, 0xcf }, { 0xd0, 0xef, 0xaa, 0xfb, 0x43,
			0x4d, 0x33, 0x85, 0x45, 0xf9, 0x02, 0x7f, 0x50, 0x3c, 0x9f, 0xa8 },
			{ 0x51, 0xa3, 0x40, 0x8f, 0x92, 0x9d, 0x38, 0xf5, 0xbc, 0xb6, 0xda,
					0x21, 0x10, 0xff, 0xf3, 0xd2 }, { 0xcd, 0x0c, 0x13, 0xec,
					0x5f, 0x97, 0x44, 0x17, 0xc4, 0xa7, 0x7e, 0x3d, 0x64, 0x5d,
					0x19, 0x73 }, { 0x60, 0x81, 0x4f, 0xdc, 0x22, 0x2a, 0x90,
					0x88, 0x46, 0xee, 0xb8, 0x14, 0xde, 0x5e, 0x0b, 0xdb }, {
					0xe0, 0x32, 0x3a, 0x0a, 0x49, 0x06, 0x24, 0x5c, 0xc2, 0xd3,
					0xac, 0x62, 0x91, 0x95, 0xe4, 0x79 }, { 0xe7, 0xc8, 0x37,
					0x6d, 0x8d, 0xd5, 0x4e, 0xa9, 0x6c, 0x56, 0xf4, 0xea, 0x65,
					0x7a, 0xae, 0x08 },
			{ 0xba, 0x78, 0x25, 0x2e, 0x1c, 0xa6, 0xb4, 0xc6, 0xe8, 0xdd, 0x74,
					0x1f, 0x4b, 0xbd, 0x8b, 0x8a }, { 0x70, 0x3e, 0xb5, 0x66,
					0x48, 0x03, 0xf6, 0x0e, 0x61, 0x35, 0x57, 0xb9, 0x86, 0xc1,
					0x1d, 0x9e }, { 0xe1, 0xf8, 0x98, 0x11, 0x69, 0xd9, 0x8e,
					0x94, 0x9b, 0x1e, 0x87, 0xe9, 0xce, 0x55, 0x28, 0xdf }, {
					0x8c, 0xa1, 0x89, 0x0d, 0xbf, 0xe6, 0x42, 0x68, 0x41, 0x99,
					0x2d, 0x0f, 0xb0, 0x54, 0xbb, 0x16 } };

	// **************key generate & key display *******************
	const int Rcon0[30] = { 0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80,
			0x1b, 0x36, 0x6c, 0xd8, 0xab, 0x4d, 0x9a, 0x2f, 0x5e, 0xbc, 0x63,
			0xc6, 0x97, 0x35, 0x6a, 0xd4, 0xb3, 0x7d, 0xfa, 0xef, 0xc5, 0x91 };

	for (i = 0; i < 16; ++i) {
		statemt[i] = st[i];
		key[i] = k[i];
	}

	// KeySchedule (key, word);

	// obfuscation: control_flow_flattening start
	for (j = 0; j < 4; ++j){ // L5 -> L10
		for (i = 0; i < 4; ++i){
			// 0 word
			word[i][j] = key[i + j * 4];
		}
	}
	// obfuscation: control_flow_flattening end

	// expanded key is generated

	// obfuscation: control_flow_flattening start
	for (j = 4; j < 4 * (10 + 1); ++j) {

		// RotByte
		if ((j % 4) == 0) {
			in = word[1][j - 1];
			tmp01[0] = Sbox[(in / 16)][(in % 16)] ^ Rcon0[(j / 4) - 1];
			in = word[2][j - 1];
			tmp01[1] = Sbox[(in / 16)][(in % 16)];
			in = word[3][j - 1];
			tmp01[2] = Sbox[(in / 16)][(in % 16)];
			in = word[0][j - 1];
			tmp01[3] = Sbox[(in / 16)][(in % 16)];
		}
		if ((j % 4) != 0) {
			tmp01[0] = word[0][j - 1];
			tmp01[1] = word[1][j - 1];
			tmp01[2] = word[2][j - 1];
			tmp01[3] = word[3][j - 1];
		}
		for (i = 0; i < 4; ++i){
			word[i][j] = word[i][j - 4] ^ tmp01[i];
		}
	}
	// obfuscation: control_flow_flattening end
	// int j;
	//AddRoundKey 0
	for (j = 0; j < 4; ++j) {
		statemt[j * 4] ^= word[0][j + 4 * 0];
		statemt[1 + j * 4] ^= word[1][j + 4 * 0];
		statemt[2 + j * 4] ^= word[2][j + 4 * 0];
		statemt[3 + j * 4] ^= word[3][j + 4 * 0];
	}
	for (i = 1; i <= 9; ++i) {
		//ByteSub_ShiftRow (statemt);
		temp = Sbox[statemt[1] >> 4][statemt[1] & 0xf];
		statemt[1] = Sbox[statemt[5] >> 4][statemt[5] & 0xf];
		statemt[5] = Sbox[statemt[9] >> 4][statemt[9] & 0xf];
		statemt[9] = Sbox[statemt[13] >> 4][statemt[13] & 0xf];
		statemt[13] = temp;

		temp = Sbox[statemt[2] >> 4][statemt[2] & 0xf];
		statemt[2] = Sbox[statemt[10] >> 4][statemt[10] & 0xf];
		statemt[10] = temp;
		temp = Sbox[statemt[6] >> 4][statemt[6] & 0xf];
		statemt[6] = Sbox[statemt[14] >> 4][statemt[14] & 0xf];
		statemt[14] = temp;

		temp = Sbox[statemt[3] >> 4][statemt[3] & 0xf];
		statemt[3] = Sbox[statemt[15] >> 4][statemt[15] & 0xf];
		statemt[15] = Sbox[statemt[11] >> 4][statemt[11] & 0xf];
		statemt[11] = Sbox[statemt[7] >> 4][statemt[7] & 0xf];
		statemt[7] = temp;

		statemt[0] = Sbox[statemt[0] >> 4][statemt[0] & 0xf];
		statemt[4] = Sbox[statemt[4] >> 4][statemt[4] & 0xf];
		statemt[8] = Sbox[statemt[8] >> 4][statemt[8] & 0xf];
		statemt[12] = Sbox[statemt[12] >> 4][statemt[12] & 0xf];

		// MixColumn_AddRoundKey (statemt, i, word);
		//, j;
		for (j = 0; j < 4; ++j) {
			ret[j * 4] = (statemt[j * 4] << 1);
			if ((ret[j * 4] >> 8) == 1){
				ret[j * 4] ^= 283;
			}
			x = statemt[1 + j * 4];
			x ^= (x << 1);
			if ((x >> 8) == 1){
				ret[j * 4] ^= (x ^ 283);
			} else {
				ret[j * 4] ^= x;
			}
			ret[j * 4] ^= statemt[2 + j * 4] ^ statemt[3 + j * 4]
					^ word[0][j + 4 * i];

			ret[1 + j * 4] = (statemt[1 + j * 4] << 1);
			if ((ret[1 + j * 4] >> 8) == 1) {
				ret[1 + j * 4] ^= 283;
			}
			x = statemt[2 + j * 4];
			x ^= (x << 1);
			if ((x >> 8) == 1) {
				ret[1 + j * 4] ^= (x ^ 283);
			} else {
				ret[1 + j * 4] ^= x;
			}
			ret[1 + j * 4] ^= statemt[3 + j * 4] ^ statemt[j * 4]
					^ word[1][j + 4 * i];

			ret[2 + j * 4] = (statemt[2 + j * 4] << 1);
			if ((ret[2 + j * 4] >> 8) == 1) {
				ret[2 + j * 4] ^= 283;
			}
			x = statemt[3 + j * 4];
			x ^= (x << 1);
			if ((x >> 8) == 1) {
				ret[2 + j * 4] ^= (x ^ 283);
			} else {
				ret[2 + j * 4] ^= x;
			}
			ret[2 + j * 4] ^= statemt[j * 4] ^ statemt[1 + j * 4]
					^ word[2][j + 4 * i];

			ret[3 + j * 4] = (statemt[3 + j * 4] << 1);
			if ((ret[3 + j * 4] >> 8) == 1) {
				ret[3 + j * 4] ^= 283;
			}
			x = statemt[j * 4];
			x ^= (x << 1);
			if ((x >> 8) == 1) {
				ret[3 + j * 4] ^= (x ^ 283);
			} else {
				ret[3 + j * 4] ^= x;
			}
			ret[3 + j * 4] ^= statemt[1 + j * 4] ^ statemt[2 + j * 4]
					^ word[3][j + 4 * i];
		}
		for (j = 0; j < 4; ++j) {
			statemt[j * 4] = ret[j * 4];
			statemt[1 + j * 4] = ret[1 + j * 4];
			statemt[2 + j * 4] = ret[2 + j * 4];
			statemt[3 + j * 4] = ret[3 + j * 4];
		}
	}
	//ByteSub_ShiftRow (statemt);

	temp = Sbox[statemt[1] >> 4][statemt[1] & 0xf];
	statemt[1] = Sbox[statemt[5] >> 4][statemt[5] & 0xf];
	statemt[5] = Sbox[statemt[9] >> 4][statemt[9] & 0xf];
	statemt[9] = Sbox[statemt[13] >> 4][statemt[13] & 0xf];
	statemt[13] = temp;

	temp = Sbox[statemt[2] >> 4][statemt[2] & 0xf];
	statemt[2] = Sbox[statemt[10] >> 4][statemt[10] & 0xf];
	statemt[10] = temp;
	temp = Sbox[statemt[6] >> 4][statemt[6] & 0xf];
	statemt[6] = Sbox[statemt[14] >> 4][statemt[14] & 0xf];
	statemt[14] = temp;

	temp = Sbox[statemt[3] >> 4][statemt[3] & 0xf];
	statemt[3] = Sbox[statemt[15] >> 4][statemt[15] & 0xf];
	statemt[15] = Sbox[statemt[11] >> 4][statemt[11] & 0xf];
	statemt[11] = Sbox[statemt[7] >> 4][statemt[7] & 0xf];
	statemt[7] = temp;

	statemt[0] = Sbox[statemt[0] >> 4][statemt[0] & 0xf];
	statemt[4] = Sbox[statemt[4] >> 4][statemt[4] & 0xf];
	statemt[8] = Sbox[statemt[8] >> 4][statemt[8] & 0xf];
	statemt[12] = Sbox[statemt[12] >> 4][statemt[12] & 0xf];

	//AddRoundKey (statemt, i, word);
	for (j = 0; j < 4; ++j) {
		statemt[j * 4] ^= word[0][j + 4 * i];
		statemt[1 + j * 4] ^= word[1][j + 4 * i];
		statemt[2 + j * 4] ^= word[2][j + 4 * i];
		statemt[3 + j * 4] ^= word[3][j + 4 * i];
	}
	for (i = 0; i < 16; ++i){
		st[i] = statemt[i];
	}

	// return 0;
}

int main(){
	int st[16] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16};
	int k[16] = {2, 42, 33, 68, 3, 96, 34, 36, 2, 42, 33, 68, 3, 96, 34, 36};

	int expected[16] = {235, 107, 53, 77, 12, 98, 208, 233, 151, 129, 78, 158, 177, 56, 55, 52};

	int i;
	int errors = 0;

	aes(st, k);

	for (i = 0; i < 16; i++){
		if (st[i] != expected[i]){
			errors += 1;
		}
	}

	printf("%d errors!\n", errors);
	return errors;
}

