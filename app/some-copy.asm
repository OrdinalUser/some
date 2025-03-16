; ============= SOME program for viewing text files =============
; Written by: Tomáš Tytykalo
; Last update: 2025-03-11
; Platform: x86_64/Linux64/nasm/gcc linker
; Description: Linux 'less' style viewer with line numbers
; ====================== Goals and scoring ======================
; Assignment: 1, variation 6
; - List all input lines and prefix each with its sequence number.
; Extra goals:
; - When the ‘-p’ switch is entered, the output will be paged
; - Page traversal may go both ways
; - Display page number, total pages, percentage of already displayed output
; - When paging, display the current date and time
; - When paging, display the absolute path of the input file, if it is longer than a line,
;   it will be truncated appropriately in the middle.
; - Handle files above 16-bit limit - 64kB
; - Implemented as an external procedure (compiled separately and linked to the resulting program)
; - Proper english documentation
; ============== Mandatory / optional bonus points ==============
; Úlohy extra:
; 	1. 	+1, Po zadaní prepínača '-p' bude výstup stránkovaný, teda po zaplnení obrazovky sa počká na stlačenie klávesu.
;	2. 	+2, Stránkovanie oboma smermi, teda aj naspäť
;	3. 	+2, Pri stránkovaní sa zobrazí poradové číslo aktuálne zobrazenej strany, tiež celkový počet strán a časť už zobrazeného výstupu v percentách.
; 	4. 	+1, Pri stránkovaní sa vždy zobrazí aj aktuálny dátum a čas
;	5. 	+1, Pri stránkovaní sa vždy zobrazí aj absolútna cesta zobrazovaného (spracovávaného) vstupného súboru. Ak je dlhšia než riadok, bude v prostriedku vhodne skrátená.
;	7. 	+1, Ak budú korektne spracované vstupné súbory s veľkosťou nad 64kB
;   10. +2, Realizovaná ako externá procedúra (kompilovaná samostatne a prilinkovaná k výslednému programu)
;	12. +1, Je možné získať za (dobré) komentáre, resp. dokumentáciu, v anglickom jazyku.
; ======================= Developer notes =======================
; - memory is bottomless => malloc, realloc never fails
; - improper padding if there are control characters or non printable ASCII in general
; - improper padding especially if lines get line-wrapped, sometimes my program cannot count okay?
; - program is very much ASCII text oriented, doesn't handle anything else properly

; Defines & assumptions
%define MAX_FILEPATH_LENGTH 256
%define SIMPLE_READ_SIZE 65536
%define RESERVED_ROWS 3
%define INITIAL_PAGE_COUNT 64
%define PAGE_ENTRY_SIZE 24

extern stdin, stdout, stderr
extern printf, strcpy, fprintf, fputc, fopen, fread, fclose, puts, fgets, fseek
extern malloc, realloc, free, fflush
extern ioctl, realpath
extern putchar, getchar
extern strlen, strcpy, strncpy
extern isprint
extern time, localtime, system

section .rodata
    fmt_int: db "%d", 10, 0
    fmt_string2: db "arg[%d]: %s", 10, 0
    fmt_string: db "%s", 10, 0
    fmt_ptr: db "%p", 10, 0
    fmt_page_info: db "ln: %d | size: %d | offset: %llu", 10, 0
    fmt_string_terminal_size: db "Terminal: %d x %d", 10, 0
    debug_args_fmt: db "[Debug]: Arguments: -h %d | -p %d | filepath: %s", 10, 0
    string_paging: db "some paging", 10, 0
    
    debug_ptr_4: db "%X %X %X %X", 10, 0

    fopen_format_read: db "r", 0
    format_ln: db "%d: ", 0
    format_ln_str: db "%d: %s", 0
    format_info_page: db "Page: %d/%d (%d%%) ", 0
    format_info_date: db "%04d-%02d-%02d ", 0
    format_info_time: db "%02d:%02d:%02d", 10, 0
    command_clear: db "clear", 0
    message_help: db "Usage: some <options> <filepath>\n", 10, 9, " ex.: some -p ../cities.csv", 10, "-h : prints this information", 10, "-p : uses page system to view file", 10, 0
    message_user_commands: db "[Q]uit | [N]ext | [P]revious : ", 0
    error_fopen: db "Couldn't open file ", 34, "%s", 34, 10, 0

section .data
    g_file_ptr: dq 0
    g_page_buffer: dq 0
    g_page_buffer_size: dq 0
    g_terminal_width: dd 0
    g_terminal_height: dd 0
    g_display_rows: dd 0

; g_page_entries contains an array of
;   struct { int page_start_linenumber, int page_length, size_t page_file_offset }

section .bss
    g_filepath resb MAX_FILEPATH_LENGTH ; Will contain filepath of the processed file
    g_filepath_truncated resb MAX_FILEPATH_LENGTH ; Will contain shortened filepath
    g_page_entries resq 1; pointer to an array of page entries to be filled in precompute_pages
    g_page_entries_capacity resq 1; capacity of g_page_entries
    g_page_entries_length resq 1; lenght of page array = page count

section .text
    global some

; Params:
;   - edi: int argc,
;   - rsi: char** argv
some:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 32

    mov     BYTE [rbp-32], 0    ; flag_help
    mov     BYTE [rbp-31], 0    ; flag_paging
    lea     rdx, [rbp-32]
    lea     rcx, [rbp-31]
    call    some_parse_args

    ;call    getchar

    ; debug print processes args
    ; xor     eax, eax
    ; lea     rdi, debug_args_fmt
    ; movzx   rsi, BYTE [rbp-32]
    ; movzx   rdx, BYTE [rbp-31] 
    ; lea     rcx, [g_filepath]
    ; call    printf

    ; Print help text if flag_help was set
    movzx   eax, BYTE [rbp-32]
    cmp     eax, 0
    je      .not_print_help
    call    some_print_help
    jmp     .end
.not_print_help:
    ; Try to open file, check for whatever fopen gives back
    xor     eax, eax
    lea     rdi, [g_filepath]
    lea     rsi, [fopen_format_read]
    call    fopen
    mov     [g_file_ptr], rax
    test    rax, rax
    jz      .file_open_error
.file_opened:
    ; We have a correct file, initialize program
    movzx   rdi, BYTE [rbp-31]
    call    some_init

    ; Select simple or paged mode
    movzx   eax, BYTE [rbp-31]
    test    eax, eax
    jnz     .simple_mode
    call    some_simple
    jmp     .some_exit
.simple_mode:
    call    some_paging
.some_exit:
    ; Deallocate memory buffers and close files
    xor     eax, eax
    mov     rdi, [g_file_ptr]
    call    fclose

    mov     rdi, [g_page_buffer]
    call    free

    mov     rdi, [g_page_entries]
    call    free
.end:
    leave 
    ret
.file_open_error:
    mov     rdi, [stderr]                 ; printing to stderr
    lea     rsi, error_fopen
    lea     rdx, [g_filepath]
    call    fprintf
    jmp     .end
; Params:
;   - edi: int argc,
;   - rsi: char** argv
;   - rdx: bool* flag_help
;   - rcx: bool* flag_paging
some_parse_args:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 16
.loop:
    test    edi, edi
    jz      .loop_end

    mov     r9, [rsi]
    mov     r8b, BYTE [r9]
    cmp     r8b, '-'
    jne     .loop_not_flag
    mov     r8b, BYTE [r9+1]
    cmp     r8b, 'h'
    jne     .loop_not_help_flag
    mov     BYTE [rdx], 1
    jmp     .loop_continue
.loop_not_help_flag:
    cmp     r8b, 'p'
    jne     .loop_continue
    mov     BYTE [rcx], 1
    jmp     .loop_continue
.loop_not_flag:
    ; Assume arg is a filepath
    mov     [rbp-8], rsi
    mov     [rbp-16], edi
    mov     rdi, r9
    lea     rsi, [g_filepath]
    call    realpath
    mov     rsi, [rbp-8]
    mov     edi, [rbp-16]
.loop_continue:
    add     rsi, 8
    dec     edi
    jmp     .loop
.loop_end:
    leave
    ret

; Initializes internal variables and gathers terminal info
; Params:
;   - rdi: bool flag_paging
some_init:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 16
    mov     [rbp-8], rdi                ; save flag_paging 

    ; Get terminal information
    xor     eax, eax
    mov     edi, 1                      ; STDOUT_FILENO
    mov     esi, 21523                  ; TIOCGWINSZ
    lea     rdx, [rbp-16]               ; struct winsize*
    call    ioctl
    movzx   eax, WORD [rbp-16]
    mov     [g_terminal_height], eax
    movzx   eax, WORD [rbp-14]
    mov     [g_terminal_width], eax

    ; Calculate display properties
    mov     eax, [g_terminal_height]
    sub     eax, RESERVED_ROWS
    mov     [g_display_rows], eax

    mov     rdx, [rbp-8]
    test    rdx, rdx
    jz      .not_paging
    mov     eax, [g_terminal_width]
    mul     DWORD [g_display_rows]
    mov     [g_page_buffer_size], eax
    jmp     .page_calc_done
.not_paging:
    mov     QWORD [g_page_buffer_size], SIMPLE_READ_SIZE
.page_calc_done:
    ; Allocate page buffer from calculated size
    xor     rax, rax
    movsx   rdi, DWORD [g_page_buffer_size]
    call    malloc
    mov     [g_page_buffer], rax

    leave
    ret

; Gets size of string until the occurence of NULL or end char
;   - rdi: const char* str
;   - sil: char end
;   - ret rax: size_t length
std_strlen_c:
    push    rbp
    mov     rbp, rsp

    xor     rax, rax
.loop:
    mov     cl, BYTE [rdi]
    test    cl, cl
    jz      .end
    cmp     cl, sil
    je      .end
    add     rax, 1
    add     rdi, 1
    jmp     .loop
.end:
    leave
    ret

; Shortens a filepath string to maximum characters
;   - rdi: char* filepath
;   - rsi: char* truncated_filepath_buff
;   - edx: int   desired_length
truncate_filepath:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 24
    push    rbx
    push    r12
    push    r13
    push    r14
    push    r15
    xor     r12, r12
    xor     r13, r13

    mov     WORD [rbp-2], 0 ; int16 characters_to_truncate

    mov     r13, rdi    ; char* filepath
    mov     rbx, rsi    ; char* buff
    mov     r12d, edx   ; int max_len

    xor     rax, rax    ; Get length of filepath
    mov     rdi, r13
    call    strlen
    mov     cx, ax
    add     cx, 3
    sub     cx, r12w
    mov     WORD [rbp-2], cx ; Calculate characters_to_truncate

    lea     rdx, [r12d]
    cmp     rax, rdx
    jg      .too_long
    mov     rdi, rbx        ; Filepath fits into size
    mov     rsi, r13
    call    strcpy
    jmp     .end
.too_long:
    xor     r14, r14        ; filepath_index
    xor     r15, r15        ; buffer_index
    cmp     BYTE [r13], '/'
    jne     .first_char_not_root
    mov     BYTE [rbx], '/'
    add     r14, 1
    add     r15, 1
.first_char_not_root:
    lea     rdi, [r13+r14]  ; copy over root part
    mov     rsi, '/'
    call    std_strlen_c
    add     rax, 1          ; include '/' at the end
    mov     [rbp-16], rax   ; store root str length

    lea     rdi, [rbx+r15]
    lea     rsi, [r13+r14]
    mov     rdx, rax
    call    strncpy
    mov     rax, [rbp-16]
    add     r14, rax
    add     r15, rax

    ; truncate filepath parts starting from left
    movzx   r12, WORD [rbp-2]   ; get characters_to_truncate count
.trunc_loop:
    cmp     r12, 0
    jle     .trunc_end
    lea     rdi, [r13+r14]
    mov     sil, '/'
    call    std_strlen_c
    add     rax, 1          ; include the leading '/' as well
    add     r14, rax
    sub     r12, rax
    jmp     .trunc_loop
.trunc_end:
    ; add visual separator that we cut out part of the path
    mov     BYTE [rbx+r15+0], '.'
    mov     BYTE [rbx+r15+1], '.'
    mov     BYTE [rbx+r15+2], '/'
    add     r15, 3

    ; copy the rest of the path
    lea     rdi, [rbx+r15]
    lea     rsi, [r13+r14]
    call    strcpy
.end:
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    pop     rbx

    leave
    ret

; Returns the digit count of a number
; - edi: int number
; - eax: returns int count
digitcount:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 8
    push    rbx

    mov     rbx, 10     ; set division coeff to 10
    xor     rcx, rcx    ; set count to 0
.loop:
    test    rdi, rdi
    jz      .end

    add     rcx, 1
    mov     rax, rdi
    mov     rdx, 0
    div     rbx
    mov     rdi, rax
    jmp     .loop
.end:
    pop     rbx
    mov     rax, rcx
    leave
    ret

; Prepares internal page data to be used for displaying later
some_precompute_pages:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 48
    push    QWORD 0
    push    rbx

    ; Allocate page entries lookup table - page_num index into array
    mov     QWORD [g_page_entries_capacity], INITIAL_PAGE_COUNT
    mov     QWORD [g_page_entries_length], 0 ; just in case
    mov     rdi, INITIAL_PAGE_COUNT
    add     rdi, rdi
    add     rdi, rdi
    sal     rdi, 3
    call    malloc
    mov     [g_page_entries], rax

    mov     DWORD [rbp-4], 0        ; page_height
    mov     DWORD [rbp-8], 0        ; page_size
    mov     DWORD [rbp-12], 0       ; page_disk_size
    mov     DWORD [rbp-16], 1       ; line_number
    mov     DWORD [rbp-20], 1       ; page_start_ln
    mov     DWORD [rbp-24], 0       ; display_length
    mov     DWORD [rbp-28], 0       ; line_height
    mov     DWORD [rbp-32], 0       ; line_size
    mov     QWORD [rbp-48], 0       ; page_offset

    ; Go line by line of input file and compute page entries
.loop:
    xor     rax, rax
    mov     rdi, [g_page_buffer]
    mov     rsi, [g_page_buffer_size]
    mov     rdx, [g_file_ptr]
    call    fgets
    test    rax, rax
    jz      .loop_end
.loop_body:
    mov     edi, [rbp-16]
    call    digitcount
    add     eax, 2              ; assuming "%d: " format
    mov     [rbp-24], eax       ; holds temporary format_length
    
    mov     rdi, [g_page_buffer]
    call    strlen
    mov     [rbp-32], eax       ; holds line_size
    add     [rbp-24], eax       ; holds display_length

    mov     eax, [rbp-24]
    mov     ecx, [g_terminal_width]
    add     ecx, 1
    mov     edx, 0
    div     ecx
    add     eax, 1
    mov     [rbp-28], eax       ; holds line_height

    xor     rax, rax
    mov     eax, [rbp-8]
    add     eax, [rbp-24]
    cmp     rax, [g_page_buffer_size]   ; page_size + display_len > g_page_buffer_size
    jg      .loop_add_entry
    xor     rax, rax
    mov     eax, [rbp-4]
    add     eax, [rbp-28]
    cmp     eax, [g_display_rows]       ; (page_height + line_height > g_display_rows)
    jg      .loop_add_entry
.loop_continue:
    mov     eax, [rbp-24]
    add     [rbp-8], eax
    mov     ecx, [rbp-32]
    add     [rbp-12], ecx
    mov     edx, [rbp-28]
    add     [rbp-4], edx
    add     DWORD [rbp-16], 1
    jmp     .loop
.loop_add_entry:
    ; Add page entry into the lookup
    mov     rax, [g_page_entries_length]
    add     rax, rax
    add     rax, rax
    sal     rax, 3
    mov     rbx, [g_page_entries]
    add     rbx, rax
    
    mov     eax, [rbp-20]
    mov     [rbx+0], eax
    mov     eax, [rbp-12]
    mov     [rbx+4], eax
    mov     eax, [rbp-4]
    mov     [rbx+8], eax
    mov     rax, [rbp-48]
    mov     [rbx+16], rax
    add     QWORD [g_page_entries_length], 1

    ; DEBUG - print page entries as they're created
    ; lea     rdi, [fmt_page_info]
    ; mov     esi, [rbp-20]
    ; mov     edx, [rbp-12]
    ; mov     rcx, [rbp-48]
    ; call    printf

    ; Check if we hit page_capacity and realloc
    mov     rax, [g_page_entries_length]
    mov     rcx, [g_page_entries_capacity]
    cmp     rax, rcx
    jl      .no_realloc
.yes_realloc:
    mov     rax, [g_page_entries_capacity]
    lea     rax, [rax+rax]
    mov     [g_page_entries_capacity], rax
    add     rax, rax
    add     rax, rax
    sal     rax, 3

    mov     rdi, [g_page_entries]
    mov     rsi, rax
    call    realloc
    mov     [g_page_entries], rax
.no_realloc:
    movsx   rax, DWORD [rbp-12]
    add     [rbp-48], rax
    mov     DWORD [rbp-8], 0
    mov     DWORD [rbp-12], 0
    mov     eax, [rbp-16]
    mov     DWORD [rbp-20], eax
    mov     DWORD [rbp-4], 0
    jmp     .loop_continue

    add     DWORD [rbp-16], 1   ; Increment line number
    jmp     .loop
.loop_end:
    cmp     DWORD [rbp-8], 0
    jle     .no_remaining_data
.commit_one_last_page:
    ; Add page entry into the lookup
    mov     rax, [g_page_entries_length]
    add     rax, rax
    add     rax, rax
    sal     rax, 3
    mov     rbx, [g_page_entries]
    add     rbx, rax

    mov     eax, [rbp-20]
    mov     [rbx+0], eax
    mov     eax, [rbp-12]
    mov     [rbx+4], eax
    mov     eax, [rbp-4]
    mov     [rbx+8], eax
    mov     rax, [rbp-48]
    mov     [rbx+16], rax
    add     QWORD [g_page_entries_length], 1

    ; ln: 737 | size: 124 | offset: 19885

    ; DEBUG - print page entries as they're created
    ; lea     rdi, [fmt_page_info]
    ; mov     esi, [rbx+0]    ; how is [rdx+ 0] != [rbp-20]
    ; mov     edx, [rbx+4]    ; how is [rdx+ 4] != [rbp-12]
    ; mov     rcx, [rbx+16]   ; how is [rdx+16] != [rbp-48]
    ; call    printf
.no_remaining_data:
    pop     rbx

    leave
    ret

; Prints string until encountering newline or NULL
; - rdi: char* string
; - rax: returns address to next line
; Disclaimer: Be warned that content needs to be marked with 2 consecutive NULL bytes!!!
puts_ln:
    push    rbp
    mov     rbp, rsp

    push    r12
    push    rbx
    mov     rbx, rdi
.loop:
    movzx   r12d, BYTE [rbx]
    test    r12d, r12d
    jz      .loop_end
    cmp     r12d, 10            ; compare to ASCII newline '\n'
    je      .loop_end
.loop_body:    
    cmp     r12d, 9             ; compare to ASCII tab '\t'
    jne     .not_tab
    mov     edi, 32
    call    putchar
.not_tab:
    mov     edi, r12d
    call    putchar
.loop_continue:
    add     rbx, 1
    jmp     .loop
.loop_end:
    mov     edi, 10
    call    putchar

    lea     rax, [rbx+1]
    pop     rbx
    pop     r12
    leave
    ret

; Prints page by index
;   - rdi: page index into g_page_entries
;   - eax: returns used rows by page
some_print_page:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 48

    mov     DWORD [rbp-8], 0        ; page_start_ln
    mov     DWORD [rbp-12], 0       ; page_length
    mov     DWORD [rbp-16], 0       ; page_height
    mov     QWORD [rbp-24], 0       ; page_file_offset
    mov     QWORD [rbp-32], 0       ; page_chars_read

    ; get page_entry from page_index
    mov     rax, rdi
    add     rax, rax
    add     rax, rax
    sal     rax, 3
    mov     rbx, [g_page_entries]
    add     rbx, rax

    mov     edx, [rbx]
    mov     [rbp-8], edx
    mov     ecx, [rbx+4]
    mov     [rbp-12], ecx
    mov     ecx, [rbx+8]
    mov     [rbp-16], ecx
    mov     rdx, [rbx+16]
    mov     [rbp-24], rdx

    ; set file_ptr to where our page starts
    mov     rdi, [g_file_ptr]
    mov     rsi, [rbp-24]
    mov     rdx, 0                  ; SEEK_SET
    call    fseek

    ; read entire page data into buffer
    mov     rdi, [g_page_buffer]
    mov     rsi, 1                  ; sizeof(char)
    movsx   rdx, DWORD [rbp-12]
    mov     rcx, [g_file_ptr]
    call    fread
    mov     [rbp-32], rax           ; store read chars

    ; mark end of content
    movsx   rcx, DWORD [rbp-12]
    mov     rbx, [g_page_buffer]
    mov     BYTE [rbx+rcx], 0
    mov     BYTE [rbx+rcx+1], 0

    push    r12
    push    rbx
    xor     r12, r12
    mov     r12d, [rbp-8]           ; line_number
    mov     rbx, [g_page_buffer]    ; content ptr

.loop:
    movzx   ecx, BYTE [rbx]
    test    ecx, ecx
    jz      .loop_end
.loop_body:
    lea     rdi, [format_ln]
    mov     esi, r12d
    call    printf                  ; print line number
    add     r12d, 1
    mov     rdi, rbx
    call    puts_ln                 ; print line terminated by newline
    mov     rbx, rax
    jmp     .loop
.loop_end:
    pop     rbx
    pop     r12
    mov     eax, [rbp-16]
    leave
    ret

; Keeps value between inclusive bounds
; - rdi: value
; - rsi: min
; - rdx: max
; - rax: ret clamed vale
clamp:
    push    rbp
    mov     rbp, rsp
    cmp     rdi, rdx
    jg      .bigger_than_max
    cmp     rdi, rsi
    jl      .less_than_min
    mov     rax, rdi
    jmp     .end
.bigger_than_max:
    mov     rax, rdx
    jmp     .end
.less_than_min:
    mov     rax, rsi
    jmp     .end
.end:
    leave
    ret

; Prints truncated filepath, page count and total read, current time data
;   - edi: current page 0 indexed
some_print_user_info:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 64
    push    r12
    push    rbx

    add     rdi, 1
    mov     r12d, edi   ; holds current page 1-indexed

    mov     eax, edi
    imul    eax, eax, 100
    cdqe
    mov     rcx, [g_page_entries_length]
    mov     edx, 0
    div     rcx
    mov     rbx, rax

    ; Print filepath
    lea     rdi, [fmt_string]
    lea     rsi, [g_filepath_truncated]
    call    printf

    ; Print page info
    lea     rdi, [format_info_page]
    mov     esi, r12d
    mov     rdx, [g_page_entries_length]
    mov     rcx, rbx
    call    printf

    ; Get date info & print
    mov     edi, 0
    call    time
    mov     [rbp-64], rax
    lea     rdi, [rbp-64]
    call    localtime
    mov     r12, rax
    lea     rdi, [format_info_date]
    mov     esi, [r12+20]
    add     esi, 1900
    mov     edx, [r12+16]
    add     edx, 1
    mov     ecx, [r12+12]
    call    printf

    ; Get time info & print
    lea     rdi, [format_info_time]
    mov     esi, [r12+8]
    mov     edx, [r12+4]
    mov     ecx, [r12]
    call    printf

    pop     rbx
    pop     r12
    leave
    ret

some_paging:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 32

    lea     rdi, [g_filepath]
    lea     rsi, [g_filepath_truncated]
    mov     edx, [g_terminal_width] ; assuming that terminal width is less than max filepath
    call    truncate_filepath

    call    some_precompute_pages

    push    r13
    push    r12

    mov     r12, 0          ; holds current page index
.loop:
    lea     rdi, [command_clear]
    call    system

    mov     rdi, r12
    call    some_print_page
    mov     r13, [g_display_rows]
    sub     r13d, eax       ; holds how many padding rows to add
    ; Add padding
.padding_loop:
    test    r13d, r13d
    jz      .padding_loop_end
    sub     r13d, 1
    mov     edi, 10
    call    putchar
    jmp     .padding_loop
.padding_loop_end:

    ; Print info
    mov     rdi, r12
    call    some_print_user_info

    ; Get user command
    lea     rdi, [message_user_commands]
    call    printf
    call    getchar
    cmp     eax, 'q'
    jne     .cmd_not_quit
    jmp     .end
.cmd_not_quit:
    cmp     eax, 'n'
    jne     .cmd_not_next
    add     r12, 1
    jmp     .loop_continue
.cmd_not_next:
    cmp     eax, 'p'
    jne     .cmd_not_previous
    sub     r12, 1
    jmp     .loop_continue
.cmd_not_previous:
    cmp     eax, 10
    jne     .loop_continue
    mov     edi, 10
    call    putchar
.loop_continue:
    mov     rdi, r12
    mov     rsi, 0
    mov     rdx, [g_page_entries_length]
    sub     rdx, 1
    call    clamp
    mov     r12, rax
    jmp     .loop
.end:
    pop    r12
    pop    r13
    leave
    ret

some_simple:
    push    rbp
    mov     rbp, rsp
    push    rbx
    sub     rsp, 8
    mov     rbx, 1 ; Holds line number
    
.loop:
    xor     rax, rax
    mov     rdi, [g_page_buffer]
    mov     rsi, [g_page_buffer_size]
    mov     rdx, [g_file_ptr]
    call    fgets
    test    rax, rax
    jz      .end
.loop_body:
    xor     eax, eax
    lea     rdi, [format_ln_str]
    mov     rsi, rbx
    mov     rdx, [g_page_buffer]
    call    printf
    inc     rbx
    jmp     .loop
.end:
    pop     rbx
    leave
    ret

some_print_help:
    push    rbp
    mov     rbp, rsp
    xor     eax, eax
    mov     rdi, [stderr]
    lea     rsi, message_help
    call    fprintf
    leave
    ret

section .note.GNU-stack noalloc noexec nowrite progbits