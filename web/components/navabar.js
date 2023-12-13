import Image from "next/image";

export default function Navbar() {
  return (
    <nav class="navbar bg-body-tertiary">
      <div class="container-fluid">
        <a class="navbar-brand">
          <Image src="/Logo_wide.png" width={100} height={100} />
        </a>
        <form class="d-flex" role="search">
          <button class="btn btn-outline-success" type="submit">
            Log in
          </button>
        </form>
      </div>
    </nav>
  );
}
