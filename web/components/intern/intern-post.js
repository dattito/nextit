import Image from "next/image";

export default function InternPost({ author, content }) {
  return (
    <div className="card my-1 p-2 d-flex">
      <div className="d-flex mt-2">
        <Image src={"/account.png"} width={30} height={30} alt="account" />
        <span className="text-primary mt-1 ml-4">
          <b>{author}</b>
        </span>
      </div>
      <div className="mt-3 m-2">{content}</div>
    </div>
  );
}
