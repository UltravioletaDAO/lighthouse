// HTTP monitoring engine - TODO
// This will implement configurable status code checking

pub struct HttpMonitor;

impl HttpMonitor {
    pub fn new() -> Self {
        HttpMonitor
    }

    pub async fn check(_url: &str) -> anyhow::Result<CheckResult> {
        // TODO: Implement HTTP check with:
        // - Configurable valid status codes
        // - Response time tracking
        // - Body validation (JSON path, regex, contains)
        // - Header validation
        Ok(CheckResult::default())
    }
}

#[derive(Debug, Default)]
pub struct CheckResult {
    pub status: String,
    pub latency_ms: u32,
    pub http_status: Option<u16>,
}
