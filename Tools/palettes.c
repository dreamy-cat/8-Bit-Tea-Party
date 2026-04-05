// 8-Бит Чаепитие! Лицензия: Creative Commons.
// Поддерживаемые платформы: ZX Spectrum; IBM PC: CGA, VGA.
// Инструменты: GCC 13.1, С11, CMake 3.5.
// Авторы: Даниил Потапов (alphatea48@proton.me) [1];
//         Александр Серов (alexander.serov@protonmail.com) [2].
// Описание: функции работы с палитрой ретро-платформ.

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stddef.h>
#include <string.h>
#include <math.h>

/*  Утилита для работы с индексной или прямой палитрой цветов для  ретро-платформ и/или файлов.
 * Активна строго одна палитра в динамеической памяти, но возможна расширяемость до предела 64кб.
 * Ограничения для всей палитры, 64К / 4 байта, т.е. 16К цветов индексов в BMP файле.
 *  Функционал текущей черновой версии:
 * - создание палитры платформы с нулевыми или сгенерированными значенями;
 * - проверка всей или части палитры на корректность, включая компоненты цветов;
 * - печать в консоль отдельного цвета, информации о палитре и полной таблицы цветов;
 * - уничтожение объекта палитры, освобождение памяти;
 * - загрузка и дополнение палитры из файла BMP по индексам, и конвертация в формат платформы, поддерживается пока
 * что полностью только VGA, сам BMP, т.е. по компонентам;
 * - сохранение палитры в файл BMP по индексам с конвертацией из формата платформы в формат стандартного BMP;
 * - экспорт палитры в текстовый формат ассемблера NASM(и аналогичных) для последующего включения напрямую в исходник;
 * - вспомогательные обслуживающие функции, ввод-вывод.
 * Платформы для поддержки: ZX Spectrum и IBM-PC, адаптеры: CGA(минимально), VGA. */

/* Активные задачи для следующей версии или просто правки, которые мы не успели доделать, порядок различен:
 * 1. Реализовать поддержку формата GIF вместо или в дополнении к BMP.
 * 2. Обновить структуры данных для платформ, адапетров и файла BMP(GIF).
 * 3. Добавить возможность выбора ограниченной палитры в 4-цвета для графического режима.
 * 4. Режимы с табличным представлением цветов, ZX, CGA проработать полностью, т.е. базовые палитры
 *    если для CGA 4 различных, для ZX - всю сразу.
 * 5. Возможно добавить константную таблицу с параметрами платформ, если постоянных данных
 *    станет слишком много, или улучшить читабельность. Тут же обновить функцию размера отдельного цвета.
 * 6. Конвертация палитры ZX в .BMP файл в атрибут и обратно по таблице, пока отсутствует полностью.
 * 7. Обновить с учетом размерности и только необходимые смещения в .BMP или GIF файле.
 * 8. Возможно что палитра будет больше 256 цветов не только VGA формата, немного подумать над необходимостью.
 * 9. Обновить в следующей версии проверку палитр ZX Spectrum, CGA с учетом табличных цветов.
 * 10. Функция изменения размера палитры для удобства или применения.
 * 11. Функция или малые функции конвертации отдельного цвета разных типов, применить вместо объемных switch.
 * 12. Вспомогательная функция из всех флагов возвращает только платформы.
 * 13. Дополнительно флаг предупреждения и возможно его отслеживание и вывод.
 * 14. Список или комбинации платформ или флагов обозначить отедльно константами например 'core'.
 * 15. Выравнивание структуры заголовка файла BMP либо флаги, либо включения, но пока смещения.
 * 16. Экспортирование данных в виде текста, дополнить параметром 'uint8_t group', для группировки
 * параметров и реализовать бинарный вид данных.
 * 17. Функция импортирования из текстового файла в палитру черновик, не тестировали подробнее.
*/

#define TEXT_MAX 0x100

enum flags : uint16_t {                         // Общие флаги состояния или управления. Разнести отдельно по модулям.
    flag_ok = 0x0000, flag_error = 0x0001,      // Нет флагов, всё хорошо или общая ошибка.
    ZX_Spectrum = 0x0002, IBM_PC = 0x0004,      // Платформы и адапетры, включая типы файлов.
    CGA = 0x0008, VGA = 0x0010, BMP = 0x0020,
    flag_default = 0x0040, flag_append = 0x0080,// Флаги управления функциями или свойства, вне платформы.
    flag_hex = 0x0100, flag_bin = 0x0200, flag_grayscale = 0x0400,
    flag_color = 0x0800, flag_pixel = 0x1000
};

struct zx_color {                       // Атрибут ZX Spectrum, битовые поля в 1 байт.
    uint8_t ink : 3;
    uint8_t paper : 3;
    uint8_t bright : 1;
    uint8_t flash : 1;
};

struct ibm_color {                      // Цвет для IBM PC, пока что общий.
    uint8_t red, green, blue;           // Просто компоненты RGB.
};

struct ibm_color_pack {                 // Упакованный VGA формат, пока не реализован.
    uint8_t packed;
};

struct bmp_color {                      // Структура цвета палитры .BMP файла.
    uint8_t blue;                       // Альфа компонент не используется.
    uint8_t green;
    uint8_t red;
    uint8_t alpha;
};

struct color {                          // Структура для отображения информации, вариант c объединением.
    union  {                            // Подумать надо именованием.
        struct zx_color zx_data;
        struct ibm_color ibm_data;
        struct ibm_color_pack ibm_pack_data;
    };
    char name[TEXT_MAX];
};

// Глобальные константы для всех платформ, числовые и текстовые параметры.

static const char* flags_names[] = {
    "no flags ok", "error", "ZX Spectrum", "IBM-PC", "CGA", "VGA", "BMP",
    "default", "append", "as hex", "as binary", "grayscale", "color", "pixel",
};

static const struct color CGA_palette[] = {
{.ibm_data = { .red = 0x00, .green = 0x00, .blue = 0x00 }, .name = "black"},
{.ibm_data = { .red = 0x00, .green = 0x00, .blue = 0xAA }, .name = "blue"},
{.ibm_data = { .red = 0x00, .green = 0xAA, .blue = 0x00 }, .name = "green"},
{.ibm_data = { .red = 0x00, .green = 0xAA, .blue = 0xAA }, .name = "cyan"},
{.ibm_data = { .red = 0xAA, .green = 0x00, .blue = 0x00 }, .name = "red"},
{.ibm_data = { .red = 0xAA, .green = 0x00, .blue = 0xAA }, .name = "magenta"},
{.ibm_data = { .red = 0xAA, .green = 0x55, .blue = 0x00 }, .name = "brown"},
{.ibm_data = { .red = 0xAA, .green = 0xAA, .blue = 0xAA }, .name = "light gray"},
{.ibm_data = { .red = 0x55, .green = 0x55, .blue = 0x55 }, .name = "dark gray"},
{.ibm_data = { .red = 0x55, .green = 0x55, .blue = 0xFF }, .name = "light blue"},
{.ibm_data = { .red = 0x55, .green = 0xFF, .blue = 0x55 }, .name = "light green"},
{.ibm_data = { .red = 0x55, .green = 0xFF, .blue = 0xFF }, .name = "light cyan"},
{.ibm_data = { .red = 0xFF, .green = 0x55, .blue = 0x55 }, .name = "light red"},
{.ibm_data = { .red = 0xFF, .green = 0x55, .blue = 0xFF }, .name = "light magenta"},
{.ibm_data = { .red = 0xFF, .green = 0xFF, .blue = 0x55 }, .name = "yellow"},
{.ibm_data = { .red = 0xFF, .green = 0xFF, .blue = 0xFF }, .name = "white"}
};

static const struct color ZX_palette[] = {
{.zx_data = {. ink = 0, .paper = 0, .bright = 0, .flash = 0 }, .name = "black" },
{.zx_data = {. ink = 1, .paper = 1, .bright = 0, .flash = 0 }, .name = "blue" },
{.zx_data = {. ink = 2, .paper = 2, .bright = 0, .flash = 0 }, .name = "red" },
{.zx_data = {. ink = 3, .paper = 3, .bright = 0, .flash = 0 }, .name = "magenta" },
{.zx_data = {. ink = 4, .paper = 4, .bright = 0, .flash = 0 }, .name = "green" },
{.zx_data = {. ink = 5, .paper = 5, .bright = 0, .flash = 0 }, .name = "cyan" },
{.zx_data = {. ink = 6, .paper = 6, .bright = 0, .flash = 0 }, .name = "yellow" },
{.zx_data = {. ink = 7, .paper = 7, .bright = 0, .flash = 0 }, .name = "white" },
{.zx_data = {. ink = 0, .paper = 0, .bright = 1, .flash = 0 }, .name = "bright" },
{.zx_data = {. ink = 0, .paper = 0, .bright = 0, .flash = 1 }, .name = "flash" }
};

// Константы для палитр и их параметров, дополнительно вычисление.
static const uint16_t palette_size_max = (UINT16_MAX + 1) / sizeof(struct bmp_color);
static const uint16_t zx_colors = 0x08, zx_colors_max = 0x80;
static const uint16_t cga_colors_min = 0x02;
static const uint16_t cga_colors_max = 0x10;
static const uint16_t vga_colors_min = 0x02;
static const uint16_t vga_colors_max = 0x100;
static const uint8_t vga_rgb_max = 0x40;
static const float red_gray = 0.30, green_gray = 0.59, blue_gray = 0.11;
// Временно через константы, во второй версии реализовать через структуру, но без внешних.
static const uint16_t bmp_pixel_data = 0x000A;
static const uint16_t bmp_width_pix = 0x0012;
static const uint16_t bmp_height_pix = 0x0016;
static const uint16_t bmp_color_depth = 0x001C;
static const uint16_t bmp_image_size = 0x0022;
static const uint16_t bmp_palette_size = 0x002E;
static const uint16_t bmp_header_size = 0x0036;
static const uint16_t bmp_color_table = 0x0036;
// Работа с файлами, лучше перенести в настраиваемый параметр.
static const uint8_t txt_file_line = 0x50;

// Глобальные данные для всей программы, палитра и параметры.

static uint16_t palette_size = 0;
static uint16_t color_depth, color_per_rgb, bit_per_color, bit_per_pix;
static enum flags palette_platform = 0;
static char palette_file[FILENAME_MAX] = "";
static void* palette = NULL;
static char text_flags[TEXT_MAX];
static uint8_t bmp_header[0x36] = {
    'B', 'M',                   // Сигнатура BMP файла.
    0x00, 0x00, 0x00, 0x00,     // Размер файла в байтах.
    0x00, 0x00, 0x00, 0x00,     // Зарезервированно.
    0x00, 0x00, 0x00, 0x00,     // Пиксельные данные относительно начала файла.
    0x28, 0x00, 0x00, 0x00,     // Размер данной структуры по версии.
    0x00, 0x00, 0x00, 0x00,     // Ширина растра в пикселях.
    0x00, 0x00, 0x00, 0x00,     // Высота растра в пикселях.
    0x01, 0x00,                 // Количество планов, системное.
    0x00, 0x00,                 // Количество бит на пиксель.
    0x00, 0x00, 0x00, 0x00,     // Способ хранения пикселей, по умолчанию 0.
    0x00, 0x00, 0x00, 0x00,     // Размер пиксельных данных, может быть 0.
    0xC4, 0x0E, 0x00, 0x00,     // Пискелей на метр по горизонтали, может 0.
    0xC4, 0x0E, 0x00, 0x00,     // Пискелей на метр по вертикали, может 0.
    0x00, 0x00, 0x00, 0x00,     // Количество цветов в ячейках.
    0x00, 0x00, 0x00, 0x00      // Количество ячеек от начала таблицы.
};

// Обьявления всех функций программы, для более удобной оргунизации и комментариев.

char* as_binary(void* data, uint8_t size);
char* flags_text(enum flags status);
enum flags is_platform(enum flags platform);
uint8_t size_color(enum flags type);
enum flags is_color(void* src, uint16_t index, enum flags platform);
enum flags create(uint16_t size, enum flags platform);
enum flags destroy(void);
enum flags verify(uint16_t first, uint16_t last, enum flags platform_type);
enum flags set_color(void* src, uint16_t index);
enum flags get_color(void* dst, uint16_t index);
void print_color(void* src, uint16_t index, enum flags type);
enum flags set_color(void* src, uint16_t index);
enum flags verify(uint16_t first, uint16_t last, enum flags type);
void print_color(void* src, uint16_t index, enum flags type);
void print_palette(uint16_t first, uint16_t last, enum flags type);
enum flags load(const char *file_name, uint8_t first, uint8_t last, enum flags type);
enum flags save(const char *file_name, uint16_t first, uint16_t last, enum flags type);
enum flags convert(enum flags type);
enum flags export_to_text(const char *filename, enum flags type);
enum flags import_from_text(const char file_name[], enum flags type);

// Основной код функций работы с палитрой.

char* as_binary(void* data, uint8_t size)   // Вынести функцию в общие и добавить внешний буфер.
{   // Преобразование данных в бинарный текстовый вид, size - размер поля в битах, от младшего разряда.
    static char binary[TEXT_MAX];
    if (data != NULL && size > 0 && size < TEXT_MAX) {
        uint8_t offs = 0x00, mask = 0x01;
        binary[size] = '\0';
        while (size) {
            binary[--size] = (((uint8_t*)data)[offs] & mask) ? '1' : '0';
            if ((mask <<= 0x01) == 0) {
                offs++;
                mask = 0x01;
            }
        }
    } else
        strncpy_s(binary, TEXT_MAX,
                  "\nWarning data as binary, data is null or size incorrect.\n", TEXT_MAX);
    return binary;
}

char* flags_text(enum flags status)
{   // Вспомогательная функция представления состояния флагов в текстовом виде, через пробел.
    if (status != flag_ok) {
        text_flags[0] = '\0';
        for (uint16_t flag = 0x0001, idx = 1; flag != 0x0000; ++idx, flag <<= 0x01)
            if (status & flag) {
                if (text_flags[0] != '\0')
                    strncat_s(text_flags, TEXT_MAX - strlen(text_flags), " ", 1);
                strncat_s(text_flags, TEXT_MAX - strlen(text_flags),
                          flags_names[idx], strlen(flags_names[idx]));
            }
    } else
        strncpy_s(text_flags, TEXT_MAX, flags_names[flag_ok],
                  strlen(flags_names[flag_ok]));
    return text_flags;
}

enum flags is_platform(enum flags platform)
{   // Вспомогательная функция возвращает корректность платформы в виде комбинации флагов.
    platform &= (ZX_Spectrum | IBM_PC | VGA | CGA | BMP);
    if ((platform == ZX_Spectrum) || (platform == (IBM_PC | CGA) || platform == (IBM_PC | VGA)) ||
            (platform == BMP))
        return flag_ok;
    else
        return flag_error;              // Упакованный формат также возможен, подумать.
}

uint8_t size_color(enum flags type)
{   // Вспомогательная функция, возвращает размер структуры отдельного цвета в палитре в байтах.
    if (is_platform(type) == flag_error) {
        printf("\nWarning, size color has incorrect type of platform '%s'.\n", flags_text(type));
        return 0;
    }
    if (type & ZX_Spectrum)             // Возможно добавить таблицу с параметрами.
        return sizeof(struct zx_color);
    else if (type & (CGA | VGA))
        return sizeof(struct ibm_color);
    else if (type & BMP)
        return sizeof(struct bmp_color);
    return 0;
}

enum flags is_color(void* src, uint16_t index, enum flags platform)
{   // Вспомогательная функция проверки цвета на допустимость, по табличному или компонентам.
    // Если источник равняется нулю, то используется индекс и глобальная палитра.
    enum flags color = (src) ? platform : palette_platform;
    void *color_ptr = (src) ? src : palette;
    if (is_platform(color) == flag_error || index >= palette_size_max) {
        printf("\nWarning is color, source (%hX), platform '%s' or index %hu incorrect.\n",
               color_ptr, flags_text(color), index);
        return flag_error;
    }
    switch (color & (ZX_Spectrum | IBM_PC | BMP)) {
    case ZX_Spectrum: {
        if (!src && index >= zx_colors_max) {
            printf("\nWarning is color, index %hu is out of range of ZX Spectrum.\n", index);
            return flag_error;
        }
        struct zx_color *zx_ptr = ((struct zx_color*)color_ptr + index);
        // ! Реализовать проверку по табличным значениям стандартных цветов Спектрума.
        break;
    } case IBM_PC: {
        switch (color & (CGA | VGA)) {
        case CGA: {
            if (!src && index >= cga_colors_max) {
                printf("\nWarning is color, index %hu is out range of CGA adapter.\n", index);
                return flag_error;
            }   // ! Обновить в соответствии с CGA палитрой и наборами по 4 цвета.
            struct ibm_color *ibm_ptr = ((struct ibm_color*)color_ptr + index);
            break;
        } case VGA: {
            struct ibm_color *ibm_ptr = ((struct ibm_color*)color_ptr + index);
            if (ibm_ptr->red >= vga_rgb_max || ibm_ptr->green >= vga_rgb_max || ibm_ptr->blue >= vga_rgb_max) {
                printf("\nWarning is color, RGB is out range, source (%hX), index %hu and platform '%s'.\n",
                       color_ptr, index, flags_text(color));
                return flag_error;
            }
            break;
        } default:
            printf("\nWarning is color, adapter '%s' unsupported.\n", flags_text(color));
            return flag_error;
        }
        break;
    } case BMP: {
        // Индекс может быть максимальным до размера и ограничений по компонентам цвета нет, можно упустить.
        struct bmp_color *bmp_ptr = ((struct bmp_color*)color_ptr + index);
        break;
    } default:
        printf("\nWarning is color, platform '%s' usupported.\n", flags_text(color));
        return flag_error;
    }
    return flag_ok;
}

enum flags create(uint16_t size, enum flags platform)
{   // Создание палитры заданного размера и типа платформы, палитра по-умолчанию или заполнена нулевыми данными.
    if (verify(0, 0, platform | flag_default) == flag_error || palette != NULL || palette_size > 0 ||
            size < cga_colors_min || size > palette_size_max) {
        printf("\nError create palette type '%s', global palette (%hX), sizes exist %hu and new %hu colors.\n",
               flags_text(platform), palette, palette_size, size);
        return flag_error;
    }
    palette = calloc(size, size_color(platform));
    if (palette == NULL) {
        printf("\nError create palette, memory allocation error, size of %hu bytes.\n", size * size_color(platform));
        return flag_error;
    }
    palette_platform = platform & (ZX_Spectrum | IBM_PC | BMP | CGA | VGA); palette_size = size;
    switch (platform & (ZX_Spectrum | IBM_PC | BMP)) {
    case ZX_Spectrum:
        printf("\nCreate new ZX Spectrum palette size %hu and flags '%s'.\n", size, flags_text(platform));
        if (platform & flag_default) {
            for (uint16_t idx = 0; idx < size && idx < zx_colors_max; ++idx) {
                struct zx_color zx = {
                    .ink = idx % zx_colors,
                            .paper = (idx / zx_colors) % zx_colors,
                            .bright = (idx >= zx_colors * zx_colors),
                            .flash = 0
                };
                // printf("%.2hhX.\n", ((struct zx_color*)palette)[idx].bright);
                set_color(&zx, idx);
            }
        }
        color_depth = 2; bit_per_pix = 1; bit_per_color = 3; color_per_rgb = 2;
        break;
    case IBM_PC:
        printf("\nCreate new IBM palette size %hu and flags '%s'.\n", size, flags_text(platform));
        switch (platform & (CGA | VGA)) {
        case CGA:
            color_depth = 16; color_per_rgb = 2; bit_per_pix = 4;
            bit_per_color = 4; color_per_rgb = 2;
            if (platform & flag_default)
                for (uint16_t idx = 0; idx < size; ++idx)
                    ((struct ibm_color*)palette)[idx] = CGA_palette[idx].ibm_data;
            break;
        case VGA:                       // Если палитра более 256 то замкнуть в круг.
            bit_per_pix = 8; bit_per_color = 6; color_depth = vga_colors_max;
            color_per_rgb = 0x01 << bit_per_color;
            if (platform & flag_default)
                for (uint16_t idx = 0; idx < size; ++idx) {     // Или через смещение.
                    struct ibm_color rgb = { .red = 0, .green = 0, .blue = 0 };
                    uint8_t idx_rgb = (idx % color_depth);
                    if (idx_rgb < color_per_rgb)
                        rgb.red = idx_rgb;
                    else if (idx_rgb >= color_per_rgb && idx_rgb < color_per_rgb * 2)
                        rgb.green = (idx_rgb - color_per_rgb);
                    else if (idx_rgb >= color_per_rgb * 2 && idx_rgb < color_per_rgb * 3)
                        rgb.blue = (idx_rgb - color_per_rgb * 2);
                    else
                        rgb.red = rgb.green = rgb.blue = (idx_rgb - color_per_rgb * 3);
                    // ((struct ibm_color*)palette)[idx] = rgb; // Более опасный способ.
                    set_color(&rgb, idx);                       // Пока объект не создан.
                }
            break;
        default:
            printf("\nError create palette '%s' and size %hu, adapter undefined.\n",
                   flags_text(platform), size);
        }
        break;
    case BMP:
        printf("\nCreate new BMP palette size %hu and flags '%s'.\n", size, flags_text(platform));
        if (platform & flag_default) {
            // Создаем красивый черно-белый градиент (от черного к белому) для BMP, проверить.
            for (uint16_t idx = 0; idx < size; ++idx) {
                uint8_t level = (uint8_t)((idx * 255) / (size > 1 ? size - 1 : 1));
                struct bmp_color c = { level, level, level, 0xFF }; // Blue, Green, Red, Alpha
                set_color(&c, idx);
            }
            printf("Palette: BMP initialized (Grayscale gradient);\n");
        }
        bit_per_pix = 8; bit_per_color = 8; color_depth = color_per_rgb = vga_colors_max;
        break;
    default:
        printf("\nError create palette '%s' and size %hu, platform not supported.\n",
               flags_text(platform), size);
    }
    return flag_ok;
}

enum flags destroy(void)
{   // Удаление всех динамических данных палитры и очистка памяти, параметров и имени файла.
    if (palette_size == 0 || palette == NULL) {
        printf("\nWarning destroy, palette (%hX) doesn't exist or empty, %hu colors.\n", palette, palette_size);
        return flag_error;
    }
    printf("\nDestroy palette (%hX) and clear %hu colors from dynamic memory, reset file name and "
           "other gloabal parameters.\n", palette, palette_size);
    free(palette);
    palette = NULL; palette_platform = flag_ok; palette_file[0] = '\0';
    palette_size = 0; color_depth = 0; bit_per_pix = 0;
    bit_per_color = 0; color_per_rgb = 0;
    return flag_ok;
}

enum flags verify(uint16_t first, uint16_t last, enum flags platform_type)
{   // Проверка палитры на корректность общих параметров, индексов и отдельных цветов.
    // Если флаг flag_default не установлен, то применяется флаг платформы аргумента и первый и последний.
    // Иначе простая проверка относительно глобальных параметров платформы и её размера.
    // Если флаг 'color' установлен, то дополнительная проверка цветов на интервале.
    if ((palette == NULL && palette_size > 0) || (palette != NULL && palette_size == 0) ||
            (palette_size > palette_size_max)) {
        printf("\nVerify palette error, data (%hX) and(or) size %hu are incorrect.\n",
               palette, palette_size, flags_text(palette_platform));
        return flag_error;
    }
    enum flags type;
    if (platform_type & flag_default) {
        type = palette_platform;
        first = 0; last = palette_size - 1;
    } else
        type = platform_type;
    if (is_platform(type) == flag_error || first > last) {
        printf("\nWarning verify, platform '%s' or first:last %hu:%hu are incorrect.\n",
               flags_text(type), first, last);
        return flag_error;
    }
    if ((platform_type & flag_default) && palette_size == 0)
        return flag_ok;
    uint16_t elements = last - first + 1;
    switch (type & (ZX_Spectrum | IBM_PC | BMP)) {
    case ZX_Spectrum:   // Обновить в следующей версии с учетом таблицы цветов.
        if (elements > zx_colors_max) {
            printf("\nVerify palette error, colors %hu of ZX Spectrum is more than max %hu.\n",
                   elements, zx_colors_max);
            return flag_error;
        }
        // ! Обновить в следующей версии в соответствии с таблицей цветов.
        break;
    case IBM_PC:
        switch (type & (CGA | VGA)) {
        case CGA:
            if (elements > cga_colors_max || elements < cga_colors_min) {
                printf("\nWarning verify, CGA palette size %hu incorrect.\n", elements);
                return flag_error;
            }
            // ! Обновить в следующей версии с учётом таблицы CGA.
            break;
        case VGA:
            if (elements < vga_colors_min || elements > palette_size_max) {
                printf("\nWarning verify, VGA palette size %hu incorrect.\n", elements);
                return flag_error;
            }
            break;
        default:
            printf("\nWarning verify, adapter not supported.\n");
            return flag_error;
        }
        break;
    case BMP:
        if (elements < cga_colors_min) {
            printf("\nWarning verify, BMP palette size %hu incorrect.\n", elements);
            return flag_error;
        }
        break;
    default:
        printf("\nWarning verify, platform not supported.\n");
        return flag_error;
    }
    if (platform_type & flag_color) {
        for ( ; first <= last; ++first) {
            if (is_color(NULL, first, type) == flag_error) {
                printf("\nVerify palette error, palette type (%s), size %hu and index %hu.\n",
                       flags_text(type), elements, first);
                return flag_error;
            }
        }
    }
    return flag_ok;
}

enum flags set_color(void* src, uint16_t index)
{   // Функция установки заданного цвета в палитре, проверка полной палитры не выполняется.
    if (src == NULL || verify(index, index, flag_default) == flag_error || is_color(src, 0, palette_platform) == flag_error) {
        printf("\nError set color, color (%hX), palette '%s', size %hu or index %hu are incorrect.\n",
               src, flags_text(palette_platform), palette_size, index);
        return flag_error;
    }
    switch (palette_platform & (ZX_Spectrum | IBM_PC | BMP)) {
    case ZX_Spectrum:                              // Или отдельно по компонентам.
        ((struct zx_color*)palette)[index] = *((struct zx_color*)src);
        break;
    case IBM_PC: {
        switch (palette_platform & (CGA | VGA)) {
        case CGA:    // Обновить установку CGA, в соответствии с палитрами и/или CGA структурой.
            ((struct ibm_color*)palette)[index] = *((struct ibm_color*)src);
            break;
        case VGA: {
            struct ibm_color *ibm_ptr = ((struct ibm_color*)palette + index);
            ibm_ptr->red = ((struct ibm_color*)src)->red;   // Короткая версия, также работает.
            ibm_ptr->green = ((struct ibm_color*)src)->green;
            ibm_ptr->blue = ((struct ibm_color*)src)->blue;
        } default:
            printf("\nError set color, adapter '%s' is undefined.\n", flags_text(palette_platform));
            return flag_error;
        }
        break;
    } case BMP: {                                      // Или использовать компоненты отдельно.
        ((struct bmp_color*)palette)[index] = *((struct bmp_color*)src);
        break;
    } default:
        printf("\nError set color, platform unsupported.\n");
        return flag_error;
    }
    return flag_ok;
}

enum flags get_color(void* dst, uint16_t index)
{   // Функция получения цвета заданного по индексу в палитре, полная проверка палитры не выполняется.
    if (dst == NULL || verify(index, index, flag_default | flag_color) == flag_error) {
        printf("\nError get color, destination [%hX], palette (%s), size %hu or index %hu are incorrect.\n",
               dst, flags_text(palette_platform), palette_size, index);
        return flag_error;
    }
    switch (palette_platform & (ZX_Spectrum | IBM_PC | BMP)) {
    case ZX_Spectrum:
        *((struct zx_color*)dst) = ((struct zx_color*)palette)[index];
        break;
    case IBM_PC: {
        switch (palette_platform & (CGA | VGA)) {
        case CGA: {          // Короткая версия, также работает, обновить вместе с таблицей CGA.
            *((struct ibm_color*)dst) = ((struct ibm_color*)palette)[index];
            break;
        } case VGA: {
            struct ibm_color *ibm_ptr = ((struct ibm_color*)palette + index);
            ((struct ibm_color*)dst)->red = ibm_ptr->red;
            ((struct ibm_color*)dst)->green = ibm_ptr->green;
            ((struct ibm_color*)dst)->blue = ibm_ptr->blue;
            break;
        } default:
            printf("\nError get color, adapter '%s' undefined.\n", flags_text(palette_platform));
            return flag_error;
        }
    } case BMP: {
        *((struct bmp_color*)dst) = *((struct bmp_color*)palette + index);
        break;
    } default:
        printf("\nError get color, platform '%s' unsupported.\n", flags_text(palette_platform));
        return flag_error;
    }
    return flag_ok;
}

void print_color(void* src, uint16_t index, enum flags type)
{   // Вывод информации об отдельном цвете в заданном формате. Если источник NULL, тогда используется индекс.
    enum flags color_type = (src) ? type : palette_platform;
    if (is_color(src, index, color_type) == flag_error)
        return;
    switch (color_type & (ZX_Spectrum | IBM_PC | BMP)) {
    case ZX_Spectrum: {
        struct zx_color *zx_ptr = (!src) ? ((struct zx_color*)palette + index) : (struct zx_color*)src;
        uint8_t ink = zx_ptr->ink, paper = zx_ptr->paper, bright = zx_ptr->bright, flash = zx_ptr->flash;
        // printf("Values: ink %hhu, paper %hhu, bright %hhu, flash %hhu.\n", ink, paper, bright, flash);
        printf("ZX Color[%02hX]: ink %s, ", index, as_binary(&ink, bit_per_color));
        printf("paper[%s], ", as_binary(&paper, bit_per_color));
        printf("bright[%s], ", as_binary(&bright, 1));
        printf("flash[%s].\n", as_binary(&flash, 1));
        break;
    } case IBM_PC: {
        struct ibm_color *ibm_ptr = (!src) ? ((struct ibm_color*)palette + index) : src;
        switch (color_type & (CGA | VGA)) {
        case CGA:
            printf("CGA[%.2hX]: %02hX:%02hX:%02hX", index, ibm_ptr->red, ibm_ptr->green, ibm_ptr->blue);
            break;
        case VGA:
            printf("VGA[%.4hX]: %2hX:%2hX:%2hX", index, ibm_ptr->red, ibm_ptr->green, ibm_ptr->blue);
            break;
        default:
            printf("\nWarning print color, adapter type undefined.\n");
        }
        break;
    } case BMP: {
        struct bmp_color *bmp_ptr = (!src) ? ((struct ibm_color*)palette + index) : src;
        printf("BMP[%.4hX]: %2hX:%2hX:%2hX:%2hX", index, bmp_ptr->red, bmp_ptr->green,
               bmp_ptr->blue, bmp_ptr->alpha);
    } default:
        printf("\nWarning print color, platform '%s' usupported.\n", flags_text(color_type));
    }
}

void print_palette(uint16_t first, uint16_t last, enum flags type)
{   // Вывод всей палитры в табличном виде с проверкой всех параметров палитры и индексов.
    // Если установлен флаг color, то выводим все цвета, иначе только общую информацию.
    printf("\nGlobal palette platform '%s' at address (%hX) and size %hu and call verify. ",
           flags_text(palette_platform), palette, palette_size);
    enum flags result = verify(first, last, flag_default | (type & flag_color));
    printf("Result is '%s'.\n", flags_text(result));
    if (result == flag_error || palette_size == 0)
        return;
    printf("Palette parameters: colors %hu, color depth %hu, bit per color %hu,"
           " bit per pixel %hu, colors per rgb %hu.\n", palette_size, color_depth,
           bit_per_color, bit_per_pix, color_per_rgb);
    if (!(type & flag_color))
        return;
    switch (palette_platform & (ZX_Spectrum | IBM_PC | BMP)) {
    case ZX_Spectrum: {
        printf("Index:\tHex:\tInk:\tBinary:\tPaper:\tBinary:\tBright:\n");
        for (uint8_t idx = first; first <= last && idx < palette_size; ++idx) {
            struct zx_color *zx_ptr = &((struct zx_color*)palette)[idx];
            uint8_t ink = zx_ptr->ink, paper = zx_ptr->paper;
            printf("%hhu\t%.2hhX\t%s\t%s\t", idx, *zx_ptr, ZX_palette[zx_ptr->ink].name,
                   as_binary(&ink, 0x03));
            printf("%s\t%s\t%hhu\n", ZX_palette[zx_ptr->paper].name,
                   as_binary(&paper, 0x03), zx_ptr->bright);
        }
        break;
    } case IBM_PC: {
        printf("Index:\tRed\tGreen:\tBlue:\tName:\n");
        for (uint16_t idx = first; idx <= last && idx < palette_size; ++idx) {
            struct ibm_color *ibm_ptr = ((struct ibm_color*)palette + idx);
            printf("%hu\t%.2hhX\t%.2hhX\t%.2hhX\t'defined'\n", idx,
                   ibm_ptr->red, ibm_ptr->green, ibm_ptr->blue);
        }
        break;
    } case BMP: {
        printf("Index:\tRed:\tGreen:\tBlue:\tAlpha:\n");
        for (uint16_t idx = first; idx <= last && idx < palette_size; ++idx) {
            struct bmp_color *bmp_ptr = ((struct bmp_color*)palette + idx);
            printf("%hu\t%.2hhX\t%.2hhX\t%.2hhX\t%.2hhX\n", idx,
                   bmp_ptr->red, bmp_ptr->green, bmp_ptr->blue, bmp_ptr->alpha);
        }
        break;
    } default:
        printf("\nError print palette, usupported platform.\n");
    }
}

enum flags load(const char *file_name, uint8_t first, uint8_t last, enum flags type)
{   // Загрузка палитры из файла в память, первый и последний индекс загружаемого цвета из палитры.
    // Пустая палитра создается, а при дополнении сохраняется в последний, типы палитр должны совпадать.
    // Сначала загрузка палитры как BMP цвета, а после уже конвертация в заданный тип.
    // Также обновляется глобальное имя файла и после может быть применено при записи.
    const char *file = (file_name) ? file_name : palette_file;
    if ((palette_size == 0 && (type & flag_append)) || (palette_size != 0 && !(type & flag_append)) ||
            (file_name == NULL && palette_file[0] == '\0') || first > last || is_platform(type) == flag_error) {
        printf("\nLoad palette error, size %hu, type '%s', first %hhu and last %hhu from ",
               palette_size, flags_text(type), first, last);
        if (file_name != NULL || palette_file[0] != '\0')
            printf("'%s' file.\n", file);
        else
            printf("no file name or global setting.\n");
        return flag_error;
    }
    FILE* bmp_file = fopen(file, "rb");
    if (bmp_file == NULL) {
        printf("\nError loading bitmap file '%s', flags '%s'", file_name, flags_text(type));
        return flag_error;
    }
    uint8_t bmp_header[bmp_header_size];
    printf("\nLoading palette from file '%s', header ", file);
    if (fread (bmp_header, sizeof(uint8_t), bmp_header_size, bmp_file) != bmp_header_size) {
        printf("reading error, return.\n");
        fclose(bmp_file);
        return flag_error;
    }
    uint16_t file_color_depth = *((uint16_t*)(bmp_header + bmp_color_depth)),
            file_palette_size = *((uint16_t*)(bmp_header + bmp_palette_size));
    printf("reading ok, color depth is %hu bits, palette size %hu colors, check indexes",
           file_color_depth, file_palette_size);
    if (last >= file_palette_size) {
        printf(", last index is out of range, so it's set to last index as file");
        last = file_palette_size - 1;
    }
    printf(": [%hu,%hu].\n", first, last);
    uint16_t new_size = palette_size + (last - first + 1), idx_color;
    if (verify(0, new_size - 1, type) == flag_error || new_size > palette_size_max) {
        printf("!%hu! type %hu.\n", new_size, type);
        printf("\nError create or append palette, incorrect size %hu of source and/or file indexes.\n", new_size);
        fclose(bmp_file);
        return flag_error;
    }
    if (!palette_size) {
        if (create(new_size, BMP) == flag_error) {
            fclose(bmp_file);
            return flag_error;
        }
        idx_color = 0;
    } else {
        printf("Append size of palette from %hu to %hu colors, converting colors to BMP.\n",
               palette_size, new_size);
        if ((convert(BMP)) == flag_error)
            return flag_error;
        // При добавлении функции изменения палитры, заменить следующее более безопасно.
        palette = realloc(palette, new_size * size_color(BMP));
        idx_color = palette_size;
        palette_size = new_size;
    }
    fseek(bmp_file, first * size_color(BMP), SEEK_CUR);
    // printf("-%hu-%hu : %hu ; %hu;\n", first, last, size_color(BMP), idx_color);
    if (fread(((struct bmp_color*)palette + idx_color), size_color(BMP),
              (last - first + 1), bmp_file) != (last - first + 1)) {
        printf("\nError reading colors palette from file, nothing to add.\n");
        fclose(bmp_file);
        return flag_error;
    }
    fclose(bmp_file);
    printf("Data of palette readed ok, new size %hu colors, convert from '%s' to destination platform.\n",
           palette_size, flags_text(palette_platform));
    if (convert(type) == flag_error)
        return flag_error;
    if (file_name)
        strncpy_s(palette_file, FILENAME_MAX, file_name, FILENAME_MAX);
    printf("Colors %hu added to palette, new size %hu colors, file name '%s'.\n",
           (last - first + 1), palette_size, palette_file);
    return flag_ok;
}

enum flags save(const char *file_name, uint16_t first, uint16_t last, enum flags type)
{   // Сохранение палитры в формат файла BMP, из формата платформы индексы в файле назначения.
    // Тип требуется только для флага растрового тестового изображения, иначе только цвета палитры.
    if (verify(0, palette_size, flag_default | flag_color) == flag_error || palette_size == 0 || first > last) {
        printf("\nError save palette (%hX), size %hu or first-last [%hu,%hu] are incorrect.\n",
               palette, palette_size, first, last);
        return flag_error;
    }
    const char *name = (file_name) ? file_name : palette_file;
    printf("\nSave palette '%s' to BMP file and/or draw some debug information. ", flags_text(palette_platform));
    FILE *bmp_file = fopen(name, "rb");
    if (bmp_file) {
        printf("Warning, file '%s' alredy exist, rewrite palette and(or) pixel data.\n", name);
        bmp_file = freopen(name, "r+", bmp_file);
        // Дополнительная проверка заголовка для комплекта.
    } else {
        printf("\nFile '%s' not exist, it will be created as empty BMP using preset header.\n", name);
        bmp_file = fopen(name, "wb+");
        print_palette(0, palette_size - 1, flag_default);
        *(uint16_t*)(bmp_header + bmp_pixel_data) = bmp_header_size + palette_size * size_color(BMP);
        if ((palette_platform & ZX_Spectrum) == ZX_Spectrum ||
                ((palette_platform & (IBM_PC | CGA)) == (IBM_PC | CGA))) {
            // printf("YE! %hu\n", bmp_header_size + palette_size * size_color(BMP));
            *(uint16_t*)(bmp_header + bmp_width_pix) = cga_colors_max;
            *(uint16_t*)(bmp_header + bmp_image_size) = (cga_colors_max * vga_colors_max * bit_per_pix) / CHAR_BIT;
        } else if ((palette_platform & (IBM_PC | VGA)) == (IBM_PC | VGA)) {
            *(uint16_t*)(bmp_header + bmp_width_pix) = vga_colors_max;
            *(uint16_t*)(bmp_header + bmp_image_size) = (vga_colors_max * vga_colors_max * bit_per_pix) / CHAR_BIT;
        }
        *(uint16_t*)(bmp_header + bmp_height_pix) = vga_colors_max;
        bmp_header[bmp_color_depth] = bit_per_color;
        *(uint16_t*)(bmp_header + bmp_palette_size) = color_depth;
        if (fwrite(bmp_header, sizeof(uint8_t), bmp_header_size, bmp_file) != bmp_header_size) {
            printf("Error save to file '%s' palette type '%s' bitmap header.\n",
                   name, flags_text(palette_platform));
            return flag_error;
        }
    }
    enum flags platform = palette_platform;
    if ((palette_platform & BMP) != BMP) {
        printf("Palette is not BMP, trying to convert to file format colors.\n");
        if (convert(BMP) == flag_error)
            return flag_error;
    } else
        printf("Palette is already in BMP format color, no convert needed.\n");
    fseek(bmp_file, bmp_color_table + (first * size_color(BMP)), SEEK_SET);
    printf("POS: %llu, size %hu.\n", ftell(bmp_file), last - first + 1);
    if (fwrite((struct bmp_color*)palette, size_color(BMP), (last - first + 1),
               bmp_file) != (last - first + 1)) {
        printf("Error save to file '%s' palette type '%s' or indexes [%hu,%hu].\n",
               name, flags_text(palette_platform), first, last);
        return flag_error;
    }
    printf("Palette saved to file '%s' ok, colors indexes [%hu,%hu], closing file.\n",
           name, first, last);
    if (platform != palette_platform) {
        printf("Palette wasn't BMP file, convert it back to source '%s'.\n", flags_text(platform));
        if (convert(platform) == flag_error)
            return flag_error;
    }
    if (type & flag_pixel) {
        for (uint16_t iy = 0; iy < vga_colors_max; ++iy) {
            for (uint16_t ix = 0, bits, color_idx = 0; ix < palette_size * bit_per_pix / CHAR_BIT; ++ix) {
                uint8_t bmp_data = 0;
                if (bit_per_pix == CHAR_BIT)
                    bmp_data = color_idx++;
                else
                    for (bits = 0; bits < CHAR_BIT; bits += bit_per_pix, color_idx++)
                        bmp_data = (bmp_data << bit_per_pix) | color_idx;
                fwrite(&bmp_data, sizeof(uint8_t), 1, bmp_file);
            }
        }
    }
    fclose(bmp_file);
    return flag_ok;
}

enum flags convert(enum flags type)
{   // Конвертация и создание новой палитры на основе исходной, если меняется тип, то должны быть
    // установлены коммбинация флагов, поддерживаемые файлом. Дополнительный флаг в оттенки серого.
    // Если тип основной палитры и палитры назначения полностью совпадают, то ничего не делаем.
    if (verify(0, 0, flag_default | flag_color) == flag_error || palette_size == 0) {
        printf("\nError convert, palette '%s' ", flags_text(palette_platform));
        printf("or destination '%s' platforms incorrect.\n", flags_text(type));
        return flag_error;
    }
    if ((palette_platform & (ZX_Spectrum | IBM_PC | CGA | VGA | BMP)) ==
            (type & (ZX_Spectrum | IBM_PC | CGA | VGA | BMP | flag_grayscale))) {
        printf("\nWarning convert, palette source '%s' or ", flags_text(palette_platform));
        printf("destination '%s' are equal, nothing to convert.\n", flags_text(type));
        return flag_ok;
    }
    void* new_palette = calloc(palette_size, size_color(type));
    if (new_palette == NULL) {
        printf("\nError convert, can't allocate dynamic memory %hu bytes, exit.\n",
               palette_size * size_color(type));
        return flag_error;
    }
    printf("\nConvert palette (%hX) platform from '%s' to ", palette, flags_text(palette_platform));
    printf("'%s' with flags and %hu colors.\n", flags_text(type), palette_size);
    struct bmp_color color; // Алгоритм по самому "широкому" формату одного цвета.
    for (uint16_t index = 0; index < palette_size; ++index) {
        switch (palette_platform & (ZX_Spectrum | IBM_PC | BMP)) {
        case ZX_Spectrum:   // Простое копирование данных как есть, обновить по таблице.
            /* struct zx_color zx;
            get_color(&zx, i);
            uint8_t lvl = zx.bright ? 0xFF : 0xAA;
            temp_rgb[i].red = (zx.ink & 0x02) ? lvl : 0x00;
            temp_rgb[i].green = (zx.ink & 0x04) ? lvl : 0x00;
            temp_rgb[i].blue = (zx.ink & 0x01) ? lvl : 0x00; */
            color.alpha = *((uint8_t*)((struct zx_color*)palette + index));
            break;
        case IBM_PC:
            switch (palette_platform & (CGA | VGA)) {
            case CGA: {  // Пока что как есть через компоненты, позже добавить таблицу.
                struct ibm_color *ibm_ptr = ((struct ibm_color*)palette + index);
                color.red = ibm_ptr->red; color.blue = ibm_ptr->blue;
                color.green = ibm_ptr->green; color.alpha = 0;
                break;
            } case VGA: {
                // Вариант дополнительный, сдвиг старших бит вправо дополнительно, т.е. rgb >> 0x04.
                struct ibm_color *ibm_ptr = ((struct ibm_color*)palette + index);
                color.red = ibm_ptr->red << 0x02; color.green = ibm_ptr->green << 0x02;
                color.blue = ibm_ptr->blue << 0x02; color.alpha = 0;
                break;
            } default:
                printf("\nConvert error, adapter undefined, palette remain as is.\n");
            }
            break;
        case BMP:
            color = ((struct bmp_color*)palette)[index];
            break;
        default:
            printf("\nConvert error, platform unsupported, palette reamin as is.\n");
        }
        // Дополнительная обработка цвета, если требуется.
        if ((type & flag_grayscale) && ((type & (IBM_PC | VGA)) == (IBM_PC | VGA) ||
                                   (type & BMP) == BMP)) {
            uint8_t gray = round((float)color.red * red_gray +
                                 (float)color.green * green_gray +
                                 (float)color.blue * blue_gray);
            color.red = color.green = color.blue = gray;
        }
        switch (type & (ZX_Spectrum | IBM_PC | BMP)) {
        case ZX_Spectrum:   // Опасный код, обновить когда будет таблица.
            *(uint8_t*)((struct zx_color*)new_palette + index) = color.alpha;
            break;
        case IBM_PC:
            switch (type & (CGA | VGA)) {
            case CGA: {      // Обновить в соответствии с таблицей.
                struct ibm_color *ibm_ptr = ((struct ibm_color*)new_palette + index);
                ibm_ptr->red = color.red; ibm_ptr->green = color.green; ibm_ptr->blue = color.blue;
                color_depth = 16; bit_per_pix = 2; bit_per_color = 4; color_per_rgb = 2;
                break;
            } case VGA: {
                struct ibm_color *ibm_ptr = ((struct ibm_color*)new_palette + index);
                ibm_ptr->red = color.red >> 0x02; ibm_ptr->green = color.green >> 0x02;
                ibm_ptr->blue = color.blue >> 0x02;
                color_depth = vga_colors_max; bit_per_pix = 8; bit_per_color = 6; color_per_rgb = vga_rgb_max;
                break;
            } default:
                printf("\nConvert error, adapter undefined.\n");
            }
            break;
        case BMP:
            color_depth = vga_colors_max; bit_per_pix = 8; bit_per_color = 8; color_per_rgb = vga_colors_max;
            ((struct bmp_color*)new_palette)[index] = color;
            break;
        default:
            printf("\nConvert error, platform unsupported.\n");
        }
    }
    free(palette);
    palette = new_palette; palette_platform = type & (ZX_Spectrum | IBM_PC | BMP | CGA | VGA);
    printf("Convert complete, %hu colors converted new address (%hX) and type '%s'.\n",
           palette_size, palette, flags_text(palette_platform));
    return flag_ok;
}

enum flags export_to_text(const char *filename, enum flags type)
{   // Экспорт палитры в текстовый файл. Формат заголовок и данные через табуляции.
    if (palette == NULL || palette_size == 0 || is_platform(type) == flag_error || filename == NULL) {
        printf("\nError export to file '%s' and flags '%s'.\n", filename, flags_text(type));
        return flag_error;
    }
    if (type & (IBM_PC | flag_hex))
        printf("\nExport palette to DOS file as HEX dump.\n");
    FILE *text_file = fopen(filename, "wb");
    char line[TEXT_MAX], hex[TEXT_MAX];
    // palette_size = 0x10; debug
    for (uint16_t idx = 0x00, rgb = 0, col = 0; idx < palette_size; ) {
        while (col < txt_file_line - 0x05 && idx < palette_size) {
            if (!col) {
                strncpy_s(line, TEXT_MAX, "\tdb ", 0x04);
                col += 11;
            }
            sprintf_s(hex, TEXT_MAX, "%.03hhXh",
                      ((uint8_t*)(((struct ibm_color*)palette) + idx))[rgb]);
            strncat_s(line, TEXT_MAX - strlen(line), hex, TEXT_MAX);
            col += 0x04;
            // printf("Check hex '%s', line '%s', rgb %hhu.\n", hex, line, rgb);
            if (++rgb == sizeof(struct ibm_color) / sizeof(uint8_t)) {
                ++idx;
                rgb = 0;
            }
            if (col < txt_file_line - 0x05 && idx < palette_size) {
                strncat_s(line, TEXT_MAX - strlen(line), ", ", TEXT_MAX);
                col += 2;
            }
        }
        printf("Check hex '%s', line '%s', rgb %hhu.\n", hex, line, rgb);
        fprintf(text_file, "%s\n", line);
        if (col >= txt_file_line - 0x05)
            col = 0;
    }
    fclose(text_file);
    return flag_ok;
}

enum flags import_from_text(const char file_name[], enum flags type)
{   // Импорт палитры из текстового файла. Пропускается заголовок, а остальное через табуляцию.
    // Вынести в следующую версию, дополнительно, т.к. функционал не особо востребован, черновик как есть.
    if (verify(0, 0, flag_default) == flag_error || file_name == NULL)
        return flag_error;
    FILE *file = fopen(file_name, "r");
    if (file == NULL) {
        printf("Import error: Cannot open file '%s';\n", file_name);
        return flag_error;
    }
    char buffer[TEXT_MAX];
    printf("\nImport start: reading from '%s'\n", file_name);
    if (fgets(buffer, sizeof(buffer), file) == NULL) {
        printf("Import error: File is empty;\n");
        fclose(file);
        return flag_error;
    }
    const char* plat_name = (palette_platform & ZX_Spectrum) ? "ZX Spectrum" : "IBM-PC";
    if (strstr(buffer, plat_name) == NULL) {
        printf("Import error: Platform mismatch! Memory is [%s], file says: %s",
               flags_text(palette_platform), buffer);
        fclose(file);
        return flag_error;
    }
    if (fgets(buffer, sizeof(buffer), file) == NULL) {
        printf("Import error: Unexpected end of file;\n");
        fclose(file);
        return flag_error;
    }
    uint16_t loaded_count = 0;
    while (fgets(buffer, sizeof(buffer), file) != NULL) {
        uint16_t idx = 0;
        if (palette_platform & ZX_Spectrum) {
            uint32_t ink, pap, brt, fls, raw;
            // Формат: Index Ink Paper Bright Flash Raw_Hex
            if (sscanf_s(buffer, "%hu\t%u\t%u\t%u\t%u\t%x", &idx, &ink, &pap, &brt, &fls, &raw) >= 5)
                if (idx < palette_size) {
                    struct zx_color zx = { (uint8_t)ink, (uint8_t)pap, (uint8_t)brt, (uint8_t)fls };
                    set_color(&zx, idx);
                    loaded_count++;
                }
        } else {
            uint32_t r, g, b;
            if (sscanf_s(buffer, "%hu\t%x\t%x\t%x", &idx, &r, &g, &b) == 4)
                if (idx < palette_size) {
                    struct ibm_color ibm = { (uint8_t)r, (uint8_t)g, (uint8_t)b };
                    set_color(&ibm, idx);
                    loaded_count++;
                }
        }
    }
    fclose(file);
    printf("Import success: %hu elements imported from '%s' [%s];\n",
           loaded_count, file_name, flags_text(palette_platform));
    return flag_ok;
}

void info()
{   // Вывод общей информации о палитре. Добавить verify.
    printf("\nGlobal palette's structures, settings and information.\n\n");
    printf("Address witdh %u bits, palette size maximum %hu and file format '.BMP'.\n",
           sizeof(void*) * CHAR_BIT, palette_size_max);
    printf("Supported platforms: ZX Spectrum, IBM_PC with adapters CGA and VGA and BMP as file.\n");
    printf("\nStructure of ZX Spectrum color attribute, colors %hu, size %u bytes, fixed palette:\n",
           zx_colors, sizeof(struct zx_color));
    printf("Bits:\tAttribute:\tHex:\tNames:\n");
    for (uint8_t idx = 0; idx < 18; ++idx) {
        if (idx == 0)
            printf("0..2");
        if (idx < 8)
            printf("\tink\t\t%.2hhX\t%s\n", idx, ZX_palette[idx].name);
        if (idx == zx_colors)
            printf("3..5");
        if (idx >= zx_colors && idx < zx_colors * 2)
            printf("\tpaper\t\t%.2hhX\t%s\n", (idx % zx_colors) << 0x03, ZX_palette[(idx % zx_colors)].name);
        if (idx == 16)
            printf("6\tbright\t\t%.2hhX\t%s\n", 0x40, ZX_palette[zx_colors].name);
        if (idx == 17)
            printf("7\tflash\t\t%.2hhX\t%s\n", 0x80, ZX_palette[zx_colors + 1].name);
    }
    // Структура bmp_color (BGRA)
    printf("\nStructure 'bmp_color' (Windows Bitmap format), size %lu bytes.\n", sizeof(struct bmp_color));
    printf("Field:\tOffset:\tType:\tSize:\tComment:\n");
    printf("blue\t%lu\tuint8_t\t%lu\tBlue color component.\n",
           offsetof(struct bmp_color, blue), sizeof(uint8_t));
    printf("green\t%lu\tuint8_t\t%lu\tGreen color component.\n",
           offsetof(struct bmp_color, green), sizeof(uint8_t));
    printf("red\t%lu\tuint8_t\t%lu\tRed color component.\n",
           offsetof(struct bmp_color, red), sizeof(uint8_t));
    printf("alpha\t%u\tuint8_t\t%u\tAlpha channel (transparency).\n",
           (unsigned int)offsetof(struct bmp_color, alpha), (unsigned int)sizeof(uint8_t));
    printf("\nStructure of IBM PC CGA default full palette, colors (%hu..%hu), size %u bytes, full data %u bytes.\n",
           cga_colors_min, cga_colors_max, sizeof(struct ibm_color), sizeof(CGA_palette));
    printf("Offset:\tSize:\tComment:\n");
    printf("%llu\t%llu\tred component of color;\n", offsetof(struct ibm_color, red), sizeof(uint8_t));
    printf("%llu\t%llu\tgreen component of color;\n", offsetof(struct ibm_color, green), sizeof(uint8_t));
    printf("%llu\t%llu\tblue component of color.\n\n", offsetof(struct ibm_color, blue), sizeof(uint8_t));
    printf("Index:\tRed:\tGreen:\tBlue:\tName:\n");
    for (uint8_t idx = 0; idx < cga_colors_max; ++idx)
        printf("%hhu\t%.2hhX\t%.2hhX\t%.2hhX\t%s\n", idx, CGA_palette[idx].ibm_data.red,
               CGA_palette[idx].ibm_data.green, CGA_palette[idx].ibm_data.blue, CGA_palette[idx].name);

}

enum flags debug(uint8_t setup)
{   // Все отладочные конфигурации в автоматическом режиме, для проверки, 0 - все или номер сценарияй.
    printf("\nDebug all extra functions, without actual workload.\n");
    printf("\nPrint data as binary, from 1 to %hu bits maximum.\n", TEXT_MAX - 1);
    uint16_t bin_data = 0x0FA5;
    printf("Value '0x0FA5' as binary one lowest bit is '%s'.\n", as_binary(&bin_data, 1));
    printf("Value '0x0FA5' as binary all 16 bits is '%s'.\n", as_binary(&bin_data, 16));
    printf("Value '0x0FA5' as binary 12 lower bits is '%s'.\n", as_binary(&bin_data, 12));
    printf("\nDebug 'is_platform' verify platform and adapters:\n");
    printf("Only flag 'ZX Spectrum' is set, result '%s'.\n",
           flags_text(is_platform(ZX_Spectrum)));
    printf("Two flags 'IBM PC and CGA' are set, result '%s'.\n",
           flags_text(is_platform(IBM_PC | CGA)));
    printf("Three flags 'IBM PC, CGA and VGA' are set, result '%s'.\n",
           flags_text(is_platform(IBM_PC | CGA | VGA)));
    printf("\nDebug all flags as names: '%s' and '%s' as no flags or ok.\n",
           flags_text(0x0FFF), flags_names[0]);
    struct ibm_color rgb_a = { 0x10, 0x20, 0x30 }, rgb_b = { 0x3F, 0x3F, 0x40 };
    printf("\nVerify VGA colors and debug print color function: ");
    print_color(&rgb_a, 0, IBM_PC | VGA);
    printf(", result is '%s', trying print second color...",
           flags_text(is_color(&rgb_a, 0, IBM_PC | VGA)));
    print_color(&rgb_b, 0, IBM_PC | VGA);
    printf("RGB component maximum RGB component %hhu.\n", vga_rgb_max);
    palette_size = 1;
    printf("\nVerify palette with empty data but size more than zero, other tests later.\n");
    verify(0, 0, ZX_Spectrum | flag_default);
    palette_size = 0;
    return flag_ok;
}

void palettes(void)
{   // Основная функция модлуя работы с палитрой цветов и файлами, на вход без аргументов.
    printf("Palette tools for retro platforms, menu or info, update debug setups.\n\n");
    info();
    debug(0);
    return;

    // Первый сценарий отладки, системные функции работы с палитрой и вывод.
    printf("\n\nDebug system functions for palette: create, destroy, print and verify. "
           "Create 'full' palette for ZX Spectrum without flash, print all, one color and destroy. "
           "Again trying to destroy empty palette. Create VGA palette with one incorrect color and verify. "
           "After create CGA with error and full default CGA and print all.\n\n");
    create(zx_colors_max, ZX_Spectrum | flag_default);
    print_palette(0, zx_colors_max - 1, flag_color);
    printf("\nDebug print one color using index 0x7F: ");
    print_color(NULL, 0x7F, flag_ok);
    destroy();
    destroy();
    create(vga_colors_min, IBM_PC | VGA);
    print_palette(0, 1, flag_color);
    ((struct ibm_color*)palette + 1)->green = vga_rgb_max;
    print_palette(0, 1, flag_color);
    destroy();
    create(vga_colors_max, IBM_PC | CGA);
    create(cga_colors_max, IBM_PC | CGA | flag_default);
    print_palette(0, cga_colors_max - 1, flag_color);
    return;

    // Второй сценарий отладки, применение функций чтения/записи отдельных цветов.
    struct ibm_color ibm_a = { 0x00, 0x00, 0x00 };
    printf("\n\nTrying functions thats works with color and rgb in palette. Print colors from [0..3], "
           "set colors to one of the CGA graphics mode and print again.\n\n");
    printf("CGA colors: ");
    for (uint16_t index = 0; index < 4; ++index) {
        get_color(&ibm_a, index);
        print_color(&ibm_a, index, IBM_PC| CGA);
        printf("; ");
    }
    printf("\nCGA colors after set to palette 0 high intensity: ");
    for (uint16_t index = 0; index < 4; ++index) {
        if (index > 0)
            set_color((void*)(&(CGA_palette[8 + index * 2].ibm_data)), index);
        print_color(NULL, index, flag_default);
        printf("; ");
    }
    destroy();
    return;

    // Третий сценнарий отладки, загрука палитры VGA для 2 файлов и расшрение размерности.
    printf("\n\nLoad new palette from monochrome file 'image_1bpp.bmp' as BMP and convert to ZX Spectrum. "
            "After load palettes from 2 '.BMP' files 'image_4bpp_a.bmp' and 'image_4bpp_b.bmp "
           "files and create extended CGA palette with, from 8 colors and append to 12 size table."
           "Pallette must be empty or existed if flag 'append' set. Files in current directory.\n\n");
    load("image_1bpp.bmp", 0, 1, BMP);
    print_palette(0, 1, flag_color);
    ((struct bmp_color*)palette)[1].alpha = 0x4C;
    convert(ZX_Spectrum);
    print_palette(0, 1, flag_color);
    destroy();
    load("image_4bpp_a.bmp", 8, 15, IBM_PC | CGA);
    print_palette(0, 7, flag_color);
    load("image_4bpp_b.bmp", 0, 3, IBM_PC | CGA | flag_append);
    print_palette(0, cga_colors_max - 1, flag_color);
    destroy();
    return;

    // Четвертый сценарий, загрузка палитры VGA, конвертация в оттенки серого и запись обратно.
    printf("\n\nLoad VGA palette from file 'image_8bpp.bmp', print it, convert to grayscale "
           "and save to new file and recheck in external program.\n\n");
    load("image_8bpp_a.bmp", 0, 255, BMP);
    print_palette(0, vga_colors_max - 1, flag_color);
    convert(palette_platform | flag_grayscale);
    // create(vga_colors_max, IBM_PC | VGA | flag_default);
    // print_palette(0, vga_colors_max - 1, color);
    create(cga_colors_max, IBM_PC | CGA | flag_default);
    // print_palette(0, cga_colors_max - 1, color);
    save("image_8bpp_c.bmp", 0, cga_colors_max - 1, flag_pixel);
    return;

    // Пятый сценарий, создание VGA палитры по умолчанию и экспорт текста.
    printf("\n\nCreate IBM PC with VGA adapter default palette and export it to assembly source ");
    create(vga_colors_max, IBM_PC | VGA | flag_default);
    print_palette(0, vga_colors_max - 1, flag_color);
    export_to_text("VGA_RGB.ASM", IBM_PC | VGA);
    destroy();
    printf("\nExit from program, check palette address (%hX), size %hu colors,"
           " platform '%s'.\n", palette, palette_size,
           flags_text(palette_platform));
    return;
}
