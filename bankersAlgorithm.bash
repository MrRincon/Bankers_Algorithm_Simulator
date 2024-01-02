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
    declare -a totalAvailable
    declare -a currentAvailable
    declare -a checkAllocated
    declare -A allocated
    declare -A maxNeed
    declare -A needs
    declare -a work
    declare -a finish
    declare -a safeSequence
    for (( i=0; i<$numProcessors; i++)); do
        finish[$i]=0
    done
    # Get the maximum resources needed for each processor
    getMaxNeed
    # Get allocated resources for each processor
    getAllocated
    # Get the needs for each processor
    getNeeds
    #Get the current available resources
    getCurrentAvailable
    # Get total available resources
    getTotalAvailable
    # Display essential existent data 
    getFirstTable
    #Get the request from the user
    # getProcessorRequest
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
            checkAllocated[$j]=$((${checkAllocated[$j]} + allocResValue))
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
        done
    done
    return $needs
}
getCurrentAvailable(){
    # 1-D array with Currently Available resources
    echo "Enter the currently available resources: "
    for (( i=0; i<$numResources; i++ )); do 
        printf "Resource $((i+1)) "
        fillCurrentAvailable
        currentAvailable[$i]=$cuAvailResValue
    done
    return $currentAvailable
}
fillCurrentAvailable(){
    # Current available resources input check
    read -p "Enter current available value: " cuAvailResValue
    if [ -z $cuAvailResValue ]; then 
        fillCurrentAvailable
    elif [ $cuAvailResValue -ge 0 ] && [ $cuAvailResValue -le 9999 ]; then 
        return $cuAvailResValue
    else
        fillCurrentAvailable
    fi
}
getTotalAvailable(){
    # 1-D Array with total available resources
    for (( i=0; i<$numResources; i++ )); do
        totalAvailable[$i]=$(( ${checkAllocated[$i]}+${currentAvailable[$i]} ))
    done
    return $totalAvailable
}
getFirstTable(){
    printf "||TOTAL AVAILABLE RESOURCES: ${totalAvailable[*]}||\n"
    printf "||CURRENTLY AVAILABLE:       ${currentAvailable[*]}||\n"
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
# getProcessorRequest(){

# }
safetyAlgorithm(){
    i=0
    count=0
    for (( j=0; j<$numResources; j++ )); do
        work[$j]=${currentAvailable[$j]}
    done
    while [ $count -lt $numProcessors ]; do
        if [ ${finish[$i]} -eq 0 ] && [ "$(resourceCheck)" -eq 0 ] ; then
            for (( j=0; j<$numResources; j++)); do
                work[$j]=$((${work[$j]} + ${allocated[$i,$j]}))
            done
            finish[$i]=1
            safeSequence+=("P$((i+1))")
            ((count++))
        fi
        (( i = (i + 1) % $numProcessors ))
    done
    if [ $count -eq $numProcessors ]; then
        printf "System is in a safe state\n"
        printf "Safe Sequence: ${safeSequence[*]}\n"
    else
        printf "System is in an unsafe state\n"
    fi
}
resourceCheck(){
    checkedResource=0
    for (( j=0; j<$numResources; j++ )); do
        if [ ${needs[$i,$j]} -le ${work[$j]} ]; then
            ((checkedResource++))
        fi
    done
    if [ $checkedResource -eq $numResources ]; then 
        echo 0
    else
        echo 1
    fi
}
start
