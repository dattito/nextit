import Image from "next/image";

export default function InternPost({ date, author, content }) {
  return (
    <div className="card my-1 p-2 d-flex">
      <div>
        <span className="text-primary" style={{ fontSize: "12px" }}>
          <b>{date}</b>
        </span>
      </div>
      <div className="d-flex mt-2">
        <Image src={"/account.png"} width={30} height={30} alt="account" />
        <span className="mt-1 ml-2">
          <b>{author}</b>
        </span>
      </div>
      <div className="mt-3 m-2">{content}</div>
    </div>
  );
}
