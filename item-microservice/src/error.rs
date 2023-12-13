#[derive(thiserror::Error, Debug)]
pub enum Error {
    #[error("Custom Status Error")]
    Custom(#[from] tonic::Status),

    #[error("Database Error")]
    DB(#[from] sqlx::Error),
}

impl From<Error> for tonic::Status {
    fn from(value: Error) -> Self {
        match value {
            Error::Custom(s) => s,
            _ => Self::internal("Something went wrong"),
        }
    }
}
