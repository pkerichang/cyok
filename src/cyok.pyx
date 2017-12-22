# distutils: language = c++

from libcpp.string cimport string
from libcpp cimport bool

from cpython cimport array
import array

from collections import namedtuple

cdef extern from "okFrontPanelDLL.h":
    int okFrontPanelDLL_LoadLib(const char *libname)
    void okFrontPanelDLL_FreeLib()
    void okFrontPanelDLL_GetVersion(char *date, char *time)

    cdef cppclass okTFlashLayout:
        unsigned int sectorCount
        unsigned int sectorSize
        unsigned int pageSize
        unsigned int minUserSector
        unsigned int maxUserSector
    
    cdef cppclass okTDeviceInfo:
        char * deviceID
        char * serialNumber
        char * productName
        int productID
        int deviceInterface
        int usbSpeed
        int deviceMajorVersion
        int deviceMinorVersion
        int hostInterfaceMajorVersion
        int hostInterfaceMinorVersion
        bool isPLL22150Supported
        bool isFrontPanelEnabled
        int wireWidth
        int triggerWidth
        int pipeWidth
        int registerAddressWidth
        int registerDataWidth

        okTFlashLayout flashSystem
        okTFlashLayout flashFPGA

        bool hasFMCEEPROM
        bool hasResetProfiles
    
        
    cdef cppclass okCFrontPanel:
        enum ErrorCode:
            NoError,
            Failed,
            Timeout,
            DoneNotHigh,
            TransferError,
            CommunicationError,
            InvalidBitstream,
            FileError,
            DeviceNotOpen,
            InvalidEndpoint,
            InvalidBlockSize,
            I2CRestrictedAddress,
            I2CBitError,
            I2CNack,
            I2CUnknownStatus,
            UnsupportedFeature,
            FIFOUnderflow,
            FIFOOverflow,
            DataAlignmentError,
            InvalidResetProfile,
            InvalidParameter
    
        okCFrontPanel()

        ErrorCode ActivateTriggerIn(int epAddr, int bit)
        void Close()
        ErrorCode ConfigureFPGA(const string strFilename)

        void EnableAsynchronousTransfers(bool enable)

        int GetDeviceCount()
        ErrorCode GetDeviceInfo(okTDeviceInfo * info)
        
        string GetDeviceListSerial(int num)
        int GetDeviceMajorVersion()
        int GetDeviceMinorVersion()

        int GetHostInterfaceWidth()
        long GetLastTransferLength()

        string GetSerialNumber()

        ErrorCode GetWireInValue(int epAddr, unsigned int * val)
        unsigned int GetWireOutValue(int epAddr)
        bool IsHighSpeed()
        bool IsFrontPanel3Supported()
        bool IsFrontPanelEnabled()
        bool IsOpen()
        bool IsTriggered(int epAddr, unsigned int mask)
        unsigned int GetTriggerOutVector(int epAddr)
        ErrorCode LoadDefaultPLLConfiguration()
        ErrorCode OpenBySerial(string)
        ErrorCode ReadI2C(const int addr, int length, unsigned char * data)
        long ReadFromBlockPipeOut(int epAddr, int blockSize, long length, unsigned char * data)
        long ReadFromPipeOut(int epAddr, long length, unsigned char * data)
        ErrorCode ReadRegister(unsigned int addr, unsigned int * data)

        ErrorCode ResetFPGA()
        ErrorCode SetBTPipePollingInterval(int interval)
        void SetDeviceID(string)

        void SetTimeout(int timeout)
        ErrorCode SetWireInValue(int ep, unsigned int val, unsigned int mask)
        void UpdateTriggerOuts()
        void UpdateWireIns()
        void UpdateWireOuts()
        ErrorCode FlashEraseSector(unsigned int address)
        ErrorCode FlashWrite(unsigned int address, unsigned int length, const unsigned char * buf)
        ErrorCode FlashRead(unsigned int address, unsigned int length, unsigned int * buf)
        ErrorCode WriteRegister(unsigned int addr, unsigned int data)
        long WriteToBlockPipeIn(int epAddr, int blockSize, long length, unsigned char * data)
        long WriteToPipeIn(int epAddr, long length, unsigned char * data)

        
        @staticmethod
        string GetErrorString(int errorCode)

        @staticmethod
        ErrorCode RemoveCustomDevice(int productID)


cdef array.array char_arr_template = array.array('B')

PyTFlashLayout = namedtuple('PyTFlashLayout', ['sectorCount', 'sectorSize', 'pageSize',
                                               'minUserSector', 'maxUserSector'])

PyTDeviceInfo = namedtuple('PyTDeviceInfo', ['deviceID', 'serialNumber', 'productName', 'productID',
                                             'deviceInterface', 'usbSpeed', 'deviceMajorVersion',
                                             'deviceMinorVersion', 'hostInterfaceMajorVersion',
                                             'hostInterfaceMinorVersion', 'isPLL22150Supported',
                                             'isFrontPanelEnabled', 'wireWidth', 'triggerWidth',
                                             'pipeWidth', 'registerAddressWidth', 'registerDataWidth',
                                             'flashSystem', 'flashFPGA', 'hasFMCEEPROM', 'hasResetProfiles'])

def load_library(libname=None):
    cdef char * name_bytes = NULL
    if libname is not None:
        temp = libname.encode()
        name_bytes = temp

    success = okFrontPanelDLL_LoadLib(name_bytes)
    if not success:
        raise ValueError('Cannot load FrontPanel DLL.')


def free_library():
    okFrontPanelDLL_FreeLib()


def get_version():
    cdef char date[32]
    cdef char time[32]
    okFrontPanelDLL_GetVersion(date, time)
    py_date = date.decode()
    py_time = time.decode()
    return py_date, py_time


cdef convert_TFlashLayout(okTFlashLayout * layout):
    return PyTFlashLayout(sectorCount=layout[0].sectorCount,
                          sectorSize=layout[0].sectorSize,
                          pageSize=layout[0].pageSize,
                          minUserSector=layout[0].minUserSector,
                          maxUserSector=layout[0].maxUserSector,
    )


cdef convert_TDeviceInfo(okTDeviceInfo * info):
    cdef char * dev_id = info[0].deviceID
    cdef char * serial_num = info[0].serialNumber
    cdef char * prod_name = info[0].productName
    return PyTDeviceInfo(deviceID=dev_id.decode(),
                         serialNumber=serial_num.decode(),
                         productName=prod_name.decode(),
                         productID=info[0].productID,
                         deviceInterface=info[0].deviceInterface,
                         usbSpeed=info[0].usbSpeed,
                         deviceMajorVersion=info[0].deviceMajorVersion,
                         deviceMinorVersion=info[0].deviceMinorVersion,
                         hostInterfaceMajorVersion=info[0].hostInterfaceMajorVersion,
                         hostInterfaceMinorVersion=info[0].hostInterfaceMinorVersion,
                         isPLL22150Supported=info[0].isPLL22150Supported,
                         isFrontPanelEnabled=info[0].isFrontPanelEnabled,
                         wireWidth=info[0].wireWidth,
                         triggerWidth=info[0].triggerWidth,
                         pipeWidth=info[0].pipeWidth,
                         registerAddressWidth=info[0].registerAddressWidth,
                         registerDataWidth=info[0].registerDataWidth,
                         flashSystem=convert_TFlashLayout(&(info[0].flashSystem)),
                         flashFPGA=convert_TFlashLayout(&(info[0].flashFPGA)),
                         hasFMCEEPROM=info[0].hasFMCEEPROM,
                         hasResetProfiles=info[0].hasResetProfiles,
    )

cdef class PyFrontPanel:
    cdef okCFrontPanel c_okfp
    def __init__(self):
        pass

    @classmethod
    def get_error_string(cls, int err_code):
        cdef string msg = okCFrontPanel.GetErrorString(err_code)
        return msg.decode()

    @classmethod
    def check_error(cls, int err_code):
        # NOTE: Technically, we should check against okCFrontPanel::ErrorCode.NoError,
        # but I cannot figure out how to expose inner enums to Cython.
        if err_code < 0:
            raise ValueError('error code = %d, msg: %s' % (err_code, cls.get_error_string(err_code)))
    
    def open_by_serial(self, name=''):
        temp = name.encode()
        cdef string name_bytes = temp
        cdef int err_code = self.c_okfp.OpenBySerial(name_bytes)
        self.check_error(err_code)
        return err_code

    def reset_fpga(self):
        cdef int err_code = self.c_okfp.ResetFPGA()
        return err_code

    def close(self):
        self.c_okfp.Close()

    def get_device_count(self):
        cdef int cnt = self.c_okfp.GetDeviceCount()
        return cnt

    def get_device_info(self):
        cdef okTDeviceInfo info
        cdef int err_code = self.c_okfp.GetDeviceInfo(&info)
        self.check_error(err_code)
        return convert_TDeviceInfo(&info)
        
    def load_default_pll_configuration(self):
        cdef int err_code = self.c_okfp.LoadDefaultPLLConfiguration()
        self.check_error(err_code)
        return err_code
        
    def configure_fpga(self, file_name):
        temp = file_name.encode()
        cdef string name_bytes = temp
        cdef int err_code = self.c_okfp.ConfigureFPGA(name_bytes)
        self.check_error(err_code)
        return err_code
        
    def is_front_panel_enabled(self):
        cdef bool enabled = self.c_okfp.IsFrontPanelEnabled()
        return enabled

    def is_front_panel_3_supported(self):
        cdef bool supported = self.c_okfp.IsFrontPanel3Supported()
        return supported

    def is_open(self):
        cdef bool opened = self.c_okfp.IsOpen()
        return opened
    
    def get_wire_in_value(self, int ep_addr):
        cdef unsigned int val
        cdef int err_code = self.c_okfp.GetWireInValue(ep_addr, &val)
        self.check_error(err_code)
        return val

    def get_wire_out_value(self, int ep_addr):
        cdef int val = self.c_okfp.GetWireOutValue(ep_addr)
        return val

    def is_triggered(self, int ep_addr, unsigned int mask):
        cdef bool ans = self.c_okfp.IsTriggered(ep_addr, mask)
        return ans
    
    def read_from_block_pipe_out(self, int ep_addr, int block_size, long length):
        cdef array.array arr
        arr = array.clone(char_arr_template, length, False)
        cdef long num_bytes = self.c_okfp.ReadFromBlockPipeOut(ep_addr, block_size, length,
                                                               arr.data.as_uchars)
        if num_bytes < 0:
            self.check_error(<int>num_bytes)
            return None
        else:
            array.resize(arr, num_bytes)
            return arr

    def read_from_pipe_out(self, int ep_addr, long length):
        cdef array.array arr
        arr = array.clone(char_arr_template, length, False)
        cdef long num_bytes = self.c_okfp.ReadFromPipeOut(ep_addr, length, arr.data.as_uchars)
        if num_bytes < 0:
            self.check_error(<int>num_bytes)
            return None
        else:
            array.resize(arr, num_bytes)
            return arr
        
    def set_wire_in_value(self, int ep, unsigned int val, unsigned int mask=0xffffffff):
        cdef int err_code = self.c_okfp.SetWireInValue(ep, val, mask)
        return err_code

    def activate_trigger_in(self, int ep_addr, int bit):
        cdef int err_code = self.c_okfp.ActivateTriggerIn(ep_addr, bit)
        return err_code
    
    def update_trigger_outs(self):
        self.c_okfp.UpdateTriggerOuts()
    
    def update_wire_ins(self):
        self.c_okfp.UpdateWireIns()

    def update_wire_outs(self):
        self.c_okfp.UpdateWireOuts()

    def write_to_block_pipe_in(self, int ep_addr, int block_size, object data_list):
        cdef long length = len(data_list)
        cdef array.array arr = array.array('B', data_list)
        cdef int err_code = self.c_okfp.WriteToBlockPipeIn(ep_addr, block_size, length, arr.data.as_uchars)
        return err_code

    def write_to_pipe_in(self, int ep_addr, object data_list):
        cdef long length = len(data_list)
        cdef array.array arr = array.array('B', data_list)
        cdef int err_code = self.c_okfp.WriteToPipeIn(ep_addr, length, arr.data.as_uchars)
        return err_code
        
    
