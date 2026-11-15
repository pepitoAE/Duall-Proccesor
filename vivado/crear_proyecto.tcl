set ver  [lindex $argv 0]
set tb   [lindex $argv 1]
if {$ver eq ""} { set ver "B_dual_issue" }
if {$tb  eq ""} { set tb  "tb_prog_profesor" }
set root [file normalize [file join [file dirname [info script]] ..]]

create_project $ver [file join $root vivado proyectos $ver] -part xc7a35tcpg236-1 -force

add_files -norecurse [glob [file join $root $ver src *.v]]
add_files -fileset sim_1 -norecurse [glob [file join $root $ver sim *.v]]
add_files -fileset sim_1 -norecurse [glob [file join $root $ver mem *.mem]]

set_property top top [current_fileset]
set_property top $tb [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]
set_property -name {xsim.simulate.runtime} -value {all} -objects [get_filesets sim_1]

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
