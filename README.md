# gas_electric_early_warning
Case study of the gas-electric early warning system in Zhejiang Province, which is coded and tested at MATLAB_R2023b.  

For the proactive control optimization problem, YALMIP R20230609 and MOSEK 10.1 are used. YALMIP is an open-source optimization modeling tool for MATLAB which can be downloaded at https://yalmip.github.io. MOSEK is a mature commercial solver for optimization problem which can be downloaded at https://www.mosek.com. Their installation methods can also be found on the corresponding website, and the installation should be very fast.

In the folder "small_case", the file "proactive_control.m" shows the main procedure of the gas-electric early warning followed by the proactive control method; the file "passive_control.m" shows the basis of comparison; the file "paspdp.m" shows the plotting program. For most mainstream laptops, these procedures should be completed in seconds.  

In the folder "large_case", the file "proactive_control.m" shows the main procedure of the gas-electric early warning followed by the proactive control method; the file "passive_control.m" shows the basis of comparison; the file "plot_proactive.m" shows the plotting program. For most mainstream laptops, the optimization procedure should be completed in tens of seconds.  

In the folder "early_warning_data", there exhibit global natural gas power generation data, globle gas pipeline infrastructure data, and coupled gas-electricity system data in Zhejiang Province.  
