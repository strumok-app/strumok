
use std::collections::HashMap;


use crate::models::{
        ContentDetails, 
        ContentInfo, 
        ContentMediaItem, 
        ContentMediaItemSource, 
        ContentType, MediaType,
    };

use super::ContentSupplier;


pub struct DummyContentSupplier;

impl Default for DummyContentSupplier {
    fn default() -> Self {
        Self {  }
    }
}

impl ContentSupplier for DummyContentSupplier {

    fn get_channels(&self) -> Vec<String> {
        vec!["dummy_channels".to_owned()]
    }

    fn get_default_channels(&self) -> Vec<String> {
        self.get_channels()
    }

    fn get_supported_types(&self) -> Vec<ContentType> {
        vec![ContentType::Movie, ContentType::Anime]
    }

    fn get_supported_languages(&self) -> Vec<String> {
        vec!["en".to_owned(), "uk".to_owned()]
    }

    async fn search(&self, query: String, types: Vec<String>) -> Result<Vec<ContentInfo>, anyhow::Error> {
        Ok(vec![
            ContentInfo {
                id: query,
                title: types.join(","),
                secondary_title: Some("secondary_dummy_title".to_owned()),
                image: "dummy_image".to_owned()
            }
        ])
    }

    async fn load_channel(&self, channel: String, page: u16) -> Result<Vec<ContentInfo>, anyhow::Error> {
        Ok(vec![
            ContentInfo {
                id: format!("{} {}", channel, page),
                title: "dummy_title".to_owned(),
                secondary_title: Some("secondary_dummy_title".to_owned()),
                image: "dummy_image".to_owned()
            }
        ])
    }

    async fn get_content_details(&self, id: String) -> Result<Option<ContentDetails>, anyhow::Error> {
        Ok(Some(
            ContentDetails { 
                title: format!("dummy_title {id}"),
                original_title: Some(String::from("original_dummy_title")), 
                image: "dummy_image".to_owned(), 
                description: "dummy_description".to_owned(), 
                media_type: MediaType::Video, 
                additional_info: vec![
                    "dummy_additional_info1".to_owned(),
                    "dummy_additional_info2".to_owned(),
                ], 
                similar: vec![
                    ContentInfo {
                        id: "dummy_similar".to_owned(),
                        title: "dummy_title".to_owned(),
                        secondary_title: Some("secondary_dummy_title".to_owned()),
                        image: "dummy_image".to_owned()
                    }
                ],
                media_items: None,
                params: vec!["1".to_owned(), "2".to_owned()]
             }
        ))
    }

    async fn load_media_items(&self, id: String, params: Vec<String>) -> Result<Vec<ContentMediaItem>, anyhow::Error> {
        let mut new_params = params;
        new_params.push(String::from("3"));

        Ok(vec![
            ContentMediaItem {
                number: 42,
                title: id,
                section: Some(new_params.join(",")),
                image: Some("dummy_image".to_owned()),
                sources: None,
                params: new_params
            }
        ])
    }

    async fn load_media_item_sources(
        &self,
        id: String,
        params: Vec<String>,
    ) -> Result<Vec<ContentMediaItemSource>, anyhow::Error> {
        Ok(vec![
            ContentMediaItemSource::Video {
                link: "http://dummy_link".to_owned(),
                description: format!("{} {}", id, params.join(",")),
                headers: Some(HashMap::from([
                    ("User-Agent".to_owned(), "dummy".to_owned())
                ]))
            },
            ContentMediaItemSource::Subtitle {
                link: "http://dummy_link".to_owned(),
                description: format!("{} {}", id, params.join(",")),
                headers: Some(HashMap::from([
                    ("User-Agent".to_owned(), "dummy".to_owned())
                ]))
            },
            ContentMediaItemSource::Manga { 
                description: format!("{} {}", id, params.join(",")), 
                pages: vec![
                    "http://page1".to_owned(),
                    "http://page2".to_owned(),
                ] 
            }
        ])
    }
}
