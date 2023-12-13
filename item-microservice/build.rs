use std::{env, path::PathBuf};

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let descriptor_path = PathBuf::from(env::var("OUT_DIR").unwrap()).join("item_descriptor.bin");
    tonic_build::configure()
        .file_descriptor_set_path(descriptor_path)
        .build_server(true)
        .compile(&["proto/item/item.proto"], &["proto/item"])?;
    Ok(())
}
