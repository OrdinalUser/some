#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <ctype.h>

// == Globals ==
#define MAX_FILEPATH_LENGTH 240

#define STRING_END_CHARACTER '\0'
#define MAX_EXPECTED_LINENUMBER_LENGTH 12
#define SIMPLE_COMMIT_BUFF_SIZE 65535
#define SIMPLE_READ_SIZE 65535
#define INITIAL_PAGE_COUNT 32

// Platform dependent -- linux
#include <sys/ioctl.h>
#include <unistd.h>

// === Helper functions ===
int16_t copy_path_string(char* dest, const char* source)
{
    int16_t copied = 0;
    char* p = (char*)source;
    for (; *p != STRING_END_CHARACTER && *p != ' '; p++)
    {
        *dest++ = *source++;
        copied++;
    }
    *dest = 0;
    return copied;
}

size_t std_strlen(const char* str)
{
    size_t len = 0;
    for (char* p = (char*)str; *p++ != STRING_END_CHARACTER; len++) {}
    return len;
}

size_t std_strlen_c(const char* str, char end)
{
    size_t len = 0;
    for (char* p = (char*)str; *p != end && *p != STRING_END_CHARACTER; len++) { p++; }
    return len;
}

void std_strcpy(char* dest, const char* source)
{
    while (*source != STRING_END_CHARACTER)
    {
        *dest++ = *source++;
    }
    *dest = STRING_END_CHARACTER;
}


void std_strncpy(char* dest, const char* source, const size_t count)
{
    for (size_t cnt = count; cnt && *source != STRING_END_CHARACTER; cnt--)
    {
        *dest++ = *source++;
    }
    *dest = STRING_END_CHARACTER;
}

size_t puts_ln_ex(const char* str, size_t* bytes_read)
{
    // Terminates on new line or NULL byte which also gets printed
    // Returns count of printed characters
    size_t cnt = 0, bytes = 0;
    for (; *str != '\n' && *str != STRING_END_CHARACTER; bytes++, str++)
    {
        if (isprint(*str)) { cnt++; putchar(*str); }
        else if (*str == '\t') { cnt++; putchar(' '); }
    }
    *bytes_read = bytes + 1; // Must include '\n' as it was in the string and we deferred it's printing
    putchar('\n');
    return cnt;
}

size_t std_utoa(char* dest, uint32_t number)
{
    size_t len = 0;
    char* p = dest;
    uint32_t temp = number;

    // Convert int to str in reverse
    if (temp == 0) { *p++ = '0'; len = 1; }
    else
    {
        while (temp > 0)
        {
            *p++ = '0' + (temp % 10);
            temp /= 10;
            len++;
        }
    }
    *p = STRING_END_CHARACTER;
    
    // Reverse converted int into proper order
    char* start = dest, *end = p-1;
    while (start < end)
    {
        char tmp = *start;
        *start++ = *end;
        *end-- = tmp;
    }
    return len;
}

uint16_t digitcount(size_t num)
{
    uint16_t count = 0;
    do {
        count++;
        num /= 10;
    } while (num > 0);
    return count;
}


void truncate_filepath(const char* filepath, char* buffer, int max_len)
{
    int filepath_len = strlen(filepath);
    if (filepath_len < max_len-3) { strcpy(buffer, filepath); return; }
    int16_t characters_to_truncate = filepath_len - max_len + 3; // we're adding ../

    // Copy first part
    uint16_t fi = 0;
    if (filepath[fi] == '/') { buffer[fi] = filepath[fi]; fi++; }
    uint16_t root_len = std_strlen_c(filepath+fi, '/') + 1;
    strncpy(buffer+fi, filepath+fi, root_len);
    fi += root_len;

    // Truncate
    uint16_t bi = fi;
    while (characters_to_truncate > 0)
    {
        int16_t path_part_len = std_strlen_c(filepath+fi, '/')+1;
        fi += path_part_len;
        characters_to_truncate -= path_part_len;
    }
    buffer[bi] = '.';
    buffer[bi+1] = '.';
    buffer[bi+2] = '/';
    bi += 3;

    // Copy rest
    strcpy(buffer+bi, filepath+fi);
}

void truncate_filepath_ex(const char* filepath, char* buffer, uint16_t filepath_len, uint16_t max_len)
{
    realpath(filepath, buffer);
    return;
    if (filepath_len < max_len) { std_strcpy(buffer, filepath); return; }
    int16_t characters_to_truncate = filepath_len - max_len + 3; // we're adding ../

    // Copy first part
    uint16_t fi = 0;
    if (filepath[fi] == '/') { buffer[fi] = filepath[fi]; fi++; }
    uint16_t root_len = std_strlen_c(filepath+fi, '/') + 1;
    std_strncpy(buffer+fi, filepath+fi, root_len);
    fi += root_len;

    // Truncate
    uint16_t bi = fi;
    while (characters_to_truncate > 0)
    {
        int16_t path_part_len = std_strlen_c(filepath+fi, '/')+1;
        fi += path_part_len;
        characters_to_truncate -= path_part_len;
    }
    buffer[bi] = '.';
    buffer[bi+1] = '.';
    buffer[bi+2] = '/';
    bi += 3;

    // Copy rest
    std_strcpy(buffer+bi, filepath+fi);
}

// === Main Program ===
typedef struct some_lookup_entry
{
    int line_number, page_length, page_height;
    int padding;
    size_t page_offset;
} page_entry_t;

// == Program globals ==
int16_t g_terminal_width;
int16_t g_terminal_height;
int16_t g_reserved_rows = 3;
int16_t g_display_rows;
int8_t* g_page_buffer;
uint16_t g_page_buffer_size;
int8_t g_filepath[MAX_FILEPATH_LENGTH] = {0};
int8_t g_display_filepath[MAX_FILEPATH_LENGTH] = {0};
FILE* g_file_ptr = 0;

struct some_lookup_entry* g_page_entries = 0;
size_t g_page_entries_length = 0;
size_t g_page_entries_capacity = 0;

void some_read_terminal_size()
{
    struct winsize w;
    ioctl(STDOUT_FILENO, TIOCGWINSZ, &w);
    g_terminal_width = w.ws_col;
    g_terminal_height = w.ws_row;
}

void some_init(int8_t paging_flag)
{
    some_read_terminal_size();
    g_display_rows = g_terminal_height - g_reserved_rows;
    if (paging_flag) g_page_buffer_size = g_terminal_width * g_display_rows;
    else g_page_buffer_size = SIMPLE_READ_SIZE;
    g_page_buffer = malloc(g_page_buffer_size);
}

void some_exit()
{
    if (g_page_entries) free(g_page_entries);
    free(g_page_buffer);
    fclose(g_file_ptr);
}

void some_print_help()
{
    fprintf(stderr, "Usage: some <options> <filepath>\n");
    fprintf(stderr, "\t ex.: some -p ../cities.csv\n");
    fprintf(stderr, "-h : prints this information\n-p : uses page system to view file\n");
}

void some_parse_args(const char** argv, int argc, int8_t* print_help_flag, int8_t* paging_flag)
{
    for (; argc--; )
    {
        const char* arg = argv[argc];
        if (arg[0] == '-')
        {
            if (arg[1] == 'h') { *print_help_flag = 1; return; }
            else if (arg[1] == 'p') { *paging_flag = 1; }
        }
        else
        {
            // Assume this is the filepath :)
            realpath(arg, (char*)g_filepath);
        }
    }
}

void some_simple()
{
    int line_number = 1;
    while (fgets(g_page_buffer, g_page_buffer_size, g_file_ptr))
    {
        printf("%d: %s", line_number++, g_page_buffer);
    }
}

void some_simple_ex()
{
    FILE* fh = fopen((const char*)&g_filepath, "rb");

    const int commit_size = SIMPLE_COMMIT_BUFF_SIZE;
    int8_t* commit_buff = malloc(commit_size);
    int32_t commit_offset = 0;

    uint32_t line_number = 1;
    size_t bytes_read = 0;
    size_t ln_str_size = 0;

    ln_str_size = std_utoa((char*)commit_buff, line_number++);
    commit_offset += ln_str_size;
    commit_buff[commit_offset++] = ':';
    commit_buff[commit_offset++] = ' ';

    while ((bytes_read = fread(g_page_buffer, sizeof(int8_t), g_page_buffer_size, fh)) > 0)
    {
        for (size_t i = 0; i < bytes_read; i++)
        {
            commit_buff[commit_offset++] = g_page_buffer[i];
            if (commit_offset >= commit_size)
            {
                fwrite(commit_buff, sizeof(int8_t), commit_size, stdout);
                commit_offset = 0;
            }
            if (g_page_buffer[i] == '\n')
            {
                if (commit_offset + MAX_EXPECTED_LINENUMBER_LENGTH >= commit_size)
                {
                    fwrite(commit_buff, sizeof(int8_t), commit_offset, stdout);
                    commit_offset = 0;
                }

                ln_str_size = std_utoa((char*)commit_buff + commit_offset, line_number++);
                commit_offset += ln_str_size;
                commit_buff[commit_offset++] = ':';
                commit_buff[commit_offset++] = ' ';
            }
        }
    }
    if (commit_offset > 0)
    {
        fwrite(commit_buff, sizeof(int8_t), commit_offset, stdout);
    }

    free(commit_buff);
    fclose(fh);
}

void some_precompute_pages()
{
    g_page_entries_capacity = INITIAL_PAGE_COUNT;
    g_page_entries = malloc(sizeof(struct some_lookup_entry) * g_page_entries_capacity);

    int page_height = 0, page_size = 0, page_disk_size = 0, page_start_ln = 1;
    size_t page_offset = 0;
    int line_number = 1;
    
    while (fgets(g_page_buffer, g_page_buffer_size, g_file_ptr))
    {
        int format_len = digitcount(line_number) + 2; // format "%d: "
        int line_size = strlen(g_page_buffer);
        int display_len = line_size + format_len;
        int line_height = display_len / (g_terminal_width+1) + 1;
        if ((page_size + display_len > g_page_buffer_size) || (page_height + line_height > g_display_rows))
        {
            struct some_lookup_entry entry = {.line_number = page_start_ln, .page_offset = page_offset, .page_length = page_disk_size, .page_height = page_height};
            g_page_entries[g_page_entries_length++] = entry;
            //printf("ln: %d | size: %d | offset: %llu\n", page_start_ln, page_disk_size, page_offset);
            if (g_page_entries_length == g_page_entries_capacity)
            {
                g_page_entries_capacity *= 2;
                g_page_entries = realloc(g_page_entries, sizeof(struct some_lookup_entry) * g_page_entries_capacity);
            }

            page_offset += page_disk_size;
            page_size = 0;
            page_disk_size = 0;
            page_start_ln = line_number;
            page_height = 0;
        }
        page_size += display_len;
        page_disk_size += line_size;
        page_height += line_height;
        line_number++;
    }
    if (page_size > 0)
    {
        struct some_lookup_entry entry = {.line_number = page_start_ln, .page_offset = page_offset, .page_length = page_disk_size, .page_height = page_height};
        g_page_entries[g_page_entries_length++] = entry;
    }
}

void some_precompute_pages_ex()
{
    g_page_entries_capacity = 10;
    g_page_entries = malloc(sizeof(struct some_lookup_entry) * g_page_entries_capacity);

    const uint16_t max_page_size = g_page_buffer_size;

    uint16_t page_height = 0, page_size = 0, page_offset = 0, page_disk_size = 0;
    uint16_t line_len = 0;

    uint16_t line_number = 1, page_start_ln = 1;
    size_t bytes_read = 0;
    while ((bytes_read = fread(g_page_buffer, sizeof(int8_t), g_page_buffer_size, g_file_ptr)) > 0)
    {
        for (size_t i = 0; i < bytes_read; i++)
        {
            line_len++;
            int is_eof = (feof(g_file_ptr) && i == bytes_read-1);
            if (g_page_buffer[i] == '\n' || is_eof)
            {
                const uint16_t display_len = line_len + digitcount(line_number) + 2; // "%d: " format
                const int16_t line_height = (int16_t)display_len / (g_terminal_width+1) + 1;
                if (page_size + display_len > max_page_size || page_height + line_height > g_display_rows)
                {
                    fprintf(stderr, "Commit page: size %u, offset %llu, line number: %u\n", page_size, page_offset, page_start_ln);
                    struct some_lookup_entry entry = {.line_number = page_start_ln, .page_offset = page_offset, .page_length = page_disk_size, .page_height = page_height};
                    
                    g_page_entries[g_page_entries_length++] = entry;
                    if (g_page_entries_length == g_page_entries_capacity)
                    {
                        g_page_entries_capacity *= 2;
                        g_page_entries = realloc(g_page_entries, sizeof(struct some_lookup_entry) * g_page_entries_capacity);
                    }

                    page_offset += page_disk_size;
                    page_size = 0;
                    page_disk_size = 0;
                    page_start_ln = line_number;
                    page_height = 0;
                }
                
                page_size += display_len;
                page_disk_size += line_len;
                line_number++;
                line_len = 0;
                page_height += line_height;
            }
        }
    }
    if (page_size > 0)
    {
        fprintf(stderr, "Commit page: si0ze %u, offset %llu, line number: %u\n", page_size, page_offset, page_start_ln);
        struct some_lookup_entry entry = {.line_number = page_start_ln, .page_offset = page_offset, .page_length = page_disk_size, .page_height = page_height};

        g_page_entries[g_page_entries_length++] = entry;
        if (g_page_entries_length == g_page_entries_capacity)
        {
            g_page_entries_capacity *= 2;
            g_page_entries = realloc(g_page_entries, sizeof(struct some_lookup_entry) * g_page_entries_capacity);
        }

        page_offset += page_disk_size;
        page_size = 0;
        page_disk_size = 0;
    }
    fprintf(stderr, "Total bytes paged: %llu\n", page_offset);
}

void some_page_lookup(uint16_t page_num, struct some_lookup_entry* entry)
{
    *entry = g_page_entries[page_num];
}

char* puts_ln(const char* str)
{
    // Terminates on new line or NULL byte which also gets printed
    // Returns pointer to where it ended

    for (; *str != '\n' && *str; str++)
    {
        if (isprint(*str)) { putchar(*str); }
        else if (*str == '\t') { putchar(' '); }
    }
    putchar('\n');
    return (char*)str+1;
}

int some_print_page(size_t page_number)
{
    int used_rows = 0;
    struct some_lookup_entry p_entry = *(g_page_entries + page_number);
    
    fseek(g_file_ptr, p_entry.page_offset, SEEK_SET);
    int read = fread(g_page_buffer, sizeof(char), p_entry.page_length, g_file_ptr);
    g_page_buffer[p_entry.page_length] = 0;
    g_page_buffer[p_entry.page_length+1] = 0; // I boldly assume that this is not a seg fault

    char* content = g_page_buffer;
    int line_number = p_entry.line_number;
    
    while (*content) 
    {
        printf("%d: ", line_number++);
        content = puts_ln(content);
    }

    return p_entry.page_height;
}

uint16_t some_print_page_ex(struct some_lookup_entry* page_entry)
{
    uint16_t used_rows = 0;
    char line_num_str[MAX_EXPECTED_LINENUMBER_LENGTH];

    fseek(g_file_ptr, page_entry->page_offset, SEEK_SET);
    int page_char_count = (int)fread(g_page_buffer, sizeof(char), page_entry->page_length, g_file_ptr);
    g_page_buffer[page_char_count] = STRING_END_CHARACTER;

    const char* content = g_page_buffer;
    uint16_t line_num = page_entry->line_number;
    while (page_char_count > 0)
    {
        size_t line_num_str_len = std_utoa((char*)line_num_str, line_num);
        fwrite(line_num_str, sizeof(char), line_num_str_len, stdout);
        fwrite(": ", sizeof(char), 2, stdout);
        
        size_t bytes_read = 0;
        int16_t printed_chars = (int16_t)puts_ln_ex(content, &bytes_read);
        page_char_count -= bytes_read;
        content += bytes_read;
        line_num++;
        
        const int16_t display_length = line_num_str_len + 2 + printed_chars;
        used_rows += display_length / (g_terminal_width+1) + 1;
    }
    return used_rows;
}

void some_print_user_info(uint16_t curr_page)
{
    int16_t shown_perc = 100 * curr_page / g_page_entries_length;
    time_t t = time(NULL);
    struct tm tm = *localtime(&t);

    printf("%s\n", g_display_filepath);
    printf("Page: %d/%d (%d%%) %04d-%02d-%02d\n", curr_page, g_page_entries_length, shown_perc, tm.tm_year + 1900, tm.tm_mon+1, tm.tm_mday);
}

void some_paging()
{
    const int16_t filepath_len = strlen((char*)g_filepath);
    truncate_filepath((char*)g_filepath, (char*)g_display_filepath, g_terminal_width);
    some_precompute_pages();
    //some_precompute_pages_ex();
    //exit(0);

    uint16_t curr_page = 0;
    uint8_t running = 1;
    while (running)
    {
        system("clear");
        
        // Print page and add padding
        uint16_t used_rows = some_print_page(curr_page);
        for (uint16_t padding_rows = g_display_rows - used_rows; padding_rows; padding_rows--) putchar('\n');

        // Print random information
        some_print_user_info(curr_page+1);

        printf("[Q]uit | [N]ext | [P]revious : ");
        char c = getchar();
        switch (c)
        {
        case 'q':
            running = 0;
            break;
        case 'w': case 'd': case 'n':
            curr_page = curr_page + 1 >= g_page_entries_length ? curr_page : curr_page + 1;
            break;
        case 's': case 'a': case 'p':
            curr_page = curr_page ? curr_page - 1 : curr_page;
            break;
        case '\n':
            putchar('\n');
        default:
            break;
        }
    }
}

void some(int argc, const char** args)
{
    int8_t print_help_flag = 0, paging_flag = 0;
    some_parse_args(args, argc, &print_help_flag, &paging_flag);
    
    if (print_help_flag) { some_print_help(); return; }  

    g_file_ptr = fopen(g_filepath, "r");
    if (!g_file_ptr) { fprintf(stderr, "Couldn't open file \"%s\"\n", g_filepath); return; }

    some_init(paging_flag);
    if (paging_flag) some_paging();
    else some_simple();

    some_exit();
}