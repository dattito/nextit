"use server";

import { newClient } from "./connection";
import { promisify } from "util";
import { GetItemsResponse } from "@/proto/item_pb";

/**
 * @typedef {Object} Item
 * @property {string} username - The username associated with the item.
 * @property {string} text - The text content of the item.
 */

/**
 * @returns {Promise<any[]>}
 */
export async function getItemsProto() {
  const client = newClient();
  return await promisify(client.getItems)
    .bind(client)({})
    .then((i) => i.items)
    .then((j) =>
      j.map((value) => {
        const textSplit = value.name.split(";");
        const username = textSplit[0];
        const text = textSplit.slice(1).join(";");

        return {
          username,
          text,
        };
      }),
    );
}

/**
 * @param {string} name
 */
export async function addItemProto(name) {
  const client = newClient();
  return await promisify(client.addItem).bind(client)({ name });
}

/**
 * @param {string} id
 */
export async function deleteItemProto(id) {
  const client = newClient();
  return await promisify(client.deleteItem).bind(client)({ id });
}
