import PublicNavbar from "@/components/publicnavabar";
import itemService from "@/lib/items";
import { AddItemRequest, Empty } from "@/proto/item_pb";

export const dynamic = "force-dynamic";

export default async function Home() {
  // const r = new AddItemRequest();
  // r.setName("Test!");
  // itemService.addItem(r, (e, res) => {
  //   console.log("Add:", res);
  // });

  return <PublicNavbar />;
}
