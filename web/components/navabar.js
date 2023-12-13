import Image from "next/image";

export default function Navbar() {
  return (
    <nav class="navbar bg-body-tertiary">
      <div class="container-fluid">
        <a class="navbar-brand">
          <Image src="/Logo_wide.png" width={100} height={100} />
        </a>
        <div class="d-flex">
          <button class="btn btn-primary">Log in</button>
        </div>
      </div>
    </nav>
  );
}
