#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <ctype.h>

// == Globals ==
#define MAX_FILEPATH_LENGTH 240
#define MSDOS_MAX_FILEPATH_LENGTH 79

#define STRING_END_CHARACTER '\0'
#define DOS_STRING_END_CHARACTER '$'

#define MAX_EXPECTED_LINENUMBER_LENGTH 12

int16_t g_terminal_width;
int16_t g_terminal_height;
int16_t g_reserved_rows = 3;
int16_t g_display_rows;
int8_t* g_page_buffer;
int16_t g_page_buffer_size;
int8_t* g_filepath[MAX_FILEPATH_LENGTH] = {0};
int8_t* g_display_filepath[MAX_FILEPATH_LENGTH] = {0};
int8_t g_filepath_len;

int8_t g_print_help = 0;
int8_t g_paging = 0;

// Platform dependent -- linux
#include <sys/ioctl.h>
#include <unistd.h>

void p_read_terminal_dimensions()
{
    struct winsize w;
    ioctl(STDOUT_FILENO, TIOCGWINSZ, &w);
    g_terminal_width = w.ws_col;
    g_terminal_height = w.ws_row;
}

// State
void some_init()
{
    p_read_terminal_dimensions();
    g_display_rows = g_terminal_height - g_reserved_rows;
    if (g_paging) g_page_buffer_size = g_terminal_width * g_display_rows;
    else g_page_buffer_size = 1024 * 4;
    g_page_buffer = malloc(g_page_buffer_size);
    fprintf(stderr, "Terminal size: %dx%d\n", g_terminal_width, g_terminal_height);
}

void some_exit()
{
    free(g_page_buffer);
}

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

// == Other functions
void debug_print_info(const char* args)
{
    fprintf(stderr, "Args: %s\n", args);
    fprintf(stderr, "Terminal: %ux%u\n", g_terminal_width, g_terminal_height);
    fprintf(stderr, "Page buffer size: %d\n", g_page_buffer_size);
    fprintf(stderr, "Filepath: %s\n", g_filepath);
    fprintf(stderr, "Flags: Print help = %d , Use paging = %d\n", g_print_help, g_paging);
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

// Terminates on new line or NULL byte which also gets printed
// Returns count of printed characters
size_t puts_ln(const char* str, size_t* bytes_read)
{
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

void truncate_filepath(const char* filepath, char* buffer, uint16_t filepath_len, uint16_t max_len)
{
    if (filepath_len < max_len-3) { std_strcpy(buffer, filepath); return; }
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


// == Main Program
void some_print_help()
{
    fprintf(stderr, "Usage: some <options> <filepath>\n");
    fprintf(stderr, "\t ex.: some -p ../cities.h\n");
    fprintf(stderr, "-h : prints this information\n-p : uses page system to view file\n");
}

void some_parse_arg_string(const char* args)
{
    const char terminator = STRING_END_CHARACTER; 
    char* p = (char*)args;
    while (*p != terminator)
    {
        if (*p == '-')
        {
            p++;
            if (*p == 'h') { g_print_help = 1; p++; return; }
            else if (*p == 'p') { g_paging = 1; p++; continue; }
        }
        else if (*p == ' ') { p++; continue; }
        else
        {
            int16_t copied_bytes = copy_path_string((char*)&g_filepath, p);
            g_filepath_len = std_strlen_c((char*)g_filepath, ' ');
            p += copied_bytes;
            continue;
        }
        p++;
    }
}

void some_simple()
{
    FILE* fh = fopen((const char*)&g_filepath, "rb");

    const int commit_size = 4096;
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

struct some_lookup_entry
{
    uint16_t line_number, page_segment, page_offset, page_length;
};

size_t some_precompute_pages(FILE* fh_in)
{
    size_t page_count = 0;
    FILE* fh = fopen("lookup.bin", "wb+");
    const uint16_t max_page_size = g_page_buffer_size;

    size_t debug_total_size = 0;

    uint16_t page_height = 0, page_size = 0, page_segment = 0, page_offset = 0, on_disk_size = 0;
    uint16_t line_len = 0;

    uint16_t line_number = 1, start_ln = 1;
    size_t bytes_read = 0;
    while ((bytes_read = fread(g_page_buffer, sizeof(int8_t), g_page_buffer_size, fh_in)) > 0)
    {
        for (size_t i = 0; i < bytes_read; i++)
        {
            line_len++;
            int is_eof = (feof(fh_in) && i == bytes_read-1);
            if (g_page_buffer[i] == '\n' || is_eof)
            {
                const uint16_t display_len = line_len + digitcount(line_number) + 2; // "%d: " format
                const int16_t line_height = (int16_t)display_len / (g_terminal_width+1) + 1;
                if (page_size + display_len > max_page_size || page_height + line_height > g_display_rows)
                {
                    fprintf(stderr, "Commit page: segment %u, offset %u, length: %u, line number: %u\n", page_segment, page_offset, on_disk_size, start_ln);
                    struct some_lookup_entry entry = {start_ln, page_segment, page_offset, on_disk_size};
                    fwrite(&entry, sizeof(struct some_lookup_entry), 1, fh);
                    page_segment += on_disk_size / 16;
                    page_offset += on_disk_size % 16;
                    debug_total_size += on_disk_size;
                    page_size = 0;
                    on_disk_size = 0;
                    start_ln = line_number;
                    page_height = 0;
                    page_count++;
                }
                
                page_size += display_len;
                on_disk_size += line_len;
                line_number++;
                line_len = 0;
                page_height += line_height;
            }
        }
    }
    if (page_size > 0)
    {
        struct some_lookup_entry entry = {start_ln, page_segment, page_offset, on_disk_size};
        fwrite(&entry, sizeof(struct some_lookup_entry), 1, fh);
        fprintf(stderr, "Commit page: segment %u, offset %u, length: %u, line number: %u\n", page_segment, page_offset, on_disk_size, start_ln);
        page_segment += on_disk_size / 16;
        page_offset += on_disk_size % 16;
        debug_total_size += on_disk_size;
        page_size = 0;
        on_disk_size = 0;
        page_count++;
    }
    fprintf(stderr, "Total bytes paged: %llu\n", debug_total_size);
    fclose(fh);
    return page_count;
}

void some_debug_lookup(FILE* fh, uint16_t page_num, uint16_t* segment, uint16_t* offset, uint16_t* length, uint16_t* line_number)
{
    // uint16_t file_seg_dx = page_num & 0xff00 * sizeof(struct some_lookup_entry);
    // uint16_t file_offset_cx = page_num & 0xff * sizeof(struct some_lookup_entry);
    // now add both high words of each?
    // adc to another register for overflow
    // wtf is this shit

    // int 42h - seek to ds:dx
    size_t debug_file_offset = page_num * sizeof(struct some_lookup_entry); // :) - go consult some shit to figure out 32-bit viable multiplication on 16-bit nigga computer
    fprintf(stderr, "File seek to: %llu\n", debug_file_offset);
    fseek(fh, debug_file_offset, SEEK_SET);

    struct some_lookup_entry e;
    fread(&e, sizeof(struct some_lookup_entry), 1, fh);
    *line_number = e.line_number;
    *segment = e.page_segment;
    *offset = e.page_offset;
    *length = e.page_length;
}

void some_page_lookup(FILE* fh, uint16_t page_num, struct some_lookup_entry* entry)
{
    size_t file_entry_offset = page_num * sizeof(struct some_lookup_entry); // :) - go consult some shit to figure out 32-bit viable multiplication on 16-bit nigga computer
    fseek(fh, file_entry_offset, SEEK_SET);
    fread(entry, sizeof(struct some_lookup_entry), 1, fh);
}

void debug_print_page(FILE* data_fh, FILE* lookup_fh, uint16_t page_num)
{
    char line_num_str[20];

    uint16_t seg, off, len, ln;
    some_debug_lookup(lookup_fh, page_num, &seg, &off, &len, &ln);
    size_t debug_absolute_offset = seg * 16 + off;
    fprintf(stderr, "Page %d - seg: %u, off: %u, length: %u, ln: %u | 64-bit offset: %llu\n", page_num, seg, off, len, ln, debug_absolute_offset);
    char* page_content = malloc(len);
    fprintf(stderr, "=========================================\n");
    fseek(data_fh, seg*16 + off, SEEK_SET);
    
    int page_char_count = (int)fread(page_content, sizeof(char), len, data_fh);
    page_content[len-1] = STRING_END_CHARACTER;

    const char* content = page_content;
    uint16_t line_num = ln;
    size_t bytes_read = 0;
    while (page_char_count > 0)
    {
        size_t line_num_str_len = std_utoa((char*)line_num_str, line_num);
        fwrite(line_num_str, sizeof(char), line_num_str_len, stdout);
        fwrite(": ", sizeof(char), 2, stdout);
        int16_t printed_chars = (int16_t)puts_ln(content, &bytes_read);
        page_char_count -= bytes_read; // 
        line_num++;
        content += bytes_read;
    }

    fprintf(stderr, "=========================================\n");
    free(page_content);
}

uint16_t print_page(FILE* data_fh, struct some_lookup_entry* page_entry)
{
    uint16_t used_rows = 0;
    char line_num_str[MAX_EXPECTED_LINENUMBER_LENGTH];

    fseek(data_fh, page_entry->page_segment*16 + page_entry->page_offset, SEEK_SET);
    int page_char_count = (int)fread(g_page_buffer, sizeof(char), page_entry->page_length, data_fh);
    g_page_buffer[page_char_count] = STRING_END_CHARACTER;

    const char* content = g_page_buffer;
    uint16_t line_num = page_entry->line_number;
    while (page_char_count > 0)
    {
        size_t line_num_str_len = std_utoa((char*)line_num_str, line_num);
        fwrite(line_num_str, sizeof(char), line_num_str_len, stdout);
        fwrite(": ", sizeof(char), 2, stdout);
        
        size_t bytes_read = 0;
        int16_t printed_chars = (int16_t)puts_ln(content, &bytes_read);
        page_char_count -= bytes_read;
        content += bytes_read;
        line_num++;
        
        const int16_t display_length = line_num_str_len + 2 + printed_chars;
        used_rows += display_length / (g_terminal_width+1) + 1;
    }
    return used_rows;
}

void debug_print_all_pages(FILE* data_fh, FILE* lookup_fh)
{
    fseek(lookup_fh, 0, SEEK_END);
    int lookup_file_size = ftell(lookup_fh);
    
    uint16_t page_count = lookup_file_size / sizeof(struct some_lookup_entry);
    fprintf(stderr, "Total pages: %u\n", page_count);
    for (uint16_t i = 0; i < page_count; i++)
    {
        debug_print_page(data_fh, lookup_fh, i);
        getchar();
        system("clear");
    }
}

// curr_page should be 1-indexed
void some_print_user_info(uint16_t curr_page, uint16_t page_count)
{
    // ; - Display page number, total pages, percentage of already displayed output
    // ; - When paging, display the current date and time
    // ; - When paging, display the absolute path of the input file, if it is longer than a line,
    // ;   it will be truncated appropriately in the middle.
    int16_t shown_perc = 100 * curr_page / page_count;
    time_t t = time(NULL);
    struct tm tm = *localtime(&t);

    printf("%s\n", g_display_filepath);
    printf("Page: %d / %d (%d%%) %04d-%02d-%02d\n", curr_page, page_count, shown_perc, tm.tm_year + 1900, tm.tm_mon+1, tm.tm_mday);
}

void some_paging()
{
    truncate_filepath((char*)g_filepath, (char*)g_display_filepath, g_filepath_len, g_terminal_width);

    //g_page_buffer_size = 30;
    FILE* fh = fopen((const char*)&g_filepath, "rb");
    size_t page_count = some_precompute_pages(fh);

    FILE* lookup_fh = fopen("lookup.bin", "rb");
    //debug_print_all_pages(fh, lookup_fh);

    uint16_t curr_page = 0;
    struct some_lookup_entry curr_entry;
    
    uint8_t running = 1;
    while (running)
    {
        system("clear");
        some_page_lookup(lookup_fh, curr_page, &curr_entry);
        
        // Print page and add padding
        uint16_t used_rows = print_page(fh, &curr_entry);
        for (uint16_t padding_rows = g_display_rows - used_rows; padding_rows; padding_rows--) putchar('\n');

        // Print random information
        some_print_user_info(curr_page+1, page_count);

        printf("[Q]uit | [N]ext | [P]revious : ");
        char c = getchar();
        switch (c)
        {
        case 'q':
            running = 0;
            break;
        case 'w': case 'd': case 'n':
            curr_page = curr_page + 1 >= page_count ? curr_page : curr_page + 1;
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

void some(char* args)
{
    some_parse_arg_string(args);
    if (g_print_help)
    {
        some_print_help();
        some_exit();
        return;
    }   
    some_init();

    if (g_paging) some_paging();
    else some_simple();

    //debug_print_info(args);

    some_exit();
}