import os
import subprocess
import sys

def list_binfiles(path):
    files = []
    list_dir = os.walk(path)
    for maindir, subdir, all_file in list_dir:
        for filename in all_file:
            apath = os.path.join(maindir, filename)
            if apath.endswith('.bin'):
                files.append(apath)
    return files
    
def main():
    bin_files = list_binfiles(r'../tests/isa/generated')
    anyfail = False
    for file in bin_files:
        cmd = r'python sim.py' + ' ' + file + ' ' + 'inst.data'
        f = os.popen(cmd)
        r = f.read()
        f.close()
        if (r.find('TEST_PASS') != -1):
            print(file + '    nlnlsofun')
        else:
            print(file + '!!!關進熊熊監獄,因為你失敗了!!!')
            anyfail = True
            break
    if (anyfail == False):
        print('恨熊熊,你在水時數阿, All PASS...')
if __name__ == '__main__':
    sys.exit(main())
