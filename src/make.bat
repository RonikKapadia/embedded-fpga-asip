@set FILES=clock_div_cpu.vhd clock_div_vga.vhd controls.vhd debounce.vhd dmem.vhd framebuffer.vhd irmem.vhd my_alu.vhd pixel_pusher.vhd regs.vhd top_tb.vhd top.vhd uart_rx.vhd uart_tx.vhd uart.vhd vga_ctrl.vhd
@set ENTITY=top_tb

@REM @set FILES=controls.vhd controls_tb.vhd
@REM @set ENTITY=controls_tb

@ghdl -a %FILES%
@if %ERRORLEVEL%==1 exit /b 1
@ghdl -e %ENTITY%
@ghdl -r %ENTITY% --vcd=sim.vcd
@REM @ghdl -r %ENTITY% --wave=sim.ghw

@echo Ran Successfully