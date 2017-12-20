# distutils: language = c++

from libcpp.string cimport string
from libcpp cimport bool

from cpython cimport array
import array

cdef extern from "okFrontPanelDLL.h":
    int okFrontPanelDLL_LoadLib(const char *libname)
    void okFrontPanelDLL_FreeLib(void)
    void okFrontPanelDLL_GetVersion(char *date, char *time)
        
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
        string GetDeviceID()
        
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
        ErrorCode UpdateTriggerOuts()
        ErrorCode UpdateWireIns()
        ErrorCode UpdateWireOuts()
        ErrorCode FlashEraseSector(unsigned int address)
        ErrorCode FlashWrite(unsigned int address, unsigned int length, const unsigned char * buf)
        ErrorCode FlashRead(unsigned int address, unsigned int length, unsigned int * buf)
        ErrorCode WriteRegister(unsigned int addr, unsigned int data)
        long WriteToBlockPipeIn(int epAddr, int blockSize, long length, const unsigned char * data)
        long WriteToPipeIn(int epAddr, long length, const unsigned char * data)

        
        @staticmethod
        string GetErrorString(int errorCode)

        @staticmethod
        ErrorCode RemoveCustomDevice(int productID)


cdef array.array char_arr_template = array.array('B')

        
def load_library(libname=None):
    if libname is None:
        success = okFrontPanelDLL_LoadLib(None)
    else:
        cdef char * name_bytes = libname.encode()
        success = okFrontPanelDLL_LoadLib(name_bytes)

    if not success:
        raise ValueError('Cannot load FrontPanel DLL.')


def free_library():
    okFrontPanelDLL_FreeLib()


def get_version():
    cdef char * date[32]
    cdef char * time[32]
    okFrontPanelDLL_GetVersion(date, time)
    return date.decode(), time.decode()


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
            raise ValueError(cls.get_error_string(err_code))
    
    def open_by_serial(self, name=''):
        cdef string name_bytes = name.encode()
        cdef int err_code = self.c_okfp.OpenBySerial(name_bytes)
        self.check_error(err_code)
        return err_code

    def close(self):
        self.c_okfp.Close()
    
    def load_default_pll_configuration(self):
        cdef int err_code = self.c_okfp.LoadDefaultPllConfiguration()
        self.check_error(err_code)
        return err_code
        
    def configure_fpga(self, file_name):
        cdef string name_bytes = file_name.encode()
        cdef int err_code = self.c_okfp.ConfigureFPGA(name_bytes)
        self.check_error(err_code)
        return err_code
        
    def is_front_panel_enabled(self):
        cdef bool enabled = self.c_okfp.IsFrontPanelEnabled()
        return enabled

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

    def read_from_block_pipe_out(int ep_addr, int block_size, long length):
        cdef array.array arr
        arr = array.clone(char_arr_template, length, False)
        cdef long num_bytes = self.c_okfp.ReadFromBlockPipeOut(ep_addr, block_size, length,
                                                               arr.data.as_uchars)
        if num_bytes < 0:
            self.check_error((int)num_bytes)
            return None
        else:
            array.resize(arr, num_bytes)
            return arr

    def read_from_pipe_out(int ep_addr, long length):
        cdef array.array arr
        arr = array.clone(char_arr_template, length, False)
        cdef long num_bytes = self.c_okfp.ReadFromPipeOut(ep_addr, length, arr.data.as_uchars)
        if num_bytes < 0:
            self.check_error((int)num_bytes)
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
        cdef int err_code = self.c_okfp.UpdateTriggerOuts()
        return err_code
    
    def update_wire_ins(self):
        cdef int err_code = self.c_okfp.UpdateWireIns()
        return err_code

    def update_wire_outs(self):
        cdef int err_code = self.c_okfp.UpdateWireIns()
        return err_code

    def write_to_block_pipe_in(self, int ep_addr, int block_size, object arr):
        cdef long length = len(arr)
        cdef int err_code = self.c_okfp.WriteToBlockPipeIn(ep_addr, block_size, length,
                                                           arr.data.as_uchars)
        return err_code

    def write_to_pipe_in(self, int ep_addr, object arr):
        cdef long length = len(arr)
        cdef int err_code = self.c_okfp.WriteToPipeIn(ep_addr, length, arr.data.as_uchars)
        return err_code
        
    
