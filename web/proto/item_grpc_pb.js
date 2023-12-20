// GENERATED CODE -- DO NOT EDIT!

'use strict';
var grpc = require('@grpc/grpc-js');
var proto_item_pb = require('../proto/item_pb.js');

function serialize_item_AddItemRequest(arg) {
  if (!(arg instanceof proto_item_pb.AddItemRequest)) {
    throw new Error('Expected argument of type item.AddItemRequest');
  }
  return Buffer.from(arg.serializeBinary());
}

function deserialize_item_AddItemRequest(buffer_arg) {
  return proto_item_pb.AddItemRequest.deserializeBinary(new Uint8Array(buffer_arg));
}

function serialize_item_AddItemResponse(arg) {
  if (!(arg instanceof proto_item_pb.AddItemResponse)) {
    throw new Error('Expected argument of type item.AddItemResponse');
  }
  return Buffer.from(arg.serializeBinary());
}

function deserialize_item_AddItemResponse(buffer_arg) {
  return proto_item_pb.AddItemResponse.deserializeBinary(new Uint8Array(buffer_arg));
}

function serialize_item_DeleteItemRequest(arg) {
  if (!(arg instanceof proto_item_pb.DeleteItemRequest)) {
    throw new Error('Expected argument of type item.DeleteItemRequest');
  }
  return Buffer.from(arg.serializeBinary());
}

function deserialize_item_DeleteItemRequest(buffer_arg) {
  return proto_item_pb.DeleteItemRequest.deserializeBinary(new Uint8Array(buffer_arg));
}

function serialize_item_Empty(arg) {
  if (!(arg instanceof proto_item_pb.Empty)) {
    throw new Error('Expected argument of type item.Empty');
  }
  return Buffer.from(arg.serializeBinary());
}

function deserialize_item_Empty(buffer_arg) {
  return proto_item_pb.Empty.deserializeBinary(new Uint8Array(buffer_arg));
}

function serialize_item_GetItemsResponse(arg) {
  if (!(arg instanceof proto_item_pb.GetItemsResponse)) {
    throw new Error('Expected argument of type item.GetItemsResponse');
  }
  return Buffer.from(arg.serializeBinary());
}

function deserialize_item_GetItemsResponse(buffer_arg) {
  return proto_item_pb.GetItemsResponse.deserializeBinary(new Uint8Array(buffer_arg));
}


var ItemServiceService = exports.ItemServiceService = {
  addItem: {
    path: '/item.ItemService/AddItem',
    requestStream: false,
    responseStream: false,
    requestType: proto_item_pb.AddItemRequest,
    responseType: proto_item_pb.AddItemResponse,
    requestSerialize: serialize_item_AddItemRequest,
    requestDeserialize: deserialize_item_AddItemRequest,
    responseSerialize: serialize_item_AddItemResponse,
    responseDeserialize: deserialize_item_AddItemResponse,
  },
  getItems: {
    path: '/item.ItemService/GetItems',
    requestStream: false,
    responseStream: false,
    requestType: proto_item_pb.Empty,
    responseType: proto_item_pb.GetItemsResponse,
    requestSerialize: serialize_item_Empty,
    requestDeserialize: deserialize_item_Empty,
    responseSerialize: serialize_item_GetItemsResponse,
    responseDeserialize: deserialize_item_GetItemsResponse,
  },
  deleteItem: {
    path: '/item.ItemService/DeleteItem',
    requestStream: false,
    responseStream: false,
    requestType: proto_item_pb.DeleteItemRequest,
    responseType: proto_item_pb.Empty,
    requestSerialize: serialize_item_DeleteItemRequest,
    requestDeserialize: deserialize_item_DeleteItemRequest,
    responseSerialize: serialize_item_Empty,
    responseDeserialize: deserialize_item_Empty,
  },
};

exports.ItemServiceClient = grpc.makeGenericClientConstructor(ItemServiceService);
