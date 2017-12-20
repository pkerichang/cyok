# distutils: language = c++

from libcpp.string cimport string
from libcpp cimport bool

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
        return okCFrontPanel.GetErrorString(err_code).decode()

    @classmethod
    def check_error(cls, int err_code):
        # NOTE: Technically, we should check against okCFrontPanel::ErrorCode.NoError,
        # but I cannot figure out how to expose inner enums to Cython.
        if err_code != 0:
            raise ValueError(cls.get_error_string(err_code))
    
    def open_by_serial(self, name=''):
        cdef string name_bytes = name.encode()
        err_code = self.c_okfp.OpenBySerial(name_bytes)
        self.check_error(err_code)

    def load_default_pll_configuration(self):
        return self.c_okfp.LoadDefaultPllConfiguration()

    def configure_fpga(self, file_name):
        cdef string name_bytes = file_name.encode()
        err_code = self.c_okfp.ConfigureFPGA(name_bytes)
        self.check_error(err_code)

    def is_front_panel_enabled(self):
        return self.c_okfp.IsFrontPanelEnabled()

