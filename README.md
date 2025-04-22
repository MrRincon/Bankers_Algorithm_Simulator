# Simulation of Banker's Algorithm for Deadlock Avoidance using C++ or Bash

THEORY
Banker's algorithm is a deadlock avoidance algorithm. It is named so because this algorithm
is used in banking systems to determine whether a loan can be granted or not.
Consider there are n account holders in a bank and the sum of the money in all their
accounts is S. Every time a loan has to be granted by the bank, it subtracts the loan
amount from the total money the bank has. Then it checks if that difference is greater than S.
It is done because, only then, the bank would have enough money even if all the n account
holders draw all their money at once.
Banker's algorithm works in a similar way in operating systems. Whenever a new process is
created, it must specify the maximum instances of each resource type that it needs, exactly.
Assume that there are n processes and m resource types in the system

ALGORITHM
1. Start the program.
2. Get the values of resources and processes.
3. Get the available value.
4. After allocation find the need value.
5. Check whether it’s possible to allocate.
6. If it is possible then the system is in the safe state.
7. Else system is not in the safety state.
8. If the new request comes then check that the system is in safe state.
9. If so, grant the request.
10. If not, deny the request.
11. Stop the program.
