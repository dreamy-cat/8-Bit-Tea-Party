#include <stdio.h>
#include <stdlib.h>

 // Используется GCC 8.3.0, 32 bits.
 // Исходный файл данных: source.txt, находящийся в текущей директории.
 // Код следующей строки: 0x0A0D, пробелов в конце строк нет.
 // Содержимое тестового файла:
 /* 5 8 12
 *  7 3 0
 */

int main(void)
{
    printf("Chapter 13, theory. File Input/Output.\n");
    printf("Using char '>' for command output to file.\n");
    printf("New line can be Unix \\n, DOS/WIN \\r\\n or Mac \\r.\n");
#define STRING_MAX 256
    char s[STRING_MAX];
    int i, c;
    printf("Input some text, using 'getchar': ");
    i = 0;
    while ((c = getchar()) != '\n' && i < STRING_MAX)
        s[i++] = c;
    s[i] = '\0';
    printf("Text and keyboard, using 'putchar': ");
    for (i = 0; s[i] != '\0'; ++i)
        putchar(s[i]);
    printf("\nInput text, using 'scanf': ");
    scanf("%s", s);
    printf("Text using 'puts': ");
    puts(s);    // printf("%s", s);
    FILE* src = fopen("source.txt", "rb");
    FILE* dst = fopen("destination.txt", "rwb");
    if (src == NULL)
        printf("File 'source.txt' not found or other error.\n");
    else
        printf("File 'source.txt' founded and opened in read-only mode.\n");
    if (dst == NULL)
        printf("Error creating file 'destination.txt'.\n");
    else
        printf("File 'destination.txt' opened, only write mode.\n");
    printf("Source file data, searching min and max values.\n");
    int is_number = 0, counter = 0, offset = 0, num_len, max = 0, min = 100;
    while ((c = getc(src)) != EOF) {
        offset = ftell(src);
        printf("Char readed from file, '%c' and code %d, offset %d and counter %d.\n",
               c, c, offset, counter);
        if (!is_number && (c >= '0' && c <= '9' || c == '-' || c == '+')) {
            is_number = 1;      // Or use while();
            num_len = 0;
            printf("Number founded at %d position.\n", offset);
        }
        if (is_number && !(c >= '0' && c <= '9' || c == '-' || c == '+')) {
            is_number = 0;
            printf("Number ended at %d position.\n", offset);
            if (num_len) {
                s[num_len] = '\0';
                int num = atoi(s);  // itoa
                printf("Number in buffer: '%s', length %d and integer %d.\n",
                       s, num_len, num);
                if (num < min)
                    min = num;
                if (num > max)
                    max = num;
                printf("Min = %d, max = %d.\n", min, max);
                num_len = 0;
            }
        }
        if (is_number)
            s[num_len++] = c;
        counter++;
    }
    printf("Writing minimum %d and maximum %d to destination file.\n", min, max);
    itoa(min, s, 10);
    i = 0;
    while (s[i] != '\0')
        putc(s[i++], dst);
    putc('\n', dst);
    itoa(max, s, 10);
    fputs(s, dst);
    printf("\nSeek source file to start and output, using functions 'fscanf' and 'fprintf'.\n");
    fseek(src, 0l, SEEK_SET);    // SEEK_CUR, SEEK_END.
    // Дополнительные функции для позиционирования в больших файлах.
    // fsetpos64(fpos_t);
    while ((fscanf(src, "%s", s)) == 1)
        printf("'%s'\n", s);
    printf("\nReading file in reverse, using 'fseek'.\n");
    offset = 0;
    while ((fseek(src, -offset, SEEK_END)) == 0) {
        c = getc(src);
        putchar(c);
        ++offset;
    }
    printf("\n\nMaximum opened files %u, temporary files %u, buffer size %u bytes.\n",
           FOPEN_MAX, TMP_MAX, BUFSIZ);
    printf("Using 'ungetc' function for keyboard: ");
    while ((c = getc(stdin)) != '\n') {
        printf("Char '%c' from input.\n", c);
        ungetc(c, stdin);
        c = getc(stdin);
        printf("Char '%c' from input, after ungetc.\n", c);
    }
    c = setvbuf(src, s, _IOFBF, STRING_MAX);
    printf("\nChange buffer for source file, code %d.\n", c);
    c = setvbuf(src, NULL, _IOFBF, 512);
    printf("\nReset buffer for source file, code %d.\n", c);
    printf("\nBinary and text code to file, %d = '%c'.\n", 33, 33);
    printf("\nWrite some binary data to file and verify: ");
    fseek(dst, 0, SEEK_SET);
    unsigned char data[STRING_MAX];
    const int data_size = 5;
    for (i = 0; i < data_size; ++i) {
        data[i] = '0' + rand() % 10;
        printf("%d(%c) ", data[i], data[i]);
    }
    c = fwrite(data, sizeof(unsigned char), data_size, dst);
    for (i = 0; i < data_size; ++i)
        data[i] = -1;
    fflush(dst);
    printf("\nBytes trying to save %d and actual bytes written is %d.\n", data_size, c);
    printf("Verify and read data, ");
    fseek(dst, 0, SEEK_SET);
    clearerr(dst);
    c = fread(data, sizeof(char), data_size, dst);
    printf("actual bytes read is %d: ", c);
    for (i = 0; i < data_size; ++i)
        printf("%d(%c) ", data[i], data[i]);
    c = ferror(dst);
    printf("\nLast code error is %d.\n", c);
    c = feof(dst);
    printf("Is EOF in destination file, %d.\n", c);
    if (fclose(src))
        printf("Something goes wrong with source file.\n");
    fflush(dst);
    if (fclose(dst))
        printf("Something goes wrong with destination file.\n");
    return 0;
}
