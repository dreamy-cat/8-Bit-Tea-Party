// 8-Бит Чаепитие! Лицензия: Creative Commons.
// Поддерживаемые платформы: ZX Spectrum.
// Инструменты: CMake 3.5, GCC 13.1 x64, С11.
// Авторы: Александр Серов (alexander.serov@protonmail.com) [1].
// Описание: инструменты для работы со спрайтами.
/*
#include <iostream>
#include <fstream>
#include <filesystem>
#include <string>

using namespace std;	// C++17.

int main()
{
	const unsigned short maxSectors = 0xFF, bytesPerSector = 0x100, pixelsPerByte = 0x8, monochrome = 0x01;
	const unsigned int dataOffset = 0x0A, widthOffset = 0x12, heightOffset = 0x16, bitDepthOffset = 0x1C;
	const uintmax_t maxSizeSprite = maxSectors * bytesPerSector;
	cout << "All files and [sizes] in current directory, max size of sprite is " 
		<< maxSectors << " TR-DOS sectors, " << bytesPerSector << " bytes per sector or " 
		<< maxSizeSprite << " bytes.\n";
	int converted = 0;
	for (const auto & entry : filesystem::directory_iterator(".")) {
		filesystem::path path = entry.path();
		uintmax_t fSize = 0;
                if (!filesystem::is_directory(path))
                        fSize = entry.file_size();
		cout << path.filename() << "\t[" << fSize << "]\n";
		if (path.extension().string() == ".bmp") {
			cout << "\tBitmap file founded, reading file to memory.\n";
			if (entry.file_size() > maxSizeSprite)
				cout << "\tWarning, file size more than 255 sectors for TR-DOS.\n";
			unsigned int memSize = static_cast<unsigned int>(fSize);
			char* sprite = new char[memSize];
			string src = path.filename().string();
			string dst(src, 0, src.find("."));
			dst += ".C";
			for (unsigned int i = 0; i < dst.size(); i++) dst[i] = (char)toupper(dst[i]);
			ifstream bitmap(src, ios::binary);
			bitmap.read(sprite, fSize);
			bitmap.close();
			int *widthPtr = (int*)(sprite + widthOffset), *heightPtr = (int*)(sprite + heightOffset);
			if (*widthPtr % pixelsPerByte || *heightPtr % pixelsPerByte)
				cout << "\tWarning, one or both sizes of pixel array aren't multiply of 8(pixels per byte).\n";
			int* bitDepthPtr = (int*)(sprite + bitDepthOffset);
			if (*bitDepthPtr != monochrome)
				cout << "\tWarning, color depth is not monochrome or 1 bit per pixel.\n";
			int *data = (int*)(sprite + dataOffset);
			cout << "\tFile loaded to memory, sizes " << *widthPtr << "x" << *heightPtr << ", color depth in bits " 
				<< *bitDepthPtr << ", pixel array offset " << *data << endl;
			cout << "\tVertical flipping image.\n";
			int extraInt = (*widthPtr % (pixelsPerByte * sizeof(int)) > 0);
			int intsPerLine = *widthPtr / (pixelsPerByte * sizeof(int)) + extraInt;
			cout << "\tIntegers per line in sprite " << intsPerLine << endl;
			int* topLine = (int*)(sprite + *data);
			int* bottomLine = (int*)(sprite + fSize);
			cout << "\tOffset of top line " << (char*)topLine - sprite
				<< ", offset of bottom line " << (char*)bottomLine - sprite << endl;
			int spriteSize = (int)((bottomLine - topLine) * sizeof(int));
			cout << "\tPixel array size in bytes " << spriteSize << endl;
			cout << "\tLines copied counter, top and bottom diffs: ";
			for (int i = 0; i < *heightPtr / 2; ++i) {
				bottomLine -= intsPerLine;
				for (int j = 0; j < intsPerLine; ++j) {
					int pixs = *topLine;
					*topLine++ = *bottomLine;
					*bottomLine++ = pixs;
				}
				cout << bottomLine - topLine << " ";
				bottomLine -= intsPerLine;
			}
			cout << endl;
			if (extraInt) {
				cout << "\tPixel array has extra data, making solid binary block.\n";
				char* binDest = sprite + *data + *widthPtr / pixelsPerByte;
				char* binSrc = sprite + *data + intsPerLine * sizeof(int);
				int extraBytes = (int)(binSrc - binDest);
				cout << "\tCopy binary offsets from " << binSrc - sprite << " to " << binDest - sprite
					<< ", extra bytes in every line " << extraBytes << ", lines " << *heightPtr << endl;
				for (int i = 0; i < *heightPtr; ++i) {
					for (unsigned int j = 0; j < intsPerLine * sizeof(int) - extraBytes; ++j)
						*binDest++ = *binSrc++;
					binSrc += extraBytes;
				}
				spriteSize -= extraBytes * *heightPtr;
				cout << "\tData moved, new sprite size " << spriteSize << endl;
			} else cout << "\tPixel array hasn't extra data, making solid don't needed.\n";
			cout << "\tWriting data of sprite to file '" << dst << "', data from " << *data << " offset.\n";
			ofstream bmpTest(dst, ios::binary);
			bmpTest.write(sprite + *data, spriteSize);
			bmpTest.close();
			delete []sprite;
			converted++;
		}
	}
	cout << "Files converted to sprites " << converted << ", return to TR-DOS..." << endl;
}
*/
