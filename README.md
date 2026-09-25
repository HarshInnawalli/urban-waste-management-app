# EcoTrack 

**Intelligent Waste Monitoring & Citizen Reporting Platform**

> © 2025–2026 Harsh Innawalli. All Rights Reserved.

## Index

1. [Overview](#overview)
2. [Key Features](#key-features)
3. [System Architecture](#system-architecture)
4. [Machine Learning Model](#machine-learning-model)
5. [AI & LLM Pipeline](#ai--llm-pipeline)
6. [Geospatial Ward Detection](#geospatial-ward-detection)
7. [Backend & Database](#backend--database)
8. [Engineering Considerations](#engineering-considerations)
9. [Testing & Evaluation](#testing--evaluation)
10. [Future Work](#future-work)

---

## Overview

EcoTrack is a mobile-based civic-environmental platform designed to encourage responsible waste segregation, help users track household waste, and simplify reporting of waste-management issues to municipal authorities.

The platform combines mobile application development, serverless backend infrastructure, AI/LLM services, geospatial processing, machine learning, and gamification into a unified waste-management system.

<img width="265" height="576" alt="image" src="https://github.com/user-attachments/assets/c8742eb9-574e-4d36-a039-836c98a0d03e" /><img width="265" height="576" alt="image" src="https://github.com/user-attachments/assets/806a3c71-fe98-4be2-b798-4bcda0592e31" /><img width="265" height="576" alt="imagei" src="https://github.com/user-attachments/assets/cfc8da6f-76d6-44e1-a800-a7e3b4f5ecc1" />



<img width="265" height="576" alt="image" src="https://github.com/user-attachments/assets/e31f16b3-4a20-4691-b6f5-3af68795408f" /><img width="265" height="576" alt="image" src="https://github.com/user-attachments/assets/1c9da1b6-87b0-4c82-8599-bdf7b7cbd509" /><img width="265" height="576" alt="image" src="https://github.com/user-attachments/assets/9c650a51-8e22-4df5-b90f-67d184a4f0a0" />

<img width="265" height="576" alt="image" src="https://github.com/user-attachments/assets/1ebfc76b-4ce7-46fe-ade8-ab8d52bf538f" /><img width="265" height="576" alt="image" src="https://github.com/user-attachments/assets/612883ee-3964-4bee-aa41-15e3542f781e" /><img width="265" height="576" alt="image" src="https://github.com/user-attachments/assets/a9ae565d-5ec8-41d8-814a-c66334b681f8" />




## Key Features

**Waste Tracking** — Log waste by category, quantity, and time.
* ♻️ **Segregation Guidance** — Access waste-specific segregation and recycling information.
* 🤖 **AI-Generated Challenges** — Generate personalized waste-reduction challenges based on user waste patterns.
* 📍 **Ward Detection** — Automatically identify the user's municipal ward using GPS coordinates and GeoJSON boundaries using a point-in-polygon algorithm.
* 📸 **Citizen Complaint Reporting** — Capture waste-related issues with image and location information.
* ✉️ **AI-Assisted Complaint Generation** — Convert complaint evidence into structured municipal email reports.
* 🗺️ **E-Waste Centre Discovery** — Find nearby e-waste collection facilities.
* 🏆 **Gamification** — Track points, streaks, badges, and challenge completion.
* 📈 **Waste Analytics** — Visualize waste-generation patterns over different time periods.
* 🔐 **Persistent Authentication** — Maintain user sessions across application launches.
---

## System Architecture

<img width="342" height="309" alt="image" src="https://github.com/user-attachments/assets/a60605ba-36ac-430c-92dd-ae3f0a20acb2" />

The application follows an N-tier architecture that separates responsibilities across the Presentation, Application & Service, and Data layers, improving maintainability, scalability, and modularity.

**Presentation Layer**: Built with Flutter, this layer provides the mobile interface for waste logging, personalized challenges, and complaint submission. It communicates with backend services through structured API calls.

**Application & Service Layer**: Handles application logic and integrates services such as camera and location access and AI-based personalized challenge generation. It coordinates user requests before forwarding data to the backend.

**Data Layer**: Implemented using Cloudflare Workers and Cloudflare D1, this layer manages API requests, validation, and persistent storage of user accounts, waste records, and challenge data.

This layered architecture enables individual components to be modified or extended with minimal impact on the rest of the system.

---

## Machine Learning Model

EcoTrack includes a supervised computer-vision pipeline for automated waste classification, where 3 different pretrained models: mobilenetv3_small, mobilenetv3_large and efficientnetv2_b0 were iteratively selected and fine-tuned to the personally curated waste dataset for a multi-class classification task 
### Model

**EfficientNetV2-B0** was chosen and fine-tuned for a **6-class waste classification task** using a dataset containing **10K+ images** with augmentation.

The three models were benchmarked and improved and achieved:

| Metric                                 |                                    Result |
| ---------------------------------------|-----------------------------------------: |
| Validation accuracy — starting         |                                    73.24% |
| Validation accuracy — final fine-tuned |                                **77.80%** |
| Deployment format                      |                                      ONNX |
| Quantization                           |                                      INT8 |
| Model size                             |                              **6.79 MiB** |
| Inference                              | **Sub-second on low-end Android devices** |

The optimized model enables the classification component to be deployed in resource-constrained mobile environments rather than relying exclusively on cloud inference.

EcoTrack uses the deep learning image classifier to assist users in identifying waste categories from photographs. The model is integrated into the mobile application to provide classification without requiring users to manually identify the material.

The model was evaluated across multiple candidate architectures before selecting the final configuration for mobile deployment. The final model improved validation accuracy from 73.24% to 77.80% while remaining compact enough for on-device inference, as shown in the above table.

**Classification in the App**

<img width="288" height="648" alt="AdobeExpress-WhatsAppVideo2026-09-25at16 51 521-ezgif com-optimize" src="https://github.com/user-attachments/assets/f1661d98-76c4-47d6-ae49-2d7e0a093a3b" />

Example: user captures a waste item → the model processes the image → EcoTrack displays the predicted waste category.

**Model Evaluation**

Validation performance of the trained waste-classification model.

<img width="1901" height="910" alt="image" src="https://github.com/user-attachments/assets/389cb3ee-6e99-4c2e-bf8c-0a11bf9e213a" />

The trained model was converted to INT8 ONNX format, reducing the deployed model to 6.79 MiB and enabling sub-second inference on low-end Android hardware.


The classification component complements the application's broader behavioral system by providing an automated way to identify waste categories.

---

## AI & LLM Pipeline

EcoTrack uses the **Google Gemini API** for AI-assisted functionality.

### Complaint Generation

EcoTrack integrates the Google Gemini API to provide AI-assisted functionality within the mobile application. The LLM is primarily used for civic complaint generation and personalized waste-reduction challenges.

**AI-Assisted Civic Complaint Reporting**

Users can capture an image of a waste-related issue along with their location. EcoTrack processes the location to identify the relevant municipal ward and provides the image, coordinates, and ward information to the Gemini API.

The model generates a structured complaint that can be used to contact the appropriate municipal authority, reducing the effort required to compose and submit a complaint manually.

In case the API experiences a demand spike in a region, delaying the LLM service, there is also a template fallback to ensure a seamless experience with a slight tradeoff for content personalization whilst maintaining sufficient functionality for complaints.

 <img width="288" height="648" alt="ai_email_demo" src="https://github.com/user-attachments/assets/75f2de70-4284-4811-a446-36c61c67bf34" />


### Personalized Waste-Reduction Challenges

EcoTrack also uses waste-log data to identify patterns in a user's waste generation. Based on the most frequently generated waste category, the application generates personalized challenges intended to encourage users to reduce that type of waste.

<img width="288" height="648" alt="challenge_demo" src="https://github.com/user-attachments/assets/b46381fc-5033-4372-8b7c-e4e84c51c6ee" />

**Engineering Considerations**

The LLM integration required handling structured information returned by the model rather than directly displaying raw model output. The application also compresses images before sending them for AI processing to reduce payload size and API usage.

Sensitive API credentials are stored as backend secrets rather than being embedded in the mobile application.

---

## Geospatial Ward Detection

EcoTrack uses **GPS coordinates and GeoJSON municipal ward boundaries** to determine the user's ward.
<img width="783" height="493" alt="image" src="https://github.com/user-attachments/assets/7193d653-fa09-4ba5-a788-e7625dff9a2f" />


A **Ray Casting algorithm** is used for point-in-polygon detection:

```text
GPS Coordinates
      │
      ▼
Ward GeoJSON Polygons
      │
      ▼
Ray Casting
      │
      ▼
Municipal Ward
```

This allows citizen complaints to be associated with the appropriate municipal region.(This feature is currently applicable to users within Mumbai, with plans for expansion)

---

## Backend & Database

### Cloudflare Workers

Cloudflare Workers provide the serverless backend layer and handle:

* Authentication
* Waste-log operations
* API requests
* Challenge generation
* Data retrieval
* Communication with Cloudflare D1

### Cloudflare D1

D1 is used as the relational SQL database.
<img width="1891" height="906" alt="image" src="https://github.com/user-attachments/assets/7dd4e70a-24f3-486d-be0b-259a1d9259f5" />


The relational schema uses foreign-key relationships to maintain data consistency. 

An SQL database was chosen because of the structured nature of the data and Cloudflare D1 was picked due to it's generous free tier for cloud storage of 
data, hence also reducing size of the app that is deployed.

---

## Technology Stack

### Mobile

* Flutter
* Dart
  <img width="108" height="134" alt="image" src="https://github.com/user-attachments/assets/2b9d9fca-63ff-4058-af8f-454bee9ca0a3" /><img width="297" height="93" alt="image" src="https://github.com/user-attachments/assets/23e4775f-4d51-4fae-a007-8fcdcd143536" />



### Backend

* Cloudflare Workers
* Cloudflare D1 (SQL)
<img width="284" height="96" alt="image" src="https://github.com/user-attachments/assets/430b5116-4339-414d-8477-c62874f85d45" />

### AI / Machine Learning

* PyTorch
* EfficientNetV2-B0
* ONNX
* Google Gemini API
  
  <img width="200" height="200" alt="image" src="https://github.com/user-attachments/assets/392733ba-2d71-43a8-9400-0e57fcb1a06c" /><img width="200" height="200" alt="image" src="https://github.com/user-attachments/assets/12ed7237-2295-49f7-8331-cc08eebbec4a" /><img width="289" height="162" alt="image" src="https://github.com/user-attachments/assets/b8c9cba2-cf84-4e54-9b14-1508562a27bd" />

### Geospatial

* GPS
* GeoJSON


### Development

* Git
* GitHub
* Android Studio
* Visual Studio Code
  
<img width="176" height="157" alt="image" src="https://github.com/user-attachments/assets/45a62a64-67e7-468c-9e67-f0ab147f8d70" /><img width="215" height="215" alt="image" src="https://github.com/user-attachments/assets/ff5c0463-274b-4b94-a66a-9c51ea9eada3" /><img width="200" height="200" alt="image" src="https://github.com/user-attachments/assets/1c3cc789-ec73-4887-a08e-37c160b506cb" />

---

## Engineering Considerations

### API Key Security

Sensitive API keys are stored using **Cloudflare Wrangler Secrets** rather than being hardcoded into the mobile application.

### LLM Payload Optimization

Complaint images are compressed before being sent to the LLM pipeline to reduce payload size, latency, and API usage.

### Version Control

Development uses GitHub with feature branches, pull requests, and controlled merges to support collaborative development and maintainability.

---

## Testing & Evaluation

**Testing**
EcoTrack was evaluated through multiple levels of testing:

* Unit testing
* Integration testing
* System testing
* UI/UX testing

Representative workflows tested include:

* Google authentication
* Persistent sessions
* Waste-log creation and retrieval
* Dynamic challenge generation
* GPS-based ward detection
* Image + location complaint submission
* End-to-end module integration

---

**Evaluation**

An initial survey collected responses from **46 participants**, followed by a post-use survey involving **15 users**.

The evaluation examined changes in areas including:

* Awareness of nearby recycling centres
* Knowledge of waste categories/bins
* Waste segregation behaviour
* Household segregation practices

The survey demonstrates a **moderate-to-high increase in awareness** following application usage, demonstrating its habit-forming aspects

---

## Future Work

Potential extensions include:

* Further optimization of mobile ML performance by gathering more data from users
* Complaint resolution tracking
* Integration with private waste-management facilities
* Automated complaint escalation
* Greater personalization of waste-reduction recommendations
* Animated quizzes and unlockables for monetization

