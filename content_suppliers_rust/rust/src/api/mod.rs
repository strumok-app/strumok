use std::str::FromStr;

use anyhow::anyhow;

use crate::{
    models::*,
    suppliers::{
        get_supplier, AllContentSuppliers, AllMangaPagesLoaders, ContentSupplier, MangaPagesLoader,
    },
};

#[flutter_rust_bridge::frb(sync)]
pub fn get_channels(supplier: String) -> anyhow::Result<Vec<String>> {
    let sup = get_supplier(&supplier)?;
    Ok(AllContentSuppliers::get_channels(&sup))
}

#[flutter_rust_bridge::frb(sync)]
pub fn get_default_channels(supplier: String) -> anyhow::Result<Vec<String>> {
    let sup = get_supplier(&supplier)?;
    Ok(AllContentSuppliers::get_default_channels(&sup))
}

#[flutter_rust_bridge::frb(sync)]
pub fn get_supported_types(supplier: &String) -> anyhow::Result<Vec<ContentType>> {
    let sup = get_supplier(&supplier)?;
    Ok(AllContentSuppliers::get_supported_types(&sup))
}

#[flutter_rust_bridge::frb(sync)]
pub fn get_supported_languages(supplier: &String) -> anyhow::Result<Vec<String>> {
    let sup = get_supplier(&supplier)?;
    Ok(AllContentSuppliers::get_supported_languages(&sup))
}

pub async fn search(supplier: String, query: String) -> anyhow::Result<Vec<ContentInfo>> {
    let sup = get_supplier(&supplier)?;
    AllContentSuppliers::search(&sup, query).await
}

pub async fn load_channel(
    supplier: String,
    channel: String,
    page: u16,
) -> anyhow::Result<Vec<ContentInfo>> {
    let sup = get_supplier(&supplier)?;
    AllContentSuppliers::load_channel(&sup, channel, page).await
}

pub async fn get_content_details(
    supplier: String,
    id: String,
    langs: Vec<String>,
) -> anyhow::Result<Option<ContentDetails>> {
    let sup = get_supplier(&supplier)?;
    AllContentSuppliers::get_content_details(&sup, id, langs).await
}

pub async fn load_media_items(
    supplier: String,
    id: String,
    langs: Vec<String>,
    params: Vec<String>,
) -> anyhow::Result<Vec<ContentMediaItem>> {
    let sup = get_supplier(&supplier)?;
    AllContentSuppliers::load_media_items(&sup, id, langs, params).await
}

pub async fn load_media_item_sources(
    supplier: String,
    id: String,
    langs: Vec<String>,
    params: Vec<String>,
) -> anyhow::Result<Vec<ContentMediaItemSource>> {
    let sup = get_supplier(&supplier)?;
    AllContentSuppliers::load_media_item_sources(&sup, id, langs, params).await
}

pub async fn load_manga_pages(
    supplier: String,
    id: String,
    params: Vec<String>,
) -> anyhow::Result<Vec<String>> {
    let loader = AllMangaPagesLoaders::from_str(&supplier).map_err(|err| anyhow!(err))?;
    AllMangaPagesLoaders::load_pages(&loader, id, params).await
}

#[flutter_rust_bridge::frb(sync)] // Synchronous mode for simplicity of the demo
pub fn avalaible_suppliers() -> Vec<String> {
    crate::suppliers::avalaible_suppliers()
}

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    // Default utilities - feel free to customize
    flutter_rust_bridge::setup_default_user_utils();
}
