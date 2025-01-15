use std::collections::HashMap;


#[derive(Debug, Clone, Copy)]
pub enum ContentType {
    Movie,
    Anime,
    Cartoon,
    Series,
    Manga,
}

#[derive(Debug, Clone, Copy)]
pub enum MediaType {
    Video,
    Manga,
}

#[derive(Debug)]
pub struct ContentInfo {
    pub id: String,
    pub title: String,
    pub secondary_title: Option<String>,
    pub image: String,
}

#[derive(Debug)]
pub struct ContentDetails {
    pub title: String,
    pub original_title: Option<String>,
    pub image: String,
    pub description: String,
    pub media_type: MediaType,
    pub additional_info: Vec<String>,
    pub similar: Vec<ContentInfo>,
    pub media_items: Option<Vec<ContentMediaItem>>,
    pub params: Vec<String>,
}

#[derive(Debug)]
pub struct ContentMediaItem {
    pub number: u32,
    pub title: String,
    pub section: Option<String>,
    pub image: Option<String>,
    pub sources: Option<Vec<ContentMediaItemSource>>,
    pub params: Vec<String>,
}

#[derive(Debug)]
pub enum ContentMediaItemSource {
    Video {
        link: String,
        description: String,
        headers: Option<HashMap<String, String>>,
    },
    Subtitle {
        link: String,
        description: String,
        headers: Option<HashMap<String, String>>,
    },
    Manga {
        description: String,
        headers: Option<HashMap<String, String>>,
        page_numbers: u32,
        pages: Option<Vec<String>>,
        params: Vec<String>,
    },
}