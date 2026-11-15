set root [file normalize [file join [file dirname [info script]] ..]]
set versiones {A_single_issue B_dual_issue C_dual_optimizado}
set tbs {tb_prog_profesor tb_prog_propio}
set resumen {}

foreach ver $versiones {
  set dir [file join $root vivado proyectos $ver]
  create_project $ver $dir -part xc7a35tcpg236-1 -force
  add_files -norecurse [glob [file join $root $ver src *.v]]
  add_files -fileset sim_1 -norecurse [glob [file join $root $ver sim *.v]]
  add_files -fileset sim_1 -norecurse [glob [file join $root $ver mem *.mem]]
  set_property top top [current_fileset]
  set_property -name {xsim.simulate.runtime} -value {all} -objects [get_filesets sim_1]
  foreach tb $tbs {
    set_property top $tb [get_filesets sim_1]
    update_compile_order -fileset sim_1
    launch_simulation
    set log [file join $dir "$ver.sim" sim_1 behav xsim simulate.log]
    if {[file exists $log]} {
      set f [open $log r]
      foreach linea [split [read $f] "\n"] {
        if {[string match "METRICS*" $linea] || [string match "Etapa*" $linea]} {
          lappend resumen "$ver $tb : $linea"
        }
      }
      close $f
    }
    close_sim -force
  }
  close_project
}

puts "================ RESUMEN ================"
foreach linea $resumen { puts $linea }
