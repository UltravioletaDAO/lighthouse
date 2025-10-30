// Database connections - TODO

#[derive(Clone)]
pub struct Database;

impl Database {
    pub async fn new(_config: &crate::config::Config) -> anyhow::Result<Self> {
        tracing::info!("Database initialized (stub)");
        Ok(Database)
    }
}
