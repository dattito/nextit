import InternHomepage from "@/components/intern/intern-homepage";
import { onlyLoggedInUser } from "@/lib/auth";

export const dynamic = "force-dynamic";

export default async function Home() {
  await onlyLoggedInUser();

  return <InternHomepage />;
}
