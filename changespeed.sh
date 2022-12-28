#!/bin/bash
usage="\nusage: $0 [-d] [value] [-a] [-g gpu_number]
-d: Set the temperature of the GPU to the default value
-a: Apply the specified speed to all NVIDIA GPUs
-g gpu_number: Apply the specified speed to the specified NVIDIA GPU
value: The speed value to apply to the GPU(s). Must be a whole number within the range of 0 to 100 (inclusive)."
num_gpus=$(lspci -k | grep -i "VGA" | grep -ci "nvidia")
if [ -z "$(command -v nvidia-settings)" ]
then
    printf "nvidia-settings not installed\n" >&2
elif [ $# -eq 0 ]
then
    printf "missing operand\n$usage\n" >&2
elif [ "$1" = "-d" ]
then
    if [ $# -gt 1 ]
    then
        printf "too many arguements\n$usage\n" >&2
    
    else
        for ((i=0; i<num_gpus; i++))
        do
            nvidia-settings -a "[gpu:$i]/GPUFanControlState=0" > /dev/null 2>&1
        done
    fi
elif [ -z "$1" ] || ! [ "$1" -eq "$1" ] || [ "$1" -lt 0 ] || [ "$1" -gt 100 ]
then
    printf "expected first arguement (fan speed/duty) to be whole number within range of 0 and 100 inclusive\n$usage\n" >&2
elif [ -n "$2" ]
then
    if [ "$2" = "-a" ]
    then
        if [ $# -gt 2 ]
        then
            printf "too many arguements\n$usage\n" >&2
        fi
        if [ "$num_gpus" -eq 1 ]
        then
            printf "only 1 gpu detected. proceeding anyways\n"
        fi
        for ((i=0; i<num_gpus; i++))
        do
            nvidia-settings -a "[gpu:$i]/GPUFanControlState=1" -a "[fan:0]/GPUTargetFanSpeed=$1" > /dev/null 2>&1
        done     
    elif [ "$2" = "-g" ]
    then
        gpus_available=$((num_gpus - 1))
        if [ $# -gt 3 ]
        then
            printf "too many arguements\n$usage\n" >&2
        elif [[ "$3" -lt 0 || "$3" -gt $gpus_available ]]
        then
            if [ $gpus_available -gt 0 ]
            then
                printf "expected gpu index within range of 0 and $gpus_available inclusive\n$usage\n" >&2
            else
                printf "expected gpu index of 0 (only 1 gpu available)\n$usage\n" >&2
            fi
        fi
        nvidia-settings -a "[gpu:$3]/GPUFanControlState=1" -a "[fan:0]/GPUTargetFanSpeed=$1" > /dev/null 2>&1
    elif [ "$2" = "-d" ]
    then
        printf "too many arguements\n$usage\n" >&2
    else
        printf "expected valid operand. got unknown arguement $2\n$usage\n" >&2
    fi
else
    nvidia-settings -a "[gpu:0]/GPUFanControlState=1" -a "[fan:0]/GPUTargetFanSpeed=$1" > /dev/null 2>&1
fi
