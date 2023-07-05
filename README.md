# VSD_TCL_Workshop

## TCL WORKSHOP: FROM INTRODUCTION TO ADVANCED SCRIPTING TECHNIQUES IN VLSI DESIGN AND SYNTHESIS

![Hello!](https://github.com/yagnavivek/VSD_TCL_Workshop/assets/93475824/a97d6a5e-5ec8-4144-8b3a-8f79a22551a2)

## What is tcl?
  TCL, which stands for Tool Command Language, is a versatile and dynamic scripting language. With its clear and concise syntax, TCL is widely used in various domains, including software development, network administration, and embedded systems. It offers a rich set of built-in commands and supports seamless integration with C/C++ code. TCL's flexibility and ease of use make it an excellent choice for both beginners and experienced programmers seeking efficient and powerful scripting capabilities.

### Obejctive : 
  Create a unique User Interface(UI) that takes RTL netlist & SDC constraints as inputs, and generate synthesized netlsit and Pre-layout timing report as an output. It should use Yosys Open source tool for synthesis and Opentimer to generate pre-layout timing reports

### Steps to follow to achieve the objective :
1. Create a command and pass .csv file from UNIX shell to tcl script
2. Convert excel file content into Yosys readable format (format-y) and .csv file to SDC format using Tcl Programming
3. Convert SDC file into Opentimer readable format (format-o) and pass format-y and format-o files to the opentimer timing tool
4. Generate output report

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
 








