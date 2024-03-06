#!/bin/bash
 
identify_c_files() {
    find "$1" -type f -name "*.c"
}
 
compile_c_file() {
    source_file="$1"
    output_folder="$2"
    
    file_name=$(basename "$source_file")
    executable_name="${file_name%.*}"
    output_path="$output_folder/$executable_name"
 
    gcc -Werror -Wfatal-errors "$source_file" -o "$output_path"
    compile_exit_code=$?
 
    if [ $compile_exit_code -eq 0 ]; then
        echo "$output_path"
        return 0
    else
        echo "Compilation error for $source_file: Compilation failed with exit code $compile_exit_code"
        return 1
    fi
}



run_executable() {
    executable_path="$1"
    input_file="$2"
    
    if [ -n "$input_file" ]; then
        result=$(cat "$input_file" | "$executable_path")
    else
        result=$("$executable_path")
    fi
 
    echo "$result"
}
 
test_executable() {
    executable_path="$1"
    expected_exit_code="$2"
    expected_output_file="$3"

    actual_output=$(run_executable "$executable_path")
    actual_exit_code=$?

    if [ "$actual_exit_code" -eq "$expected_exit_code" ]; then
        echo "Exit code is correct: $actual_exit_code"

        if [ -n "$expected_output_file" ]; then
            expected_output=$(cat "$expected_output_file")
            if [ "$actual_output" == "$expected_output" ]; then
                echo "Output is correct."
            else
                echo "Output is incorrect."
            fi
        fi
    else
        echo "Exit code is incorrect: $actual_exit_code"
    fi
}

 
main() {
    source_folder="Source"
    output_folder="Output"
    test_folder="Tests"
    successful_compiles=0
    invalid_files=0
    successful_files=()
    unsuccessful_files=()

    [ -d "$output_folder" ] || mkdir "$output_folder"
 
    c_files=($(identify_c_files "$source_folder"))
 
    for source_file in "${c_files[@]}"; do
        echo "Compiling $source_file..."
        executable_path=$(compile_c_file "$source_file" "$output_folder")


        if [ $? -eq 0 ]; then
            successful_compiles=$((successful_compiles + 1))
            successful_files+=("$source_file")
            echo "Running tests for $executable_path..."
            test_file="$test_folder/$(basename "$source_file" .c).txt"
            test_executable "$executable_path" 0 "$test_file"
        else
            invalid_files=$((invalid_files + 1))
            unsuccessful_files+=("$source_file")
        fi
    done


    echo "=========="
    echo "Total compilations: ${#c_files[@]}"
    echo "Successful compilations: $successful_compiles"
    echo "Invalid files: $invalid_files"
    echo "Successful files:"
    for file in "${successful_files[@]}"; do
        echo "- $file"
    done
    echo "Unsuccessful files:"
    for file in "${unsuccessful_files[@]}"; do
        echo "- $file"
    done
}
 
main
