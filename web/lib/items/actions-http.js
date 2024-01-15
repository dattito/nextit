"use client";

import { GetItemsResponse } from "@/proto/item_pb";

/**
 * @returns {Promise<GetItemsResponse[]>}
 */
export async function getItems() {
  const res = await fetch("/api/items");

  if (!res.ok) {
    return [];
  }

  return await res.json();
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
