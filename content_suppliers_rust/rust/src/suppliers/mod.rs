/// flutter_rust_bridge:ignore
mod dummy;

use std::str::FromStr;

use dummy::{DummyContentSupplier, DummyPageLoader};
use enum_dispatch::enum_dispatch;
use strum::VariantNames;
use strum_macros::{EnumIter, EnumString, VariantNames};

use crate::models::{
    ContentDetails, ContentInfo, ContentMediaItem, ContentMediaItemSource, ContentType,
};

#[enum_dispatch]
pub trait ContentSupplier {
    fn get_channels(&self) -> Vec<String>;
    fn get_default_channels(&self) -> Vec<String>;
    fn get_supported_types(&self) -> Vec<ContentType>;
    fn get_supported_languages(&self) -> Vec<String>;
    async fn search(&self, query: String) -> anyhow::Result<Vec<ContentInfo>>;
    async fn load_channel(&self, channel: String, page: u16) -> anyhow::Result<Vec<ContentInfo>>;
    async fn get_content_details(&self, id: String, langs: Vec<String>) -> anyhow::Result<Option<ContentDetails>>;
    async fn load_media_items(
        &self,
        id: String,
        params: Vec<String>,
    ) -> anyhow::Result<Vec<ContentMediaItem>>;
    async fn load_media_item_sources(
        &self,
        id: String,
        params: Vec<String>,
    ) -> anyhow::Result<Vec<ContentMediaItemSource>>;
}

#[enum_dispatch]
pub trait MangaPagesLoader {
    async fn load_pages(&self, id: String, params: Vec<String>) -> anyhow::Result<Vec<String>>;
}

#[enum_dispatch(ContentSupplier)]
#[derive(EnumIter, EnumString, VariantNames)]
pub enum AllContentSuppliers {
    #[strum(serialize = "dummy")]
    DummyContentSupplier,
}

#[enum_dispatch(MangaPagesLoader)]
#[derive(EnumString)]
pub enum AllMangaPagesLoaders {
    #[strum(serialize = "dummy")]
    DummyPageLoader,
}

pub fn avalaible_suppliers() -> Vec<String> {
    AllContentSuppliers::VARIANTS
        .iter()
        .map(|&s| s.to_owned())
        .collect()
}

pub fn get_supplier(name: &str) -> Result<AllContentSuppliers, anyhow::Error> {
    AllContentSuppliers::from_str(name).map_err(|err| err.into())
}
