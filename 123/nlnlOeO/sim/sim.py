import sys
import filecmp
import subprocess
import sys
import os


def main():

    cmd = r'python ../tools/B2M.py' + ' ' + sys.argv[1] + ' ' + sys.argv[2]
    f = os.popen(cmd)
    f.close()

    cmd = r'python compile_rtl.py' + r' ..'
    f = os.popen(cmd)
    f.close()

    vvp_cmd = [r'vvp']
    vvp_cmd.append(r'out.vvp')
    process = subprocess.Popen(vvp_cmd)
    try:
        process.wait(timeout=20)
    except subprocess.TimeoutExpired:
        print('!!!Fail, vvp exec timeout!!!')
if __name__ == '__main__':
    sys.exit(main())
