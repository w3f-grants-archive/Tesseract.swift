use super::error::CError;
use super::result::CResult;
use std::mem::ManuallyDrop;

#[repr(u8)]
#[derive(Copy, Clone, Debug)]
pub enum CResponseOption {
    Error = 0,
    None,
    Some,
}

pub trait CResponse<T, R> {
    fn response(self, value: &mut T, error: &mut ManuallyDrop<CError>) -> R;
}

// impl<T: Copy> CResponse<T, bool> for CResult<T> {
//   fn response(self, value: &mut T, error: &mut ManuallyDrop<CError>) -> bool {
//     match self {
//       Err(err) => {
//         *error = ManuallyDrop::new(err);
//         false
//       }
//       Ok(val) => {
//         *value = val;
//         true
//       }
//     }
//   }
// }

impl<T> CResponse<ManuallyDrop<T>, bool> for CResult<T> {
    fn response(self, value: &mut ManuallyDrop<T>, error: &mut ManuallyDrop<CError>) -> bool {
        match self {
            Err(err) => {
                *error = ManuallyDrop::new(err);
                false
            }
            Ok(val) => {
                *value = ManuallyDrop::new(val);
                true
            }
        }
    }
}

impl<T: Copy> CResponse<T, CResponseOption> for CResult<Option<T>> {
    fn response(self, value: &mut T, error: &mut ManuallyDrop<CError>) -> CResponseOption {
        match self {
            Err(err) => {
                *error = ManuallyDrop::new(err);
                CResponseOption::Error
            }
            Ok(opt) => match opt {
                None => CResponseOption::None,
                Some(val) => {
                    *value = val;
                    CResponseOption::Some
                }
            },
        }
    }
}

impl<T> CResponse<ManuallyDrop<T>, CResponseOption> for CResult<Option<T>> {
    fn response(
        self,
        value: &mut ManuallyDrop<T>,
        error: &mut ManuallyDrop<CError>,
    ) -> CResponseOption {
        match self {
            Err(err) => {
                *error = ManuallyDrop::new(err);
                CResponseOption::Error
            }
            Ok(opt) => match opt {
                None => CResponseOption::None,
                Some(val) => {
                    *value = ManuallyDrop::new(val);
                    CResponseOption::Some
                }
            },
        }
    }
}
