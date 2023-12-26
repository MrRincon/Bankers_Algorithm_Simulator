#Coursework 1 - M00774667 - Alam Rincon Rodrigues
#Bankers Algorithm for Deadlock Avoidance using Bash
#!/bin/sh
start(){
    #Get processors
    getProcessors
    num_processors=$numProcessors
    echo "There is $num_processors processor(s)"
    #Get resources
    getResources
    num_resources=$numResources
    echo "There is $num_resources resource(s)"
    #Initialise arrays
    available=();
    allocated=()
    maxDemand=()
    need=()
    #Get Available resources
    getAvailable
    for (( i=0; i<$numResources; i++ ))
    do
        echo ${available[$i]}
        done
}
getProcessors(){
    read -p "Enter the number of processors(min 1 and max 10): " numProcessors
    #Processors input check
    if [ -z $numProcessors ] 
    then
        getProcessors
    elif [ $numProcessors -ge 1 ] && [ $numProcessors -le 10 ] 
    then
        return $numProcessors
    else 
        getProcessors
    fi
}
getResources(){
    read -p "Enter the number of resources(min 3 and max 5): " numResources
    #Resources input check
    if [ -z $numResources ] 
    then
        getResources 
    elif [ $numResources -ge 3 ] && [ $numResources -le 5 ] 
    then
        return $numResources
    else 
        getResources
    fi
}
getAvailable(){
    echo "Enter the available resources: "
    for (( i=0; i<$num_resources; i++ ))
    do
        echo "Resource $((i+1))"
        fillResource
        available[$i]=$avResValue
        done
    return $available
}
fillResource(){
    read -p "Enter value: " avResValue 
    if [ -z $avResValue ]
    then 
        fillResource
    elif [ $avResValue -ge 0 ]
    then 
        return $avResValue
    else
        fillResource
    fi
}
start