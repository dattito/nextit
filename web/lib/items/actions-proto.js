import { newClient } from "./connection";
import { promisify } from "util";
import { GetItemsResponse } from "@/proto/item_pb";

/**
 * @returns {Promise<GetItemsResponse[]>}
 */
export function getItemsProto() {
  const client = newClient();
  return promisify(client.getItems)
    .bind(client)({})
    .then((i) => i.items);
}

/**
 * @param {string} name
 */
export function addItemProto(name) {
  const client = newClient();
  return promisify(client.addItem).bind(client)({ name });
}

/**
 * @param {string} id
 */
export function deleteItemProto(id) {
  const client = newClient();
  return promisify(client.deleteItem).bind(client)({ id });
}
