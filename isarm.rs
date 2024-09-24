use std::env;
use std::process::{self, Command};

fn is_arm() -> bool {
    #[cfg(target_os = "linux")]
    {
        let output = Command::new("uname")
            .arg("-m")
            .output()
            .expect("Failed to execute uname");
        let arch = String::from_utf8_lossy(&output.stdout);
        arch.contains("arm") || arch.contains("aarch64")
    }

    #[cfg(target_os = "macos")]
    {
        let output = Command::new("uname")
            .arg("-p")
            .output()
            .expect("Failed to execute uname");
        let arch = String::from_utf8_lossy(&output.stdout);
        arch.contains("arm") || arch.starts_with("arm64")
    }

    #[cfg(target_os = "windows")]
    {
        let output = Command::new("powershell")
            .args(&["-Command", "(Get-WmiObject Win32_Processor).Architecture"])
            .output()
            .expect("Failed to execute PowerShell command");
        let arch = String::from_utf8_lossy(&output.stdout);
        arch.trim() == "12"
    }

    #[cfg(target_os = "ios")]
    {
        let output = Command::new("arch")
            .output()
            .expect("Failed to execute arch");
        let arch = String::from_utf8_lossy(&output.stdout);
        arch.contains("arm64")
    }

    #[cfg(target_os = "android")]
    {
        let output = Command::new("uname")
            .arg("-m")
            .output()
            .expect("Failed to execute uname");
        let arch = String::from_utf8_lossy(&output.stdout);
        arch.contains("arm") || arch.contains("aarch64")
    }
}

fn main() {
    let args: Vec<String> = env::args().collect();
    let mut quiet = false;
    let mut verbose = false;

    for arg in &args[1..] {
        match arg.as_str() {
            "-q" | "--quiet" => quiet = true,
            "-v" | "--verbose" => verbose = true,
            _ => {}
        }
    }

    if quiet && verbose {
        eprintln!("Cannot be quiet and verbose at the same time!");
        process::exit(1);
    }

    let is_arm_arch = is_arm();

    if quiet {
        process::exit(if is_arm_arch { 0 } else { 1 });
    }

    if verbose {
        println!("Architecture details:");
        println!("Target OS: {}", env::consts::OS);
        println!("Is ARM: {}", is_arm_arch);
    } else {
        println!("{}", if is_arm_arch { "yes" } else { "no" });
    }
}
