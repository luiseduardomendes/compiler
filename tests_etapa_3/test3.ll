declare result as int,
factorial returns int with n as int is [
   declare i as int with 1 
   set_result(1) 
   while (i <= n)[ 
      set_result(get_result() * i) 
      i is i + 1 
   ] 
   return get_result() as int 
], 
set_result returns int with a as int is [ 
   result is a 
   return result as int 
], 
get_result returns int is [ 
   return result as int 
], 
main returns int is [ 
   declare num as int with 5 
   factorial(num) 
   return 0 as int
]; 