"use client";

import Image from "next/image";
import { useRef, useState, ChangeEvent } from "react";

interface Input {
  visibility: "private" | "public";
  value: string;
}

export default function Home() {
  const fileInputRef = useRef<HTMLInputElement>(null);
  const [selectedFile, setSelectedFile] = useState<File | null>(null);
  const [uploadStatus, setUploadStatus] = useState<string>("");
  const [apiKey, setApiKey] = useState<string>("");
  const [programHash, setProgramHash] = useState<string>("");
  const [inputs, setInputs] = useState<Input[]>([
    { visibility: "private", value: "" },
  ]);
  const [requestStatus, setRequestStatus] = useState<string>("");

  const handleDeployClick = () => {
    if (fileInputRef.current) {
      fileInputRef.current.click();
    }
  };

  const handleFileChange = (event: ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (file) {
      setSelectedFile(file);
      sendHttpRequest(file);
    }
  };

  const sendHttpRequest = async (file: File) => {
    const formData = new FormData();
    formData.append("program", file);

    setUploadStatus("Uploading...");

    try {
      const response = await fetch(
        "http://program-registery.api.herodotus.cloud/upload-program",
        {
          method: "POST",
          body: formData,
        }
      );

      if (response.ok) {
        const result = await response.json();
        console.log("Deploy successful:", result);
        setUploadStatus("Program uploaded successfully!");
      } else {
        console.error("Deploy failed");
        setUploadStatus("Failed to upload program. Please try again.");
      }
    } catch (error) {
      console.error("Error during deploy:", error);
      setUploadStatus("An error occurred while uploading. Please try again.");
    }
  };

  const handleAddInput = () => {
    setInputs([...inputs, { visibility: "private", value: "" }]);
  };

  const handleInputChange = (
    index: number,
    field: "visibility" | "value",
    value: string
  ) => {
    const newInputs = [...inputs];
    if (field === "visibility") {
      newInputs[index].visibility = value as "private" | "public";
    } else {
      newInputs[index].value = value;
    }
    setInputs(newInputs);
  };

  const handleSendRequest = async () => {
    if (!apiKey) {
      setRequestStatus("Please enter an API key.");
      return;
    }

    if (!programHash) {
      setRequestStatus("Please enter a program hash.");
      return;
    }

    setRequestStatus("Sending request...");

    const requestBody = {
      destinationChainId: "11155111",
      tasks: [
        {
          type: "Module",
          programHash: programHash,
          inputs: inputs,
        },
      ],
    };

    try {
      const response = await fetch(
        `https://hdp.api.herodotus.cloud/submit-batch-query?apiKey=${apiKey}`,
        {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify(requestBody),
        }
      );

      if (response.ok) {
        const result = await response.json();
        console.log("Request successful:", result);
        setRequestStatus("Request sent successfully!");
      } else {
        console.error("Request failed");
        setRequestStatus("Failed to send request. Please try again.");
      }
    } catch (error) {
      console.error("Error during request:", error);
      setRequestStatus(
        "An error occurred while sending the request. Please try again."
      );
    }
  };

  return (
    <div
      style={{
        fontFamily: "Arial, sans-serif",
        maxWidth: "800px",
        margin: "0 auto",
        padding: "20px",
      }}>
      <main>
        <h1 style={{ textAlign: "center" }}>HDP (Herodotus Data Processor)</h1>
        <ol>
          <li>
            Enhance zk-offchain compute for verifiable onchain data using zkVMs
          </li>
        </ol>

        <div
          style={{
            display: "flex",
            justifyContent: "center",
            gap: "10px",
            marginBottom: "20px",
          }}>
          <a
            href="https://github.com/HerodotusDev/hdp-module-template"
            target="_blank"
            rel="noopener noreferrer"
            style={{
              padding: "10px 20px",
              backgroundColor: "#0070f3",
              color: "white",
              textDecoration: "none",
              borderRadius: "5px",
            }}>
            <Image
              src="/vercel.svg"
              alt="Vercel logomark"
              width={20}
              height={20}
              style={{ marginRight: "5px" }}
            />
            Start Now
          </a>
          <a
            href="https://docs.herodotus.dev/herodotus-docs/developers/data-processor"
            target="_blank"
            rel="noopener noreferrer"
            style={{
              padding: "10px 20px",
              backgroundColor: "#f0f0f0",
              color: "#333",
              textDecoration: "none",
              borderRadius: "5px",
            }}>
            Read Docs
          </a>
        </div>

        <div style={{ marginBottom: "20px" }}>
          <h2>Quick Start</h2>
          <div style={{ display: "flex", gap: "10px", marginBottom: "10px" }}>
            <button
              style={{
                padding: "10px 20px",
                backgroundColor: "#0070f3",
                color: "white",
                border: "none",
                borderRadius: "5px",
                cursor: "pointer",
              }}
              onClick={handleDeployClick}>
              Deploy Program
            </button>
            <input
              type="file"
              ref={fileInputRef}
              style={{ display: "none" }}
              onChange={handleFileChange}
              accept=".json"
            />
            <button
              style={{
                padding: "10px 20px",
                backgroundColor: "#0070f3",
                color: "white",
                border: "none",
                borderRadius: "5px",
                cursor: "pointer",
              }}
              onClick={handleSendRequest}>
              Send Request
            </button>
            <button
              style={{
                padding: "10px 20px",
                backgroundColor: "#0070f3",
                color: "white",
                border: "none",
                borderRadius: "5px",
                cursor: "pointer",
              }}>
              Get Status
            </button>
            <button
              style={{
                padding: "10px 20px",
                backgroundColor: "#0070f3",
                color: "white",
                border: "none",
                borderRadius: "5px",
                cursor: "pointer",
              }}>
              Get Value
            </button>
          </div>
          <div style={{ marginBottom: "10px" }}>
            <input
              type="text"
              placeholder="Enter API Key"
              value={apiKey}
              onChange={(e) => setApiKey(e.target.value)}
              style={{ width: "100%", padding: "10px", marginBottom: "10px" }}
            />
            <input
              type="text"
              placeholder="Enter Program Hash"
              value={programHash}
              onChange={(e) => setProgramHash(e.target.value)}
              style={{ width: "100%", padding: "10px" }}
            />
          </div>
          <div>
            {inputs.map((input, index) => (
              <div
                key={index}
                style={{ display: "flex", gap: "10px", marginBottom: "10px" }}>
                <select
                  value={input.visibility}
                  onChange={(e) =>
                    handleInputChange(index, "visibility", e.target.value)
                  }
                  style={{ padding: "10px" }}>
                  <option value="private">Private</option>
                  <option value="public">Public</option>
                </select>
                <input
                  type="text"
                  placeholder="Input Value"
                  value={input.value}
                  onChange={(e) =>
                    handleInputChange(index, "value", e.target.value)
                  }
                  style={{ flex: 1, padding: "10px" }}
                />
              </div>
            ))}
            <button
              onClick={handleAddInput}
              style={{
                padding: "10px 20px",
                backgroundColor: "#f0f0f0",
                color: "#333",
                border: "none",
                borderRadius: "5px",
                cursor: "pointer",
              }}>
              Add Input
            </button>
          </div>
          {selectedFile && <p>Selected file: {selectedFile.name}</p>}
          {uploadStatus && <p>{uploadStatus}</p>}
          {requestStatus && <p>{requestStatus}</p>}
        </div>
      </main>
      <footer style={{ textAlign: "center", marginTop: "20px" }}>
        <a
          href="https://nextjs.org/learn?utm_source=create-next-app&utm_medium=appdir-template&utm_campaign=create-next-app"
          target="_blank"
          rel="noopener noreferrer"
          style={{ marginRight: "10px" }}>
          <Image src="/file.svg" alt="File icon" width={16} height={16} />
          Learn
        </a>
        <a
          href="https://vercel.com/templates?framework=next.js&utm_source=create-next-app&utm_medium=appdir-template&utm_campaign=create-next-app"
          target="_blank"
          rel="noopener noreferrer"
          style={{ marginRight: "10px" }}>
          <Image src="/window.svg" alt="Window icon" width={16} height={16} />
          Examples
        </a>
        <a
          href="https://nextjs.org?utm_source=create-next-app&utm_medium=appdir-template&utm_campaign=create-next-app"
          target="_blank"
          rel="noopener noreferrer">
          <Image src="/globe.svg" alt="Globe icon" width={16} height={16} />
          Go to nextjs.org →
        </a>
      </footer>
    </div>
  );
}
