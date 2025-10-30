// Background task scheduler - TODO

pub struct Scheduler;

impl Scheduler {
    pub fn new(_db: crate::database::Database) -> Self {
        Scheduler
    }

    pub async fn start(&self) -> anyhow::Result<()> {
        tracing::info!("Scheduler started (stub)");
        Ok(())
    }
}
