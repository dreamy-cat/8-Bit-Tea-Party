#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Вещание на канале 8-Bit-Tea-Party.

/*   rerum: Написать программу, которая осуществляет считывание введенных данных,
     * определяет их тип и сохраняет в виде массива данных. Результатом работы программы
     * является вывод на экран размера массива и объем памяти занимаемый им.
     * Требования: Программа должна иметь примитивное «меню». После вывода результата,
     * программа должна передоложить повторный ввод пользователю.
     * Данные должны храниться в виде динамического массива.
     * Запрещена запись в незарезервированные участки памяти!
     *  Для второй, дополнение: Правила формирования входной последовательности
     * Последовательность символов разделенных символом «пробел».
     * По первой последовательности символов определяется тип данных в последующих.
     * В случае не соответствия определенного типа выводится сообщение об ошибке введенных данных,
     *  при возможности, данные преобразуются и программа продолжает своё выполнение.
*/

int getline(char s[], int lim)
{
    int c, i;
    for (i = 0; i < lim - 1 && (c = getchar()) != '\n'; ++i)
        s[i] = c;
    s[i] = '\0';
    return i;
}

int myisdigit(int c)
{
    return (c >= '0' && c <= '9');
}

int lower(int c)
{
    return (c >= 'A' && c <= 'Z') ? (c + ('a' - 'A')) : c;
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

int length(char s[])
{
    int i = 0;
    while (s[i] != '\0')
        ++i;
    return i;
}

int main()
{
#define MAXLINE 256
    char s[MAXLINE], word[MAXLINE];
    void* data[MAXLINE];
    int data_size = 0, memory = 0;
    enum data_type { Void, Char, Int, Double } types[MAXLINE];
    const char* type_names[] = { "Void", "Char", "Int", "Double" };
    printf("Save char, int and double to dynamic memory, maximum %d objects.\n", MAXLINE);
    printf("Maximum length string %d and empty to exit.\n", MAXLINE);
    printf("Size of types char %d, integer %d and double %d bytes.\n", sizeof(char), sizeof(int), sizeof(double));
    int i, j, k, l;
    while ((l = getline(s, MAXLINE)) != 0 && data_size < MAXLINE) {
        // Source "3.0 -5.3 3.1 text 123 82..."
        printf("Source length[%d]: %s\n", l, s);
        printf("Word:\tType:\tData:\tMemory:\n");
        for (i = 0; i < l; i += j + 1) {
            for (j = 0; s[i + j] != '\0' && s[i + j] != ' ' && s[i + j] != '\t'; ++j)
                word[j] = s[i + j];
            word[j] = '\0';
            // Word "-32.25"
            enum data_type wtype = Void;
            for (k = 0; k < j && wtype != Char && data_size < MAXLINE; ++k) {
                if ((k == 0 && j > 1) && (word[k] == '-' || word[k] == '+'))
                    k++;
                if (word[k] == '.' && wtype == Int)
                    wtype = Double;
                else if (myisdigit(word[k]) && wtype == Void)
                    wtype = Int;
                else if (!myisdigit(word[k]))
                    wtype = Char;
            }
            double d_write, d_verify;
            int i_write, i_verify;
            unsigned int word_len;
            switch (wtype) {
            case Double:
                d_write = my_atof(word);
                data[data_size] = malloc(sizeof(double));
                memory += sizeof(double);
                memcpy(data[data_size], &d_write, sizeof(double));
                d_verify = *((double*)data[data_size]);
                printf("%s\t%s\t%3.3f\t%d\n", word, type_names[wtype], d_verify, sizeof(double));
                types[data_size++] = wtype;
                break;
            case Int:
                i_write = my_atoi(word);
                data[data_size] = malloc(sizeof(int));
                memory += sizeof(int);
                memcpy(data[data_size], &i, sizeof(int));
                i_verify = *((int*)data[data_size]);
                printf("%s\t%s\t%d\t%d\n", word, type_names[wtype], i_verify, sizeof(int));
                types[data_size++] = wtype;
                break;
            case Char:
                word_len = (unsigned int)length(word) + 1;
                data[data_size] = malloc(sizeof(char) * word_len);
                memory += word_len;
                memcpy(data[data_size], &word, word_len);
                // char* sr = (char*)(data[data_size]);
                printf("%s\t%s\t%s\t%d\n", word, type_names[wtype], (char*)(data[data_size]), word_len);
                types[data_size++] = wtype;
                break;
            default:
                printf("'%s'\t%s\tIndex = %d\n", word, type_names[wtype], i);
            }
        }
        printf("Dynamic array has %d objects and use %d bytes of memory.\n\n", data_size, memory);
    }
    return 0;
}
