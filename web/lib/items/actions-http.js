"use client";

import { GetItemsResponse } from "@/proto/item_pb";

/**
 * @returns {Promise<import("./actions-proto").Item[]>}
 */
export async function getItems() {
  const res = await fetch("/api/items");

  if (!res.ok) {
    return [];
  }

  /** @type {GetItemsResponse[]} */
  const j = await res.json();

  console.log(j);

  return j;
}

/**
 * @param {string} name
 * @returns {Promise<Response>}
 */
export function addItem(name) {
  return fetch("/api/items", {
    method: "POST",
    body: JSON.stringify({ name }),
  });
}

/**
 * @param {string} id
 * @returns {Promise<Response>}
 */
export function deleteItem(id) {
  return fetch("/api/items", {
    method: "DELETE",
    body: JSON.stringify({ id }),
  });
}
