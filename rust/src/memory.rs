use sysinfo::{MemoryRefreshKind, RefreshKind, System};

use crate::utils::Storage;

#[derive(Debug, Clone)]
pub struct Memory {
    pub total_memory: Storage,
    pub used_memory: Storage,
    pub total_swap: Storage,
    pub used_swap: Storage,
}

impl Memory {
    pub fn get() -> Self {
        let mut sys = System::new_with_specifics(
            RefreshKind::nothing().with_memory(MemoryRefreshKind::everything()),
        );
        sys.refresh_all();

        let total_memory = Storage::from_bytes(sys.total_memory());
        let used_memory = Storage::from_bytes(sys.used_memory());
        let total_swap = Storage::from_bytes(sys.total_swap());
        let used_swap = Storage::from_bytes(sys.used_swap());

        Self {
            total_memory,
            used_memory,
            total_swap,
            used_swap,
        }
    }
}
