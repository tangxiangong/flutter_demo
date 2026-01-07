use crate::{
    memory::{Memory, ProcessMemoryInfo},
    utils::{Storage, Unit},
};

pub fn get_memory_info() -> anyhow::Result<Memory> {
    Ok(Memory::get())
}

pub fn get_first_process_memory_usage(n: usize) -> anyhow::Result<Vec<(u32, ProcessMemoryInfo)>> {
    let info = Memory::get();
    Ok(info.first(n))
}

#[flutter_rust_bridge::frb(sync)]
pub fn storage_to_float(storage: &Storage) -> anyhow::Result<f64> {
    Ok(storage.to_float())
}

#[flutter_rust_bridge::frb(sync)]
pub fn unit_to_string(unit: Unit) -> anyhow::Result<String> {
    Ok(unit.to_string())
}

#[flutter_rust_bridge::frb(init)]
pub fn init_app() -> anyhow::Result<bool> {
    flutter_rust_bridge::setup_default_user_utils();
    Ok(true)
}
