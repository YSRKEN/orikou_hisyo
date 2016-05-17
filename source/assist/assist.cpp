/* http://independence-sys.net/main/?p=1806
 * ���Q�l�ɃR���p�C���ɒ���
 */
#define _CRT_SECURE_NO_WARNINGS
#include <tesseract/baseapi.h>
#include <leptonica/allheaders.h>

#include <iostream>
#include <fstream>
#include <string>
 
int main(int argc, char* argv[])
{
	tesseract::TessBaseAPI api;
	api.Init("", "eng", tesseract::OEM_DEFAULT);
	api.SetVariable("tessedit_char_whitelist", "0123456789:");

    STRING text_out;
	api.ProcessPages(argv[1], NULL, 0, &text_out);
 
    //���
    std::cout << text_out.string();

    //�O�̂���
    api.Clear();
    api.End();

//	system("pause");
}
