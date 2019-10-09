#include <iostream>
#include <string>
#include <vector>

// Compile with C++14.

using namespace std;

void func_1(char c)
{
    cout << "Function with char argument " << c << endl;
}

void func_1(int i)
{
    cout << "Function with int argument " << i << endl;
}

void func_2(const char* p, short s)
{
    cout << "Function with const char* and short arguments, " << *p << " and " << s << endl;
}

void func_2(char* p, int s)
{
    cout << "Function with char* and integer arguments, " << *p << " and " << s << endl;
}

class Colors {
public:
    /*
    Colors(size_t size) {
        palette.resize(size);
        cout << "Simple constructor of Colors, size of palette " << palette.size() << endl;
    }
    Colors(vector<string>& clrs) {
        cout << "Constructor of Colors with strings: ";
        for (auto &e : clrs) {
            cout << e << " ";
            palette.push_back(e);
        }
        cout << "- size of vector " << palette.size() << endl;
    }
    */
    Colors(size_t size, char, vector<string>* clrs = nullptr) {
        palette.resize(size);
        cout << "Simple constructor of Colors, size of palette " << palette.size() << endl;
        if (clrs == nullptr) {
            cout << "Nothing to copy from source vector." << endl;
            return;
        }
        cout << "Copy to palette: ";
        for (size_t i = 0; i < clrs->size(); ++i) {
            palette.push_back((*clrs)[i]);
            cout << (*clrs)[i] << " ";
        }
        cout << "- size of vector " << palette.size() << endl;
    }
    friend int operator==(const Colors &lv, const Colors &rv);
    static string msg;
    string& operator[](unsigned int idx) {
        if (idx >= palette.size())
            return msg;
        return palette[idx];
    }
    vector<string> palette;
};

string Colors::msg = "Index of Colors out of range.";

int operator==(const Colors &lv, const Colors &rv)
{
    if (lv.palette.size() != rv.palette.size())
        return 0;
    for (size_t i = 0; i < lv.palette.size(); ++i)
        if (lv.palette[i] != rv.palette[i])
            return 0;
    return 1;
}

char* copy_c(char* s1, char* s2)
{
    while (*s1 != '\0')
        *s2++ = *s1++;
    *s2 = '\0';
    return s2;
}

int main()
{
    // Определение частот символов в строке.
    string source = "String with many chars.";
    const int maxChars = 256;
    int chars[maxChars];
    for (int i = 0; i < maxChars; ++i)
        chars[i] = 0;
    for (size_t i = 0; i < source.length(); ++i)
        chars[int(source[i])]++;
    cout << "All chars in string '" << source << "', Char[Counter]." << endl;
    for (int i = 0; i < maxChars; ++i)
        if (chars[i] > 0)
            cout << "'" << char(i) << "':" << chars[i] << " ";
    cout << endl;
    const unsigned short max_len = 256;
    char s1[max_len] = "alpha and ", s2[max_len] = "beta", s3[max_len];
    printf("Classic C copy array of chars: '%s' and '%s'.\n", s1, s2);
    char* ptr_1 = copy_c(s1, s3);
    if (ptr_1 != s3)
        printf("Copy first string: '%s'.\n", s3);
    char* ptr_2 = copy_c(s2, ptr_1);
    if (ptr_2 != ptr_1)
        printf("Copy second string: '%s'.\n", s3);
    if (ptr_1 == s3 || ptr_2 == ptr_1)
        printf("One or both strings were empty.\n");
    func_1('A');
    func_1(7);
    // Перегрузка функций, методов и операторов.
    char c1 = 'a';
    const char c2 = 'b';
    short i1 = 7;
    int i2 = 5;
    long long i3 = 3;
    func_2(&c1, i1);        // call to 'func_2' is ambigious
    func_2(&c2, i1);
    func_2(&c2, i2);        // implicit conversion
    func_2(&c1, i3);        // implicit conversion
    vector<string> rgb = { "Red", "Green", "Blue" };
    // Colors clr_1(3), clr_2(rgb);
    Colors clr_3(3, 'a'), clr_4(0, 'b', &rgb), clr_5(0, 'c', &rgb);
    cout << "Operator== for Colors (rgb == rgb): " << (clr_4 == clr_5) << endl;
    cout << "Operator== for Colors (rgb != rgb): " << (clr_4 == clr_3) << endl;
    cout << "Operator[] of Colors, RGB[0] - " << clr_4[0] << endl;
    cout << "Operator[] of Colors, RGB[5] - " << clr_4[5] << endl;
    return 0;
}
