import sys
import filecmp
import subprocess
import sys
import os

def main():
    rtl_dir = sys.argv[1]

    if rtl_dir != r'..':
        tb_file = r'/tb/compliance_test/cwwppb_soc_tb.v'
    else:
        tb_file = r'/tb/cwwppb_soc_tb.v'


    iverilog_cmd = ['iverilog']

    iverilog_cmd += ['-o', r'out.vvp']

    iverilog_cmd += ['-I', rtl_dir + r'/rtl/core']

    iverilog_cmd += ['-D', r'OUTPUT="signature.output"']

    iverilog_cmd.append(rtl_dir + tb_file)
    iverilog_cmd.append(rtl_dir + r'/rtl/core/clint.v')
    iverilog_cmd.append(rtl_dir + r'/rtl/core/csr_reg.v')
    iverilog_cmd.append(rtl_dir + r'/rtl/core/ctrl.v')
    iverilog_cmd.append(rtl_dir + r'/rtl/core/defines.v')
    iverilog_cmd.append(rtl_dir + r'/rtl/core/div.v')
    iverilog_cmd.append(rtl_dir + r'/rtl/core/ex.v')
    iverilog_cmd.append(rtl_dir + r'/rtl/core/id.v')
    iverilog_cmd.append(rtl_dir + r'/rtl/core/id_ex.v')
    iverilog_cmd.append(rtl_dir + r'/rtl/core/if_id.v')
    iverilog_cmd.append(rtl_dir + r'/rtl/core/pc_reg.v')
    iverilog_cmd.append(rtl_dir + r'/rtl/core/regs.v')
    iverilog_cmd.append(rtl_dir + r'/rtl/core/rib.v')
    iverilog_cmd.append(rtl_dir + r'/rtl/core/cwwppb.v')

    iverilog_cmd.append(rtl_dir + r'/rtl/perips/ram.v')
    iverilog_cmd.append(rtl_dir + r'/rtl/perips/rom.v')
    iverilog_cmd.append(rtl_dir + r'/rtl/perips/timer.v')
    iverilog_cmd.append(rtl_dir + r'/rtl/perips/uart.v')
    iverilog_cmd.append(rtl_dir + r'/rtl/perips/gpio.v')
    iverilog_cmd.append(rtl_dir + r'/rtl/perips/spi.v')

    iverilog_cmd.append(rtl_dir + r'/rtl/debug/jtag_dm.v')
    iverilog_cmd.append(rtl_dir + r'/rtl/debug/jtag_driver.v')
    iverilog_cmd.append(rtl_dir + r'/rtl/debug/jtag_top.v')
    iverilog_cmd.append(rtl_dir + r'/rtl/debug/uart_debug.v')

    iverilog_cmd.append(rtl_dir + r'/rtl/soc/cwwppb_soc_top.v')

    iverilog_cmd.append(rtl_dir + r'/rtl/utils/full_handshake_rx.v')
    iverilog_cmd.append(rtl_dir + r'/rtl/utils/full_handshake_tx.v')
    iverilog_cmd.append(rtl_dir + r'/rtl/utils/gen_buf.v')
    iverilog_cmd.append(rtl_dir + r'/rtl/utils/gen_dff.v')

    process = subprocess.Popen(iverilog_cmd)
    process.wait(timeout=5)

if __name__ == '__main__':
    sys.exit(main())
