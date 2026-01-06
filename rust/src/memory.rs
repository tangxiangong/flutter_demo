use sysinfo::{MemoryRefreshKind, RefreshKind, System};

#[derive(Debug, Clone)]
pub struct Memory {
    pub total_memory: u64,
    pub used_memory: u64,
    pub total_swap: u64,
    pub used_swap: u64,
}

impl Memory {
    pub fn get() -> Self {
        let mut sys = System::new_with_specifics(
            RefreshKind::nothing().with_memory(MemoryRefreshKind::everything()),
        );
        sys.refresh_all();

        let total_memory = sys.total_memory();
        let used_memory = sys.used_memory();
        let total_swap = sys.total_swap();
        let used_swap = sys.used_swap();

        Self {
            total_memory,
            used_memory,
            total_swap,
            used_swap,
        }
    }
}
