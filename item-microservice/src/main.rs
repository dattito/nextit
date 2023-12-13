use error::Error;
use item::{
    item_service_server::{ItemService, ItemServiceServer},
    AddItemRequest, AddItemResponse, DeleteItemRequest, Empty, GetItemsResponse, Item,
};
use sqlx::PgPool;
use tonic::{transport::Server, Request, Response, Status};
use uuid::Uuid;

mod error;

mod item {
    tonic::include_proto!("item");

    pub(crate) const FILE_DESCRIPTOR_SET: &[u8] =
        tonic::include_file_descriptor_set!("item_descriptor");
}

#[derive(serde::Serialize, sqlx::FromRow)]
pub struct ItemDB {
    pub id: Uuid,
    pub name: String,
}

impl ItemDB {
    pub fn new(name: String) -> Self {
        Self {
            id: Uuid::new_v4(),
            name,
        }
    }
}

struct XItemService {
    db_pool: PgPool,
}

impl XItemService {
    pub fn new(db_pool: PgPool) -> Self {
        Self { db_pool }
    }
}

#[tonic::async_trait]
impl ItemService for XItemService {
    async fn add_item(
        &self,
        request: Request<AddItemRequest>,
    ) -> Result<Response<AddItemResponse>, Status> {
        let name = request.into_inner().name;

        if name.is_empty() {
            return Err(Error::Custom(Status::invalid_argument(
                r#""name" cannot be empty"#,
            )).into());
        };

        let item_db = ItemDB::new(name);

        let i =
            sqlx::query_as::<_, ItemDB>("INSERT INTO items (id, name) VALUES ($1, $2) RETURNING *")
                .bind(item_db.id)
                .bind(item_db.name)
            .fetch_one(&self.db_pool)
            .await.map_err(|_e| Status::internal("Something went wrong"))?;

        Ok(Response::new(AddItemResponse {
            id: i.id.to_string(),
        }))
    }

    async fn get_items(&self, _request: Request<Empty>) -> Result<Response<GetItemsResponse>, Status> {
        let i: Vec<ItemDB> = sqlx::query_as::<_, ItemDB>("SELECT * FROM items")
            .fetch_all(&self.db_pool)
            .await.map_err(|_e| Status::internal("Something went wrong"))?;
        Ok(Response::new(GetItemsResponse {
            items: i
                .iter()
                .map(|it| Item {
                    id: it.id.to_string(),
                    name: it.name.to_string(),
                })
                .collect(),
        }))
    }

    async fn delete_item(&self, request: Request<DeleteItemRequest>) -> Result<Response<Empty>, Status> {
        sqlx::query("DELETE FROM items WHERE id=$1")
            .bind(Uuid::parse_str(&request.into_inner().id).map_err(|_e|Status::invalid_argument("id is not a uuid"))?)
            .execute(&self.db_pool)
            .await.map_err(|_e| Status::internal("Something went wrong"))?;

        Ok(Response::new(Empty {}))
    }
}

#[tokio::main]
async fn main() -> core::result::Result<(), Box<dyn std::error::Error>> {
    let addr = "127.0.0.1:50051".parse().unwrap();
    let db_pool = PgPool::connect(
        &std::env::var("DATABASE_URL").expect("environment variable \"DATABASE_URL\""),
    )
    .await?;
    let item_service = XItemService::new(db_pool);

    let reflector_service = tonic_reflection::server::Builder::configure()
        .register_encoded_file_descriptor_set(item::FILE_DESCRIPTOR_SET)
        .build()
        .unwrap();

    println!("GreeterServer listening on {}", addr);

    Server::builder()
        .add_service(ItemServiceServer::new(item_service))
        .add_service(reflector_service)
        .serve(addr)
        .await?;

    Ok(())
}
