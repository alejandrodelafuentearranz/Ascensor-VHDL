@echo off
REM ****************************************************************************
REM Vivado (TM) v2020.2 (64-bit)
REM
REM Filename    : simulate.bat
REM Simulator   : Xilinx Vivado Simulator
REM Description : Script for simulating the design by launching the simulator
REM
REM Generated by Vivado on Sat Jun 26 19:53:38 +0200 2021
REM SW Build 3064766 on Wed Nov 18 09:12:45 MST 2020
REM
REM Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
REM
REM usage: simulate.bat
REM
REM ****************************************************************************
REM simulate design
echo "xsim DISPLAY_DECODER_TB_behav -key {Behavioral:display_test:Functional:DISPLAY_DECODER_TB} -tclbatch DISPLAY_DECODER_TB.tcl -view C:/Users/Alejandro/SED/Trabajo_v11/display_decoder_tb_behav.wcfg -log simulate.log"
call xsim  DISPLAY_DECODER_TB_behav -key {Behavioral:display_test:Functional:DISPLAY_DECODER_TB} -tclbatch DISPLAY_DECODER_TB.tcl -view C:/Users/Alejandro/SED/Trabajo_v11/display_decoder_tb_behav.wcfg -log simulate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
