#[cfg(feature="protocol-test-client")]
pub mod client;

#[cfg(feature="protocol-test-service")]
pub mod service;

use std::mem::ManuallyDrop;
use tesseract_swift_transports::protocol::TesseractProtocol;
use tesseract_swift_utils::string::CStringRef;
use tesseract_swift_utils::{ptr::CAnyDropPtr, future_impls::CFutureString};

#[repr(C)]
pub struct TestService {
    ptr: CAnyDropPtr,
    sign_transaction: unsafe extern "C" fn(
        this: &TestService,
        req: CStringRef,
    ) -> ManuallyDrop<CFutureString>,
}

#[no_mangle]
pub extern "C" fn tesseract_protocol_test_new() -> ManuallyDrop<TesseractProtocol> {
    ManuallyDrop::new(TesseractProtocol::new(tesseract_protocol_test::Test::Protocol))
}