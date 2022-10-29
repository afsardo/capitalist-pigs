import dynamic from "next/dynamic";
import React from "react";

const Test = dynamic(() => import("../components/Test"), {
  ssr: false,
});

const TestPage = () => {
  return (
    <>
      <p>Test Paragraph</p>
      <Test />
    </>
  );
};

export default TestPage;
