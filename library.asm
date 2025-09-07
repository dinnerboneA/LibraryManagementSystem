



.MODEL SMALL
.STACK 100H

.DATA




    ; System Constants
    MAX_BOOKS equ 10
    TITLE_LEN equ 20
    AUTHOR_LEN equ 20

    
    
    
    ; System Strings
    menu_msg      db 13, 10, 'Library Management System $'
    menu_options  db 13, 10, '1. Add Book', 13, 10
                  db '2. Borrow Book', 13, 10
                  db '3. Return Book', 13, 10
                  db '4. Display Books', 13, 10
                  db '5. Search Book', 13, 10
                  db '6. Clear All Books', 13, 10
                  db '7. System Info', 13, 10
                  db '8. Exit', 13, 10
                  db '> Choice: $'
    
    add_id_msg    db 13, 10, 'Enter Book ID (1-999): $'
    add_title_msg db 13, 10, 'Enter Title (max 19 chars): $'
    add_author_msg db 13, 10, 'Enter Author (max 19 chars): $'
    borrow_msg    db 13, 10, 'Enter Book ID to borrow: $'
    return_msg    db 13, 10, 'Enter Book ID to return: $'
    late_msg      db 13, 10, 'Days late: $'
    fine_msg      db 13, 10, 'Fine: $$'
    search_msg    db 13, 10, 'Enter title to search: $'
    status_avail  db 'Available$'
    status_borr   db 'Borrowed$'
    header        db 13, 10, 'ID    Status    Title            Author$'
    divider       db 13, 10, '----------------------------------------$'
    err_msg       db 13, 10, 'Error: Invalid input!$'
    not_found_msg db 13, 10, 'Book not found!$'
    borrowed_msg  db 13, 10, 'Book already borrowed!$'
    not_borrowed_msg db 13, 10, 'Book was not borrowed!$'
    full_msg      db 13, 10, 'Database full!$'
    cleared_msg   db 13, 10, 'All books cleared!$'
    exit_msg      db 13, 10, 'Exiting...$'
    press_key_msg db 13, 10, 'Press any key to continue...$'
    newline       db 13, 10, '$'
    stats_msg     db 13, 10, 'System Information $'
    total_books_msg db 13, 10, 'Total books: $'
    borrowed_books_msg db 13, 10, 'Borrowed books: $'
    total_fine_msg db 13, 10, 'Total fines collected: $$'
    help_msg      db 13, 10, 'Help $'
    help_text     db 13, 10, '1. Add Book: Add new book to system', 13, 10
                  db '2. Borrow Book: Check out a book', 13, 10
                  db '3. Return Book: Return a book (with fine if late)', 13, 10
                  db '4. Display Books: Show all books', 13, 10
                  db '5. Search Book: Find book by title', 13, 10
                  db '6. Clear All: Remove all books', 13, 10
                  db '7. System Info: Show statistics', 13, 10
                  db '8. Exit: Quit program$'

                  
                  
                  
    ; Book Data Structures
    book_ids      dw MAX_BOOKS dup(0)
    book_titles   db MAX_BOOKS * TITLE_LEN dup('$')
    book_authors  db MAX_BOOKS * AUTHOR_LEN dup('$')
    book_status   db MAX_BOOKS dup(0)
    
    ; System Variables
    book_count    dw 0
    total_fine    dw 0
    borrowed_count dw 0
    
    ; Input Buffers
    input_buffer  db 20, ?, 20 dup('$')
    search_buffer db 20, ?, 20 dup('$')
    num_buffer    db 5, ?, 5 dup('$')

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    MOV ES, AX      

    
    
    
    
    
main_loop:
    CALL display_menu
    
    
    
    
    
    
    CALL get_choice
    
    
    
    
    ; Process menu choice
    CMP AL, '1'
    JE do_add_book
    CMP AL, '2'
    JE do_borrow_book
    CMP AL, '3'
    JE do_return_book
    CMP AL, '4'
    JE do_display_books
    CMP AL, '5'
    JE do_search_book
    CMP AL, '6'
    JE do_clear_books
    CMP AL, '7'
    JE do_system_info
    CMP AL, '8'
    JE exit_program
    
    
    ; Invalid input
    CALL show_error
    JMP wait_and_continue

do_add_book:
    CALL add_book
    JMP wait_and_continue

    
    
do_borrow_book:
    CALL borrow_book
    JMP wait_and_continue

    
    
do_return_book:
    CALL return_book
    JMP wait_and_continue

do_display_books:
    CALL display_books
    JMP wait_and_continue

    
do_search_book:
    CALL search_book
    JMP wait_and_continue

    
    
do_clear_books:
    CALL clear_books
    JMP wait_and_continue

    
do_system_info:
    CALL system_info
    JMP wait_and_continue

wait_and_continue:
    CALL press_to_continue
    JMP main_loop

    
    
exit_program:
    CALL exit_cleanly
MAIN ENDP








; MAIN PROCEDURES 



display_menu PROC
    CALL clear_screen
    LEA DX, menu_msg
    CALL print_string
    LEA DX, menu_options
    CALL print_string
    RET
display_menu ENDP



get_choice PROC
    MOV AH, 01H      
    INT 21H          
    
    ; Save user input
    MOV BL, AL       
   
    MOV AH, 0CH
    MOV AL, 00H
    INT 21H

    ; Restore character to AL
    MOV AL, BL
    RET
get_choice ENDP



add_book PROC
    CALL clear_screen
    
    ; Check if database is full
    MOV AX, book_count
    CMP AX, MAX_BOOKS
    JL add_continue
    LEA DX, full_msg
    CALL print_string
    RET

add_continue:
    ; Get book ID
    LEA DX, add_id_msg
    CALL print_string
    CALL read_number
    MOV BX, book_count
    SHL BX, 1        
    MOV book_ids[BX], AX
    
    ; Get book title
    LEA DX, add_title_msg
    CALL print_string
    LEA DX, input_buffer
    CALL read_string
    
    ; Store title
    MOV AX, book_count
    MOV CX, TITLE_LEN
    MUL CX
    LEA DI, book_titles
    ADD DI, AX
    LEA SI, input_buffer + 2  
    CALL copy_string
    
    ; Get author
    LEA DX, add_author_msg
    CALL print_string
    LEA DX, input_buffer
    CALL read_string
    
    ; Store author
    MOV AX, book_count
    MOV CX, AUTHOR_LEN
    MUL CX
    LEA DI, book_authors
    ADD DI, AX
    LEA SI, input_buffer + 2
    CALL copy_string
    
    ; Set as available
    MOV BX, book_count
    MOV book_status[BX], 0
    
    ; Increment book count
    INC book_count
    RET
add_book ENDP




borrow_book PROC
    CALL clear_screen
    
    ; Check if there are books
    CMP book_count, 0
    JNE borrow_continue
    LEA DX, not_found_msg
    CALL print_string
    RET

borrow_continue:
    LEA DX, borrow_msg
    CALL print_string
    CALL read_number
    
    ; Search for book
    MOV CX, book_count
    MOV BX, 0
search_borrow_loop:
    CMP book_ids[BX], AX
    JE found_borrow
    ADD BX, 2
    LOOP search_borrow_loop
    
    ; Book not found
    LEA DX, not_found_msg
    CALL print_string
    RET

found_borrow:
    SHR BX, 1        
    CMP book_status[BX], 0
    JE can_borrow
    
    ; Book already borrowed
    LEA DX, borrowed_msg
    CALL print_string
    RET

can_borrow:
    MOV book_status[BX], 1
    INC borrowed_count
    RET
borrow_book ENDP





return_book PROC
    CALL clear_screen
    
    ; Check if there are books
    CMP book_count, 0
    JNE return_continue
    LEA DX, not_found_msg
    CALL print_string
    RET

return_continue:
    LEA DX, return_msg
    CALL print_string
    CALL read_number
    
    ; Search for book
    MOV CX, book_count
    MOV BX, 0
search_return_loop:
    CMP book_ids[BX], AX
    JE found_return
    ADD BX, 2
    LOOP search_return_loop
    
    ; Book not found
    LEA DX, not_found_msg
    CALL print_string
    RET

found_return:
    SHR BX, 1        
    CMP book_status[BX], 1
    JE can_return
    
    ; Book wasn't borrowed
    LEA DX, not_borrowed_msg
    CALL print_string
    RET

can_return:
    ; Get days late
    LEA DX, late_msg
    CALL print_string
    CALL read_number
    MOV DX, AX       
    
    ; Calculate fine 
    ADD total_fine, AX
    
    ; Display fine
    LEA DX, fine_msg
    CALL print_string
    MOV AX, DX
    CALL print_number
    
    ; Mark as available
    MOV book_status[BX], 0
    DEC borrowed_count
    RET
return_book ENDP





display_books PROC
    CALL clear_screen
    
    ; Check if there are books
    CMP book_count, 0
    JNE display_continue
    LEA DX, not_found_msg
    CALL print_string
    RET

display_continue:
    LEA DX, header
    CALL print_string
    LEA DX, divider
    CALL print_string
    
    MOV CX, book_count
    MOV BX, 0        ; Book index
display_loop:
    ; Display book info
    CALL print_newline
    
    ; Display ID
    PUSH BX
    SHL BX, 1        
    MOV AX, book_ids[BX]
    CALL print_number
    POP BX
    
    CALL print_tab
    
    ; Display status
    LEA DX, status_avail
    CMP book_status[BX], 1
    JNE display_status
    LEA DX, status_borr
display_status:
    CALL print_string
    CALL print_tab
    
    ; Display title
    PUSH BX
    MOV AX, BX
    MOV CX, TITLE_LEN
    MUL CX
    LEA DX, book_titles
    ADD DX, AX
    CALL print_string
    CALL print_tab
    
    ; Display author
    POP BX
    PUSH BX
    MOV AX, BX
    MOV CX, AUTHOR_LEN
    MUL CX
    LEA DX, book_authors
    ADD DX, AX
    CALL print_string
    POP BX
    
    INC BX
    LOOP display_loop
    
    RET
display_books ENDP







search_book PROC
    CALL clear_screen
    
    ; Check if there are books
    CMP book_count, 0
    JNE search_continue
    LEA DX, not_found_msg
    CALL print_string
    RET

search_continue:
    LEA DX, search_msg
    CALL print_string
    LEA DX, search_buffer
    CALL read_string
    
    MOV CX, book_count
    MOV BX, 0        ; Book index
search_loop:
    ; Compare titles
    PUSH BX
    MOV AX, BX
    MOV DX, TITLE_LEN
    MUL DX
    LEA SI, book_titles
    ADD SI, AX
    LEA DI, search_buffer + 2
    CALL compare_strings
    POP BX
    JC found_search
    
    INC BX
    LOOP search_loop
    
    ; Book not found
    LEA DX, not_found_msg
    CALL print_string
    RET

found_search:
    ; Display found book
    CALL print_newline
    CALL print_newline
    LEA DX, header
    CALL print_string
    CALL print_newline
    
    ; Display ID
    PUSH BX
    SHL BX, 1        
    MOV AX, book_ids[BX]
    CALL print_number
    POP BX
    
    CALL print_tab
    
    ; Display status
    LEA DX, status_avail
    CMP book_status[BX], 1
    JNE display_search_status
    LEA DX, status_borr
display_search_status:
    CALL print_string
    CALL print_tab
    
    ; Display title
    PUSH BX
    MOV AX, BX
    MOV CX, TITLE_LEN
    MUL CX
    LEA DX, book_titles
    ADD DX, AX
    CALL print_string
    CALL print_tab
    
    ; Display author
    POP BX
    MOV AX, BX
    MOV CX, AUTHOR_LEN
    MUL CX
    LEA DX, book_authors
    ADD DX, AX
    CALL print_string
    
    RET
search_book ENDP








clear_books PROC
    CALL clear_screen
    
    
    ; Reset all book data
    MOV CX, MAX_BOOKS
    MOV BX, 0
clear_loop:
    MOV book_ids[BX], 0
    ADD BX, 2
    LOOP clear_loop
    
    
    
    
    ; Clear titles and authors
    MOV CX, MAX_BOOKS * TITLE_LEN
    LEA DI, book_titles
    MOV AL, '$'
    REP STOSB
    
    MOV CX, MAX_BOOKS * AUTHOR_LEN
    LEA DI, book_authors
    MOV AL, '$'
    REP STOSB
    
    
    
    
    ; Clear statuses
    MOV CX, MAX_BOOKS
    LEA DI, book_status
    MOV AL, 0
    REP STOSB
    
    
    
    
    ; Reset counters
    MOV book_count, 0
    MOV borrowed_count, 0
    
    LEA DX, cleared_msg
    CALL print_string
    RET
clear_books ENDP





system_info PROC
    CALL clear_screen
    LEA DX, stats_msg
    CALL print_string
    
    
    
    
    ; Display total books
    LEA DX, total_books_msg
    CALL print_string
    MOV AX, book_count
    CALL print_number
    
    
    
    
    
    ; Display borrowed books
    LEA DX, borrowed_books_msg
    CALL print_string
    MOV AX, borrowed_count
    CALL print_number
    
    
    
    
    
    ; Display total fines
    LEA DX, total_fine_msg
    CALL print_string
    MOV AX, total_fine
    CALL print_number
    
    
    
    
    
    ; Display help
    CALL print_newline
    LEA DX, help_msg
    CALL print_string
    LEA DX, help_text
    CALL print_string
    
    RET
system_info ENDP






show_error PROC
    LEA DX, err_msg
    CALL print_string
    RET
show_error ENDP





press_to_continue PROC
    LEA DX, press_key_msg
    CALL print_string
    MOV AH, 01H
    INT 21H
    RET
press_to_continue ENDP




exit_cleanly PROC
    CALL clear_screen
    LEA DX, exit_msg
    CALL print_string
    MOV AH, 4CH
    INT 21H
    RET
exit_cleanly ENDP




;UTILITY PROCEDURES 

print_string PROC
    MOV AH, 09H
    INT 21H
    RET
print_string ENDP





read_string PROC
    MOV AH, 0AH
    INT 21H
    RET
read_string ENDP




print_number PROC
    ; Print 16-bit number in AX
    PUSH BX
    PUSH CX
    PUSH DX
    
    
    
    
    ; Handle zero case
    CMP AX, 0
    JNE print_num_cont
    MOV DL, '0'
    MOV AH, 02H
    INT 21H
    JMP print_num_done

    
    
    
print_num_cont:
    MOV BX, 10
    XOR CX, CX       
    
    
    
    ; Push digits onto stack
extract_digits:
    XOR DX, DX
    DIV BX
    PUSH DX
    INC CX
    CMP AX, 0
    JNE extract_digits
    
    
    
    
    ; Pop and print digits
print_digits:
    POP DX
    ADD DL, '0'
    MOV AH, 02H
    INT 21H
    LOOP print_digits

print_num_done:
    POP DX
    POP CX
    POP BX
    RET
print_number ENDP





read_number PROC
    ; Read multi-digit number (returns in AX)
    PUSH BX
    PUSH CX
    PUSH DX
    
    LEA DX, num_buffer
    MOV AH, 0AH
    INT 21H
    
    ; Convert to number
    LEA SI, num_buffer + 2
    MOV CL, num_buffer + 1  
    MOV CH, 0
    JCXZ read_num_done
    
    XOR AX, AX
    MOV BX, 10
    
read_num_loop:
    MUL BX
    MOV DL, [SI]
    SUB DL, '0'
    ADD AX, DX
    INC SI
    LOOP read_num_loop

read_num_done:
    POP DX
    POP CX
    POP BX
    RET
read_number ENDP





print_tab PROC
    MOV DL, 09H
    MOV AH, 02H
    INT 21H
    RET
print_tab ENDP




print_newline PROC
    LEA DX, newline
    CALL print_string
    RET
print_newline ENDP



copy_string PROC

    PUSH SI
    PUSH DI
copy_loop:
    MOVSB
    CMP BYTE PTR [SI-1], '$'
    JNE copy_loop
    POP DI
    POP SI
    RET
copy_string ENDP


compare_strings PROC


    PUSH SI
    PUSH DI
compare_loop:
    CMPSB
    JNE compare_not_equal
    CMP BYTE PTR [SI-1], '$'
    JNE compare_loop
    STC             
    JMP compare_done
compare_not_equal:
    CLC              
compare_done:
    POP DI
    POP SI
    RET
compare_strings ENDP



clear_screen PROC
    MOV AX, 0600H
    MOV BH, 07H
    MOV CX, 0000H
    MOV DX, 184FH
    INT 10H
    
    MOV AH, 02H
    MOV BH, 00H
    MOV DX, 0000H
    INT 10H
    RET
clear_screen ENDP

END MAIN



























