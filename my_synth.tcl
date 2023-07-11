set working_dir [exec pwd]
set enable_prelayout_timing 1


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
#
#
# #####################################################################################
# #----assign all the variables in .csv file with their respective paths and names----#
# #####################################################################################


while {$i < $rows} {
		puts "info : setting $my_arr(0,$i) as '$my_arr(1,$i)'"
		if {$i == 0} {
			set [string map {" " ""} $my_arr(0,$i)] $my_arr(1,$i)
		} else {
			set [string map {" " ""} $my_arr(0,$i)] [file normalize $my_arr(1,$i)]
		}
		set i [expr {$i+1}]
	
	}

#puts "\nInfo : Below are the list of initial variables and their values. User can use these variables for further debug. Use 'puts <variable name>' command to query value of below variables\n"
#puts "DesignName = $DesignName"
#puts "OutputDirectory = $OutputDirectory"
#puts "NetlistDirectory = $NetlistDirectory"
#puts "EarlyLibraryPath = $EarlyLibraryPath"
#puts "LateLibraryPath = $LateLibraryPath"
#puts "ConstraintsFile = $ConstraintsFile"

###############################################################################################################################
#-----------------------------------------------------------------------------------------------------------------------------#
#-----Now as we have set the variable names, we have to check if the file and path are correct and exist in the directory-----#
#-----------------------------------------------------------------------------------------------------------------------------#
###############################################################################################################################
#
#

if {! [file exists $EarlyLibraryPath] } {
	puts "\nError : Cannot find early cell library in $EarlyLibraryPath Terminating............. "
	exit 
} else {
	puts "\nInfo : early cell library found in $EarlyLibraryPath"
}

if {! [file exists $LateLibraryPath] } {
        puts "Error : Cannot find late cell library in $LateLibraryPath. Terminating............. "
        exit
} else {
        puts "Info : late cell library found in $LateLibraryPath"
}

if {! [file exists $ConstraintsFile] } {
        puts "Error : Cannot find Constraints file in $ConstraintsFile. Terminating............. "
        exit
} else {
        puts "Info : Constraints File found in $ConstraintsFile"
}

if {! [file isdirectory $NetlistDirectory] } {
        puts "Error : Cannot find RTL Netlist Directory in $NetlistDirectory. Terminating............. "
        exit
} else {
        puts "Info : RTL netlist directory  found in $NetlistDirectory."
}

if {! [file isdirectory $OutputDirectory] } {
	puts "Error : Cannot find RTL Netlist Directory in $OutputDirectory .creating $OutputDirectory "
	file mkdir $OutputDirectory
} else {
        puts "Info :Output directory found at path $OutputDirectory."
}


##########################################################################################################
#--------------------------------------------------------------------------------------------------------#
#------------Read the constraint file provided in csv file and convert to SDC format---------------------#
#--------------------------------------------------------------------------------------------------------#
##########################################################################################################
#

puts "\ninfo : Dumping SDC constraints for $DesignName"
struct::matrix constraints
set chan [open $ConstraintsFile]
csv::read2matrix $chan constraints , auto
close $chan
set number_of_rows [constraints rows]
set number_of_columns [constraints columns]

#puts "r = $number_of_rows c = $number_of_columns"

########################################################################################################
#------------------------------------------------------------------------------------------------------#
#-------we have to categorize all ports as INPUTS OUTPUTS CLOCKS and then process seperately-----------#
#------------------------------------------------------------------------------------------------------#
########################################################################################################
#
#


set clock_start [lindex [lindex [constraints search all CLOCKS] 0] 1]
set input_start [lindex [lindex [constraints search all INPUTS] 0] 1]
set output_start [lindex [lindex [constraints search all OUTPUTS] 0] 1]
set clock_start_column [lindex [lindex [constraints search all CLOCKS] 0 ] 0]
set col2 [expr {$number_of_columns-1}]
#puts "clock_start_index = $clock_start"
#puts "input port start = $input_start"
#puts "output port start = $output_start"
#puts "clock_start_column = $clock_start_column"


#########################################################################################################
#-------------------------------------------------------------------------------------------------------#
#-----------------category 1 : CLOCKS ports-------------------------------------------------------------#
#-------------------------------------------------------------------------------------------------------#
#########################################################################################################


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

#puts "clock_early_rise_delay_start = $clock_early_rise_delay_start"
#puts "clock_early_fall_delay_start = $clock_early_fall_delay_start"
#puts "clock_late_rise_delay_start = $clock_late_rise_delay_start"
#puts "clock_late_fall_delay_start = $clock_late_fall_delay_start"
#puts "clock_early_rise_slew_start = $clock_early_rise_slew_start"
#puts "clock_early_fall_fall_start = $clock_early_fall_slew_start"
#puts "clock_late_rise_slew_start = $clock_late_rise_slew_start"
#puts "clock_late_rise_slew_start = $clock_late_fall_slew_start"
#puts "clock_period = $clock_period"
#puts "clock_duty_cycle = $clock_duty_cycle"



#########################################################################################################
#-------------------------------------------------------------------------------------------------------#
#--------------------------Update the SDC file----------------------------------------------------------#
#-------------------------------------------------------------------------------------------------------#
#########################################################################################################


set sdc_file [open $OutputDirectory/$DesignName.sdc "w"]
set i [expr {$clock_start+1}]
set end_of_clock_ports [expr {$input_start-1}]
puts "\nInfo : SDC : Working on clock constrains................"
while {$i < $end_of_clock_ports} {
	puts -nonewline $sdc_file "\ncreate_clock -name [constraints get cell $clock_start $i] -period [constraints get cell $clock_period $i] -waveform \{0 [expr {[constraints get cell $clock_period $i]*[constraints get cell $clock_duty_cycle $i]/100}]\} \[get_ports [constraints get cell $clock_start $i]\]"
	puts -nonewline $sdc_file "\nset_clock_latency  -source -early -rise [constraints get cell $clock_early_rise_delay_start $i] \[get_clocks [constraints get cell 0 $i]\]"
        puts -nonewline $sdc_file "\nset_clock_latency  -source -early -fall [constraints get cell $clock_early_fall_delay_start $i] \[get_clocks [constraints get cell 0 $i]\]"
        puts -nonewline $sdc_file "\nset_clock_latency  -source -late -rise [constraints get cell $clock_late_rise_delay_start $i] \[get_clocks [constraints get cell 0 $i]\]"
        puts -nonewline $sdc_file "\nset_clock_latency  -source -late -fall [constraints get cell $clock_late_fall_delay_start $i] \[get_clocks [constraints get cell 0 $i]\]"
	puts -nonewline $sdc_file "\nset_clock_transition -rise -min [constraints get cell $clock_early_rise_slew_start $i] \[get_clocks [constraints get cell 0 $i]\]"
        puts -nonewline $sdc_file "\nset_clock_transition -fall -min [constraints get cell $clock_early_fall_slew_start $i] \[get_clocks [constraints get cell 0 $i]\]"
        puts -nonewline $sdc_file "\nset_clock_transition -rise -max [constraints get cell $clock_late_rise_slew_start $i] \[get_clocks [constraints get cell 0 $i]\]"
        puts -nonewline $sdc_file "\nset_clock_transition -fall -max [constraints get cell $clock_late_fall_slew_start $i] \[get_clocks [constraints get cell 0 $i]\]"
	set i [expr {$i+1}]
}

#########################################################################################################
#-------------------------------------------------------------------------------------------------------#
#------------------category 2 : INPUT ports-------------------------------------------------------------#
#-------------------------------------------------------------------------------------------------------#
#########################################################################################################

set input_early_rise_delay_start [lindex [lindex [constraints search rect $clock_start_column $input_start $col2 [expr {$output_start-1}] early_rise_delay] 0] 0]
set input_early_fall_delay_start [lindex [lindex [constraints search rect $clock_start_column $input_start $col2 [expr {$output_start-1}] early_fall_delay] 0] 0]
set input_late_rise_delay_start [lindex [lindex [constraints search rect $clock_start_column $input_start $col2 [expr {$output_start-1}] late_rise_delay] 0] 0]
set input_late_fall_delay_start [lindex [lindex [constraints search rect $clock_start_column $input_start $col2 [expr {$output_start-1}] late_fall_delay] 0] 0]
set input_early_rise_slew_start [lindex [lindex [constraints search rect $clock_start_column $input_start $col2 [expr {$output_start-1}] early_rise_slew] 0] 0]
set input_early_fall_slew_start [lindex [lindex [constraints search rect $clock_start_column $input_start $col2 [expr {$output_start-1}] early_fall_slew] 0] 0]
set input_late_rise_slew_start [lindex [lindex [constraints search rect $clock_start_column $input_start $col2 [expr {$output_start-1}] late_rise_slew] 0] 0]
set input_late_fall_slew_start [lindex [lindex [constraints search rect $clock_start_column $input_start $col2 [expr {$output_start-1}] late_fall_slew] 0] 0]
set input_clocks [lindex [lindex [constraints search rect $clock_start_column $input_start $col2 [expr {$output_start-1}] clocks] 0] 0]

set j [expr {$input_start+1}]
set end_of_input_ports [expr {$output_start-1}]
puts "Info : SDC : Working on Input Constraints.............."
puts "Info : SDC : *indicates bus"
while {$j < $end_of_input_ports} {
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

	
        puts -nonewline $sdc_file "\nset_input_delay -clock  [constraints get cell $input_clocks $j] -min -rise  [constraints get cell $input_early_rise_delay_start $j] \[get_ports $input_ports\]"
        puts -nonewline $sdc_file "\nset_input_delay -clock  [constraints get cell $input_clocks $j] -min -fall  [constraints get cell $input_early_fall_delay_start $j] \[get_ports $input_ports\]"
        puts -nonewline $sdc_file "\nset_input_delay -clock  [constraints get cell $input_clocks $j] -max -rise  [constraints get cell $input_late_rise_delay_start $j] \[get_ports $input_ports\]"
        puts -nonewline $sdc_file "\nset_input_delay -clock  [constraints get cell $input_clocks $j] -max -fall  [constraints get cell $input_late_fall_delay_start $j] \[get_ports $input_ports\]"

        puts -nonewline $sdc_file "\nset_input_transition -clock  [constraints get cell $input_clocks $j] -min -rise  [constraints get cell $input_early_rise_slew_start $j] \[get_ports $input_ports\]"
        puts -nonewline $sdc_file "\nset_input_transition -clock  [constraints get cell $input_clocks $j] -min -fall  [constraints get cell $input_early_fall_slew_start $j] \[get_ports $input_ports\]"
        puts -nonewline $sdc_file "\nset_input_transition -clock  [constraints get cell $input_clocks $j] -max -rise  [constraints get cell $input_late_rise_slew_start $j] \[get_ports $input_ports\]"
        puts -nonewline $sdc_file "\nset_input_transition -clock  [constraints get cell $input_clocks $j] -max -fall  [constraints get cell $input_late_fall_slew_start $j] \[get_ports $input_ports\]"


        set j [expr {$j+1}]
}
close $tmp2_file


#########################################################################################################
#-------------------------------------------------------------------------------------------------------#
#------------------category 3 : OUTPUT ports------------------------------------------------------------#
#-------------------------------------------------------------------------------------------------------#
#########################################################################################################

set output_early_rise_delay_start [lindex [lindex [constraints search rect $clock_start_column $output_start $col2 [expr {$number_of_rows-1}] early_rise_delay] 0] 0]
set output_early_fall_delay_start [lindex [lindex [constraints search rect $clock_start_column $output_start $col2 [expr {$number_of_rows-1}] early_fall_delay] 0] 0]
set output_late_rise_delay_start [lindex [lindex [constraints search rect $clock_start_column $output_start $col2 [expr {$number_of_rows-1}] late_rise_delay] 0] 0]
set output_late_fall_delay_start [lindex [lindex [constraints search rect $clock_start_column $output_start $col2 [expr {$number_of_rows-1}] late_fall_delay] 0] 0]
set output_load_start [lindex [lindex [constraints search rect $clock_start_column $output_start $col2 [expr {$number_of_rows-1}] load] 0] 0]
set output_clocks [lindex [lindex [constraints search rect $clock_start_column $output_start $col2 [expr {$number_of_rows-1}] clocks] 0] 0]

set k [expr {$output_start+1}]
set end_of_op_ports [expr {$number_of_rows}]
puts "\nInfo-SDC: Working on IO constraints....."
puts "\nInfo-SDC: Categorizing output ports as bits and bussed"

while { $k < $end_of_op_ports } {
#----------------differentiating output ports as bussed and bits-----------------------#
set netlist [glob -dir $NetlistDirectory *.v]
set tmp_file [open /tmp/1 w]
foreach fyle $netlist {
        set fd [open $fyle]
        while {[gets $fd line] != -1} {
			set pattern1 " [constraints get cell 0 $k];"
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
    set op_ports [concat [constraints get cell 0 $k]*]
} else {
    set op_ports [constraints get cell 0 $k]
}
        puts -nonewline $sdc_file "\nset_output_delay -clock  [constraints get cell $output_clocks $k] -min -rise  [constraints get cell $output_early_rise_delay_start $k] \[get_ports $op_ports\]"
        puts -nonewline $sdc_file "\nset_output_delay -clock  [constraints get cell $output_clocks $k] -min -fall  [constraints get cell $output_early_fall_delay_start $k] \[get_ports $op_ports\]"
        puts -nonewline $sdc_file "\nset_output_delay -clock  [constraints get cell $output_clocks $k] -max -rise  [constraints get cell $output_late_rise_delay_start $k] \[get_ports $op_ports\]"
        puts -nonewline $sdc_file "\nset_output_delay -clock  [constraints get cell $output_clocks $k] -max -fall  [constraints get cell $output_late_fall_delay_start $k] \[get_ports $op_ports\]"
		puts -nonewline $sdc_file "\nset_load [constraints get cell $output_load_start $k] \[get_ports $op_ports\]"

	set k [expr {$k+1}]
}
close $tmp2_file
close $sdc_file

puts "\nInfo: SDC created. Please use constraints in path  $OutputDirectory/$DesignName.sdc"



#########################################################################################################
#-------------------------------------------------------------------------------------------------------#
#------------------------------Hierarchy check----------------------------------------------------------#
#-------------------------------------------------------------------------------------------------------#
#########################################################################################################


puts "\nInfo: Creating hierarchy check script to be used by Yosys"
set data "read_liberty -lib -ignore_miss_dir -setattr blackbox ${LateLibraryPath}"
set filename "$DesignName.hier.ys"
set fileId [open $OutputDirectory/$filename "w"]
puts -nonewline $fileId $data

set netlist [glob -dir $NetlistDirectory *.v]
foreach f $netlist {
	set data $f
	puts -nonewline $fileId "\nread_verilog $f"
}

puts -nonewline $fileId "\nhierarchy -check"
close $fileId 

puts "\nInfo: Checking hierarchy ....."
set my_err [catch { exec yosys -s $OutputDirectory/$DesignName.hier.ys >& $OutputDirectory/$DesignName.hierarchy_check.log} msg]
if { $my_err } {
	set filename "$OutputDirectory/$DesignName.hierarchy_check.log"
	set pattern "referenced in module"
	set count 0
	set fid [open $filename r]
	while {[gets $fid line] != -1} {
		incr count [regexp -all -- $pattern $line]
		if {[regexp -all -- $pattern $line]} {
			puts "\nError: module [lindex $line 2] is not part of design $DesignName. Please correct RTL in the path '$NetlistDirectory'"
			puts "\nInfo: Hierarchy check FAIL"
		}
	}
	close $fid
} else {
	puts "\nInfo: Hierarchy check PASS"
}
puts "\nInfo: Please find hierarchy check in details in [file normalize $OutputDirectory/$DesignName.hierarchy_check.log] for more info"
cd $working_dir

#########################################################################################################
#-------------------------------------------------------------------------------------------------------#
#-----------------------------------------Main Synthsis Script------------------------------------------#
#-------------------------------------------------------------------------------------------------------#
#########################################################################################################


puts "\nInfo: Creating main synthesis script to be used by Yosys"
set data "read_liberty -lib -ignore_miss_dir -setattr blackbox ${LateLibraryPath}"
set filename "$DesignName.ys"
#puts "filename is \"$filename\""
set fileId [open $OutputDirectory/$filename "w"]
puts -nonewline $fileId $data

set netlist [glob -dir $NetlistDirectory *.v]
foreach f $netlist {
	set data $f
	puts -nonewline $fileId "\nread_verilog $f"
}

puts -nonewline $fileId "\nhierarchy -top $DesignName"
puts -nonewline $fileId "\nsynth -top $DesignName"
puts -nonewline $fileId "\nsplitnets -ports -format __\ndfflibmap -liberty ${LateLibraryPath}\nopt"
puts -nonewline $fileId "\nabc -liberty ${LateLibraryPath}"
puts -nonewline $fileId "\nflatten"
puts -nonewline $fileId "\nclean -purge \niopadmap -outpad BUFX2 A:Y -bits \nopt \nclean"
puts -nonewline $fileId "\nwrite_verilog $OutputDirectory/$DesignName.synth.v"
close $fileId
puts "\nInfo: Synthesis script created and can be accessed from path $OutputDirectory/$DesignName.ys"
puts "\nInfo: Running synthesis............."

#----------------------------------------------------------------------------#
#----------------------Run synthesis script using yosys----------------------#
#----------------------------------------------------------------------------#
if { !$my_err } {
	set my_err1 [catch { exec yosys -s $OutputDirectory/$DesignName.ys >& $OutputDirectory/$DesignName.synthesis.log} msg]
	if { $my_err1 } {
	puts "\nError: Synthesis failed due to errors. Please refer to log $OutputDirectory/$DesignName.synthesis.log for errors"
	puts "\nInfo: Please refer to $OutputDirectory/$DesignName.synthesis.log"
	exit
	} else {
	puts "\nInfo: Synthesis finished successfully"
	puts "\nInfo: Please refer to $OutputDirectory/$DesignName.synthesis.log"
	}
} else {
	puts "Refer to [file normalize $OutputDirectory/$DesignName.hierarchy_check.log]. Need to ensure Hierachy Check Pass "
}

#We have to edit the output file because it has to be accepted by other tools. So we have to remove the redundant lines and symbols inorder to do it.


################################################################################
#--------------------Edit synth.v to be used by opentimer----------------------#
################################################################################


set fileid [open /tmp/1 "w"]
puts -nonewline $fileid [exec grep -v -w "*" $OutputDirectory/$DesignName.synth.v]
#grep  -v -w "*" gets alll the instances with * in it so that we can remove them as they arent understood by Opentimer
close $fileid

set output [open $OutputDirectory/$DesignName.final.synth.v "w"]

set filename "/tmp/1"
set fid [open $filename r]
while {[gets $fid line] != -1} {
	puts -nonewline $output [string map {"\\" ""} $line]
	puts -nonewline $output "\n"
}

close $fid
close $output

puts "\nInfo : Please find the final synthesized netlist for $DesignName at below path. You cann use this netlist for STA or PNR"
puts "$OutputDirectory/$DesignName.final.synth.v"

#Here we are replacing backslashes with null charachter

##########################################
#PROCS helps us to create custom commands#
##########################################

#################################################################################
#-------------------------------------------------------------------------------#
#---------------Static Timing Analysis using opentimer--------------------------#
#-------------------------------------------------------------------------------#
#################################################################################



puts "\nInfo : To know more about procs , Navigate to /home/vsduser/vsdsynth/procs"
puts "\nInfo : sourcing all the procs available in above path using another proc called -prochelp"
puts "\nInfo : Timing Analysis Started"
puts "Initializing number of threads, libraries, sdc, verilog netlist paths.............\n"
source /home/vsduser/vsdsynth/procs/proc_help.proc
proc_help -prochelp
reopenStdout $OutputDirectory/$DesignName.conf
set_multi_cpu_usage -localCpu 4
read_lib -early /home/vsduser/vsdsynth/osu018_stdcells.lib
read_lib -late /home/vsduser/vsdsynth/osu018_stdcells.lib
read_verilog $OutputDirectory/$DesignName.final.synth.v
read_sdc $OutputDirectory/$DesignName.sdc
reopenStdout /dev/tty


#In the SDC file we generated using Constraints given, there were brackets but opentimer doesnt accept those brackets so we have to remove them

#all changes to be done to sdc fikle for it to go to opentimer is done

#now we have to create a .conf file

#.conf file is the  master file that is supplied to Opentimer tool


if {$enable_prelayout_timing == 1} {
	puts "\nInfo : enable_prelayout_timing is $enable_prelayout_timing.Enabling zero-wire load parasitics.........."
	set spef_file [open $OutputDirectory/$DesignName.spef w]
	puts $spef_file "*SPEF \"IEEE 1481-1998\""
	puts $spef_file "*DESIGN \"$DesignName\""
	puts $spef_file "*DATE \"Mon Jul 10 06:36:15 2023\""
	puts $spef_file "*VENDOR \"VLSI System Design\""
	puts $spef_file "*PROGRAM \"VSD TCL Workshop\""
	puts $spef_file "*VERSION \"0.0\""
	puts $spef_file "*DESIGN FLOW \"NETLIST_TYPE_VERILOG\""
	puts $spef_file "*DIVIDER /"
	puts $spef_file "*DELIMITER : "
	puts $spef_file "*BUS_DELIMITER [ ]"
	puts $spef_file "*T_UNIT 1 PS"
	puts $spef_file "*C_UNIT 1 FF"
	puts $spef_file "*R_UNIT 1 KOHM"
	puts $spef_file "*L_UNIT 1 UH"
}
close $spef_file

set conf_file [open $OutputDirectory/$DesignName.conf a] 
# a in above line end indicates append mode
puts $conf_file "set_spef_fpath $OutputDirectory/$DesignName.spef"
puts $conf_file "init_timer"
puts $conf_file "report_timer"
puts $conf_file "report_wns"
puts $conf_file "report_tns"
puts $conf_file "report_worst_paths -numPaths 10000 " 
close $conf_file

#Script to generate QOR Quality of Results required to determine performance of our design
#one of the prefferred formats for the QOR is horizontal format


###########################################################################
#-------------------------------------------------------------------------#
#----------------------Getting Runtime------------------------------------#
#-------------------------------------------------------------------------#
###########################################################################


set tcl_precision 3
set time_elapsed_in_us [time {exec /home/vsduser/OpenTimer-1.0.5/bin/OpenTimer < $OutputDirectory/$DesignName.conf >& $OutputDirectory/$DesignName.results} 1]

set time_elapsed_in_sec "[expr {[lindex $time_elapsed_in_us 0]/100000}]sec"

puts "\nInfo: STA finished in $time_elapsed_in_sec seconds"

#time is a tcl command that gives runtime for entire command that is followed by time command

puts "\nInfo : Refer to $OutputDirectory/$DesignName.results for errors and warnings"

#RAT - Rted arrival time

###########################################################################
#-------------------------------------------------------------------------#
#----------------------Find Worst Output Violations-----------------------#
#-------------------------------------------------------------------------#
###########################################################################

puts "Info : Finding Worst output violation time in ns.............."
set worst_RAT_slack "-"
set report_file [open $OutputDirectory/$DesignName.results r]
set pattern {RAT}
while {[gets $report_file line] != -1} {
	if {[regexp $pattern $line]} {
		puts "Pattern RAT found in $line"
		set worst_RAT_slack "[expr {[lindex $line 3]/1000}]ns"
		break
	} else {
		continue
	}
}
close $report_file

###########################################################################
#-------------------------------------------------------------------------#
#----------------------Find no.of Output Violations-----------------------#
#-------------------------------------------------------------------------#
###########################################################################

puts "\nInfo : Calculating no.of output violations..............."
set report_file [open $OutputDirectory/$DesignName.results r]
set count 0
while {[gets $report_file line] != -1} {
	incr count [regexp -all -- $pattern $line]
}
puts "$count"
set number_of_output_violations $count
close $report_file

###########################################################################
#-------------------------------------------------------------------------#
#----------------------Find Worst setup violations------------------------#
#-------------------------------------------------------------------------#
###########################################################################

puts "Info : Finding worst setup violation time in ns..............."
set worst_neative_setup_slack "-"
set report_file [open $OutputDirectory/$DesignName.results r]
set pattern {Setup}
while {[gets $report_file line] != -1} {
        if {[regexp $pattern $line]} {
                puts "Pattern Setup found in $line"
                set worst_negative_setup_slack "[expr {[lindex $line 3]/1000}]ns"
                break
        } else {
                continue
        }
}
close $report_file


###########################################################################
#-------------------------------------------------------------------------#
#----------------------Find no.of setup Violations------------------------#
#-------------------------------------------------------------------------#
###########################################################################

puts "Info : Finding no.of setup violations..................."
set report_file [open $OutputDirectory/$DesignName.results r]
set count 0
while {[gets $report_file line] != -1} {
        incr count [regexp -all -- $pattern $line]
}
set number_of_setup_violations $count
close $report_file

###########################################################################
#-------------------------------------------------------------------------#
#----------------------Find Worst hold violations------------------------#
#-------------------------------------------------------------------------#
###########################################################################

puts "Info : Finding the worst hold violation in ns.............."
set worst_neative_hold_slack "-"
set report_file [open $OutputDirectory/$DesignName.results r]
set pattern {Hold}
while {[gets $report_file line] != -1} {
        if {[regexp $pattern $line]} {
                puts "Pattern hold found in $line"
                set worst_negative_hold_slack "[expr {[lindex $line 3]/1000}]ns"
                break
        } else {
                continue
        }
}
close $report_file


###########################################################################
#-------------------------------------------------------------------------#
#-----------------------Find no.of hold Violations------------------------#
#-------------------------------------------------------------------------#
###########################################################################

puts "Finding the number of hold violations.............."
set report_file [open $OutputDirectory/$DesignName.results r]
set count 0
while {[gets $report_file line] != -1} {
        incr count [regexp -all -- $pattern $line]
}
set number_of_hold_violations $count
close $report_file

###########################################################################
#-------------------------------------------------------------------------#
#----------------------------Instance count-------------------------------#
#-------------------------------------------------------------------------#
###########################################################################

#in results file, there is something called as Num of gates so just grabbing that and getting the value beside it does the job

puts "Info : getting instance count..............."
set pattern {Num of gates}
set report_file [open $OutputDirectory/$DesignName.results r]
while {[gets $report_file line] != -1} {
	if {[regexp -all -- $pattern $line]} {
		set Instance_count [lindex [join $line " "] 4]
		break
	} else {
		continue 
	}
}
close $report_file

#puts "DesignName is \{$DesignName\}"
#puts "time_elapsed_in_sec is \{$time_elapsed_in_sec\}"
#puts "Instance_count is \{$Instance_count\}"
#puts "worst_negative_setup_slack is \{$worst_negative_setup_slack\}"
#puts "Number_of_setup_violations is \{$Number_of_setup_violations\}"
#puts "worst_negative_hold_slack is \{$worst_negative_hold_slack\}"
#puts "Number_of_hold_violations is \{$Number_of_hold_violations\}"
#puts "worst_RAT_slack is \{$worst_RAT_slack\}"
#puts "Number_of_output_violations is \{$Number_of_output_violations\}"

puts "\n"
puts "						****PRELAYOUT TIMING RESULTS**** 					"
set formatStr "%15s %15s %15s %15s %15s %15s %15s %15s %15s"

puts [format $formatStr "----------" "-------" "--------------" "---------" "---------" "--------" "--------" "-------" "-------"]
puts [format $formatStr "DesignName" "Runtime" "Instance Count" "WNS Setup" "FEP Setup" "WNS Hold" "FEP Hold" "WNS RAT" "FEP RAT"]
puts [format $formatStr "----------" "-------" "--------------" "---------" "---------" "--------" "--------" "-------" "-------"]

foreach design_name $DesignName runtime $time_elapsed_in_sec instance_count $Instance_count wns_setup $worst_negative_setup_slack fep_setup $number_of_setup_violations wns_hold $worst_negative_hold_slack fep_hold $number_of_hold_violations wns_rat $worst_RAT_slack fep_rat $number_of_output_violations {
	puts [format $formatStr $design_name $runtime $instance_count $wns_setup $fep_setup $wns_hold $fep_hold $wns_rat $fep_rat]
}

puts [format $formatStr "----------" "-------" "--------------" "---------" "---------" "--------" "--------" "-------" "-------"]
puts "\n"




