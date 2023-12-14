"use client";

import { signIn } from "next-auth/react";

export default function LoginButton() {
  return (
    <button className="btn btn-primary" onMouseUp={() => signIn("authentik")}>
      Log in
    </button>
  );
}
