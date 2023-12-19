import { Inter } from "next/font/google";
import "./globals.css";
import "../css/custom.css";
import InitBootstrap from "@/components/init-bootstrap";

const inter = Inter({ subsets: ["latin"] });

export const metadata = {
  title: "NextIT",
  description: "NextIT - Innovate, Transform, Lead",
};

export default function RootLayout({ children }) {
  return (
    <html lang="en">
      <body className={inter.className}>
        <InitBootstrap />
        {children}
      </body>
    </html>
  );
}
