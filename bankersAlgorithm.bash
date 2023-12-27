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
    declare -a available
    declare -A allocated
    maxDemand=()
    need=()
    #Get Available resources
    getAvailable
    #Get allocated resources for each processor
    getAllocated
    #Print Processors, available resources and allocated resources
    echo "AVAILABLE RESOURCES: ${available[*]}"
    # for (( i=0; i<$numProcessors; i++ )); do 
    #     echo "P$((i+1)) "  
    # done
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
getAvailable(){
    echo "Enter the available resources: "
    for (( i=0; i<$numResources; i++ )); do
        echo "Resource $((i+1))" 
        fillAvaiResource
        available[$i]=$avaiResValue
    done
    return $available
}
fillAvaiResource(){
    read -p "Enter value: " avaiResValue 
    if [ -z $avaiResValue ]; then 
        fillAvaiResource
    elif [ $avaiResValue -ge 0 ]; then 
        return $avaiResValue
    else
        fillAvaiResource
    fi
}
getAllocated(){
    echo "Enter the allocated resources of each processor:"
    for (( i=0; i<$numProcessors; i++ )); do 
        echo "PROCESSOR $((i+1))"
        for (( j=0; j<$numProcessors; j++ )); do 
            echo "Resource $((j+1))" 
            fillAllocResource
            allocated[$i,$j]=$allocResValue
        done
    done
    return $allocated
}
fillAllocResource(){
    read -p "Enter value: " allocResValue
    if [ -z $allocResValue ]; then 
        fillAllocResource
    elif [ $allocResValue -ge 0 ]; then
        return $allocResValue
    else
        fillAllocResource
    fi
}
start 