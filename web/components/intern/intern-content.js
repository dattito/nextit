"use client";
import { useEffect, useState } from "react";
import InternPost from "./intern-post";
import { addItem, getItems } from "@/lib/items/actions-http";

export default function InternContent({ username, defaultItems }) {
  /** @type {[import("@/lib/items/actions-proto").Item[], any]} */
  const [items, setItems] = useState(defaultItems ?? []);

  const [newText, setNewText] = useState("");

  async function loadItems() {
    await getItems().then(setItems);
  }

  async function addNewPost() {
    if (!newText) return;

    await addItem(newText);

    setNewText(() => "");

    await loadItems();
  }

  return (
    <>
      <div
        className="bg-image"
        style={{
          backgroundImage: "url('/slider2.jpg')",
          height: "200px",
          backgroundPosition: "center",
          backgroundSize: "cover",
        }}
      >
        <div
          className="d-flex align-items-center h-100"
          style={{ margin: "0 0 0 56px" }}
        >
          <h1
            className="text-white me-auto"
            style={{ textShadow: "0px 0px 8px #000" }}
          >
            Hallo {username}
          </h1>
        </div>
      </div>
      <div className="mt-3 m-4">
        <h4>Intranet</h4>

        <div className="d-flex justify-content-end mt-2">
          <button
            type="button"
            className="btn btn-sm btn-primary"
            data-bs-toggle="modal"
            data-bs-target="#newEntry"
          >
            Neuer Post
          </button>
        </div>

        <div className="card mt-2 p-2">
          {items.length > 0 ? (
            items
              .map((item, index) => (
                <InternPost
                  key={index}
                  author={item.username}
                  content={item.text}
                />
              ))
              .reverse()
          ) : (
            <p className="text-tertiary mt-3">Noch keine Posts erstellt</p>
          )}
        </div>
      </div>

      <div
        className="modal fade"
        id="newEntry"
        tabIndex="-1"
        aria-labelledby="newEntryLabel"
        aria-hidden="true"
      >
        <div className="modal-dialog modal-lg">
          <div className="modal-content">
            <div className="modal-header">
              <h1 className="modal-title fs-5" id="newEntryLabel">
                Neuen Post hinzufügen
              </h1>
              <button
                type="button"
                className="btn-close"
                data-bs-dismiss="modal"
                aria-label="Close"
              ></button>
            </div>
            <div className="modal-body">
              <div className="mb-3">
                <textarea
                  type="datetime-local"
                  className="form-control min-h-64"
                  id="newPostContent"
                  placeholder="Eine Nachricht formulieren..."
                  value={newText}
                  onChange={(e) => setNewText(e.target.value)}
                ></textarea>
              </div>
            </div>
            <div className="modal-footer">
              <button
                type="button"
                className="btn btn-sm btn-secondary"
                data-bs-dismiss="modal"
              >
                Abbrechen
              </button>
              <button
                type="button"
                className="btn btn-sm btn-primary"
                data-bs-dismiss="modal"
                onMouseUp={addNewPost}
              >
                Posten
              </button>
            </div>
          </div>
        </div>
      </div>
    </>
  );
}
