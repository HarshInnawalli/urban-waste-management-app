const functions = require("firebase-functions");
const fetch = require("node-fetch");

exports.generateComplaint = functions.https.onRequest(async (req, res) => {
  try {
    const base64Image = req.body.image;

    if (!base64Image) {
      return res.status(400).json({ error: "Image not provided" });
    }

    const response = await fetch(
      "https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash:generateContent?key=YOUR_API_KEY",
      {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          contents: [
            {
              parts: [
                {
                  text:
                    "Write a formal complaint email based on the issue visible in this image. Keep it professional."
                },
                {
                  inline_data: {
                    mime_type: "image/jpeg",
                    data: base64Image
                  }
                }
              ]
            }
          ]
        })
      }
    );

    const data = await response.json();

    // Safe extraction without optional chaining
    let text = "No response";

    if (
      data &&
      data.candidates &&
      data.candidates.length > 0 &&
      data.candidates[0].content &&
      data.candidates[0].content.parts &&
      data.candidates[0].content.parts.length > 0
    ) {
      text = data.candidates[0].content.parts[0].text;
    }

    res.json({ complaint: text });

  } catch (e) {
    console.error(e);
    res.status(500).send(e.toString());
  }
});

