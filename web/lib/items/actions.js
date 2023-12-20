import { newClient } from "./connection";
import { promisify } from "util";
import { GetItemsResponse } from "@/proto/item_pb";

/**
 * @returns {Promise<GetItemsResponse[]>}
 */
export function getItems() {
  const client = newClient();
  return promisify(client.getItems)
    .bind(client)({})
    .then((i) => i.items);
}

/**
 * @param {string} name
 */
export function addItem(name) {
  const client = newClient();
  return promisify(client.addItem).bind(client)({ name });
}

/**
 * @param {string} id
 */
export function deleteItem(id) {
  const client = newClient();
  return promisify(client.deleteItem).bind(client)({ id });
}
