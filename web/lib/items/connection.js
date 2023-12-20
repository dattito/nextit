import path from "path";
var grpc = require("@grpc/grpc-js");
var protoLoader = require("@grpc/proto-loader");

const PROTO_PATH = path.join(process.cwd(), "./proto/item.proto");

const packageDefinition = protoLoader.loadSync(PROTO_PATH, {
  keepCase: true,
  longs: String,
  enums: String,
  defaults: true,
  oneofs: true,
});

const itemProto = grpc.loadPackageDefinition(packageDefinition).item;

export function newClient() {
  return new itemProto.ItemService(
    process.env.ITEM_SERVICE_HOST,
    grpc.credentials.createInsecure(),
  );
}
