#!/bin/bash
#Coursework 1 - M00774667 - Alam Rincon Rodrigues
#Bankers Algorithm for Deadlock Avoidance using Bash
start(){
    #Get processors
    getProcessors
    echo "There is $numProcessors processor(s)"
    #Get resources
    getResources
    echo "There is $numResources resource(s)"
    #Initialise arrays
    declare -a totalAvail
    declare -a currentAvailable
    declare -A allocated
    declare -A maxNeed
    declare -A needs
    #Get Total available resources
    getTotalAvail
    #Get the maximum resources needed for each processor
    getMaxNeed
    #Get allocated resources for each processor
    getAllocated
    #Get the needs for each processor
    getNeeds
    #Display essential existent data 
    getFirstTable
}
getProcessors(){
    read -p "Enter the number of processors(min 1 and max 10): " numProcessors
    #Processors input check
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
    #Resources input check
    if [ -z $numResources ]; then
        getResources 
    elif [ $numResources -ge 3 ] && [ $numResources -le 5 ]; then
        return $numResources
    else 
        getResources
    fi
}
getTotalAvail(){
    #1-D Array with total available resources
    echo "Enter the total available resources: "
    for (( i=0; i<$numResources; i++ )); do
        printf "Resource $((i+1)) " 
        fillTotalAvailResource
        totalAvail[$i]=$totalAvailResValue
    done
    return $totalAvail
}
fillTotalAvailResource(){
    #Total available resources input check
    read -p "Enter total available value: " totalAvailResValue 
    if [ -z $totalAvailResValue ]; then 
        fillTotalAvailResource
    elif [ $totalAvailResValue -ge 0 ] && [ $totalAvailResValue -le 9999 ]; then 
        return $totalAvailResValue
    else
        fillTotalAvailResource
    fi
}
getMaxNeed(){
    #2-D Array with max need of resources of each processor
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
    #Maximum need resources input check
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
    #2-D Array with allocated resources of each processor
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
    #Allocated resources input check
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
    #2-D Array with the needs of resources of each processor
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
    printf "||TOTAL AVAILABLE RESOURCES: ${totalAvail[*]}||\n"
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

start