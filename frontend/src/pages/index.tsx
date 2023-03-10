import { GetServerSideProps, NextPage } from "next";
import Head from "next/head";
import Link from "next/link";
import { useEffect } from "react";
import styles from "../../styles/Home.module.css";

type Props = {
  title: string;
};

const Home: NextPage<Props> = ({ title }) => {
  useEffect(() => {
    const getCookie = async () => {
      const cookie = await fetch(`${window.origin}/api/get-cookie`, {
        method: "GET",
      }).then((d) => d.json());

      console.log(cookie);
    };
    getCookie();
  }, []);
  return (
    <div className={styles.container}>
      <Head>
        <title>Create Next App</title>
        <meta name="description" content="Generated by create next app" />
        <link rel="icon" href="/favicon.ico" />
      </Head>

      <main className={styles.main}>
        <h1 className={styles.title}>{title}</h1>
        <div>
          <Link href={"./index2"}>to index2</Link>
        </div>
        <div>
          <p>{`current hash: ${process.env.NEXT_PUBLIC_BUILD_ID}`}</p>
        </div>
      </main>
    </div>
  );
};

export default Home;

export const getServerSideProps: GetServerSideProps<Props> = async () => {
  return {
    props: {
      title: "top page",
    },
  };
};
