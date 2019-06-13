#include <stdio.h>
#include <stdlib.h>
#include <limits.h>
#include <float.h>

int power(int base, int n)
{
    int r = 1;
    for (int i = 1; i <= n; ++i)
        r = r * base;
    return r;
}

float celsius(int fahr)
{
    float r = (5.0 / 9.0) * (fahr - 32);
    return r;
}

int getline(char s[], int lim)
{
    int c, i;
    for (i = 0; i < lim - 1 && (c = getchar()) != '\n'; ++i)
        s[i] = c;
    s[i] = '\0';
    return i;
}

void copy(char to[], char from[])
{
    int i = 0;
    while ((to[i] = from[i]) != '\0')
        ++i;
}

int length(char s[])
{
    int i = 0;
    while (s[i] != '\0')
        ++i;
    return i;
}

void reverse(char s[])
{
    for (int i = 0, j = length(s) - 1; i < j; ++i, --j) {
        char c = s[i];
        s[i] = s[j];
        s[j] = c;
    }
}

void chapter_1()
{
    printf("Hello World!\n");
    printf("\nChapter 1.\n");
    printf("\nHorizontal tab:\t\tHello!\n");
    printf("Vertical tab:\vHello!\n");
    printf("Hello!\b.\n");
    printf("\tCarriage return.\rOk.\n");
    printf("New page.\f\n");
    printf("Sound beeper.\a\n");
    printf("Hex char 'A': \x41\n");
    printf("\nFahrenheit:\tCelsius:\n");
    float fahr, cels;
    int lower = 0, upper = 200, step = 20;
    fahr = lower;
    while (fahr <= upper) {
        cels = (5.0 / 9.0) * (fahr - 32.0);
        printf("%3.0f\t\t%.2f\n", fahr, cels);
        fahr = fahr + step;
    }
    printf("\nCelsius:\tFahrenheit:\n");
#define CelsMax 100
#define CelsMin 0
#define CelsStep 10
    lower = CelsMin;
    upper = CelsMax;
    step = CelsStep;
    cels = lower;
    while (cels <= CelsMax) {
        fahr = cels * (9.0 / 5.0) + 32.0;
        printf("%.2f\t\t%3.0f\n", cels, fahr);
        cels = cels + CelsStep;
    }
    printf("\nFahrenheit:\tCelsius, using operator for.\n");
    for (int fahr = 0; fahr <= 200; fahr = fahr + 20)
        printf("%d\t\t%.2f\n", fahr, (5.0 / 9.0) * (fahr - 32));
    printf("\nCelsius:\tFahrenheit, using operator for.\n");
    for (int cels = 100; cels >= 0; cels = cels - 10)
        printf("%d\t\t%.2f\n", cels, cels * (9.0 / 5.0) + 32.0);
    printf("\nStandard input/output stream, enter for exit, not EOF.\n");
    int c = 0;
    while ((c = getchar()) != '\n')
        putchar(c);
    printf("\nConstant EOF = %d and logic (c != EOF) is %d\n", EOF, (c != EOF));
#define IN 1
#define OUT 0
    printf("\nCount for chars, lines, spaces and tabs in stream, enter to exit.\n");
    int size = 0, lines = 0, spaces = 0, tabs = 0;
    int prev = 0, state = OUT, word = 0;
    while ((c = getchar()) != '\n') {
        ++size;
        if (c == '\n')
            ++lines;
        if (c == '\t')
            ++tabs;
        if (c == ' ')
            ++spaces;
        if (c == ' ' || c == '\t' || c == '\n') {
            if (state == IN)
                putchar('\n');
            state = OUT;
        }
        else if (state == OUT) {
            state = IN;
            ++word;
        }
        if (c == '\t') {
            putchar('\\');
            putchar('t');
        } else if (c == '\b') {
            putchar('\\');
            putchar('b');
        } else if (c == '\\') {
            putchar('\\');
            putchar('\\');
        } else if (c != ' ' || prev != ' ')
            putchar(c);
        prev = c;
    }
    printf("\nChars %d, lines %d, spaces %d, tabs %d\n", size, lines, spaces, tabs);
    printf("All words in stream %d\n", word);
    printf("\nDigits in stream.\n");
    int digits[10], chars[256], words[10];
    word = 0;
    for (int i = 0; i < 10; ++i) {
        digits[i] = 0;
        words[i] = 0;
    }
    for (int i = 0; i < 256; ++i)
        chars[i] = 0;
    while ((c = getchar()) != '\n') {
        if (c >= ' ' && c <= '~')
            ++chars[c];
        if (c >= '0' &&  c <= '9')
            ++digits[c - '0'];
        if (c == ' ' || c == '\t') {
            if (word > 0)
                ++words[--word];
            word = 0;
        } else if (word == 0)
            word = 1;
        if (word > 0) {
            ++word;
            putchar(c);
        }
    }
    if (word > 0)
        ++words[--word];
    printf("\nDigits frequency in stream: ");
    for (int i = 0; i < 10; ++i)
        if (digits[i] > 0)
            printf("%d[%d] ", i, digits[i]);
    printf("\nChars frequency in stream: ");
    for (int i = 0; i < 256; ++i)
        if (chars[i] > 0)
            printf("%c[%d] ", i, chars[i]);
    printf("\nWords frequency in stream, length: ");
    for (int i = 0; i < 10; ++i)
        if (words[i] > 0)
            printf("%d[%d] ", i, words[i]);
    printf("\n\nPower function(5,3) = %d\n", power(5,3));
    printf("\nFahrenheit:\tCelsius:\n");
    for (int fahr = 0; fahr <= 200; fahr = fahr + 20) {
        float cels = celsius(fahr);
        printf("%d\t\t%.2f\n", fahr, cels);
    }
#define MAXLINE 0x100
    char line[MAXLINE], longest[MAXLINE];
    int max = 0, len, longer = 5;
    printf("\nThe longest string in stream. Empty string to exit.\n");
    printf("Echo strings with length more than %d.\n", longer);
    printf("Spaces and tabs in tail of strings will be removed.\n");
    printf("All strings in stream reversed.\n");
    while ((len = getline(line, MAXLINE)) > 0) {
        reverse(line);
        int i = len;
        while ((i > 0) && (line[i - 1] == '\t' || line[i - 1] == ' '))
            line[--i] = '\0';
        if (i < len)
            printf("String '%s' has extra tabs and spaces in tail.\n", line);
        else
            printf("String has no extra tail.\n");
        len = i;
        if (len > longer)
            printf("String '%s' is longer than %d.\n", line, longer);
        if (len > max) {
            copy(longest, line);
            max = len;
        }
    }
    if (max > 0)
        printf("The longest string '%s' with length %d.\n", longest, max);
    else
        printf("No strings was found in stream.\n");
    int tabSize = 8, column = 0;
    printf("\nReplace all tabs in stream, with spaces.\n");
    printf("TABS:\t1:\t2:\t3:\t4:\t5:\n");
    while ((c = getchar()) != '\n') {
        if (c == '\t') {
            do  {
                putchar('.');
                ++column;
            } while (column % tabSize != 0);
        } else {
            putchar(c);
            ++column;
        }
    }
    putchar('\n');
    printf("\nReplace extra spaces with tabs and spaces.\n");
    printf("TABS:\t1:\t2:\t3:\t4:\t5:\n");
    column = 0;
    spaces = 0;
    while ((c = getchar()) != '\n') {
        if (c == '\t')
            column += tabSize - (column % tabSize);
        else
            ++column;
        if (c == ' ')
            ++spaces;
        else
            while (spaces > 0) {
                putchar(' ');
                --spaces;
            }
        if (spaces > 0) {
            if (column % tabSize == 0) {
                putchar('\t');
                spaces = 0;
            }
        } else
            putchar(c);
    }
    putchar('\n');
    longer = 16;
    printf("\nFormat long strings to %d chars.\n", longer);
    printf("TABS:\t1:\t2:\t3:\t4:\t5:\n");
    while ((len = getline(line, MAXLINE)) > 0) {
        int word = 0;
        column = 0;
        for (int i = 0; i <= length(line); ++i) {
            if (line[i] == '\t' || line[i] == ' ' || line[i] == '\0')
                while (word != i)
                    putchar(line[word++]);
            if (c == '\t')
                column += tabSize - (column % tabSize);
            else
                ++column;
            if (column > longer) {
                while ((word < i) && (line[word] == '\t' || line[word] == ' '))
                    ++word;
                putchar('\n');
                column = i - word + (column - longer);
            }
        }
        putchar('\n');
    }
    // This section need to test next task and various comments types.
    // Non of variables are using in tasks.
    char p = '\''; /**/
        /**/char s = '/';
        const char str[] = "Comment \" in str/ing /* not comment */, after chars // not comment too...";
        int ai;            // Comment with string and literal char c = 'r'; /* trying many lines*/
        /* ai = 0;         // Comment with many lines. And string "text". Literal ''.
         *                 /* Open comment, but not actual.
         * */   ai = 15;   // In the same line.
        char w2 = '\"';    /**/// Constant char with all comments.
        w2 = 'a';
    // End of section.
    printf("\nContent of the file main.c without comments, file must compile correctly.\n");
    FILE* main = fopen("main.c", "r");
    if (!main) {
        printf("File main.c does not exist. Check paths.\n");
        return;
    }
    int isString = 0, isSingleLine = 0, isManyLines = 0;
    const char brackets[] = "()[]{}";
    int bracketCounters[] = { 0, 0, 0, 0, 0, 0 };
    while ( (c = getc(main)) != EOF) {
        if ( !isSingleLine && !isManyLines ) {
            if ( c == '\\' ) {
                printf("%c", c);
                c = getc(main);
            } else {
                if ( !isString && ( c == '\'' || c == '"'))
                    isString = c;
                else
                    if ( isString == c )
                        isString = 0;
                if ( !isString ) {
                    if ( c == '/' ) {
                        c = getc(main);
                        if ( c == '*' )
                            isManyLines = 1;
                        else if ( c == '/' )
                            isSingleLine = 1;
                        else
                            printf("/");
                    }
                }
            }
            if ( !isSingleLine && !isManyLines ) {
                printf("%c", c);
                int i = 0;
                while (brackets[i] != '\0' && brackets[i] != c)
                    i++;
                if ( c == brackets[i] )
                    bracketCounters[i]++;
            }
        } else {
            if ( isSingleLine && c == '\n' ) {
                printf("\n");
                isSingleLine = 0;
            }
            if ( isManyLines && c == '*') {
                c = getc(main);
                if ( c == '/' )
                    isManyLines = 0;
            }
        }
    }
    printf("\nAll brackets in source file main.c: ");
    for (int i = 0; i < 6; i++)
        printf("'%c':%i ", brackets[i], bracketCounters[i]);
    printf("\n");
    fclose(main);
}

int myisdigit(int c);

int my_atoi(char s[])
{
    int i = 0, n = 0;
    while (s[i] != '-' && s[i] != '+' && !myisdigit(s[i]))
        i++;
    int sign = (s[i] == '-') ? -1 : 1;
    if (s[i] == '-' || s[i] == '+')
        i++;
    while (s[i] >= '0' && s[i] <= '9')
        n = n * 10 + (s[i++] - '0');
    return (n * sign);
}

int lower(int c)
{
    return (c >= 'A' && c <= 'Z') ? (c + ('a' - 'A')) : c;
}

int htoi(char s[])
{
    int n = 0;
    for (int i = 0; s[i] != '\0'; ++i) {
        char c = lower(s[i]);
        if (c >= '0' && c <= '9')
            n = n * 16 + (c - '0');
        else if (c >= 'a' && c <= 'f')
            n = n * 16 + (c - 'a' + 10);
    }
    return n;
}

void squeeze(char s1[], char s2[])
{
    int i, j, k;
    for (i = 0, j = 0; s1[i] != '\0'; ++i) {
        k = 0;
        while (s2[k] != '\0' && s2[k] != s1[i])
            ++k;
        if (s2[k] == '\0')
            s1[j++] = s1[i];
    }
    s1[j] = '\0';
}

int any(char s1[], char s2[])
{
    for (int i = 0; s1[i] != '\0'; ++i) {
        int j = 0;
        while (s2[j] != '\0' && s2[j] != s1[i])
            ++j;
        if (s1[i] == s2[j])
            return i;
    }
    return -1;
}

unsigned char getbits(unsigned char x, int p, int n)
{
    return (x >> (p + 1 + n)) & ~(0xFF << n);
}

void printbinary(unsigned char byte, const char message[])
{
    char binary[CHAR_BIT + 1];
    const int tabSize = 8;
    for (int i = 0; i < CHAR_BIT; ++i)
        if ((0x01 << i) & byte)
            binary[CHAR_BIT - (i + 1)] = '1';
        else
            binary[CHAR_BIT - (i + 1)] = '0';
    binary[CHAR_BIT] = '\0';
    int i = 0;
    while (message[i] != '\0')
        ++i;
    if (i <= tabSize)
        printf("%s\t\t%d\t%s\n", message, byte, binary);
    else
        printf("%s\t%d\t%s\n", message, byte, binary);
}

int bitcount(unsigned char x)
{
    int b;
    for (b = 0; x > 0; ++b)
        x &= (x - 1);
    return b;
}

void chapter_2()
{
    printf("Chapter 2.\n");
    printf("\nAll basic types and parameters.\n");
    printf("Type:\t\tBits[calc]:\tMin:\t\tMax:\n");
    int bits = 0;
    for (char c = 1; c > 0; ++bits)
        c = c * 2;
    printf("Signed char\t%d[%d]\t\t%d\t\t%d\n", CHAR_BIT, bits, CHAR_MIN, CHAR_MAX);
    bits = 0;
    for (unsigned char c = 1; c > 0; ++bits)
        c = c * 2;
    printf("Unsigned char\t%d[%d]\t\t%d\t\t%d\n", CHAR_BIT, bits, 0, UCHAR_MAX);
    bits = 0;
    for (short int i = 1; i > 0; ++bits)
        i = i * 2;
    printf("Signed short\t%d[%d]\t\t%d\t\t%d\n", bits, bits, SHRT_MIN, SHRT_MAX);
    bits = 0;
    for (unsigned short int i = 1; i > 0; ++bits)
        i = i * 2;
    printf("Unsigned short\t%d[%d]\t\t%d\t\t%d\n", bits, bits, 0, USHRT_MAX);
    printf("Signed int\t%d[%d]\t\t%d\t%d\n", sizeof(int) * CHAR_BIT, 31, INT_MIN, INT_MAX);
    printf("Unsigned int\t%d[%d]\t\t%d\t\t%u\n", sizeof(int) * CHAR_BIT, 32, 0, UINT_MAX);
    printf("Signed long\t%d[%d]\t\t%ld\t%ld\n", sizeof(long) * CHAR_BIT, 31, LONG_MIN, LONG_MAX);
    printf("Unsigned long\t%d[%d]\t\t%d\t\t%lu\n", sizeof(long) * CHAR_BIT, 32, 0, ULONG_MAX);
    printf("\nFloating:\tBits:\tDigits:\tMant:\tMinExp:\tMaxExp:\tMin:\tMax:\n");
    printf("Float\t\t%d\t%d\t%d\t%d\t%d\t%2.2g%2.2g\n",
           sizeof(float) * CHAR_BIT, FLT_DIG, FLT_MANT_DIG, FLT_MIN_EXP, FLT_MAX_EXP, FLT_MIN, FLT_MAX);
    printf("Double\t\t%d\t%d\t%d\t%d\t%d\t%2.2g%2.2g\n",
           sizeof(double) * CHAR_BIT, DBL_DIG, DBL_MANT_DIG, DBL_MIN_EXP, DBL_MAX_EXP, DBL_MIN, DBL_MAX);
    printf("Long double\t%d\t%d\t%d\t%d\t%d\t%2.2f%2.2f\n",
           sizeof(long double) * CHAR_BIT, LDBL_DIG, LDBL_MANT_DIG, LDBL_MIN_EXP, LDBL_MAX_EXP, LDBL_MIN, LDBL_MAX);
    enum colors { red, green, blue };
    printf("\nEnumeration example. Red %d, green %d and blue %d.\n", red, green, blue);
    char line[MAXLINE];
    const int limit = 5;
    printf("\nEnter simple string, limit %d chars.\n", limit);
    for (int i = 0, c = ' '; c != '\0'; ++i) {
        c = getchar();
        if (c == '\n')
            c = '\0';
        else if (i == limit)
            c = '\0';
        else if (c == EOF)
            c = '\0';
        line[i] = c;
    }
    printf("String was '%s'.\n", line);
    char numstr[] = "15";
    printf("\nString '%s' to intger %d.\n", numstr, my_atoi(numstr));
    int left = 3, right = 5;
    printf("Values of simple logic operators 'if (%d < %d), integer %d, if (%d == 0), integer %d'.\n",
           left, right, (left > right), right, (right == 0));
    char hexstr[] = "0x1F";
    printf("\nString '%s' to integer %d.\n", hexstr, htoi(hexstr));
    char str1[] = "abc def eg", str2[] = "eg";
    printf("\nDelete extra chars from string '%s'.\n", str1);
    squeeze(str1, str2);
    printf("String without chars '%s', '%s'.\n", str2, str1);
    char str3[] = "e ";
    printf("\nFinding any char of '%s', in string '%s'.\n", str3, str1);
    int pos = any(str1, str3);
    if (pos != -1)
        printf("Index of first char %d.\n", pos);
    else
        printf("No chars was found.\n");
    unsigned char x = 171, y = 173;
    int n = 4, p = 3;
    printf("\nCopy N %d lower bits from Y %d to X %d to P %d index.\n", n, y, x, p);
    printf("Step:\t\tValue:\tBinary:\n");
    unsigned char mask = 0xFF >> (CHAR_BIT - n);
    printbinary(mask, "Mask for Y");
    printbinary(y, "Y");
    y = y & mask;
    printbinary(y, "Y and Mask");
    y = y << p;
    printbinary(y, "Y roll left");
    printbinary(x, "X");
    mask = ~((0xFF >> (CHAR_BIT - n)) << p);
    printbinary(mask, "Mask for X");
    x = x & mask;
    printbinary(x, "X and mask");
    x = x | y;
    printbinary(x, "X or Y");
    printf("\nInvert N %d bits in X %d from P %d index.\n", n, x, p);
    printf("Step:\t\tValue:\tBinary:\n");
    printbinary(x, "X");
    mask = (0xFF >> (CHAR_BIT - n)) << p;
    printbinary(mask, "Mask for X");
    x = x ^ mask;
    printbinary(x, "X xor mask");
    printf("\nCycle roll to the right N %d bits from X %d.\n", n, x);
    printf("Step:\t\tValue:\tBinary:\n");
    printbinary(x, "X");
    mask = (0xFF >> (CHAR_BIT - n));
    printbinary(mask, "Mask for X");
    unsigned char tail = x & mask;
    printbinary(tail, "Tail for X");
    x = x >> n;
    printbinary(x, "X roll right");
    x = x | (tail << (CHAR_BIT - n));
    printbinary(x, "X or tail");
    printf("\nBit counter in X %d, %d.\n", x, bitcount(x));
    char str4[] = "A bc hd D EG";
    printf("\nOriginal string '%s', ", str4);
    for (int i = 0; str4[i] != '\0'; ++i)
        str4[i] = lower(str4[i]);
    printf("with lower chars '%s'.\n", str4);
}

int binsearch(int x, int v[], int n)
{
    int low = 0, high = n - 1;
    int mid = (low + high) / 2;
    while (low <= high && v[mid] != x) {
        if (x < v[mid])
            high = mid - 1;
        else
            low = mid + 1;
        mid = (low + high) / 2;
    }
    if (v[mid] == x)
        return mid;
    else
        return -1;
}

void escape(char s[], char t[])
{
    int j = 0;
    for (int i = 0; t[i] != '\0'; ++i) {
        switch (t[i]) {
        case '\t':
            s[j++] = '\\';
            s[j++] = 't';
            break;
        case '\n':
            s[j++] = '\\';
            s[j++] = 'n';
            break;
        default:
            s[j++] = t[i];
            break;
        }
    }
    s[j] = '\0';
}

void unescape(char s[], char t[])
{
    int j = 0;
    for (int i = 0; t[i] != '\0'; ++i)
        if (t[i] == '\\' && t[i + 1] != '\0')
            switch (t[i+1]) {
            case 't':
                s[j++] = '\t';
                ++i;
                break;
            case 'n':
                s[j++] = '\n';
                ++i;
            default:
                break;
            }
        else
            s[j++] = t[i];
    s[j] = '\0';
}

int myatois(char s[])
{
    int i = 0, n, sign = (s[i] == '-') ? -1 : 1;
    if (s[i] == '+' || s[i] == '-')
        ++i;
    for (n = 0; (s[i] >= '0' && s[i] <= '9'); ++i)
        n = 10 * n + (s[i] - '0');
    return sign * n;
}

int myisalpha(int c)
{
    return (lower(c) >= 'a' && lower(c) <= 'z');
}

int myisdigit(int c)
{
    return (c >= '0' && c <= '9');
}

void expand(char s1[], char s2[])
{
    int j = 0;
    for (int i = 0; s1[i] != '\0'; ++i) {
        char c = s1[i], c1 = s1[i + 1], c2 = s1[i + 2];
        if (c1 == '-' && c2 >= c && ((myisalpha(c) && myisalpha(c2)) || (myisdigit(c) && myisdigit(c2)))) {
            c1 = c;
            while (c < c2)
                s2[j++] = s1[i] + (c++ - c1);
            ++i;
        } else
            s2[j++] = s1[i];
    }
    s2[j] = '\0';
}

void myitoa(int n, char s[])
{
    int i = 0, sign = (n < 0) ? -1 : 1;
    do {
        s[i++] = (n % 10) * sign + '0';
    } while ((n /= 10) * sign > 0);
    if (sign == -1)
        s[i++] = '-';
    s[i] = '\0';
    reverse(s);
}

void itob(int n, char s[], int b)
{
    if (b < 2 || b > 16)
        return;
    char digits[] = "0123456789ABCDEF";
    int i = 0, sign = (n < 0) ? -1 : 1;
    do {
        s[i++] = digits[(n * sign) % b];
    } while ((n /= b) * sign > 0);
    if (sign == -1)
        s[i++] = '-';
    s[i] = '\0';
    reverse(s);
}

void myitoafield(int n, char s[], int f)
{
    int i = f - 1, sign = (n < 0) ? -1 : 1;
    if (f < 1 + (sign == -1))
        return;
    do {
        s[i--] = (n % 10) * sign + '0';
    } while ((n /= 10) * sign > 0 &&  i >= (sign == -1));
    if (sign < 0)
        s[i--] = '-';
    while (i >= 0)
        s[i--] = ' ';
    s[f] = '\0';
}

void chapter_3()
{
    printf("Chapter 3.\n");
    int v[] = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 };
    printf("\nBinary search in V[0..9], value %d, position %d.\n", 7, binsearch(7, v, 10));
    printf("Binary search in V[0..9], value %d, position %d.\n", 0, binsearch(0, v, 10));
    printf("Binary search in V[0..9], value %d, position %d.\n", 9, binsearch(9, v, 10));
    char s1[] = "\t abc \t\tdef\ngh\t\n", s2[MAXLINE], s3[MAXLINE];
    printf("\nString with all espace sequences '%s'.\n", s1);
    escape(s2, s1);
    printf("String with all escape sequences '%s'.\n", s2);
    unescape(s3, s2);
    printf("String after unescape sequences '%s'.\n", s3);
    char s4[] = "53";
    printf("\nSigned atoi function string %s, to integer %d.\n", s4, myatois(s4));
    char s5[] = "-- f-d b-b A-D a-c-f -pre post- 3-7 1-3-5 --";
    printf("\nExpanding string '%s'.\n", s5);
    expand(s5, s2);
    printf("Expanded string '%s'.\n", s2);
    int i1 = INT_MIN;
    myitoa(i1, s2);
    printf("\nInteger %d to string '%s'.\n", i1, s2);
    int i2 = -173;
    itob(i2, s2, 10);
    printf("\nInteger %d, in decimal '%s'.\n", i2, s2);
    itob(i2, s2, 2);
    printf("Integer %d, in binary '%s'.\n", i2, s2);
    itob(i2, s2, 8);
    printf("Integer %d, in oct '%s'.\n", i2, s2);
    itob(i2, s2, 16);
    printf("Integer %d, in hex '%s'.\n", i2, s2);
    int i3 = -235;
    myitoafield(i3, s2, 8);
    printf("\nInteger %d to string '%s', field %d.\n", i3, s2, 8);
    myitoafield(i3, s2, 4);
    printf("Integer %d to string '%s', field %d.\n", i3, s2, 4);
    char s6[] = "3 tabs and 2 spaces in tail \t\t \t";
    printf("\nString with extra tail '%s'.\n", s6);
    int i;
    for (i = length(s6) - 1; i >= 0; --i)
        if (s6[i] != '\t' && s6[i] != ' ' && s6[i] != '\n')
            break;
    s6[++i] = '\0';
    printf("String without extra tail '%s'.\n", s6);
    printf("\nTesting operator 'goto'.\n");
    int i4 = 5;
    if (i4 == 7)
        goto label1;
    printf("Operand before 'goto' operator.\n");
label1:
    printf("Operand after 'goto' operator, label 'label1'.\n");
}

int str_index(char source[], char search[]);

int str_index(char src[], char str[])
{
    int i, j, k;
    for (i = 0; src[i] != '\0'; ++i) {
        for (j = i, k = 0; str[k] != '\0' && str[k] == src[j]; j++, k++)
            ;
        if (k > 0 && str[k] == '\0')
            return i;
    }
    return -1;
}

double my_atof(char s[])
{
    double value, power, base = 10;
    int i, sign;
    for (i = 0; s[i] != '\0' && !myisdigit(s[i]) && s[i] != '+' && s[i] != '-'; i++)
        ;
    sign = (s[i] == '-') ? -1 : 1;
    if (s[i] == '+' || s[i] == '-')
        i++;
    for (value = 0.0; myisdigit(s[i]); ++i)
        value = base * value + (s[i] - '0');
    if (s[i] == '.')
        i++;
    for (power = 1.0; myisdigit(s[i]); i++) {
        value = base * value + (s[i] - '0');
        power *= base;
    }
    if (lower(s[i]) == 'e' && (s[i+1] == '-' || s[i+1] == '+')) {
        double exp = 0.0, multiplier;
        multiplier = (s[i+1] == '+') ? base : (1.0 / base);
        i += 2;
        while (myisdigit(s[i]))
            exp = exp * base + (s[i++] - '0');
        while (exp > 0) {
            power /= multiplier;
            exp -= 1.0;
        }
    }
    return sign * value / power;
}

static int stack_calc[MAXLINE];
static int sp_calc = 0;

void push_calc(int i)
{
    if (sp_calc < MAXLINE)
        stack_calc[sp_calc++] = i;
    else
        printf("Stack is full, no more push.\n");
}

int pop_calc()
{
    if (sp_calc > 0)
        return stack_calc[--sp_calc];
    else {
        printf("No values in stack.");
        return -1;
    }
}

void chapter_4()
{
    printf("Chapter 4.\n");
    /*
    char line[MAXLINE], search[] = "ab";
    int i1 = 0;
    printf("Enter strings with possible substring '%s' or empty to exit.\n", search);
    while (getline(line, MAXLINE) > 0)
        if (str_index(line, search) >= 0) {
            printf("String with '%s' substring - %s.\n", search, line);
            ++i1;
        } else
            printf("String does not contains substring '%s'.\n", search);
    printf("All findings %d.\n", i1);
    printf("\nConvert strings to double.\n");
    char num1[] = "0.0", num2[] = "-0.15", num3[] = "+100.0";
    char num4[] = "10.5e+2", num5[] = "-5.1E-1";
    printf("%s\t%0.3f\n", num1, my_atof(num1));
    printf("%s\t%0.3f\n", num2, my_atof(num2));
    printf("%s\t%0.3f\n", num3, my_atof(num3));
    printf("%s\t%0.3f\n", num4, my_atof(num4));
    printf("%s\t%0.3f\n", num5, my_atof(num5));
    */

    printf("Calculator with reverse polish notation.\n");
    printf("Empty string for exit: ");
    char s[MAXLINE], n[MAXLINE];
    while ((getline(s, MAXLINE)) != 0) {
        int i, j, r_op;
        printf("Index:\tStack:\tOperator:\n");
        for (i = 0; s[i] != '\0'; i++) {
            printf("\n%d\t", i);
            for (j = 0; j < sp_calc; j++)
                printf("%d ", stack_calc[j]);
            switch (s[i]) {
            case '+':
                printf("\t+");
                push_calc(pop_calc() + pop_calc());
                break;
            case '-':
                printf("\t-");
                r_op = pop_calc();
                push_calc(pop_calc() - r_op);
                break;
            case '*':
                printf("\t*");
                push_calc(pop_calc() * pop_calc());
                break;
            case '/':
                printf("\t/");
                r_op = pop_calc();
                push_calc(pop_calc() / r_op);
                break;
            default:
                for (j = 0; myisdigit(s[i]); n[j++] = s[i++]);
                if (j > 0) {
                    n[j] = '\0';
                    int d = my_atoi(n);
                    push_calc(d);
                    printf("[%d]", d);
                    break;
                }
            }
        }
        printf("\nResult: %d", pop_calc());
    }
}

int main()
{
    chapter_4();
    return 0;
}
