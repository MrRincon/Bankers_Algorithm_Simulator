#Coursework 1 - M00774667 - Alam Rincon Rodrigues
#Bankers Algorithm for Deadlock Avoidance using Bash
#!/bin/bash
start(){
    #Check that inputs are correct
    getProcessors
    echo "There is $numProcessors processor(s)"
    getResources
    echo "There is $numResources resource(s)"
}
getProcessors(){
    read -p "Enter the number of processors(min 1 and max 5): " numProcessors
    if [ -z $numProcessors ] 
    then
        # echo "Please enter some processors"
        getProcessors
    elif [ $numProcessors -lt 1 ] || [ $numProcessors -gt 5 ] 
    then
        # echo "Minimum 1 and maximum 10 processors. try again"
        getProcessors
    else 
        # echo "There is $numProcessors processor(s)"
        return $numProcessors
    fi
}
getResources(){
    read -p "Enter the number of resources: " numResources
    if [ -z $numResources ] 
    then
        # echo "Please enter some resources"
        getResources 
    elif [ $numResources -lt 1 ] || [ $numResources -gt 3 ] 
    then
        # echo "Minimum 1 and maximum 3 resources. try again"
        getResources
    else 
        # echo "There is $numResources resources(s)"
        return $numResources
    fi
}
start