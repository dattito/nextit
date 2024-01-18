import InternPost from "./intern-post";

export default function InternContent() {
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
            Hallo Benjamin
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
          <InternPost
            date="05. Januar 2024, 15:03 Uhr"
            author="Benjamin Jung"
            content="Lorem ipsum dolor sit amet, consetetur sadipscing elitr, ..."
          />
          <InternPost
            date="05. Januar 2024, 15:03 Uhr"
            author="Benjamin Jung"
            content="Lorem ipsum dolor sit amet, consetetur sadipscing elitr, ..."
          />
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
                <label htmlFor="newPostDate" className="form-label">
                  Datum und Uhrzeit
                </label>
                <input
                  type="datetime-local"
                  className="form-control"
                  id="newPostDate"
                  placeholder=""
                />
              </div>
              <div className="mb-3">
                <label htmlFor="newPostContent" className="form-label">
                  Post
                </label>
                <textarea
                  type="datetime-local"
                  className="form-control"
                  id="newPostContent"
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
              <button type="button" className="btn btn-sm btn-primary">
                Posten
              </button>
            </div>
          </div>
        </div>
      </div>
    </>
  );
}
