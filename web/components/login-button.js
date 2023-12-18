"use client";

import { signIn } from "next-auth/react";

export default function LoginButton() {
  return (
    <button
      className="btn btn-sm btn-outline-primary"
      onMouseUp={() =>
        signIn("authentik", {
          callbackUrl: "/intern",
        })
      }
    >
      Log in
    </button>
  );
}
