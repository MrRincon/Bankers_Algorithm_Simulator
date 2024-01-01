#!/bin/bash
# Coursework 1 - M00774667 - Alam Rincon Rodrigues
# Bankers Algorithm for Deadlock Avoidance using Bash

start(){
    # Get processors
    getProcessors
    echo "There is $numProcessors processor(s)"
    # Get resources
    getResources
    echo "There is $numResources resource(s)"
    # Initialise arrays
    declare -a available
    declare -A allocated
    declare -A maxNeed
    declare -A needs
    declare -a work
    declare -a finish
    declare -a safeSequence
    for (( i=0; i<$numProcessors; i++)); do
        finish[$i]=0
    done
    # declare -a finish
    # declare -a safe
    # Get the maximum resources needed for each processor
    getMaxNeed
    # Get allocated resources for each processor
    getAllocated
    # Get the needs for each processor
    getNeeds
    # Get available resources
    getAvailable
    # Display essential existent data 
    getFirstTable
    # Initialise safety algorithm
    safetyAlgorithm
}
getProcessors(){
    read -p "Enter the number of processors(min 1 and max 10): " numProcessors
    # Processors input check
    if [ -z $numProcessors ]; then
        getProcessors
    elif [ $numProcessors -ge 1 ] && [ $numProcessors -le 10 ]; then
        return $numProcessors
    else 
        getProcessors
    fi
}
getResources(){
    read -p "Enter the number of resources(min 3 and max 5): " numResources
    # Resources input check
    if [ -z $numResources ]; then
        getResources 
    elif [ $numResources -ge 3 ] && [ $numResources -le 5 ]; then
        return $numResources
    else 
        getResources
    fi
}
getAvailable(){
    # 1-D Array with available resources
    echo "Enter the available resources: "
    for (( i=0; i<$numResources; i++ )); do
        printf "Resource $((i+1)) " 
        fillAvailResource
        available[$i]=$AvailResValue
    done
    return $available
}
fillAvailResource(){
    # Available resources input check
    read -p "Enter available value: " AvailResValue 
    if [ -z $AvailResValue ]; then 
        fillAvailResource
    elif [ $AvailResValue -ge 0 ] && [ $AvailResValue -le 9999 ]; then 
        return $AvailResValue
    else
        fillAvailResource
    fi
}
getMaxNeed(){
    # 2-D Array with max need of resources of each processor
    echo "Enter the max need of resources of each processor:"
    for (( i=0; i<$numProcessors; i++ )); do 
        printf "PROCESSOR $((i+1))\n"
        for (( j=0; j<$numResources; j++ )); do 
            printf "Resource $((j+1)) " 
            fillMaxNeedResource
            maxNeed[$i,$j]=$maxNeedResValue
        done
    done
    return $maxNeed
}
fillMaxNeedResource(){
    # Maximum need resources input check
    read -p "Enter maximum need value: " maxNeedResValue
    if [ -z $maxNeedResValue ]; then 
        fillMaxNeedResource
    elif [ $maxNeedResValue -ge 0 ] && [ $maxNeedResValue -le 9999 ]; then
        return $maxNeedResValue
    else
        fillMaxNeedResource
    fi
}
getAllocated(){
    # 2-D Array with allocated resources of each processor
    echo "Enter the allocated resources of each processor:"
    for (( i=0; i<$numProcessors; i++ )); do 
        printf "PROCESSOR $((i+1))\n"
        for (( j=0; j<$numResources; j++ )); do 
            printf "Resource $((j+1)) " 
            fillAllocResource
            allocated[$i,$j]=$allocResValue
        done
    done
    return $allocated
}
fillAllocResource(){
    # Allocated resources input check
    read -p "Enter allocated value: " allocResValue
    if [ -z $allocResValue ]; then 
        fillAllocResource
    elif [ $allocResValue -ge 0 ] && [ $allocResValue -le 9999 ]; then
        if [ ${maxNeed[$i,$j]} -ge $allocResValue ]; then
            return $allocResValue
        else 
            printf "Allocated value can't be higher than the maximum need value, try again.\n"
            fillAllocResource
        fi
    else
        fillAllocResource
    fi
}
getNeeds(){
    # 2-D Array with the needs of resources of each processor
    for (( i=0; i<$numProcessors; i++ )); do
        for (( j=0; j<$numResources; j++ )); do
            needs[$i,$j]=$(( ${maxNeed[$i,$j]} - ${allocated[$i,$j]} ))
            if [ ${needs[$i,$j]} -lt 0 ]; then 
                printf "\nCheck the values of maximum need and allocated resources.\nMAX NEED - ALLOCATED = NEEDS\nNEEDS has to be greater or equal to 0\nStart again with the right values"
                exit 0
            fi
        done
    done
    return $needs
}
getFirstTable(){
    printf "||AVAILABLE RESOURCES: ${available[*]}||\n"
    printf "||%-12s||%-$(($numResources*5))s||%-$(($numResources*5))s||%-$(($numResources*5))s||\n" "PROCESSOR(S)" "ALLOCATED" "MAX NEED" "NEEDS"
    for (( i=0; i<$numProcessors; i++ )); do 
        printf "||%-12s||" "P$((i+1))"
        for (( j=0; j<$numResources; j++ )); do  
            printf "%-5s" "${allocated[$i,$j]}"
        done
        printf "||"
        for (( j=0; j<$numResources; j++ )); do
            printf "%-5s" "${maxNeed[$i,$j]}"
        done
        printf "||"
        for (( j=0; j<$numResources; j++ )); do
            printf "%-5s" "${needs[$i,$j]}"
        done
        printf "||\n"
    done
}
safetyAlgorithm(){
    i=0
    count=0
    # for (( l=0; l<$numResources; l++)); do
    #     work[0,$l]=${allocated[0,$l]}
    # done
    # while [ $count -lt $numProcessors ]; do
    #     for (( k=0; k<$numProcessors; k++)); do
    #         printf "P$k\n"
    #         for (( l=0; l<$numResources; l++)); do 
    #             if [ ${available[$k,$l]} -ge ${needs[$k,$l]} ]; then 
    #                 printf "Yes"
    #                 work[$l]=1
    #             else 
    #                 printf "No"
    #                 work[$l]=0
    #             fi
    #         done 
    #         printf "\n"
    #         if [ ${work[*]} -eq 1 ]; then
    #             echo "Executable"
    #             count+=1
    #         fi
    #     done 
        # if [ "${finish[$i]}" -eq 0 ] && [ $(resourceCheck) -eq 1 ]; then
        #     for (( j=0; j<$numResources; j++ )); do 
        #         work[$j]=$((${work[$j]} + ${allocated[$i,$j]}))
        #     done
        #     finish[$i]=1
        #     echo "${finish[$i]} line 175" 
        #     safeSequence+=("P$i")
        #     count+=1
        # else 
        #     echo "Next processor"
        #     (( $count-1 ))
        # fi
        # (( i=( $i+1 ) % $numProcessors ))
        # echo "line 180"
#     done
#     if [ $count -eq $numProcessors ];then 
#         echo "System is in a safe state"
#         echo "Safe sequence: ${safeSequence[*]}"
#     else 
#         echo "System is in an unsafe state"
#     fi 

}
# resourceCheck(){
#     extraCheck=0
#     # for (( j=0; j<$numResources; j++ )); do
#         if [ ${needs[$i,$j]} -le ${work[$j]} ]; then
#             extraCheck+=1
#             printf "HELLO\n"
#         fi
#     # done
#     if [ $extraCheck -eq $numResources ]; then 
#         return 1
#     else
#         return 0
#     fi
# }
start
