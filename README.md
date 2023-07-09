# VSD_TCL_Workshop

## TCL WORKSHOP: FROM INTRODUCTION TO ADVANCED SCRIPTING TECHNIQUES IN VLSI DESIGN AND SYNTHESIS

## What is tcl?
  TCL, which stands for Tool Command Language, is a versatile and dynamic scripting language. With its clear and concise syntax, TCL is widely used in various domains, including software development, network administration, and embedded systems. It offers a rich set of built-in commands and supports seamless integration with C/C++ code. TCL's flexibility and ease of use make it an excellent choice for both beginners and experienced programmers seeking efficient and powerful scripting capabilities.

### Obejctive : 
  Create a unique User Interface(UI) that takes RTL netlist & SDC constraints as inputs, and generate synthesized netlsit and Pre-layout timing report as an output. It should use Yosys Open source tool for synthesis and Opentimer to generate pre-layout timing reports

### Steps to follow to achieve the objective :
1. Create a command and pass .csv file from UNIX shell to tcl script
2. Convert excel file content into Yosys readable format (format-y) and .csv file to SDC format using Tcl Programming
3. Convert SDC file into Opentimer readable format (format-o) and pass format-y and format-o files to the opentimer timing tool
4. Generate output report

# Links For Easy Navigation:
1. [DAY-1](https://github.com/yagnavivek/VSD_TCL_Workshop/blob/main/README.md#day-1)
2. [DAY-2](https://github.com/yagnavivek/VSD_TCL_Workshop/blob/main/README.md#day-2)
3. [DAY-3](https://github.com/yagnavivek/VSD_TCL_Workshop/blob/main/README.md#day-3)
4. [DAY-4](https://github.com/yagnavivek/VSD_TCL_Workshop/blob/main/README.md#day-4)
5. [DAY-5](https://github.com/yagnavivek/VSD_TCL_Workshop/blob/main/README.md#day-5)
6. [Code Explaination](https://github.com/yagnavivek/VSD_TCL_Workshop/blob/main/README.md#code-explaination)

## DAY-1

___Before Executing the command in terminal dont forget to provide the permission to it using___
```
chmod -R 777 mysynth
```

#### Task:
____Create a welcome command____
____Check for User errors and help____
____Source the UNIX shell to tcl script by passing the csv file____

1. Creating the logo/welcome command(CHIPS)
- Since UNIX should be able to understand the shell script, we use the commmand :
```
#!/bin/tcsh -f
```
- create the command using the algorithm
```
echo
echo
echo "********************     *****               *****     ********************     ********************     ********************"
echo "********************     *****               *****     ********************     ********************     ********************"
echo "********************     *****               *****     ********************     ********************     ********************"
echo "*****                    *****               *****             *****            ******         *****     ******              "
echo "*****                    *****               *****             *****            ******         *****     ******              "
echo "*****                    *****               *****             *****            ******         *****     ******              "
echo "*****                    *****               *****             *****            ******         *****     ******              "
echo "*****                    *************************             *****            ********************     ********************"
echo "*****                    *************************             *****            ********************     ********************"
echo "*****                    *************************             *****            ********************     ********************"
echo "*****                    *****               *****             *****            ******                                 ******"
echo "*****                    *****               *****             *****            ******                                 ******"
echo "*****                    *****               *****             *****            ******                                 ******"
echo "*****                    *****               *****             *****            ******                                 ******"
echo "********************     *****               *****      ********************    ******                   ********************"
echo "********************     *****               *****      ********************    ******                   ********************"
echo "********************     *****               *****      ********************    ******                   ********************"
echo
echo "                        Please wait while we provide you the pre-layout timing report with the help                          "
echo "                                                of Yosys and Opentimer                                                       "
echo
echo
echo "                If you have some sugggestions or queries please feel free to mail pesug20ec109@pesu.pes.edu                  "


```

2. Check for user errors and help
#### Scenario 1
- user doesnot provide the .csv file
![WhatsApp Image 2023-07-05 at 5 58 48 PM](https://github.com/yagnavivek/VSD_TCL_Workshop/assets/93475824/ce1c01a8-7083-4c56-98f2-1df4176d4050)

#### Scenario 2:
- user provides the name of .csv file but it doesnot exist
![WhatsApp Image 2023-07-05 at 5 59 27 PM](https://github.com/yagnavivek/VSD_TCL_Workshop/assets/93475824/7e9547c1-5dfc-4213-bdb7-4be0677c10f6)

#### Scenario 3:
- user requests for help regarding the excel sheet content and execution using --help
![WhatsApp Image 2023-07-05 at 5 59 27 PM (1)](https://github.com/yagnavivek/VSD_TCL_Workshop/assets/93475824/4baad759-1140-4400-a254-fbda8f90bc07)

3. Source the UNIX shell to tcl script by passing the csv file
```
tclsh my_synth.tcl $argv[1]
```
## DAY-2

### Task : Convert all inputs to format-y and SDC format and pass them to Yosys tool

#### Subtasks:
- Creating the variables so that we can access the paths in excel sheet using these
- check if files and directories mentioned in csv exists or not
- Read constraints file in csv and convert to SDC format
- Read all the files in netlist directory
- create main synthesis script into format 2
- pass that script to Yosys

#### 1. Creating variables
- since we pass the csv file from terminal into tcl file, first we have to access it
- convert it into matrix form
- transfer the contents of matrix to an array so that indexing feature can be used
```
######################################################################
#-----mysynth has sent this script, the .csv file so to access it----#
######################################################################

set filename [lindex $argv 0]
package require csv
package require struct::matrix
struct::matrix m
set f [open $filename]
csv::read2matrix $f m , auto
close $f

set columns [m columns]

#The below line is not required but just remember the other way to use the columns
#
#m add columns $columns
#
#

m link my_arr
set rows [m rows]
set i 0

#  puts "$filename $columns $rows $i"
```
- Now create the variables by removing spaces in their names by using map function
- assign the paths to variables using indexing
```
while {$i < $rows} {
                puts "info : setting $my_arr(0,$i) as '$my_arr(1,$i)'"
                if {$i == 0} {
                        set [string map {" " ""} $my_arr(0,$i)] $my_arr(1,$i)
                } else {
                        set [string map {" " ""} $my_arr(0,$i)] [file normalize $my_arr(1,$i)]
                }
                set i [expr {$i+1}]

        }

puts "\nInfo : Below are the list of initial variables and their values. User can use these variables for further debug. Use 'puts <variable name>' command to query value of below variables\n"
puts "DesignName = $DesignName"
puts "OutputDirectory = $OutputDirectory"
puts "NetlistDirectory = $NetlistDirectory"
puts "EarlyLibraryPath = $EarlyLibraryPath"
puts "LateLibraryPath = $LateLibraryPath"
puts "ConstraintsFile = $ConstraintsFile"
```
### Display the created variables
![creating_variables (1)](https://github.com/yagnavivek/VSD_TCL_Workshop/assets/93475824/cdfa0c7c-7a52-4526-845a-ae225157e799)

#### 2. Check if the directories and files mentioned in csv are available or not
```
if {! [file exists $EarlyLibraryPath] } {
        puts "\nError : Cannot find early cell library in $EarlyLibraryPath Terminating............. "
        exit
} else {
        puts "\nInfo : early cell library found in $EarlyLibraryPath"
}

if {! [file exists $LateLibraryPath] } {
        puts "\nError : Cannot find late cell library in $LateLibraryPath. Terminating............. "
        exit
} else {
        puts "\nInfo : late cell library found in $LateLibraryPath"
}

if {! [file exists $ConstraintsFile] } {
        puts "\nError : Cannot find Constraints file in $ConstraintsFile. Terminating............. "
        exit
} else {
        puts "\nInfo : Constraints File found in $ConstraintsFile"
}

if {! [file isdirectory $NetlistDirectory] } {
        puts "\nError : Cannot find RTL Netlist Directory in $NetlistDirectory. Terminating............. "
        exit
} else {
        puts "\nInfo : RTL netlist directory  found in $NetlistDirectory."
}

if {! [file isdirectory $OutputDirectory] } {
        puts "\nError : Cannot find RTL Netlist Directory in $OutputDirectory .creating $OutputDirectory "
        file mkdir $OutputDirectory
} else {
        puts "\nInfo :Output directory found at path $OutputDirectory."
}
```
### Check the prescence of paths and names
![check_dir (1)](https://github.com/yagnavivek/VSD_TCL_Workshop/assets/93475824/d0fd641d-ef27-4a59-84df-627a5ca6a6cc)

### return error if the required parameters are not present
![check_dir_error](https://github.com/yagnavivek/VSD_TCL_Workshop/assets/93475824/fb38a012-ffb9-40b1-a56c-c08f7fd275a7)

#### 3. Read Constraint file in csv and convert it to SDC Format
- First dump the SDC constraints
```
puts "\ninfo : Dumping SDC constraints for $DesignName"
struct::matrix constraints
set chan [open $ConstraintsFile]
csv::read2matrix $chan constraints , auto
close $chan
set number_of_rows [constraints rows]
set number_of_columns [constraints columns]

puts "r = $number_of_rows c = $number_of_columns"
```
- we have to categorize all ports as INPUTS OUTPUTS CLOCKS and then process seperately
```
set clock_start [lindex [lindex [constraints search all CLOCKS] 0] 1]
set input_start [lindex [lindex [constraints search all INPUTS] 0] 1]
set output_start [lindex [lindex [constraints search all OUTPUTS] 0] 1]

puts "clock_start_index = $clock_start"
puts "input_port_start = $input_start"
puts "output_port_start = $output_start"
```
![SDC_Dump](https://github.com/yagnavivek/VSD_TCL_Workshop/assets/93475824/956a1603-806b-4007-a489-316fcf4d9285)

## DAY-3

____As said in Day 2, We have to categorize all ports as inputs,ouputs,clocks and process them sepeartely____

#### 1. CLOCKS
###### Clock latency and transition constraints
To get all the parameters under "CLOCKS" we need row and column number and traverse using them.
from prev code , we know that row number for clocks = ```$clock_start``` and column number is ```$clock_start_column```
TO access them :
```
set clock_early_rise_delay_start [lindex [lindex [constraints search rect $clock_start_column $clock_start $col2 [expr {$input_start-1}] early_rise_delay] 0] 0]
set clock_early_fall_delay_start [lindex [lindex [constraints search rect $clock_start_column $clock_start $col2 [expr {$input_start-1}] early_fall_delay] 0] 0]
set clock_late_rise_delay_start [lindex [lindex [constraints search rect $clock_start_column $clock_start $col2 [expr {$input_start-1}] late_rise_delay] 0] 0]
set clock_late_fall_delay_start [lindex [lindex [constraints search rect $clock_start_column $clock_start $col2 [expr {$input_start-1}] late_fall_delay] 0] 0]
set clock_early_rise_slew_start [lindex [lindex [constraints search rect $clock_start_column $clock_start $col2 [expr {$input_start-1}] early_rise_slew] 0] 0]
set clock_early_fall_slew_start [lindex [lindex [constraints search rect $clock_start_column $clock_start $col2 [expr {$input_start-1}] early_fall_slew] 0] 0]
set clock_late_rise_slew_start [lindex [lindex [constraints search rect $clock_start_column $clock_start $col2 [expr {$input_start-1}] late_rise_slew] 0] 0]
set clock_late_fall_slew_start [lindex [lindex [constraints search rect $clock_start_column $clock_start $col2 [expr {$input_start-1}] late_fall_slew] 0] 0]
set clock_period [lindex [lindex [constraints search rect $clock_start_column $clock_start $col2 [expr {$input_start-1}] frequency] 0] 0]
set clock_duty_cycle [lindex [lindex [constraints search rect $clock_start_column $clock_start $col2 [expr {$input_start-1}] duty_cycle] 0] 0]
```
![clock_constraint_col_nums](https://github.com/yagnavivek/VSD_TCL_Workshop/assets/93475824/4770ec54-3241-4915-b4ba-f68c40a0acf4)

____Now update te values under these colums for each row into SDC file____
```set sdc_file [open $OutputDirectory/$DesignName.sdc "w"]
set i [expr {$clock_start+1}]
set end_of_clock_ports [expr {$input_start-1}]
puts "\nInfo : SDC : Working on clock constrains................"
while {$i < $end_of_clock_ports} {
        puts -nonewline $sdc_file "\ncreate_clock -name [constraints get cell $clock_start $i]_chips -period [constraints get cell $clock_period $i] -waveform \{0 [expr {[constraints get cell $clock_period $i]*[constraints get cell $clock_duty_cycle $i]/100}]\} \[get_ports [constraints get cell $clock_start $i]\]"
        puts -nonewline $sdc_file "\nset_clock_latency  -source -early -rise [constraints get cell $clock_early_rise_delay_start $i] \[get_ports [constraints get cell 0 $i]\]"
 ###Perform the above command for all the parameters in that row
        set i [expr {$i+1}]
}
```
![clocks_scd_updated](https://github.com/yagnavivek/VSD_TCL_Workshop/assets/93475824/b83a1dd1-91d8-4c18-9ea8-195e03053e61)

#### 2.Inputs
Clock ports are standard ports but the ports under inputports are not standard ports as some are single bit and some are multi bit buses.SO 
- set variables for all the parameters
- indicate if its a bus by appending a '*' in front of the port. we can do this by
    1. get all the netlist files in a serial format ```set netlist [glob -dir $NetlistDirectory *.v] ```
    2. open a temporary file under write mode ```set tmp_file [open /tmp/1 w] ```
    3. now traverse for input ports through all the files and each line in the file until EOF and End of all files
    4. Since we get multiple declarations of the name_to_serach in inputs and outputs, we can split each finding using ';' as a delimiter use lindex[0] to get the first declaration
    5. if there are multiple spaces,remove them and replace with single space as it makes a unique pattern and makes it easy to filter
    6. if number of that unique pattern count is < 2 - its a single bit wire else its a multibit bus
    7. Similar to clock ports ,send the input ports data to SDC file
```
set netlist [glob -dir $NetlistDirectory *.v]
        set tmp_file [open /tmp/1 w]
        foreach fyle $netlist {
                set fd [open $fyle]
                while {[gets $fd line] != -1} {
                        set pattern1 " [constraints get cell 0 $j];"
                        if {[regexp -all -- $pattern1 $line]} {
                                set pattern2 [lindex [split $line ";"] 0]
                                if {[regexp -all {input} [lindex [split $pattern2 "\S+"] 0]]} {
                                        set s1 "[lindex [split $pattern2 "\S+"] 0] [lindex [split $pattern2 "\S+"] 1] [lindex [split $pattern2 "\S+"] 2]"
                                        puts -nonewline $tmp_file "\n[regsub -all {\s+} $s1 " "]"
                                }
                        }
                }
                close $fd
        }
close $tmp_file

set tmp_file [open /tmp/1 r]
set tmp2_file [open /tmp/2 w]

puts -nonewline $tmp2_file "[join [lsort -unique [split [read $tmp_file] \n]] \n]"

close $tmp_file
close $tmp2_file

set tmp2_file [open /tmp/2 r]
set count [llength [read $tmp2_file]]


if {$count > 2} {
        set input_ports [concat [constraints get cell 0 $j]*]
} else {
        set input_ports [constraints get cell 0 $j]
}
```
![input_cmd](https://github.com/yagnavivek/VSD_TCL_Workshop/assets/93475824/85b4beb3-6ca7-4e4b-9fea-604211cfa2f0)

#### SDC Contents W.R.T Input ports
![input_sdc](https://github.com/yagnavivek/VSD_TCL_Workshop/assets/93475824/e360f2dc-eaba-4fbe-83b8-710fbc849dab)

## DAY-4

#### YOSYS (Yosys Open SYnthesis Suite)
YOSYS is an open-source RTL synthesis and formal verification framework for digital circuits. It takes RTL descriptions (e.g., Verilog) as input and performs synthesis to generate a gate-level netlist. YOSYS supports technology mapping, optimization, and formal verification. It has a scripting interface, integrates with other EDA tools, and is widely used in academia and industry for digital design tasks.

### Tasks:
- Checking the Hierarchy
- Error handling
- Synthesize netlist

#### 1. Checking the hierarchy 

##### case 1 : All the referenced modules are interlinked properly and the hierarchy is properly defined - Hierarchy PASS
![hierarchy_pass](https://github.com/yagnavivek/VSD_TCL_Workshop/assets/93475824/eae77ef1-8cc2-41ae-9948-cde1205679b7)

##### case 2 : Hierarchy FAIL
![hier_fail_new](https://github.com/yagnavivek/VSD_TCL_Workshop/assets/93475824/d3842e8f-fdb4-43c4-916e-26bd9d4f50fe)

##### Log file message regarding the error
![hierarchy_fail_log](https://github.com/yagnavivek/VSD_TCL_Workshop/assets/93475824/b4e12d96-4bec-45af-824c-7eba725aca74)

#### 2. Completing the synthesis
![synthesis_completed](https://github.com/yagnavivek/VSD_TCL_Workshop/assets/93475824/79833cbd-f4f7-43eb-8540-0d10eab7d33b)

#### Synthesized netlist
![synthesized](https://github.com/yagnavivek/VSD_TCL_Workshop/assets/93475824/ea76cc5f-041b-4038-bf92-a00f9ad3a12a)

## DAY-5

## Code Explaination

















