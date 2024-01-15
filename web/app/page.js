import PublicHomepage from "@/components/public-homepage";
import { userIsLoggedIn } from "@/lib/auth";
import { redirect } from "next/navigation";

export const dynamic = "force-dynamic";

export default async function Home() {
  if (await userIsLoggedIn()) {
    redirect("/intern");
  }

  return <PublicHomepage />;
}
