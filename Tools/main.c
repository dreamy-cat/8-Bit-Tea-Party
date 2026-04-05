// 8-Бит Чаепитие! Лицензия: Creative Commons.
// Поддерживаемые платформы: ZX Spectrum; IBM PC: CGA, VGA.
// Инструменты: GCC 13.1, С11, CMake 3.5.
// Авторы: Даниил Потапов (alphatea48@proton.me) [1];
//         Александр Серов (alexander.serov@protonmail.com) [2].
// Описание: наш дополнительный инструментарий для ретро-платформ.

// Набор утилит для работы с ретро-платформами, функции организованы по файлам:
// main.c       этот файл с основным меню;
// palettes.c   функции работы с палитрой, еще много задач для реализации.
// sprites.c    загрузка и преобразования спрайтов - обновить на Си;

/* Общие задачи для следующего обновления:
 * - оформить базовое меню самой программы, всё сразу или по модулям отдельно;
 * - дополнительное тестирование палитр и вывод общей информации;
 * - обновить базовую работу со спрайтами, изменить структуру;
 * - общий функционал, флаги и константы вынести в текущий файл.
 * - потестировать на обновленный стандарт и возможно для ДОС. :)
 * */

#include <stdio.h>

// Модули и функции в отдельных файлах по группам.
void palettes(void);
void sprites(void);

int main(void)
{   // Основая программа и меню для взаимодействия, аргументы не требуется.
    printf("Tools for retro platforms ZX Spectrum and IBM PC by 8-Bit "
           "Tea party!\nLicense: Creative Commons (CC).\n"
           "Compile using CMake 3.5, GCC 13.1 x64, standard C11.\n"
           "Authors: Daniil Potapov, alphatea48@proton.me;\n"
           "         Alexander Serov, alexander.serov@protonmail.com.\n\n");
    printf("Create main menu for tool in next version, see draft in this source file, "
           "direct call of functions available: 'void palettes(void)' and 'void sprites(void)'.\n\n");
    palettes();
    // sprites();
    return 0;
}

// Краткая история кода и вещаний на канале.
// 05.04.26 [1,2]: .
// 01.04.26 [1,2]: Сохранение палитры в файл и функция конвертации, оттенки серого.
// 31.03.26 [1,2]: Добавление платформы файла и загрузка с конвертацией по типу.
// 25.03.26 [1,2]: Улучшение струкутуры программы и функций проверки цветов и палитры.
// 08.03.26 [1,2]: Загрузка палитры из файла(ов) .bmp и функции записи и чтения цвета.
// 05.03.26 [1,2]: Добарабатываем базовые фукнции и сценарии отладки.
// 07.02.26 [1,2]: Генерация палитры VGA и экспортирование в нашу демку.
// 05.02.26 [1,2]: Функции создания, удлаения и вывода информции о палитре.
// 03.02.26 [1,2]: Первый набросок черновика для утилиты и обсуждения платформ.

/* char key = ' ';
    uint16_t sz_input;
    int plat_choice;
    while (key != 'X') {
        printf("Part 14. Structures and Other Data Forms;\n");
        if (palette != NULL) {
            const char* plat_name = "Unknown";
            if (palette_platform & VGA) plat_name = "VGA (256)";
            else if (palette_platform & IBM_PC) plat_name = "IBM PC (16)";
            else if (palette_platform & CGA) plat_name = "CGA (16)";
            else if (palette_platform & ZX_Spectrum) plat_name = "ZX Spectrum (16)";
            printf(" STATUS: active\n");
            printf(" Platform: %-20s Size: %hu colors\n", plat_name, palette_size);
            printf(" Memory  : %-20u File: %s\n", (uint16_t)(palette_size * sizeof(struct color)),
                   filename[0] ? filename : "Not set");
        } else {
            printf(" Status: empty (Palette not created)\n");
        }
        printf("--------------------------------------------------\n");
        printf("[1] Create NEW Palette (Empty)        [6] Save to BINARY/RAW\n");
        printf("[2] Create NEW Palette (Default)      [7] Load from BINARY/BMP\n");
        printf("[3] View Palette Table (info)         [8] Export to TEXT Table\n");
        printf("[4] Modify Color at Index (set)       [9] Import from TEXT Table\n");
        printf("[5] View Color Details (info_color)   [0] Destroy Palette\n");
        printf("\n[F] Set Global Filename\n");
        printf("[X] Exit Program\n");
        printf("\nChoose action: ");
        key = toupper(getchar());
        while (getchar() != '\n');
        switch (key) {
        case '1':
        case '2': {
            if (palette != NULL)
                destroy();
            printf("\nSelect Platform:\n");
            printf("1: VGA (max 256)\n2: CGA (max 16)\n3: IBM_PC (max 16)\n4: ZX Spectrum (max 16)\n");
            printf("Your choice: ");
            scanf_s("%d", &plat_choice);
            while (getchar() != '\n');
            enum flags p_flag = 0;
            uint16_t limit = 0;
            if (plat_choice == 1)      {
                p_flag = VGA;
                limit = vga_max_size; }
            else if (plat_choice == 2) {
                p_flag = CGA;
                limit = cga_colors_max; }
            else if (plat_choice == 3) {
                p_flag = IBM_PC;
                limit = cga_colors_max; }
            else if (plat_choice == 4) {
                p_flag = ZX_Spectrum;
                limit = zx_colors; }
            else {
                printf("Error: Invalid platform choice!\n");
                break;
            }
            printf("Enter size for this platform (1-%hu): ", limit);
            if (scanf_s("%hu", &sz_input) != 1) {
                printf("Error: Invalid number input!\n");
                while (getchar() != '\n');
                break;
            }
            while (getchar() != '\n')
                ;
            if (sz_input > limit) {
                printf("Error: Size %hu exceeds platform limit %hu!\n", sz_input, limit);
            } else {
                if (key == '2') p_flag |= is_default;
                create(sz_input, p_flag);
            }
            break;
        }
        case '3':
            info();
            break;
        case '4': {
            if (verify() == error)
                break;
            uint16_t idx;
            printf("\nEnter index to modify (0-%hu): ", palette_size - 1);
            scanf_s("%hu", &idx);
            if (palette_platform & ZX_Spectrum) {
                struct zx_data z;
                uint16_t ink, pap, brt;
                printf("Enter Ink(0-7) Paper(0-7) Bright(0-1): ");
                scanf_s("%u %u %u", &ink, &pap, &brt);
                z.ink = ink; z.paper = pap; z.bright = brt; z.flash = 0;
                set_color(&z, idx, ZX_Spectrum);
            } else {
                struct ibm_color v;
                uint16_t r, g, b;
                printf("Enter R G B (0-255): ");
                scanf_s("%u %u %u", &r, &g, &b);
                v.red = r; v.green = g; v.blue = b;
                set_color(&v, idx, palette_platform & (VGA|CGA|IBM_PC));
            }
            while (getchar() != '\n');
            break;
        }
        case '5': {
            uint16_t idx;
            printf("\nEnter index: ");
            scanf_s("%hu", &idx);
            while (getchar() != '\n');
            if (palette && idx < palette_size)
                info_color(&((struct color*)palette)[idx], palette_platform);
            break;
        }
        case '6':
            if (filename[0]) save(filename, NULL, palette_platform);
            else printf("Error: Filename not set. Press 'F'.\n");
            break;
        case '7': {
            if (filename[0]) {
                printf("Is it BMP? (1:Yes, 0:Raw): ");
                int is_bmp; scanf_s("%d", &is_bmp);
                while (getchar() != '\n');
                load(filename, NULL, is_bmp ? (palette_platform | BMP) : palette_platform);
            } else printf("Error: Filename not set.\n");
            break;
        }
        case '8':
            export_to_text();
            break;
        case '9':
            import_from_text();
            break;
        case '0':
            destroy();
            break;
        case 'F':
            printf("\nEnter new filename: ");
            scanf_s("%s", filename, (uint16_t)sizeof(filename));
            while (getchar() != '\n');
            break;
        case 'X':
            printf("Respect paid. Closing utility\n");
            destroy();
            break;
        default:
            printf("Invalid action '%c'.\n", key);
        }
        if (key != 'X') {
            printf("\nPress Enter to back");
            while (getchar() != '\n');
        }
    }
    */
