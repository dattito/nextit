// package: item
// file: proto/item.proto

import * as grpc from '@grpc/grpc-js';
import * as proto_item_pb from '../proto/item_pb';

interface IItemServiceService extends grpc.ServiceDefinition<grpc.UntypedServiceImplementation> {
  addItem: IItemServiceService_IAddItem;
  getItems: IItemServiceService_IGetItems;
  deleteItem: IItemServiceService_IDeleteItem;
}

interface IItemServiceService_IAddItem extends grpc.MethodDefinition<proto_item_pb.AddItemRequest, proto_item_pb.AddItemResponse> {
  path: '/item.ItemService/AddItem'
  requestStream: false
  responseStream: false
  requestSerialize: grpc.serialize<proto_item_pb.AddItemRequest>;
  requestDeserialize: grpc.deserialize<proto_item_pb.AddItemRequest>;
  responseSerialize: grpc.serialize<proto_item_pb.AddItemResponse>;
  responseDeserialize: grpc.deserialize<proto_item_pb.AddItemResponse>;
}

interface IItemServiceService_IGetItems extends grpc.MethodDefinition<proto_item_pb.Empty, proto_item_pb.GetItemsResponse> {
  path: '/item.ItemService/GetItems'
  requestStream: false
  responseStream: false
  requestSerialize: grpc.serialize<proto_item_pb.Empty>;
  requestDeserialize: grpc.deserialize<proto_item_pb.Empty>;
  responseSerialize: grpc.serialize<proto_item_pb.GetItemsResponse>;
  responseDeserialize: grpc.deserialize<proto_item_pb.GetItemsResponse>;
}

interface IItemServiceService_IDeleteItem extends grpc.MethodDefinition<proto_item_pb.DeleteItemRequest, proto_item_pb.Empty> {
  path: '/item.ItemService/DeleteItem'
  requestStream: false
  responseStream: false
  requestSerialize: grpc.serialize<proto_item_pb.DeleteItemRequest>;
  requestDeserialize: grpc.deserialize<proto_item_pb.DeleteItemRequest>;
  responseSerialize: grpc.serialize<proto_item_pb.Empty>;
  responseDeserialize: grpc.deserialize<proto_item_pb.Empty>;
}

export const ItemServiceService: IItemServiceService;
export interface IItemServiceServer extends grpc.UntypedServiceImplementation {
  addItem: grpc.handleUnaryCall<proto_item_pb.AddItemRequest, proto_item_pb.AddItemResponse>;
  getItems: grpc.handleUnaryCall<proto_item_pb.Empty, proto_item_pb.GetItemsResponse>;
  deleteItem: grpc.handleUnaryCall<proto_item_pb.DeleteItemRequest, proto_item_pb.Empty>;
}

export interface IItemServiceClient {
  addItem(request: proto_item_pb.AddItemRequest, callback: (error: grpc.ServiceError | null, response: proto_item_pb.AddItemResponse) => void): grpc.ClientUnaryCall;
  addItem(request: proto_item_pb.AddItemRequest, metadata: grpc.Metadata, callback: (error: grpc.ServiceError | null, response: proto_item_pb.AddItemResponse) => void): grpc.ClientUnaryCall;
  addItem(request: proto_item_pb.AddItemRequest, metadata: grpc.Metadata, options: Partial<grpc.CallOptions>, callback: (error: grpc.ServiceError | null, response: proto_item_pb.AddItemResponse) => void): grpc.ClientUnaryCall;
  getItems(request: proto_item_pb.Empty, callback: (error: grpc.ServiceError | null, response: proto_item_pb.GetItemsResponse) => void): grpc.ClientUnaryCall;
  getItems(request: proto_item_pb.Empty, metadata: grpc.Metadata, callback: (error: grpc.ServiceError | null, response: proto_item_pb.GetItemsResponse) => void): grpc.ClientUnaryCall;
  getItems(request: proto_item_pb.Empty, metadata: grpc.Metadata, options: Partial<grpc.CallOptions>, callback: (error: grpc.ServiceError | null, response: proto_item_pb.GetItemsResponse) => void): grpc.ClientUnaryCall;
  deleteItem(request: proto_item_pb.DeleteItemRequest, callback: (error: grpc.ServiceError | null, response: proto_item_pb.Empty) => void): grpc.ClientUnaryCall;
  deleteItem(request: proto_item_pb.DeleteItemRequest, metadata: grpc.Metadata, callback: (error: grpc.ServiceError | null, response: proto_item_pb.Empty) => void): grpc.ClientUnaryCall;
  deleteItem(request: proto_item_pb.DeleteItemRequest, metadata: grpc.Metadata, options: Partial<grpc.CallOptions>, callback: (error: grpc.ServiceError | null, response: proto_item_pb.Empty) => void): grpc.ClientUnaryCall;
}

export class ItemServiceClient extends grpc.Client implements IItemServiceClient {
  constructor(address: string, credentials: grpc.ChannelCredentials, options?: Partial<grpc.ClientOptions>);
  public addItem(request: proto_item_pb.AddItemRequest, callback: (error: grpc.ServiceError | null, response: proto_item_pb.AddItemResponse) => void): grpc.ClientUnaryCall;
  public addItem(request: proto_item_pb.AddItemRequest, metadata: grpc.Metadata, callback: (error: grpc.ServiceError | null, response: proto_item_pb.AddItemResponse) => void): grpc.ClientUnaryCall;
  public addItem(request: proto_item_pb.AddItemRequest, metadata: grpc.Metadata, options: Partial<grpc.CallOptions>, callback: (error: grpc.ServiceError | null, response: proto_item_pb.AddItemResponse) => void): grpc.ClientUnaryCall;
  public getItems(request: proto_item_pb.Empty, callback: (error: grpc.ServiceError | null, response: proto_item_pb.GetItemsResponse) => void): grpc.ClientUnaryCall;
  public getItems(request: proto_item_pb.Empty, metadata: grpc.Metadata, callback: (error: grpc.ServiceError | null, response: proto_item_pb.GetItemsResponse) => void): grpc.ClientUnaryCall;
  public getItems(request: proto_item_pb.Empty, metadata: grpc.Metadata, options: Partial<grpc.CallOptions>, callback: (error: grpc.ServiceError | null, response: proto_item_pb.GetItemsResponse) => void): grpc.ClientUnaryCall;
  public deleteItem(request: proto_item_pb.DeleteItemRequest, callback: (error: grpc.ServiceError | null, response: proto_item_pb.Empty) => void): grpc.ClientUnaryCall;
  public deleteItem(request: proto_item_pb.DeleteItemRequest, metadata: grpc.Metadata, callback: (error: grpc.ServiceError | null, response: proto_item_pb.Empty) => void): grpc.ClientUnaryCall;
  public deleteItem(request: proto_item_pb.DeleteItemRequest, metadata: grpc.Metadata, options: Partial<grpc.CallOptions>, callback: (error: grpc.ServiceError | null, response: proto_item_pb.Empty) => void): grpc.ClientUnaryCall;
}

