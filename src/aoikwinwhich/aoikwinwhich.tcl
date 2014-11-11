#/

proc ret {x} {
    return $x
}

#/ Modified from |http://stackoverflow.com/a/3235303|
##
## This proc returns a func-like list with |apply| being first item, and
##  |apply|'s first arg (i.e. func definition) as second item.
## When the result list is expanded using syntax |{*}$f|, |apply| becomes the
##  command, it will perform the func call. Any following args become args of
##  the func call.
##
## Syntax for creating a func-like list:
## ```
## set fl [func {x} {expr $x > 0}]
## ```
##
## Syntax for calling a func-like list:
## ```
## {*}$fl $arg
## ```
proc func {args body} {
    set ns [uplevel 1 namespace current]
    return [list ::apply [list $args $body $ns]]
}

proc any {item_s funcl} {
    foreach item $item_s {
        if {[{*}$funcl $item] != 0} {
            return 1
        }
    }
    return 0
}

#/ Modified from |http://stackoverflow.com/a/20376860|
proc uniq item_s {
    set item_d [dict create]

    foreach item $item_s {
        dict set item_d $item 1
    }

    return [dict keys $item_d]
}

proc endswith {hay ndl} {
    set hay_len [string length $hay]

    set ndl_len [string length $ndl]

    if {[expr $hay_len < $ndl_len]} {
        return 0
    } else {
        if {[expr [string last $ndl $hay] == [expr $hay_len - $ndl_len]]} {
            return 1
        } else {
            return 0
        }
    }
}

proc find_executable prog {
    #/ 8f1kRCu
    set env_var_PATHEXT [
        if {[info exists ::env(PATHEXT)]} {
            ret $::env(PATHEXT)
        } else {
            ret {}
        }
    ]

    #/ 6qhHTHF
    #/ split into a list of extensions
    set ext_s [
        if {[string length $env_var_PATHEXT] == 0} {
            ret [list]
        } else {
            ret [split $env_var_PATHEXT ";"]
        }
    ]

    #/ 2pGJrMW
    #/ strip
    set ext_s [lmap x $ext_s {set x [string trim $x]}]

    #/ 2gqeHHl
    #/ remove empty
    set ext_s [lmap x $ext_s {
        if {[string length $x] == 0} continue
        set x
        }
    ]

    #/ 2zdGM8W
    #/ convert to lowercase
    set ext_s [lmap x $ext_s {set x [string tolower $x]}]

    #/ 2fT8aRB
    #/ uniquify
    set ext_s [uniq $ext_s]

    #/ 4ysaQVN
    set env_var_PATH [
        if {[info exists ::env(PATH)]} {
            ret $::env(PATH)
        } else {
            ret {}
        }
    ]

    #/ 6mPI0lg
    set dir_path_s [
        if {[string length $env_var_PATH] == 0} {
            ret [list]
        } else {
            ret [split $env_var_PATH ";"]
        }
    ]

    #/ 5rT49zI
    #/ insert empty dir path to the beginning
    ##
    ## Empty dir handles the case that |prog| is a path, either relative or
    ##  absolute. See code 7rO7NIN.
    set dir_path_s [linsert $dir_path_s 0 ""]

    #/ 2klTv20
    #/ uniquify
    set dir_path_s [uniq $dir_path_s]

    #/
    set prog_lc [string tolower $prog]

    set func_body "endswith $prog_lc \$ext"
    ## Must substitute |$prog_lc| to its value here
    ##  because |func| below does not support closure.

    set prog_has_ext [any $ext_s [func {ext} $func_body]]

    #/ 6bFwhbv
    set exe_path_s [list]

    foreach dir_path $dir_path_s {
        #/ 7rO7NIN
        #/ synthesize a path with the dir and prog
        set path [
            if {$dir_path == ""} {
                ret $prog
            } else {
                ret [string cat $dir_path [file separator] $prog]
            }
        ]

        #/ 6kZa5cq
        ## assume the path has extension, check if it is an executable
        if {$prog_has_ext && [file isfile $path]} {
            set exe_path_s [lappend exe_path_s $path]
        }

        #/ 2sJhhEV
        ## assume the path has no extension
        foreach ext $ext_s {
            #/ 6k9X6GP
            #/ synthesize a new path with the path and the executable extension
            set path_plus_ext [string cat $path $ext]

            #/ 6kabzQg
            #/ check if it is an executable
            if {[file isfile $path_plus_ext]} {
                set exe_path_s [lappend exe_path_s $path_plus_ext]
            }
        }
    }

    #/ 8swW6Av
    #/ uniquify
    set exe_path_s [uniq $exe_path_s]

    #/
    return $exe_path_s
}

proc main {} {
    #/ 9mlJlKg
    if {[llength $::argv] != 1} {
        #/ 7rOUXFo
        #/ print program usage
        puts {Usage: aoikwinwhich PROG}
        puts {}
        puts {#/ PROG can be either name or path}
        puts {aoikwinwhich notepad.exe}
        puts {aoikwinwhich C:\Windows\notepad.exe}
        puts {}
        puts {#/ PROG can be either absolute or relative}
        puts {aoikwinwhich C:\Windows\notepad.exe}
        puts {aoikwinwhich Windows\notepad.exe}
        puts {}
        puts {#/ PROG can be either with or without extension}
        puts {aoikwinwhich notepad.exe}
        puts {aoikwinwhich notepad}
        puts {aoikwinwhich C:\Windows\notepad.exe}
        puts {aoikwinwhich C:\Windows\notepad}

        #/ 3nqHnP7
        return
    }

    #/ 9m5B08H
    #/ get name or path of a program from cmd arg
    set prog [lindex $::argv 0]

    #/ 8ulvPXM
    #/ find executables
    set path_s [find_executable $prog]

    #/ 5fWrcaF
    #/ has found none, exit
    if {[llength $path_s] == 0} {
        #/ 3uswpx0
        return
    }

    #/ 9xPCWuS
    #/ has found some, output
    set txt [join $path_s "\n"]

    puts $txt

    #/ 4s1yY1b
    return
}

main
