#!/usr/bin/env bash
set -euo pipefail

# create a new cargo cli project

cargo new tmp

cd tmp

cargo add clap --features cargo,env
cargo add paris --features macros
cargo add requestty --features macros
cargo add itertools
cargo add serde --features derive
cargo add toml
cargo add memoize
cargo add owo-colors
cargo add anyhow

# OPTIONAL=$(gum choose --no-limit tabular colorgrad kdam crossterm duct chrono nom strp)

# cargo add $OPTIONAL

echo "# cargo justfile" >> justfile

echo "
use clap::{command, Arg};

fn main() {
    let matches = command!() // requires cargo feature
        .arg(Arg::new(\"name\"))
        .get_matches();

    println!(\"name: {:?}\", matches.get_one::<String>(\"name\"));
}
" > src/main.rs

# TODO: modify Cargo.toml file

echo "Done!"

cargo check

echo "Finished!"
