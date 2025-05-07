declare total as int,
add_square returns int with n as int is [
    total is total + n * n
    return total as int
],
set_total returns int with a as int is [ total is a return total as int ],
get_total returns int is [ return total as int ],
main returns int is [
    declare i as int with 1
    declare b as int with 5
    set_total(0)
    while (i <= b)[
        add_square(i)
        i is i + 1
    ]
    return 0 as int
];