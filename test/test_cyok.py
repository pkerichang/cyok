import pprint

import cyok

bit_file = 'foobar.bit'

# load DLL
cyok.load_library()

# check version
print('FrontPanel DLL built on: %s, %s' % cyok.get_version())

# connect to device
dev = cyok.PyFrontPanel()

print('Opening device connection.')
dev.open_by_serial()

print('Getting device information.')
dev_info = dev.get_device_info()
pprint.pprint(dev_info)

print('Program FPGA with bit file.')
dev.configure_fpga(bit_file)

if not dev.is_front_panel_enabled():
    raise ValueError('FrontPanel is not enabled on the device.')

print('Closing device.')
dev.close()

# free DLL
cyok.free_library()
