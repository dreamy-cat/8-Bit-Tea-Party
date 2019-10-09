#include <stdio.h>
#include <limits.h>

// Вещание на канале 8-Bit-Tea-Party.

/*
    rerum: Написать программу, которая проверят является ли введенное значение факториалом,
    если это так, то вывести факториалом какого числа. Программа должна иметь примитивное «меню».
    Пользователю должно быть предложено: Нахождение факториала рекурсивным методом.
    Нахождение факториала не рекурсивным методом. Выход из программы.
    После вывода результата перед завершение программа должна передоложить повторный ввод пользователю.
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

unsigned int is_factorial_mult(unsigned int n)
{
    if (n <= 1)
        return 1;
    unsigned int d = 1, s = 1;
    while (s < n) {
        d++;
        s = s * d;
        printf("Number %u and factorial %u.\n", s, d);
    }
    if(s == n)
        return d;
    return 0;
}

unsigned int is_factorial_cycles(unsigned int n)
{
    unsigned int m = 2;
    while (n > 1 &&  n % m == 0) {
        n /= m++;
        printf("Number %u and delimeter %u.\n", n, m);
    }
    if (n == 1)
        return --m;
    return 0;
}

unsigned int is_factorial_recursion(unsigned int n, unsigned int m)
{
    if (n == 1)
        return --m;
    if (n % m != 0)
        return 0;
    n = n / m;
    m++;
    printf("Number %u and delimiter %u.\n", n, m);
    return is_factorial_recursion(n, m);
}

int main()
{
#define MAXLINE 256
    printf("Unsinged integer is %u bytes and maxiumum value is %u.\n", sizeof(unsigned int), UINT_MAX);
    char s[MAXLINE];
    printf("Enter number that can factorial of any number in [0..12], empty string to exit.\n");
    while (getline(s, MAXLINE)) {
        unsigned int n = (unsigned int)my_atoi(s);
        if (n > 1 && n <= 479001600) {
            printf("Finding factorial of N = %u, using multiplier.\n", n);
            printf("N = %u is factorial of %u.\n", n, is_factorial_mult(n));
            printf("Finding factorial of N = %u, using delemiter.\n", n);
            printf("N = %u is factorial of %u.\n", n, is_factorial_cycles(n));
            printf("Finding factorial of N = %u, using recursion.\n", n);
            printf("N = %u is factorial of %u.\n", n, is_factorial_recursion(n, 1));
        } else
            printf("Factorial is 1.\n");
    }
    return 0;
}
