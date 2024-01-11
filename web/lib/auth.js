"use server";

import { authOptions } from "@/app/api/auth/[...nextauth]/route";
import { getServerSession } from "next-auth";
import { redirect } from "next/navigation";

export async function onlyLoggedInUser() {
  if (!(await getServerSession(authOptions))) {
    redirect("/");
  }
}
