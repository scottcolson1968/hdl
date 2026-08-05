# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "BEATCNT_W" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DATA_W" -parent ${Page_0}
  ipgui::add_param $IPINST -name "KEEP_W" -parent ${Page_0}
  ipgui::add_param $IPINST -name "META_DEPTH" -parent ${Page_0}


}

proc update_PARAM_VALUE.BEATCNT_W { PARAM_VALUE.BEATCNT_W } {
	# Procedure called to update BEATCNT_W when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.BEATCNT_W { PARAM_VALUE.BEATCNT_W } {
	# Procedure called to validate BEATCNT_W
	return true
}

proc update_PARAM_VALUE.DATA_W { PARAM_VALUE.DATA_W } {
	# Procedure called to update DATA_W when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DATA_W { PARAM_VALUE.DATA_W } {
	# Procedure called to validate DATA_W
	return true
}

proc update_PARAM_VALUE.KEEP_W { PARAM_VALUE.KEEP_W } {
	# Procedure called to update KEEP_W when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.KEEP_W { PARAM_VALUE.KEEP_W } {
	# Procedure called to validate KEEP_W
	return true
}

proc update_PARAM_VALUE.META_DEPTH { PARAM_VALUE.META_DEPTH } {
	# Procedure called to update META_DEPTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.META_DEPTH { PARAM_VALUE.META_DEPTH } {
	# Procedure called to validate META_DEPTH
	return true
}


proc update_MODELPARAM_VALUE.DATA_W { MODELPARAM_VALUE.DATA_W PARAM_VALUE.DATA_W } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DATA_W}] ${MODELPARAM_VALUE.DATA_W}
}

proc update_MODELPARAM_VALUE.KEEP_W { MODELPARAM_VALUE.KEEP_W PARAM_VALUE.KEEP_W } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.KEEP_W}] ${MODELPARAM_VALUE.KEEP_W}
}

proc update_MODELPARAM_VALUE.BEATCNT_W { MODELPARAM_VALUE.BEATCNT_W PARAM_VALUE.BEATCNT_W } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.BEATCNT_W}] ${MODELPARAM_VALUE.BEATCNT_W}
}

proc update_MODELPARAM_VALUE.META_DEPTH { MODELPARAM_VALUE.META_DEPTH PARAM_VALUE.META_DEPTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.META_DEPTH}] ${MODELPARAM_VALUE.META_DEPTH}
}

