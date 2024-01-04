#!/bin/bash
# Simulation of Bankers algorithm for Deadlock Avoidance using Bash.
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
    declare -a newRequest
    # Get the maximum resources needed for each processor
    getMaxNeed
    # Get allocated resources for each processor
    getAllocated
    # Get the needs for each processor
    getNeeds
    # Get the current available resources
    getCurrentAvailable
    # Get total available resources
    getTotalAvailable
    # Display essential existent data 
    getTable
    # Store zeros in the finish array to use in the safety algorithm
    for (( j=0; j<$numProcessors; j++)); do
        finish[$j]=0
    done
    # Initialise safety algorithm and check if it returns 0
    if [ "$(safetyAlgorithm)" -eq 0 ]; then
        printf "System is in a safe state\n"
        # Get the request from the user
        getNewRequest
    else
        printf "System is in an unsafe state\n"
        exit 0
    fi
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
    for (( j=0; j<$numProcessors; j++ )); do 
        printf "PROCESSOR $((j+1))\n"
        for (( k=0; k<$numResources; k++ )); do 
            printf "Resource $((k+1)) " 
            fillMaxNeedResource
            maxNeed[$j,$k]=$maxNeedResValue
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
    for (( j=0; j<$numProcessors; j++ )); do 
        printf "PROCESSOR $((j+1))\n"
        for (( k=0; k<$numResources; k++ )); do 
            printf "Resource $((k+1)) " 
            fillAllocResource
            allocated[$j,$k]=$allocResValue
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
        if [ ${maxNeed[$j,$k]} -ge $allocResValue ]; then
            checkAllocated[$k]=$((${checkAllocated[$k]} + allocResValue))
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
    for (( j=0; j<$numProcessors; j++ )); do
        for (( k=0; k<$numResources; k++ )); do
            needs[$j,$k]=$(( ${maxNeed[$j,$k]} - ${allocated[$j,$k]} ))
        done
    done
    return $needs
}
getCurrentAvailable(){
    # 1-D array with Currently Available resources
    echo "Enter the currently available resources: "
    for (( j=0; j<$numResources; j++ )); do 
        printf "Resource $((j+1)) "
        fillCurrentAvailable
        currentAvailable[$j]=$cuAvailResValue
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
    for (( j=0; j<$numResources; j++ )); do
        totalAvailable[$j]=$(( ${checkAllocated[$j]}+${currentAvailable[$j]} ))
    done
    return $totalAvailable
}
getTable(){
    # Print the table with the values
    printf "||TOTAL AVAILABLE RESOURCES: ${totalAvailable[*]}||\n"
    printf "||CURRENTLY AVAILABLE:       ${currentAvailable[*]}||\n"
    printf "||%-12s||%-$(($numResources*5))s||%-$(($numResources*5))s||%-$(($numResources*5))s||\n" "PROCESSOR(S)" "ALLOCATED" "MAX NEED" "NEEDS"
    for (( j=0; j<$numProcessors; j++ )); do 
        printf "||%-12s||" "P$((j+1))"
        for (( k=0; k<$numResources; k++ )); do  
            printf "%-5s" "${allocated[$j,$k]}"
        done
        printf "||"
        for (( k=0; k<$numResources; k++ )); do
            printf "%-5s" "${maxNeed[$j,$k]}"
        done
        printf "||"
        for (( k=0; k<$numResources; k++ )); do
            printf "%-5s" "${needs[$j,$k]}"
        done
        printf "||\n"
    done
}
safetyAlgorithm(){
    # Start the safety algorithm
    i=0
    count=0
    x=0
    # Place the resources of currently available in a separate array to work with
    for (( j=0; j<$numResources; j++ )); do
        work[$j]=${currentAvailable[$j]}
    done
    # Loop through x until x is equal to the (amount of processors * amount of processors) to avoid an endless loop
    while [ $x -lt $(($numProcessors*$numProcessors)) ]; do
        # Check for values in the finish array to see if any is equal to 0, and that a check function returns 0
        if [ ${finish[$i]} -eq 0 ] && [ "$(resourceCheck)" -eq 0 ] ; then
            for (( j=0; j<$numResources; j++)); do
                work[$j]=$((${work[$j]} + ${allocated[$i,$j]}))
            done
            # If the checks are true assign the finish value of that processor to 1 and then increment the count
            finish[$i]=1
            ((count++))
        fi
        ((x++))
        # Change the value of i constantly to loop through the processors
        (( i = (i + 1) % $numProcessors ))
    done
    if [ $count -eq $numProcessors ]; then
        echo 0
    else
        echo 1
    fi
}
resourceCheck(){
    checkedResource=0
    # Loop through the resources to check if the needs of the processor are less 
    # or equal to the current available array is working with
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
checkIfCuAvail(){
    # Check if there is any resources left in the currently available to allow future requests
    checkIfAvail=0
    for (( j=0; j<$numResources; j++)); do
        if [ ${currentAvailable[$j]} -eq 0 ]; then
            ((checkIfAvail++))
        fi
    done
    if [ $checkIfAvail -eq $numResources ]; then 
        echo 0
    else 
        echo 1
    fi
}
getNewRequest(){
    # New Request input checks for the processor selection
    read -p "Enter the Processor for a new request: " pNewRequest
    if [ -z $pNewRequest ]; then 
        getNewRequest
    elif [ $pNewRequest -ge 1 ] && [ $pNewRequest -le $numProcessors ]; then 
        # Get the new resources for the process chosen
        getResourcesRequest
        # Calculate needs with the new allocated values and print the new table
        getNeeds
        getTable
        # Check if it is safe or unsafe to grant the request
        if [ $(safetyAlgorithm) -eq 0 ]; then 
            printf "Request Granted. System is in a safe state\n"
            # Check if there is any resources available before letting the user request more.
            if [ $(checkIfCuAvail) -eq 0 ]; then
                printf "There is no resources available to grant more requests"
                exit 0
            else
                # Keep looping the new request function for future requests.
                getNewRequest
            fi
            
        else
            # Exit the program if unsafe
            printf "Request not granted. System is in an unsafe state\n"
            exit 0
        fi
    else
        printf "Only able to select Processor from 1 to $numProcessors \n"
        getNewRequest
    fi
}
getResourcesRequest(){
    # Loop through the resources of the processor chosen
    printf "Enter the new resources for the new request: \n"
    for (( j=0; j<$numResources; j++ )); do
        printf "Resource $((j+1)) "
        fillNewResourceRequest
        # Update the allocated values and the currently available values
        allocated[$(($pNewRequest-1)),$j]=$(( ${allocated[$(($pNewRequest-1)),$j]}+$resRequest ))
        currentAvailable[$j]=$(( ${currentAvailable[$j]}-$resRequest ))
    done
    return
}
fillNewResourceRequest(){
    # New Resource input check
    read -p "Enter the request: " resRequest
    if [ -z $resRequest ]; then 
        fillNewResourceRequest
    elif [ $resRequest -ge 0 ] && [ $resRequest -le ${needs[$(($pNewRequest-1)),$j]} ] && [ $resRequest -le ${currentAvailable[$j]} ]; then 
        return $resRequest
    else
        printf "Please make sure your request is not less than 0 and \n not greater than need and available\n"
        fillNewResourceRequest
    fi
}
start