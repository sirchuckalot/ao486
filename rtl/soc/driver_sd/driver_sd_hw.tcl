# TCL File Generated by Component Editor 13.1
# Thu Jan 16 22:27:48 CET 2014
# DO NOT MODIFY


# 
# driver_sd "driver_sd" v1.0
#  2014.01.16.22:27:48
# 
# 

# 
# request TCL package from ACDS 13.1
# 
package require -exact qsys 13.1


# 
# module driver_sd
# 
set_module_property DESCRIPTION ""
set_module_property NAME driver_sd
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP ao486
set_module_property AUTHOR ""
set_module_property DISPLAY_NAME driver_sd
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL AUTO
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false


# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL driver_sd
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
add_fileset_file driver_sd.v VERILOG PATH driver_sd.v TOP_LEVEL_FILE


# 
# parameters
# 


# 
# display items
# 


# 
# connection point clock
# 
add_interface clock clock end
set_interface_property clock clockRate 0
set_interface_property clock ENABLED true
set_interface_property clock EXPORT_OF ""
set_interface_property clock PORT_NAME_MAP ""
set_interface_property clock CMSIS_SVD_VARIABLES ""
set_interface_property clock SVD_ADDRESS_GROUP ""

add_interface_port clock clk clk Input 1


# 
# connection point avalon_slave_0
# 
add_interface avalon_slave_0 avalon end
set_interface_property avalon_slave_0 addressUnits WORDS
set_interface_property avalon_slave_0 associatedClock clock
set_interface_property avalon_slave_0 associatedReset reset_sink
set_interface_property avalon_slave_0 bitsPerSymbol 8
set_interface_property avalon_slave_0 burstOnBurstBoundariesOnly false
set_interface_property avalon_slave_0 burstcountUnits WORDS
set_interface_property avalon_slave_0 explicitAddressSpan 0
set_interface_property avalon_slave_0 holdTime 0
set_interface_property avalon_slave_0 linewrapBursts false
set_interface_property avalon_slave_0 maximumPendingReadTransactions 0
set_interface_property avalon_slave_0 readLatency 0
set_interface_property avalon_slave_0 readWaitTime 1
set_interface_property avalon_slave_0 setupTime 0
set_interface_property avalon_slave_0 timingUnits Cycles
set_interface_property avalon_slave_0 writeWaitTime 0
set_interface_property avalon_slave_0 ENABLED true
set_interface_property avalon_slave_0 EXPORT_OF ""
set_interface_property avalon_slave_0 PORT_NAME_MAP ""
set_interface_property avalon_slave_0 CMSIS_SVD_VARIABLES ""
set_interface_property avalon_slave_0 SVD_ADDRESS_GROUP ""

add_interface_port avalon_slave_0 avs_address address Input 2
add_interface_port avalon_slave_0 avs_read read Input 1
add_interface_port avalon_slave_0 avs_readdata readdata Output 32
add_interface_port avalon_slave_0 avs_write write Input 1
add_interface_port avalon_slave_0 avs_writedata writedata Input 32
add_interface_port avalon_slave_0 avs_waitrequest waitrequest Output 1
set_interface_assignment avalon_slave_0 embeddedsw.configuration.isFlash 0
set_interface_assignment avalon_slave_0 embeddedsw.configuration.isMemoryDevice 0
set_interface_assignment avalon_slave_0 embeddedsw.configuration.isNonVolatileStorage 0
set_interface_assignment avalon_slave_0 embeddedsw.configuration.isPrintableDevice 0


# 
# connection point reset_sink
# 
add_interface reset_sink reset end
set_interface_property reset_sink associatedClock clock
set_interface_property reset_sink synchronousEdges DEASSERT
set_interface_property reset_sink ENABLED true
set_interface_property reset_sink EXPORT_OF ""
set_interface_property reset_sink PORT_NAME_MAP ""
set_interface_property reset_sink CMSIS_SVD_VARIABLES ""
set_interface_property reset_sink SVD_ADDRESS_GROUP ""

add_interface_port reset_sink rst_n reset_n Input 1


# 
# connection point avalon_master_0
# 
add_interface avalon_master_0 avalon start
set_interface_property avalon_master_0 addressUnits SYMBOLS
set_interface_property avalon_master_0 associatedClock clock
set_interface_property avalon_master_0 associatedReset reset_sink
set_interface_property avalon_master_0 bitsPerSymbol 8
set_interface_property avalon_master_0 burstOnBurstBoundariesOnly false
set_interface_property avalon_master_0 burstcountUnits WORDS
set_interface_property avalon_master_0 doStreamReads false
set_interface_property avalon_master_0 doStreamWrites false
set_interface_property avalon_master_0 holdTime 0
set_interface_property avalon_master_0 linewrapBursts false
set_interface_property avalon_master_0 maximumPendingReadTransactions 0
set_interface_property avalon_master_0 readLatency 0
set_interface_property avalon_master_0 readWaitTime 1
set_interface_property avalon_master_0 setupTime 0
set_interface_property avalon_master_0 timingUnits Cycles
set_interface_property avalon_master_0 writeWaitTime 0
set_interface_property avalon_master_0 ENABLED true
set_interface_property avalon_master_0 EXPORT_OF ""
set_interface_property avalon_master_0 PORT_NAME_MAP ""
set_interface_property avalon_master_0 CMSIS_SVD_VARIABLES ""
set_interface_property avalon_master_0 SVD_ADDRESS_GROUP ""

add_interface_port avalon_master_0 avm_waitrequest waitrequest Input 1
add_interface_port avalon_master_0 avm_read read Output 1
add_interface_port avalon_master_0 avm_readdata readdata Input 32
add_interface_port avalon_master_0 avm_readdatavalid readdatavalid Input 1
add_interface_port avalon_master_0 avm_write write Output 1
add_interface_port avalon_master_0 avm_writedata writedata Output 32
add_interface_port avalon_master_0 avm_address address Output 32


# 
# connection point export_sd
# 
add_interface export_sd conduit end
set_interface_property export_sd associatedClock clock
set_interface_property export_sd associatedReset reset_sink
set_interface_property export_sd ENABLED true
set_interface_property export_sd EXPORT_OF ""
set_interface_property export_sd PORT_NAME_MAP ""
set_interface_property export_sd CMSIS_SVD_VARIABLES ""
set_interface_property export_sd SVD_ADDRESS_GROUP ""

add_interface_port export_sd sd_clk export Output 1
add_interface_port export_sd sd_dat export Bidir 4
add_interface_port export_sd sd_cmd export Bidir 1

