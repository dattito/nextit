export default function Navbar() {
  return (
    <nav class="navbar bg-body-tertiary">
      <div class="container-fluid">
        <a class="navbar-brand">Ihr Logo</a>
        <form class="d-flex" role="search">
          <button class="btn btn-outline-success" type="submit">
            Log in
          </button>
        </form>
      </div>
    </nav>
  );
}
