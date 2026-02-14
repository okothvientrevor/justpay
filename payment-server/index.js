const express = require("express");
const cors = require("cors");
const fetch = require("node-fetch");

const app = express();
app.use(cors());
app.use(express.json());

// ── Relworx credentials (keep secret on the server) ──
const RELWORX_BASE_URL = "https://payments.relworx.com/api/mobile-money";
const ACCOUNT_NO = "RELC8C526ADB6";
const API_TOKEN = "4d1aeb1f378199.fqOLe7HjEfHzJG_V9i8vtg";
const SENDER_MSISDN = "+256776000651";

const relworxHeaders = {
  "Content-Type": "application/json",
  Accept: "application/vnd.relworx.v2",
  Authorization: `Bearer ${API_TOKEN}`,
};

// ── Health check ──
app.get("/", (_req, res) => {
  res.json({ status: "ok", service: "justpay-payment-proxy" });
});

// ── POST /requestPayment ──
app.post("/requestPayment", async (req, res) => {
  try {
    const { amount, description, reference } = req.body;

    if (!amount || !reference) {
      return res.status(400).json({
        success: false,
        message: "Missing required fields: amount, reference",
      });
    }

    const payload = {
      account_no: ACCOUNT_NO,
      reference: reference,
      msisdn: SENDER_MSISDN,
      currency: "UGX",
      amount: parseFloat(amount),
      description: description || "Payment Request.",
    };

    console.log("Requesting payment:", JSON.stringify(payload));

    const response = await fetch(`${RELWORX_BASE_URL}/request-payment`, {
      method: "POST",
      headers: relworxHeaders,
      body: JSON.stringify(payload),
    });

    const data = await response.json();
    console.log("Relworx response:", response.status, JSON.stringify(data));

    return res.status(response.status).json(data);
  } catch (error) {
    console.error("Error requesting payment:", error);
    return res.status(500).json({
      success: false,
      message: `Server error: ${error.message}`,
    });
  }
});

// ── GET /checkPaymentStatus?internal_reference=xxx ──
app.get("/checkPaymentStatus", async (req, res) => {
  try {
    const internalReference = req.query.internal_reference;

    if (!internalReference) {
      return res.status(400).json({
        success: false,
        message: "Missing required query parameter: internal_reference",
      });
    }

    const url = `${RELWORX_BASE_URL}/check-request-status?internal_reference=${encodeURIComponent(internalReference)}&account_no=${ACCOUNT_NO}`;

    console.log("Checking payment status:", url);

    const response = await fetch(url, {
      method: "GET",
      headers: relworxHeaders,
    });

    const data = await response.json();
    console.log("Relworx status response:", response.status, JSON.stringify(data));

    return res.status(response.status).json(data);
  } catch (error) {
    console.error("Error checking payment status:", error);
    return res.status(500).json({
      success: false,
      message: `Server error: ${error.message}`,
    });
  }
});

// ── POST /sendPayment ──
app.post("/sendPayment", async (req, res) => {
  try {
    const { msisdn, amount, description, reference } = req.body;

    if (!msisdn || !amount || !reference) {
      return res.status(400).json({
        success: false,
        message: "Missing required fields: msisdn, amount, reference",
      });
    }

    const payload = {
      account_no: ACCOUNT_NO,
      reference: reference,
      msisdn: msisdn,
      currency: "UGX",
      amount: parseFloat(amount),
      description: description || "Send Payment.",
    };

    console.log("Sending payment:", JSON.stringify(payload));

    const response = await fetch(`${RELWORX_BASE_URL}/send-payment`, {
      method: "POST",
      headers: relworxHeaders,
      body: JSON.stringify(payload),
    });

    const data = await response.json();
    console.log("Relworx send response:", response.status, JSON.stringify(data));

    return res.status(response.status).json(data);
  } catch (error) {
    console.error("Error sending payment:", error);
    return res.status(500).json({
      success: false,
      message: `Server error: ${error.message}`,
    });
  }
});

// ── Start server ──
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Payment proxy server running on port ${PORT}`);
});
