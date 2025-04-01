// Original correct program
declare global_factor as int,
multiply_accumulate with a as int, b as int is [ a is a + a * b ],
set_global returns int with a as int is [ global_factor is a return global_factor as int ],
get_global returns int is [ return global_factor as int ],
main returns int is [
    declare x as int with 2
    declare y as int with 3
    set_global(x)
    while (get_global() <= 12)[
        if (get_global() % 2 == 1)[
            set_global(multiply_accumulate(get_global(), x))    
        ] else [ 
            set_global(multiply_accumulate(get_global(), y))    
        ]
    ]
    return 0 as int
];