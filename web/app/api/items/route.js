import { getServerSession } from "next-auth";
import { authOptions } from "../auth/[...nextauth]/route";
import {
  addItemProto,
  deleteItemProto,
  getItemsProto,
} from "@/lib/items/actions-proto";

export async function GET() {
  const session = await getServerSession(authOptions);
  if (!session) {
    return Response.json({ message: "not authorized" }, { status: 401 });
  }

  try {
    const items = await getItemsProto();
    return Response.json(items);
  } catch {
    return Response.json({ message: "internal server error" }, { status: 500 });
  }
}

/**
 *
 * @param {Request} request
 */
export async function POST(request) {
  const session = await getServerSession(authOptions);
  if (!session) {
    return Response.json({ message: "not authorized" }, { status: 401 });
  }

  let body = {};
  try {
    body = await request.json();
  } catch {
    return Response.json(
      { message: "could'nt parse json body" },
      { status: 400 },
    );
  }

  if (!body.name) {
    return Response.json(
      { message: "'name' is missing in request body" },
      { status: 400 },
    );
  }

  try {
    const res = await addItemProto(body.name);

    return Response.json({ id: res.id });
  } catch {
    return Response.json({ message: "internal server error" }, { status: 500 });
  }
}

/**
 *
 * @param {Request} request
 */
export async function DELETE(request) {
  const session = await getServerSession(authOptions);
  if (!session) {
    return Response.json({ message: "not authorized" }, { status: 401 });
  }

  let body = {};
  try {
    body = await request.json();
  } catch {
    return Response.json(
      { message: "could'nt parse json body" },
      { status: 400 },
    );
  }

  if (!body.id) {
    return Response.json(
      { message: "'id' is missing in request body" },
      { status: 400 },
    );
  }

  try {
    await deleteItemProto(body.id);

    return Response.json({ ok: true });
  } catch {
    return Response.json({ message: "internal server error" }, { status: 500 });
  }
}
