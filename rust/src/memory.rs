use crate::utils::Storage;
use itertools::Itertools;
use std::collections::HashMap;
use sysinfo::{MemoryRefreshKind, ProcessRefreshKind, RefreshKind, System, UpdateKind};

#[derive(Debug, Clone)]
pub struct Memory {
    pub total_memory: Storage,
    pub used_memory: Storage,
    pub total_swap: Storage,
    pub used_swap: Storage,
    pub processes: HashMap<u32, ProcessMemoryInfo>,
}

#[derive(Debug, Clone)]
pub struct ProcessMemoryInfo {
    pub memory: Storage,
    pub raw_memory: u64,
    pub name: String,
    pub exe: Option<String>,
}

impl Memory {
    pub fn get() -> Self {
        let mut sys = System::new_with_specifics(
            RefreshKind::nothing()
                .with_memory(MemoryRefreshKind::everything())
                .with_processes(
                    ProcessRefreshKind::nothing()
                        .with_exe(UpdateKind::Always)
                        .with_memory(),
                ),
        );
        sys.refresh_all();

        let total_memory = Storage::from_bytes(sys.total_memory());
        let used_memory = Storage::from_bytes(sys.used_memory());
        let total_swap = Storage::from_bytes(sys.total_swap());
        let used_swap = Storage::from_bytes(sys.used_swap());
        let processes = sys
            .processes()
            .iter()
            .map(|(pid, process)| {
                let raw_memory = process.memory();
                let memory = Storage::from_bytes(raw_memory);
                let name = process.name().to_string_lossy().to_string();
                let exe = process.exe().map(|path| path.to_string_lossy().to_string());

                (
                    pid.as_u32(),
                    ProcessMemoryInfo {
                        memory,
                        raw_memory,
                        name,
                        exe,
                    },
                )
            })
            .collect::<HashMap<u32, ProcessMemoryInfo>>();

        Self {
            total_memory,
            used_memory,
            total_swap,
            used_swap,
            processes,
        }
    }

    pub fn first(n: usize) -> Vec<(u32, ProcessMemoryInfo)> {
        let info = Self::get();
        info.processes
            .into_iter()
            .sorted_by(|(_, a), (_, b)| b.raw_memory.cmp(&a.raw_memory))
            .take(n)
            .collect_vec()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_first() {
        let first = Memory::first(10);
        println!("{:#?}", first);
    }
}
